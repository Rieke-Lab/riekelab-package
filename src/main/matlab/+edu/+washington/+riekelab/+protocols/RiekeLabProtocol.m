classdef (Abstract) RiekeLabProtocol < symphonyui.core.Protocol
    
    properties (Hidden, SetAccess = private)
        meaFileName
        isMeaRig
    end
    
    methods
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            controllers = obj.rig.getDevices('Temperature Controller');
            if ~isempty(controllers)
                epoch.addResponse(controllers{1});
            end
            
            % This is for the MEA setup. Check if this is an MEA rig on the
            % first epoch.
            if obj.numEpochsCompleted == 0
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
                catch ME
                    disp(ME.message);
                end
            end
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
    
end

