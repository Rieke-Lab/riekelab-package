classdef (Abstract) RiekeLabProtocol < symphonyui.core.Protocol
    
    properties (Hidden, SetAccess = private)
        meaFileName
        isMeaRig
        startedRun
    end
    
    methods
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);

            obj.startedRun = false;

            % Determine MEA status up front. Subclasses query
            % obj.isMeaRig inside their own prepareRun (before the
            % first prepareEpoch runs), so it must be a valid logical
            % here rather than [] — otherwise `if ~obj.isMeaRig`
            % evaluates as false on the first run and figure setup is
            % silently skipped until a rerun.
            obj.isMeaRig = ~isempty(obj.rig.getDevices('MEA'));
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            % Save the protocol source code to the EpochBlock.
            obj.saveProtocolSource();
            
            controllers = obj.rig.getDevices('Temperature Controller');
            if ~isempty(controllers)
                epoch.addResponse(controllers{1});
            end
            
            wvfrm = obj.rig.getDevices('Waveform Generator');
            if ~isempty(wvfrm)
                epoch.addResponse(wvfrm{1});
            end
            
%             optometer = obj.rig.getDevices('Optometer');
%             if ~isempty(optometer)
%                 epoch.addResponse(optometer{1});
%             end
            
            % This is for the MEA setup. Check if this is an MEA rig on the
            % first epoch.
            if ~obj.startedRun
                obj.startedRun = true;
                obj.isMeaRig = false; % Default
                obj.meaFileName = ''; % Default
                
                % Check if this is an MEA rig.
                mea = obj.rig.getDevices('MEA');
                if ~isempty(mea)
                    obj.isMeaRig = true;
                    
                    mea = mea{1};
                    % Try to pull the output file name from the server.
%                     fname = mea.getFileName(30);
                    
                    % New tests:
                    mea.start();
                    fname = char(mea.fileName);
                    
                    if ~isempty(fname)
                        obj.meaFileName = char(fname);
                    else
                        obj.meaFileName = '';
                    end
                    
                    % Persist the file name
                    if ~isempty(fname) && ~isempty(obj.persistor)
                        try
                            eb = obj.persistor.currentEpochBlock;
                            if ~isempty(eb)
                                eb.setProperty('dataFileName', char(fname))
                            end
                        catch
                        end
                    end
                end
            end
            
            % Persist the file name to the epoch if it's an MEA rig.
            if obj.isMeaRig
                try
                    epoch.addParameter('dataFileName', obj.meaFileName);
                    
                    % Create the external trigger to the MEA DAQ.
                    triggers = obj.rig.getDevices('ExternalTrigger');
                    if ~isempty(triggers)
                        epoch.addStimulus(triggers{1}, obj.createTriggerStimulus(triggers{1}));
                    end
                catch ME
                    disp(ME.message);
                end
            end
        end
        
        function stim = createTriggerStimulus(obj, trigger_device)
            gen = symphonyui.builtin.stimuli.PulseGenerator();
            
            if strcmp(trigger_device.background.displayUnits,'V') 
                amplitude = 5;
                units = 'V';
            else
                amplitude = 1;
                units = symphonyui.core.Measurement.UNITLESS;
            end
            
            % Ensure that pre/stim/tail time are defined.
            if isprop(obj, 'preTime')
                preT = obj.preTime;
            else
                preT = 50;
            end
            
            if isprop(obj, 'tailTime')
                tailT = obj.tailTime;
            else
                tailT = 50;
            end
            
            if isprop(obj, 'stimTime')
                stimT = obj.stimTime;
            else
                stimT = 0;
            end
            total_time = max(100, preT + stimT + tailT);
            
            gen.preTime = 0;
            gen.stimTime = total_time - 1;
            gen.tailTime = 1;
            gen.amplitude = amplitude;
            gen.mean = 0;
            gen.sampleRate = obj.sampleRate;
            gen.units = units; %symphonyui.core.Measurement.UNITLESS;
            
            stim = gen.generate();
        end
        
        function completeEpoch(obj, epoch)
            completeEpoch@symphonyui.core.Protocol(obj, epoch);
            
            controllers = obj.rig.getDevices('Temperature Controller');
            if ~isempty(controllers) && epoch.hasResponse(controllers{1})
                response = epoch.getResponse(controllers{1});
                [quantities, units] = response.getData();
                if ~strcmp(units, 'V')
                    error('Temperature Controller must be in volts');
                end
                
                % Temperature readout from Warner TC-324B controller 100 mV/degree C.
                temperature = mean(quantities) * 1000 * (1/100);
                temperature = round(temperature * 10) / 10;
                epoch.addProperty('bathTemperature', temperature);
                
                epoch.removeResponse(controllers{1});
            end
        end
        
    end
    
    methods (Access = private)
        function saveProtocolSource(obj)
            % Snapshot the running protocol's .m source into the current epoch
            % block as a raw UTF-8 resource ('public.plain-text' / 'protocolSource').
            % Read back in MATLAB via:
            %   native2unicode(uint8(block.cobj.GetResource('protocolSource').Data), 'UTF-8')
            % (block.getResource() will NOT work -- it assumes MATLAB byte-stream data.)
            if isempty(obj.persistor) || isempty(obj.persistor.currentEpochBlock)
                return
            end
            block = obj.persistor.currentEpochBlock;
            try
                if any(strcmp(block.getResourceNames(), 'protocolSource'))
                    return  % already saved for this block (covers pause/resume)
                end
                srcPath = which(class(obj));
                if isempty(srcPath)
                    error('Could not resolve source file for %s', class(obj));
                end
                fid = fopen(srcPath, 'r');
                if fid == -1
                    error('Could not open %s', srcPath);
                end
                closer = onCleanup(@() fclose(fid));
                bytes = fread(fid, Inf, '*uint8')';
                block.cobj.AddResource('public.plain-text', 'protocolSource', bytes);
            catch ME
                warning('riekeLab:protocolSnapshot', ...
                    'Could not save protocol source.\n Error: %s', ME.message);
            end
        end
    end
    
end

