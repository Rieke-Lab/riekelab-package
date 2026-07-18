classdef MeaHekaLcrVideoMode505 < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MeaHekaLcrVideoMode505()
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
            
            optometer = UnitConvertingDevice('Optometer', 'V').bindStream(daq.getStream('ai1'));
            obj.addDevice(optometer);  

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
            
            % micronsPerPixel remeasured on 2026-03-12 after installing
            % achromat ACT508 lens. Older value was 3.37
            lightCrafter = edu.washington.riekelab.devices.LightCrafterDevice(...
                'micronsPerPixel', 3.07, ...
                'gammaRamps', ramps, ...
                'host', '192.168.0.102', ...
                'local_movie_directory','C:\Users\Public\Documents\GitRepos\Symphony2\movies\',...
                'stage_movie_directory','Y:\\movies\',...
                'ledCurrents',[10,7,30],...
                'customLightEngine',true,...
		'mode','video');
            
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_auto505_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_red505_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_green505_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_blue505_flux_factors.txt')}));
            lightCrafter.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            
            myspect = containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_auto505_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_red505_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_green505_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_below_blue505_spectrum.txt'))});
            
            lightCrafter.addResource('spectrum', myspect);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}));
            % New FWND Measurements Made 05.05.2026
%             lightCrafter.addResource('ndfAttenuations', containers.Map( ...
%                 {'auto','red', 'green', 'blue'}, { ...
%                 containers.Map( ...
%                     {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
%                     {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918,0.2866, 0.5933, 0.9675, 1.9279, 2.1372}), ...
%                 containers.Map( ...
%                     {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
%                     {0, 0.5082, 1.0000, 2.0152, 3.0310, 4.0374,0.2866, 0.5933, 0.9675, 1.9279, 2.1372}), ...
%                 containers.Map( ...
%                     {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
%                     {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918,0.2866, 0.5933, 0.9675, 1.9279, 2.1372}), ...
%                 containers.Map( ...
%                     {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
%                     {0, 0.5305, 1.0502, 2.4253, 3.6195, 4.8356,0.2663, 0.5389, 0.9569, 2.0810, 2.3747})}));
            
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'auto','red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5153, 1.0175, 2.1873, 3.2603, 4.3110, 0.2866, 0.5460, 0.9675, 1.9279, 2.1372}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5089, 1.0047, 2.0381, 3.0604, 4.0434, 0.2866, 0.5945, 0.9675, 1.9279, 2.1372}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5074, 1.0031, 2.1752, 3.2626, 4.2867, 0.2866, 0.5470, 0.9675, 1.9279, 2.1372}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40','C1', 'C2', 'C3', 'C4', 'C5'}, ...
                    {0, 0.5312, 1.0494, 2.4151, 3.6192, 4.7103, 0.2663, 0.5140, 0.9569, 2.0810, 2.3747})}));    
            % Compute the quantal catch and add it to the rig config.
%             paths = lightCrafter.getResource('fluxFactorPaths');
%             spectrum = lightCrafter.getResource('spectrum');
%             qCatch = manookinlab.util.computePhotoreceptorCatch(paths, spectrum, 'species', 'macaque');
%           
            % Automatic computations are wrong, manual values accurate as
            % of 07/17/2026, Column order is L, M, S, Rod. Row order is R,
            % G, B.
            qCatch = [
               0.664987   0.169773   0.040604   0.154258
               0.638458   1.136154   0.227892   3.911955
               0.114495   0.115746   1.121788   0.715405]*1e6;
                
%             qCatch = zeros(3,4);
%             names = {'red','green','blue'};
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
            greenRamp = importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_led_gamma_ramp.txt'));
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
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_led_low_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_led_medium_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_led_high_flux_factors.txt')}));
            green.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            green.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_led_spectrum.txt')));
            obj.addDevice(green);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM5');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            filterWheel.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(filterWheel, 14);
            obj.addDevice(filterWheel);

            % Gain controller device for LCR LEDs.
            gainRamp = importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'projector_led_gain_gamma_ramp.txt'));
            gain_device = CalibratedDevice('Projector Gain', Measurement.NORMALIZED, gainRamp(:, 1), gainRamp(:, 2)).bindStream(daq.getStream('ao3'));
            obj.addDevice(gain_device);
            
            
            % Add the MEA device controller. This waits for the stream from Vision, strips of the header, and runs the block.
%             mea = manookinlab.devices.MEADevice('host', '192.168.0.100');
            mea = manookinlab.devices.MEADevice(9001);
            obj.addDevice(mea);
            
%             optometer = UnitConvertingDevice('Optometer', 'V').bindStream(daq.getStream('ai0'));
%             obj.addDevice(optometer);  
        end
    end
end

