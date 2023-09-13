classdef MEAWithLightCrafter < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MEAWithLightCrafter()
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
            
            % Add the LightCrafter
            %ramps = containers.Map();
            %ramps('red')    = 65535 * importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'red_gamma_ramp.txt'));
            %ramps('green')  = 65535 * importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'green_gamma_ramp.txt'));
            %ramps('blue')   = 65535 * importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'blue_gamma_ramp.txt'));
            
            %lightCrafter = manookinlab.devices.LcrVideoDevice(...
            %    'micronsPerPixel', 1.0, ...
            %    'gammaRamps',ramps, 'host', '192.168.0.102', ...
            %    'ledCurrents',[20,20,20],...
            %    'customLightEngine',true);
            lightCrafter = manookinlab.devices.LcrVideoDevice(...
                'micronsPerPixel', 1.0, ...
                'host', '192.168.0.102', ...
                'ledCurrents',[20,20,20],...
                'customLightEngine',true);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            daq = obj.daqController;
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            
            % Get the quantal catch.
            myspect = containers.Map( ...
                {'white', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_white_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_green_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'mea', 'microdisplay_below_blue_spectrum.txt'))});
            
%             lightCrafter.addResource('spectrum', containers.Map( ...
%                 {'red', 'Green_505nm', 'Green_570nm', 'blue', 'wavelength'}, { ...
%                 importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'red_spectrum.txt')), ...
%                 importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'Green_505nm_spectrum.txt')), ...
%                 importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'Green_570nm_spectrum.txt')), ...
%                 importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'blue_spectrum.txt')), ...
%                 importdata(manookinlab.Package.getCalibrationResource('rigs', 'rig_A', 'wavelength.txt'))}));
            
            
            qCatch = zeros(3,4);
            names = {'red','green','blue'};
            for jj = 1 : length(names)
                q = myspect(names{jj});
%                 p = manookinlab.util.PhotoreceptorSpectrum( q(:, 1) );
%                 p = p / sum(p(1, :));
%                 qCatch(jj, :) = p * q(:, 2);
                qCatch(jj,:) = manookinlab.util.computeQuantalCatch(q(:, 1), q(:, 2));
            end
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
%             mea = manookinlab.devices.MEADevice('host', '192.168.0.100');
%             mea = manookinlab.devices.MEADevice(9001);
%             obj.addDevice(mea);
        end
    end
end

