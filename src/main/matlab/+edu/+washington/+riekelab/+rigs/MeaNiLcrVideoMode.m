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
            
%             qCatch = [
%                5.184688757116199   0.989878332801999   0.008229213610837   0.145705079000616
%                9.159851013454308   5.957476307570245   0.013348490075679   4.331345172549151
%                1.224271638811880   1.133503831880406   6.080292576715589   6.361776042858103]*1e4*0.56;
            
            % Compute the quantal catch and add it to the rig config.
            paths = lightCrafter.getResource('fluxFactorPaths');
            spectrum = lightCrafter.getResource('spectrum');

            qCatch = obj.computeCatch(paths, spectrum);
            
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
        
        function quantalCatch = computeCatch(obj, paths, spectrum)
            led_names = {'red','green','blue'};
            quantalCatch = zeros(length(led_names),4);
            canComputeCatch = true;
            m = containers.Map();
            settings = paths.keys;
            for k = 1:numel(settings)
                setting = settings{k};
                if exist(paths(setting), 'file')
                    t = readtable(paths(setting), 'Format', '%s %s %f %f %f %f %s');
                    t.date = datetime(t.date);
                    t = sortrows(t, 'date', 'descend');
                    m(setting) = t;
                else
                    disp('Warning: Flux factors not calibrated, cannot compute quantal catch.');
                    canComputeCatch = false;
                end
            end
            if canComputeCatch
                for ii = 1 : length(led_names)
                    flashArea = (m(led_names{ii}).diameter(1)/2)^2 * pi;
                    ledPower = m(led_names{ii}).power(1) * 1e-9;
                    spect = spectrum(led_names{ii});
                    wavelength = spect(:,1);
                    energySpectrum = spect(:,2) / sum(spect(:,2));
                    lambda = wavelength * 1e-9;

                    quantalSpectrum = (energySpectrum * ledPower) .* lambda / (h*c);

                    % Compute the Quantal catch.
                    p = manookinlab.util.PhotoreceptorSpectrum( wavelength, [559 530 430 493],[cDensity*ones(1,3) rDensity]);
                    photonFlux = quantalSpectrum' * p';
                    fluxPerSqMicron = photonFlux / flashArea;
                    qCatch = fluxPerSqMicron;

                    qCatch(1:3) = qCatch(1:3) * coneArea;
                    qCatch(4) = qCatch(4) * rodArea;
                    quantalCatch(ii,:) = qCatch(:)';
                end
            end
        end
    end
end

