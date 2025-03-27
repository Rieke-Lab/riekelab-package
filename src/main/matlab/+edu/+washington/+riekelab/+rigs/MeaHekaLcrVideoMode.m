classdef MeaHekaLcrVideoMode < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MeaHekaLcrVideoMode()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;

            % Add the HEKA A/D board.
            daq = HekaDaqController();
            obj.daqController = daq;
            daq = obj.daqController;
            
            % Add the Multiclamp device (demo mode).
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ao0')).bindStream(daq.getStream('ai0'));
            obj.addDevice(amp1);

            % Check which analog input channel the temperature controller is on!!
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ai3'));
            obj.addDevice(temperature);
            
            % Get the red sync pulse from the lightcrafter.
            redTTL = UnitConvertingDevice('Red Sync', 'V').bindStream(daq.getStream('ai6'));
            obj.addDevice(redTTL);
            
            % Add the LightCrafter
            ramps = containers.Map();
            ramps('red')    = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'red_gamma_ramp.txt'));
            ramps('green')  = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_gamma_ramp.txt'));
            ramps('blue')   = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'blue_gamma_ramp.txt'));
            
            lightCrafter = manookinlab.devices.LcrVideoDevice(...
                'micronsPerPixel', 3.37, ...
                'gammaRamps', ramps, ...
                'host', '192.168.0.102', ...
                'local_movie_directory','C:\Users\Public\Documents\GitRepos\Symphony2\movies\',...
                'stage_movie_directory','Y:\\movies\',...
                'ledCurrents',[10,7,30],...
                'customLightEngine',true);
            
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_auto_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_red_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_green_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_blue_flux_factors.txt')}));
            lightCrafter.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            
            myspect = containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_auto_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_green_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_blue_spectrum.txt'))});
            
            lightCrafter.addResource('spectrum', myspect);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}));
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'auto','red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918,0.2866, 0.5933, 0.9675, 1.9279, 2.1372}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5082, 1.0000, 2.0152, 3.0310, 4.0374,0.2866, 0.5933, 0.9675, 1.9279, 2.1372}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918,0.2866, 0.5933, 0.9675, 1.9279, 2.1372}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5305, 1.0502, 2.4253, 3.6195, 4.8356,0.2663, 0.5389, 0.9569, 2.0810, 2.3747})}));
            
            % Compute the quantal catch and add it to the rig config.
%             paths = lightCrafter.getResource('fluxFactorPaths');
%             spectrum = lightCrafter.getResource('spectrum');
%             qCatch = manookinlab.util.computePhotoreceptorCatch(paths, spectrum, 'species', 'macaque');
%             
%             lightCrafter.addResource('quantalCatch', qCatch);
            
            qCatch = [
               0.369447881495107   0.070536240481100   0.000586393065682   0.010382577485673
               1.496654228091196   0.973409075254781   0.002181047932008   0.707710863014727
               0.154309237808581   0.142868712143260   0.766370210190195   0.801848855401907]*1e5;
                
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
            
            % The 505 nm LED.
            greenRamp = importdata(riekelab.Package.getCalibrationResource('rigs', 'confocal', 'green_led_gamma_ramp.txt'));
            green = CalibratedDevice('Green LED', Measurement.NORMALIZED, greenRamp(:, 1), greenRamp(:, 2)).bindStream(daq.getStream('ao2'));
            green.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'C1', 'C2', 'C3', 'C4', 'C5'}));
            green.addResource('ndfAttenuations', containers.Map( ...
                {'C1', 'C2', 'C3', 'C4', 'C5'}, ...
                {0.2866, 0.5933, 0.9675, 1.9279, 2.1372}));
            green.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            green.addResource('fluxFactorPaths', containers.Map( ...
                {'low', 'medium', 'high'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'green_led_low_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'green_led_medium_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'green_led_high_flux_factors.txt')}));
            green.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            green.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'confocal', 'green_led_spectrum.txt')));
            obj.addDevice(green);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM5');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            filterWheel.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(filterWheel, 14);
            obj.addDevice(filterWheel);

            % Add the SPDT switch to control the LEDs.
%             led_switch = riekelab.devices.LedSPDTDevice('comPort', 'COM6', 'ledNames', {'Green_570nm','Green_505nm'});
%             daq.getStream('doport1').setBitPosition(led_switch, 13);
%             obj.addDevice(led_switch);
            
            
            % Add the MEA device controller. This waits for the stream from Vision, strips of the header, and runs the block.
%             mea = manookinlab.devices.MEADevice('host', '192.168.0.100');
            mea = manookinlab.devices.MEADevice(9001);
            obj.addDevice(mea);
        end
    end
end

