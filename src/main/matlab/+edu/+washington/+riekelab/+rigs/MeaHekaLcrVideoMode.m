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
                'micronsPerPixel', 2.43, ...
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
                'type', PropertyType('cellstr', 'row', {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40'}));
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'auto','red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40'}, ...
                    {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918}), ...
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
               0.427928281158783   0.396201570865606   2.125287451583463   2.223676348313830]*1e5;
                
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
            
            % The 505 nm LED for stimulating channelrhodopsin.
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ao2'));
            green.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'B1', 'B2', 'B3', 'B4', 'B5', 'B11'}));
            green.addResource('ndfAttenuations', containers.Map( ...
                {'B1', 'B2', 'B3', 'B4', 'B5', 'B11'}, ...
                {0.29, 0.61, 1.01, 2.08, 4.41, 3.94}));
            green.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            green.addResource('fluxFactorPaths', containers.Map( ...
                {'low', 'medium', 'high'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_low_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_medium_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_high_flux_factors.txt')}));
            green.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
%             green.addConfigurationSetting('lightPath', '', ...
%                 'type', PropertyType('char', 'row', {'', 'below', 'above'}));
            green.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_spectrum.txt')));
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

