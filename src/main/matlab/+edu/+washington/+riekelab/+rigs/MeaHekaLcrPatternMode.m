classdef MeaHekaLcrPatternMode < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MeaHekaLcrPatternMode()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;

            % Add the HEKA A/D board.
            daq = HekaDaqController();
            obj.daqController = daq;
            
            % Add the Multiclamp device (demo mode).
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ao0')).bindStream(daq.getStream('ai0'));
            obj.addDevice(amp1);

            % Check which analog input channel the temperature controller is on!!
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ai3'));
            obj.addDevice(temperature);
            
            % Get the red sync pulse from the lightcrafter.
            redTTL = UnitConvertingDevice('Red Sync', 'V').bindStream(daq.getStream('ai6'));
            obj.addDevice(redTTL);
            
            % Add the LightCrafter (pattern mode)
            lightCrafter = edu.washington.riekelab.devices.LightCrafterDevice(...
                'micronsPerPixel', 2.43, ...
                'host', '192.168.0.102', ...
                'ledCurrents',[10,7,30],...
                'customLightEngine',true);
            
            myspect = containers.Map( ...
                {'red', 'green_505', 'green_565', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Green_505nm_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Green_570nm_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Blue_spectrum.txt'))});
            
            lightCrafter.addResource('spectrum', myspect);
            lightCrafter.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            daq = obj.daqController;
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40'}));
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40'}, ...
                    {0, 0.5082, 1.0000, 2.0152, 3.0310, 4.0374}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40'}, ...
                    {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40'}, ...
                    {0, 0.5305, 1.0502, 2.4253, 3.6195, 4.8356})}));
            
            qCatch = [
                0.296662164412504   0.056639744924133   0.000470866513993   0.008337083695311
               1.717472065022683   1.117026807669420   0.002502841889190   0.812127219852966
               0.427928281158783   0.396201570865606   2.125287451583463   2.223676348313830]*1e5*4;
                
%             qCatch = zeros(3,4);
%             names = {'red','green_565','blue'};
%             for jj = 1 : length(names)
%                 q = myspect(names{jj});
%                 qCatch(jj,:) = manookinlab.util.computeQuantalCatch(q(:, 1), q(:, 2));
%             end
            lightCrafter.addResource('quantalCatch', qCatch);
            obj.addDevice(lightCrafter);
            
            % Add the frame monitor to record the timing of the monitor refresh.
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
            
            % Add a device for external triggering to synchronize MEA DAQ clock with Symphony DAQ clock.
            trigger = riekelab.devices.TriggerDevice();
            trigger.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(trigger, 0);
            obj.addDevice(trigger);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM5');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            filterWheel.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(filterWheel, 14);
            obj.addDevice(filterWheel);

            % Add the MEA device controller. This waits for the stream from Vision, strips of the header, and runs the block.
            mea = manookinlab.devices.MEADevice(9001);
            obj.addDevice(mea);
        end
    end
end
