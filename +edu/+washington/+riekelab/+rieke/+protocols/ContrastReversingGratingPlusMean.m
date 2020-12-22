classdef ContrastReversingGratingPlusMean < edu.washington.riekelab.protocols.RiekeLabStageProtocol

    properties
        preTime = 500 % ms
        stimTime = 1000 % ms
        tailTime = 1000 % ms
        contrast = 0.9 % relative to mean (0-1)
        temporalFrequency = 6 % Hz
        apertureDiameter = 200; % um
        backgroundDiameter = 600
        maskDiameter = 0; % um
        barWidth = [1 2 100] % um
        rotation = 0; % deg
        backgroundIntensity = 0.05 % (0-1)
        stepIntensity = 0.5
        onlineAnalysis = 'none'
        numberOfAverages = uint16(20) % number of epochs to queue
        amp
    end
    
    properties (Hidden)
        ampType
        onlineAnalysisType = symphonyui.core.PropertyType('char', 'row', {'none', 'extracellular', 'exc', 'inh'})
        barWidthSequence
        currentBarWidth
    end
       
    properties (Hidden, Transient)
        analysisFigure
    end

    methods

        function didSetRig(obj)
            didSetRig@edu.washington.riekelab.protocols.RiekeLabStageProtocol(obj);
            [obj.amp, obj.ampType] = obj.createDeviceNamesProperty('Amp');
        end
        
        function prepareRun(obj)
            prepareRun@edu.washington.riekelab.protocols.RiekeLabStageProtocol(obj);
            if length(obj.barWidth) > 1
                colors = edu.washington.riekelab.turner.utils.pmkmp(length(obj.barWidth)+2,'CubicYF');
            else
                colors = [0 0 0];
            end
            obj.showFigure('symphonyui.builtin.figures.ResponseFigure', obj.rig.getDevice(obj.amp));
            obj.showFigure('edu.washington.riekelab.turner.figures.MeanResponseFigure',...
                obj.rig.getDevice(obj.amp),'recordingType',obj.onlineAnalysis,...
                'groupBy',{'currentBarWidth'},...
                'sweepColor',colors);
            obj.showFigure('edu.washington.riekelab.turner.figures.FrameTimingFigure',...
                obj.rig.getDevice('Stage'), obj.rig.getDevice('Frame Monitor'));
            if ~strcmp(obj.onlineAnalysis,'none')
                % custom figure handler
                if isempty(obj.analysisFigure) || ~isvalid(obj.analysisFigure)
                    obj.analysisFigure = obj.showFigure('symphonyui.builtin.figures.CustomFigure', @obj.CRGanalysis);
                    f = obj.analysisFigure.getFigureHandle();
                    set(f, 'Name', 'CRGs');
                    obj.analysisFigure.userData.trialCounts = zeros(size(obj.barWidth));
                    obj.analysisFigure.userData.F1 = zeros(size(obj.barWidth));
                    obj.analysisFigure.userData.F2 = zeros(size(obj.barWidth));
                    obj.analysisFigure.userData.axesHandle = axes('Parent', f);
                else
                    obj.analysisFigure.userData.trialCounts = zeros(size(obj.barWidth));
                    obj.analysisFigure.userData.F1 = zeros(size(obj.barWidth));
                    obj.analysisFigure.userData.F2 = zeros(size(obj.barWidth));
                end
                
            end
            % Create bar width sequence.
            obj.barWidthSequence = obj.barWidth;
        end
        
        function CRGanalysis(obj, ~, epoch) %online analysis function
            response = epoch.getResponse(obj.rig.getDevice(obj.amp));
            epochResponseTrace = response.getData();
            sampleRate = response.sampleRate.quantityInBaseUnits;
            
            axesHandle = obj.analysisFigure.userData.axesHandle;
            trialCounts = obj.analysisFigure.userData.trialCounts;
            F1 = obj.analysisFigure.userData.F1;
            F2 = obj.analysisFigure.userData.F2;
            
            if strcmp(obj.onlineAnalysis,'extracellular') %spike recording
                %take (prePts+1:prePts+stimPts)
                epochResponseTrace = epochResponseTrace((sampleRate*obj.preTime/1000)+1:(sampleRate*(obj.preTime + obj.stimTime)/1000));
                %count spikes
                S = edu.washington.riekelab.turner.utils.spikeDetectorOnline(epochResponseTrace);
                epochResponseTrace = zeros(size(epochResponseTrace));
                epochResponseTrace(S.sp) = 1; %spike binary
                
            else %intracellular - Vclamp
                epochResponseTrace = epochResponseTrace-mean(epochResponseTrace(1:sampleRate*obj.preTime/1000)); %baseline
                %take (prePts+1:prePts+stimPts)
                epochResponseTrace = epochResponseTrace((sampleRate*obj.preTime/1000)+1:(sampleRate*(obj.preTime + obj.stimTime)/1000));
            end

            L = length(epochResponseTrace); %length of signal, datapoints
            X = abs(fft(epochResponseTrace));
            X = X(1:L/2);
            f = sampleRate*(0:L/2-1)/L; %freq - hz
            [~, F1ind] = min(abs(f-obj.temporalFrequency)); %find index of F1 and F2 frequencies
            [~, F2ind] = min(abs(f-2*obj.temporalFrequency));

            F1power = 2*X(F1ind); %pA^2/Hz for current rec, (spikes/sec)^2/Hz for spike rate
            F2power = 2*X(F2ind); %double b/c of symmetry about zero
            
            barInd = find(obj.currentBarWidth == obj.barWidth);
            trialCounts(barInd) = trialCounts(barInd) + 1;
            F1(barInd) = F1(barInd) + F1power;
            F2(barInd) = F2(barInd) + F2power;
            
            cla(axesHandle);
            h1 = line(obj.barWidth, F1./trialCounts, 'Parent', axesHandle);
            set(h1,'Color','g','LineWidth',2,'Marker','o');
            h2 = line(obj.barWidth, F2./trialCounts, 'Parent', axesHandle);
            set(h2,'Color','r','LineWidth',2,'Marker','o');
            hl = legend(axesHandle,{'F1','F2'});
            xlabel(axesHandle,'Bar width (um)')
            ylabel(axesHandle,'Amplitude')

            obj.analysisFigure.userData.trialCounts = trialCounts;
            obj.analysisFigure.userData.F1 = F1;
            obj.analysisFigure.userData.F2 = F2;
        end

        function p = createPresentation(obj)
            canvasSize = obj.rig.getDevice('Stage').getCanvasSize();
            
            %convert from microns to pixels...
            apertureDiameterPix = obj.rig.getDevice('Stage').um2pix(obj.apertureDiameter);
            maskDiameterPix = obj.rig.getDevice('Stage').um2pix(obj.maskDiameter);
            currentBarWidthPix = obj.rig.getDevice('Stage').um2pix(obj.currentBarWidth);
            
            p = stage.core.Presentation((obj.preTime + obj.stimTime + obj.tailTime) * 1e-3); %create presentation of specified duration
            p.setBackgroundColor(obj.backgroundIntensity); % Set background intensity
          
            % step background spot for specified time 
            spotDiameterPix = obj.rig.getDevice('Stage').um2pix(obj.backgroundDiameter);            
            background = stage.builtin.stimuli.Ellipse();
            background.radiusX = spotDiameterPix/2;
            background.radiusY = spotDiameterPix/2;
            background.position = canvasSize/2;
            p.addStimulus(background);            
            backgroundMean = stage.builtin.controllers.PropertyController(background, 'color',...
                @(state)getBackgroundMean(obj, state.time));
            p.addController(backgroundMean); %add the controller

    	    index = mod(obj.numEpochsCompleted, length(obj.barWidthSequence)) + 1;
            if (index ~= 2) % grating
                % Create grating stimulus.
                grate = stage.builtin.stimuli.Grating('square'); %square wave grating
                grate.orientation = obj.rotation;
                grate.size = [apertureDiameterPix, apertureDiameterPix];
                grate.position = canvasSize/2;
                grate.spatialFreq = 1/(2*currentBarWidthPix); %convert from bar width to spatial freq
                grate.color = 2*obj.backgroundIntensity;
                %calc to apply phase shift s.t. a contrast-reversing boundary
                %is in the center regardless of spatial frequency. Arbitrarily
                %say boundary should be positve to right and negative to left
                %crosses x axis from neg to pos every period from 0
                zeroCrossings = 0:(grate.spatialFreq^-1):grate.size(1);
                offsets = zeroCrossings-grate.size(1)/2; %difference between each zero crossing and center of texture, pixels
                [shiftPix, ~] = min(offsets(offsets>0)); %positive shift in pixels
                phaseShift_rad = (shiftPix/(grate.spatialFreq^-1))*(2*pi); %phaseshift in radians
                phaseShift = 360*(phaseShift_rad)/(2*pi); %phaseshift in degrees
                grate.phase = phaseShift; %keep contrast reversing boundary in center
                
                p.addStimulus(grate);
                
                %make it contrast-reversing
                if (obj.temporalFrequency > 0)
                    grateContrast = stage.builtin.controllers.PropertyController(grate, 'contrast',...
                        @(state)getGrateContrast(obj, index, state.time));
                    p.addController(grateContrast); %add the controller
                end
                %step mean
                grateMean = stage.builtin.controllers.PropertyController(grate, 'color',...
                    @(state)getGrateMean(obj, state.time));
                p.addController(grateMean); %add the controller

                % make sure turns off at end
                grateVisible = stage.builtin.controllers.PropertyController(grate, 'visible', ...
                    @(state)state.time < (obj.preTime + obj.stimTime + obj.tailTime - 50) * 1e-3);
                p.addController(grateVisible);

            end
                        
            % modulated spot
            if (index == 2)
                spotDiameterPix = obj.rig.getDevice('Stage').um2pix(obj.apertureDiameter);              
                spot = stage.builtin.stimuli.Ellipse();
                spot.radiusX = spotDiameterPix/2;
                spot.radiusY = spotDiameterPix/2;
                spot.position = canvasSize/2;
                p.addStimulus(spot);
                spotMean = stage.builtin.controllers.PropertyController(spot, 'color',...
                    @(state)getSpotMean(obj, state.time));
                p.addController(spotMean); %add the controller
                
                % make sure turns off at end
                spotVisible = stage.builtin.controllers.PropertyController(spot, 'visible', ...
                    @(state)state.time < (obj.preTime + obj.stimTime + obj.tailTime - 50) * 1e-3);
                p.addController(spotVisible);
                               
            end
            
            % aperture for grating
            if  (obj.apertureDiameter > 0) % Create aperture
                aperture = stage.builtin.stimuli.Rectangle();
                aperture.position = canvasSize/2;
                aperture.size = [apertureDiameterPix, apertureDiameterPix];
                mask = stage.core.Mask.createCircularAperture(1, 1024); %circular aperture
                aperture.setMask(mask);
                p.addStimulus(aperture); %add aperture
                apertureMean = stage.builtin.controllers.PropertyController(aperture, 'color',...
                    @(state)getBackgroundMean(obj, state.time));
                p.addController(apertureMean); %add the controller
            end
            
            % central mask - follows mean of background but not modulated
            if (obj.maskDiameter > 0) % Create mask
                mask = stage.builtin.stimuli.Ellipse();
                mask.position = canvasSize/2;
                mask.radiusX = maskDiameterPix/2;
                mask.radiusY = maskDiameterPix/2;
                p.addStimulus(mask); %add mask
                maskMean = stage.builtin.controllers.PropertyController(mask, 'color',...
                    @(state)getBackgroundMean(obj, state.time));
                p.addController(maskMean); %add the controller
            end
            
            % grating contrast - 0 for first epoch of block when just mean
            % stepped
            function c = getGrateContrast(obj, index, time)
                if (index > 1)
                    c = obj.contrast.*sin(2 * pi * obj.temporalFrequency * time);
                else
                    c = 0;
                end
            end

            % grating mean
            function m = getGrateMean(obj, time)
                m = obj.backgroundIntensity*2;
                if (time > obj.preTime/1e3 & time < (obj.preTime/1e3 + obj.stimTime/1e3))
                    m = obj.stepIntensity*2;
                end
            end
            
            % set mean of center (modulated) spot
            function m = getSpotMean(obj, time)
                m = obj.backgroundIntensity;
                if (time > obj.preTime/1e3 & time < (obj.preTime/1e3 + obj.stimTime/1e3))
                    m = obj.stepIntensity;
                end
                m = m*obj.contrast.*(1+sin(2 * pi * obj.temporalFrequency * time)/2);
            end
            
            % mean of background spot
            function m = getBackgroundMean(obj, time)
                m = obj.backgroundIntensity;
                if (time > obj.preTime/1e3 & time < (obj.preTime/1e3 + obj.stimTime/1e3))
                    m = obj.stepIntensity;
                end
            end
            
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@edu.washington.riekelab.protocols.RiekeLabStageProtocol(obj, epoch);
            
            device = obj.rig.getDevice(obj.amp);
            duration = (obj.preTime + obj.stimTime + obj.tailTime) / 1e3;
            epoch.addDirectCurrentStimulus(device, device.background, duration, obj.sampleRate);
            epoch.addResponse(device);
            
            index = mod(obj.numEpochsCompleted, length(obj.barWidthSequence)) + 1;
            obj.currentBarWidth = obj.barWidthSequence(index);
            % bar greater than 1/2 aperture size -> just split field grating.
            % Allows grating texture to be the size of the aperture and the
            % resulting stimulus is the same...
            if (obj.currentBarWidth > obj.apertureDiameter/2);
                obj.currentBarWidth = obj.apertureDiameter/2;
            end
            epoch.addParameter('currentBarWidth', obj.currentBarWidth);
        end
 
        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = shouldContinueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
        
    end
    
end