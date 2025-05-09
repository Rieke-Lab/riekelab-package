classdef SharedTwoPhotonWithLightCrafterWithoutBlueFilter < edu.washington.riekelab.rigs.SharedTwoPhotonWithLedAboveWithoutBlueFilter
    
    methods
        
        function obj = SharedTwoPhotonWithLightCrafterWithoutBlueFilter()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            lightCrafter = riekelab.devices.LightCrafterDevice('micronsPerPixel', 0.97,'host','SCIENTIFICA-PC');
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'EL03','EL06','ES03','EL1', 'EL2', 'EL3', 'FW05', 'FW1', 'FW2', 'FW3', 'FW4'}));
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'EL03','EL06','ES03','EL1', 'EL2', 'EL3', 'FW05', 'FW1', 'FW2', 'FW3', 'FW4'}, ...
                    {0.29,0.62,0.26,0.97, 2.11, 4.23,0.51, 1.01, 2.06, 3.13, 4.06 }), ...
                containers.Map( ...
                    {'EL03','EL06','ES03','EL1', 'EL2', 'EL3', 'FW05', 'FW1', 'FW2', 'FW3', 'FW4'}, ...
                    {0.32,0.63,0.3,0.98, 2.06, 4.09,0.51, 1.02, 1.99, 2.97, 3.85}), ...
                containers.Map( ...
                    {'EL03','EL06','ES03','EL1', 'EL2', 'EL3', 'FW05', 'FW1', 'FW2', 'FW3', 'FW4'}, ...
                    {0.29,0.62,0.28,0.99, 2.14, 4.29,0.51,1.0, 2.09, 3.17,4.03 }), ...
                containers.Map( ...
                    {'EL03','EL06','ES03','EL1', 'EL2', 'EL3', 'FW05', 'FW1', 'FW2', 'FW3', 'FW4'}, ...
                    {0.25,0.61, 0.27,0.98, 2.16, 4.40, 0.5, 1.0, 2.12, 3.21, 4.12})}));
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_auto_flux_factors_noFilter.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_red_flux_factors_noFilter.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_green_flux_factors_noFilter.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_blue_flux_factors_noFilter.txt')}));
            lightCrafter.addConfigurationSetting('lightPath', 'above', 'isReadOnly', true);
            lightCrafter.addResource('spectrum', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_auto_spectrum_noFilter.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_red_spectrum_noFilter.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_green_spectrum_noFilter.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'shared_two_photon', 'lightcrafter_above_blue_spectrum_noFilter.txt'))}));
            obj.addDevice(lightCrafter);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM3');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            daq = obj.daqController;
            filterWheel.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(filterWheel, 15);
            
            obj.addDevice(filterWheel);
        end
        
    end
    
end

