classdef MeaNiLcrVideoMode < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MeaNiLcrVideoMode()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;

            % Add the NiDAQ A/D board.
            daq = NiDaqController();
            obj.daqController = daq;
            % Black magic
            daq = obj.daqController;
            
            % Add the Multiclamp device (demo mode).
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ao0')).bindStream(daq.getStream('ai0'));
            obj.addDevice(amp1);
            
            % Add the signal generator (~100 Hz).
%             signal_gen = UnitConvertingDevice('Waveform Generator', 'V').bindStream(daq.getStream('ai1'));
%             obj.addDevice(signal_gen);

            % Bath temperature
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ai2'));
            obj.addDevice(temperature);
            
            % Get the red sync pulse from the lightcrafter.
            redTTL = UnitConvertingDevice('Red Sync', 'V').bindStream(daq.getStream('ai6'));
            obj.addDevice(redTTL);
            
            % Add the LightCrafter
            ramps = containers.Map();
            ramps('red')    = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'red_gamma_ramp.txt'));
            ramps('green')  = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'green_gamma_ramp.txt'));
            ramps('blue')   = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'blue_gamma_ramp.txt'));
            
            lightCrafter = manookinlab.devices.LcrVideoDevice(...
                'micronsPerPixel', 3.24, ...
                'gammaRamps', ramps, ...
                'host', '192.168.0.102', ...
                'local_movie_directory','C:\Users\Public\Documents\GitRepos\Symphony2\movies\',...
                'stage_movie_directory','Y:\\movies\',...
                'ledCurrents',[10,7,30],...
                'customLightEngine',true);
            
            % Add the flux calibrations.
            flux_paths = containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_auto_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_red_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_green_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_blue_flux_factors.txt')});
            lightCrafter.addResource('fluxFactorPaths', flux_paths);
            lightCrafter.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            
            % Add the projector spectra.
            myspect = containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_auto_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_green_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_blue_spectrum.txt'))});
            lightCrafter.addResource('spectrum', myspect);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            lightCrafter.bindStream(daq.getStream('doport0'));
            daq.getStream('doport0').setBitPosition(lightCrafter, 15);
            
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40', 'C03', 'C06', 'C1', 'C2'}));
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'auto','red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40', 'C03', 'C06', 'C1', 'C2'}, ...
                    {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918, 0.2866, 0.5933, 0.9675, 1.9279}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40', 'C03', 'C06', 'C1', 'C2'}, ...
                    {0, 0.5082, 1.0000, 2.0152, 3.0310, 4.0374, 0.2866, 0.5933, 0.9675, 1.9279}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40', 'C03', 'C06', 'C1', 'C2'}, ...
                    {0, 0.5054, 0.9961, 2.1100, 3.1363, 4.1918, 0.2866, 0.5933, 0.9675, 1.9279}), ...
                containers.Map( ...
                    {'FW00', 'FW05', 'FW10', 'FW20', 'FW30', 'FW40', 'C03', 'C06', 'C1', 'C2'}, ...
                    {0, 0.5305, 1.0502, 2.4253, 3.6195, 4.8356, 0.2663, 0.5389, 0.9569, 2.0810})}));
            
            % Compute the quantal catch and add it to the rig config.
            paths = lightCrafter.getResource('fluxFactorPaths');
            spectrum = lightCrafter.getResource('spectrum');
            qCatch = manookinlab.util.computePhotoreceptorCatch(paths, spectrum, 'species', 'macaque');
            
            lightCrafter.addResource('quantalCatch', qCatch);
            obj.addDevice(lightCrafter);
   
            % Add the frame monitor to record the timing of the monitor refresh.
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai4'));
            obj.addDevice(frameMonitor);
            
            % Add a device for external triggering to synchronize MEA DAQ clock with Symphony DAQ clock.
            trigger = riekelab.devices.TriggerDevice();
            trigger.bindStream(daq.getStream('doport0'));
            daq.getStream('doport0').setBitPosition(trigger, 0);
            obj.addDevice(trigger);
            
            % Add the high-intensity green LED for stimulating
            % channelrhodopsin.
%             green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ao1'));
%             green.addConfigurationSetting('ndfs', {}, ...
%                 'type', PropertyType('cellstr', 'row', {'B1', 'B2', 'B3', 'B4', 'B5', 'B11'}));
%             green.addResource('ndfAttenuations', containers.Map( ...
%                 {'B1', 'B2', 'B3', 'B4', 'B5', 'B11'}, ...
%                 {0.29, 0.61, 1.01, 2.08, 4.41, 3.94}));
%             green.addConfigurationSetting('gain', '', ...
%                 'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
%             green.addResource('fluxFactorPaths', containers.Map( ...
%                 {'low', 'medium', 'high'}, { ...
%                 riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_low_flux_factors.txt'), ...
%                 riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_medium_flux_factors.txt'), ...
%                 riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_high_flux_factors.txt')}));
%             green.addConfigurationSetting('lightPath', '', ...
%                 'type', PropertyType('char', 'row', {'', 'below', 'above'}));
%             green.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'red_led_spectrum.txt')));
%             obj.addDevice(green);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM5');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            filterWheel.bindStream(daq.getStream('doport0'));
            daq.getStream('doport0').setBitPosition(filterWheel, 14);
            obj.addDevice(filterWheel);
            
            % Add the MEA device controller. This waits for the stream from Vision, strips of the header, and runs the block.
            mea = manookinlab.devices.MEADevice(9001);
            obj.addDevice(mea);
        end
    end
end

