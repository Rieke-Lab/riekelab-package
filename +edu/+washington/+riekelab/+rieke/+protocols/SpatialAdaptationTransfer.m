classdef SpatialAdaptationTransfer < edu.washington.riekelab.protocols.RiekeLabStageProtocol

    properties
        preTime = 500 % ms
        stimTime = 1000 % ms
        tailTime = 1000 % ms
        flashDuration = 50; % ms
        fixedFlashTime = 100; % ms
        variableFlashTime = [50 100 200 400]; % ms
        testContrast = 0.75 % relative to mean (0-1)
        stepContrast = 0.5 % relative to mean (0-1)
        apertureDiameter = 300; % um
        barWidth = [10 20 40 80 120] % um
        backgroundIntensity = 0.05 % (0-1)
        amp
        zeroMeanStep = false;           % mean of adapting grating
        psth = false;                   % Toggle psth in mean response figure
    end

    properties
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 0          % Duration between pulses (s)
    end
 
    properties (Hidden)
        ampType
        barWidthSequence
        currentBarWidth
        currentFlashDelay
        rotation = 0
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
            obj.showFigure('edu.washington.riekelab.figures.MeanResponseFigure',...
                obj.rig.getDevice(obj.amp),'groupBy',{'stimulusIndex'},'psth',obj.psth,'sweepColor',colors);
            obj.showFigure('edu.washington.riekelab.turner.figures.FrameTimingFigure',...
                obj.rig.getDevice('Stage'), obj.rig.getDevice('Frame Monitor'));
            % Create bar width sequence.
            obj.barWidthSequence = obj.barWidth;
        end

        function p = createPresentation(obj)
            canvasSize = obj.rig.getDevice('Stage').getCanvasSize();
            
            %convert from microns to pixels...
            apertureDiameterPix = obj.rig.getDevice('Stage').um2pix(obj.apertureDiameter);
            currentBarWidthPix = obj.rig.getDevice('Stage').um2pix(obj.currentBarWidth);
            
            p = stage.core.Presentation((obj.preTime + obj.stimTime + obj.tailTime) * 1e-3); %create presentation of specified duration
            p.setBackgroundColor(obj.backgroundIntensity); % Set background intensity
                      
    	    index = mod(obj.numEpochsCompleted, 1 + 2*length(obj.variableFlashTime)) + 1;
 
            % add background
            background = stage.builtin.stimuli.Grating('square'); %square wave grating
            background.orientation = obj.rotation;
            background.size = [apertureDiameterPix, apertureDiameterPix];
            background.position = canvasSize/2;
            background.spatialFreq = 1/(2*currentBarWidthPix); %convert from bar width to spatial freq
            background.phase = 0;
            background.opacity = 0.5;
            p.addStimulus(background);
            backgroundMean = stage.builtin.controllers.PropertyController(background, 'color',...
                       @(state)getBackgroundMean(obj, state.time));
                p.addController(backgroundMean); %add the controller

            backgroundContrast = stage.builtin.controllers.PropertyController(background, 'contrast',...
                        @(state)getBackgroundContrast(obj, state.time));
                p.addController(backgroundContrast); %add the controller
    
            
            % Create bar stimulus.
            if (index > 1)
                grate = stage.builtin.stimuli.Grating('square'); %square wave grating
                grate.orientation = obj.rotation;
                grate.size = [apertureDiameterPix, apertureDiameterPix];
                grate.position = canvasSize/2;
                grate.spatialFreq = 1/(2*currentBarWidthPix); %convert from bar width to spatial freq
                grate.opacity = 0.5;
                if (mod(index, 2))
                    grate.phase = 0; %keep contrast reversing boundary in center
                else
                    grate.phase = 180;
                end
                p.addStimulus(grate);
                
                grateMean = stage.builtin.controllers.PropertyController(grate, 'color',...
                           @(state)getGrateMean(obj, state.time));
                    p.addController(grateMean); %add the controller

                grateContrast = stage.builtin.controllers.PropertyController(grate, 'contrast',...
                            @(state)getGrateContrast(obj, state.time));
                    p.addController(grateContrast); %add the controller
             end

             if  (obj.apertureDiameter > 0) % Create aperture
                aperture = stage.builtin.stimuli.Rectangle();
                aperture.position = canvasSize/2;
                aperture.size = [apertureDiameterPix, apertureDiameterPix];
                mask = stage.core.Mask.createCircularAperture(1, 1024); %circular aperture
                aperture.setMask(mask);
                p.addStimulus(aperture); %add aperture
                aperture.color = obj.backgroundIntensity;
             end
             
            % set mean of test spot
            function m = getGrateMean(obj, time)
                m = 2*obj.backgroundIntensity; % 2 because opacity = 0.5
                flashTime = [obj.fixedFlashTime obj.preTime+obj.currentFlashDelay ...
                    obj.preTime+obj.stimTime-obj.fixedFlashTime obj.preTime+obj.stimTime+obj.currentFlashDelay ...
                    obj.preTime+obj.stimTime+obj.tailTime-obj.fixedFlashTime];
                for flash = 1:length(flashTime)
                    if (time > flashTime(flash)/1e3 & time < (flashTime(flash)/1e3 + obj.flashDuration/1e3))
                        if (obj.testContrast > 0)
                            m = obj.backgroundIntensity * (2/(1-obj.testContrast));
                        else
                            m = obj.backgroundIntensity * (2/(1+abs(obj.testContrast)));
                        end
                    end
                end
                if ((m*(1+obj.testContrast) + obj.backgroundIntensity * (2/(1-obj.stepContrast))) > 2)
                    fprintf(1, 'gamma error\n');
                end
            end
            
            function c = getGrateContrast(obj, time)
                c = 0;
                flashTime = [obj.fixedFlashTime obj.preTime+obj.currentFlashDelay ...
                    obj.preTime+obj.stimTime-obj.fixedFlashTime obj.preTime+obj.stimTime+obj.currentFlashDelay ...
                    obj.preTime+obj.stimTime+obj.tailTime-obj.fixedFlashTime];
                for flash = 1:length(flashTime)
                    if (time > flashTime(flash)/1e3 & time < (flashTime(flash)/1e3 + obj.flashDuration/1e3))
                        c = obj.testContrast;
                    end
                end
            end
            
            % set mean of background spot
            function m = getBackgroundMean(obj, time)
                m = 2*obj.backgroundIntensity; % 2 because opacity = 0.5
                if (~obj.zeroMeanStep)
                    if (time > obj.preTime/1e3 & time < (obj.preTime/1e3 + obj.stimTime/1e3))
                        if (obj.stepContrast > 0)
                            m = obj.backgroundIntensity * (2/(1-obj.stepContrast));
                        else
                            m = obj.backgroundIntensity * (2/(1+abs(obj.stepContrast)));
                        end
                    end
                end
            end
            
            function c = getBackgroundContrast(obj, time)
                if (time > obj.preTime/1e3 & time < (obj.preTime/1e3 + obj.stimTime/1e3))
                    c = obj.stepContrast;
                else
                    c = 0;
                end
            end
         
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@edu.washington.riekelab.protocols.RiekeLabStageProtocol(obj, epoch);
            
            device = obj.rig.getDevice(obj.amp);
            duration = (obj.preTime + obj.stimTime + obj.tailTime) / 1e3;
            epoch.addDirectCurrentStimulus(device, device.background, duration, obj.sampleRate);
            epoch.addResponse(device);
            
    	    index = mod(obj.numEpochsCompleted, 1 + 2*length(obj.variableFlashTime)) + 1;
            flashIndex = ceil((index - 1)/2);
            if (flashIndex < 1)
                flashIndex = 1;
            end
            obj.currentFlashDelay = obj.variableFlashTime(flashIndex);
            epoch.addParameter('currentFlashDelay', obj.currentFlashDelay);

            index = floor(obj.numEpochsCompleted / (1 + 2 * length(obj.variableFlashTime)));
            index = mod(index, length(obj.barWidthSequence))+1;
            obj.currentBarWidth = obj.barWidthSequence(index);
            epoch.addParameter('currentBarWidth', obj.currentBarWidth);

            index = (index-1)*(1 + 2 * length(obj.variableFlashTime)) + mod(obj.numEpochsCompleted, 1 + 2*length(obj.variableFlashTime)) + 1;
            epoch.addParameter('stimulusIndex', index);
            index
            
        end
 
        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = shouldContinueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
        
    end
    
end