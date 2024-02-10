classdef MEAWithMicrodisplay < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MeaHekaLcrVideoMode()
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
            
            % Add the LEDs.
            uvRamp = importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'uv_led_gamma_ramp.txt'));
            uv = CalibratedDevice('UV LED', Measurement.NORMALIZED, uvRamp(:, 1), uvRamp(:, 2)).bindStream(daq.getStream('ao1'));
            uv.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'C1', 'C2', 'C3', 'C4', 'C5'}));
            uv.addResource('ndfAttenuations', containers.Map( ...
                {'C1', 'C2', 'C3', 'C4', 'C5'}, ...
                {0.2768, 0.5076, 0.9281, 2.1275, 2.5022}));
            uv.addResource('fluxFactorPaths', containers.Map( ...
                {'none'}, {riekelab.Package.getCalibrationResource('rigs', 'mea', 'uv_led_flux_factors.txt')}));
            uv.addConfigurationSetting('lightPath', '', ...
                'type', PropertyType('char', 'row', {'', 'below', 'above'}));
            uv.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'uv_led_spectrum.txt')));          
            obj.addDevice(uv);
            
            blueRamp = importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'blue_led_gamma_ramp.txt'));
            blue = CalibratedDevice('Blue LED', Measurement.NORMALIZED, blueRamp(:, 1), blueRamp(:, 2)).bindStream(daq.getStream('ao2'));
            blue.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'C1', 'C2', 'C3', 'C4', 'C5'}));
            blue.addResource('ndfAttenuations', containers.Map( ...
                {'C1', 'C2', 'C3', 'C4', 'C5'}, ...
                {0.2663, 0.5389, 0.9569, 2.0810, 2.3747}));
            blue.addResource('fluxFactorPaths', containers.Map( ...
                {'none'}, {riekelab.Package.getCalibrationResource('rigs', 'mea', 'blue_led_flux_factors.txt')}));
            blue.addConfigurationSetting('lightPath', '', ...
                'type', PropertyType('char', 'row', {'', 'below', 'above'}));
            blue.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'blue_led_spectrum.txt')));                       
            obj.addDevice(blue);
            
            greenRamp = importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'green_led_gamma_ramp.txt'));
            green = CalibratedDevice('Green LED', Measurement.NORMALIZED, greenRamp(:, 1), greenRamp(:, 2)).bindStream(daq.getStream('ao3'));
            green.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'C1', 'C2', 'C3', 'C4', 'C5'}));
            green.addResource('ndfAttenuations', containers.Map( ...
                {'C1', 'C2', 'C3', 'C4', 'C5'}, ...
                {0.2866, 0.5933, 0.9675, 1.9279, 2.1372}));
            green.addResource('fluxFactorPaths', containers.Map( ...
                {'none'}, {riekelab.Package.getCalibrationResource('rigs', 'mea', 'green_led_flux_factors.txt')}));
            green.addConfigurationSetting('lightPath', '', ...
                'type', PropertyType('char', 'row', {'', 'below', 'above'}));
            green.addResource('spectrum', importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'green_led_spectrum.txt')));            
            obj.addDevice(green);
            
            % Add the Microdisplay
            ramps = containers.Map();
            ramps('minimum') = linspace(0, 65535, 256);
            ramps('low')     = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_low_gamma_ramp.txt'));
            ramps('medium')  = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_medium_gamma_ramp.txt'));
            ramps('high')    = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_high_gamma_ramp.txt'));
            ramps('maximum') = linspace(0, 65535, 256);
%             microdisplay = riekelab.devices.MicrodisplayDevice('gammaRamps', ramps, 'micronsPerPixel', 3.0, 'comPort', 'COM4');
            microdisplay = riekelab.devices.MicrodisplayDevice('gammaRamps', ramps, 'micronsPerPixel', 3.8, 'comPort', 'COM4', 'host', '192.168.0.102');
            microdisplay.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(microdisplay, 15);
            microdisplay.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'E1', 'E2', 'E3', 'E4', 'E12'}));
            microdisplay.addResource('ndfAttenuations', containers.Map( ...
                {'white', 'red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'E1', 'E2', 'E3', 'E4', 'E12'}, ...
                    {0.26, 0.59, 0.94, 2.07, 0.30}), ...
                containers.Map( ...
                    {'E1', 'E2', 'E3', 'E4', 'E12'}, ...
                    {0.26, 0.61, 0.94, 2.05, 0.29}), ...
                containers.Map( ...
                    {'E1', 'E2', 'E3', 'E4', 'E12'}, ...
                    {0.26, 0.58, 0.94, 2.12, 0.29}), ...
                containers.Map( ...
                    {'E1', 'E2', 'E3', 'E4', 'E12'}, ...
                    {0.26, 0.57, 0.93, 2.13, 0.29})}));
            microdisplay.addResource('fluxFactorPaths', containers.Map( ...
                {'low', 'medium', 'high'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_low_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_medium_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_high_flux_factors.txt')}));
            microdisplay.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            microdisplay.addResource('spectrum', containers.Map( ...
                {'white', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_white_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_green_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_blue_spectrum.txt'))}));
            
            % Get the quantal catch.
            myspect = containers.Map( ...
                {'white', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_white_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_green_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_blue_spectrum.txt'))});
            
            qCatch = zeros(3,4);
            names = {'red','green','blue'};
            for jj = 1 : length(names)
                q = myspect(names{jj});
%                 p = manookinlab.util.PhotoreceptorSpectrum( q(:, 1) );
%                 p = p / sum(p(1, :));
%                 qCatch(jj, :) = p * q(:, 2);
                qCatch(jj,:) = manookinlab.util.computeQuantalCatch(q(:, 1), q(:, 2));
            end
            microdisplay.addResource('quantalCatch', qCatch);
            
            obj.addDevice(microdisplay);
            
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
%             mea = manookinlab.devices.MEADevice('host', '192.168.0.100');
            mea = manookinlab.devices.MEADevice(9001);
            obj.addDevice(mea);
        end
    end
end

