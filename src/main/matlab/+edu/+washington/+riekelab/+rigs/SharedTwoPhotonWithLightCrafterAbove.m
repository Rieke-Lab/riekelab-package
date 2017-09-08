classdef SharedTwoPhotonWithLightCrafterAbove < edu.washington.riekelab.rigs.SharedTwoPhoton
    
    methods
        
        function obj = SharedTwoPhotonWithLightCrafterAbove()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            lightCrafter = riekelab.devices.LightCrafterDevice('micronsPerPixel', 1.3);
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'EL1', 'EL2', 'EL3'}));
            lightCrafter.addResource('ndfAttenuations', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                containers.Map( ...
                    {'EL1', 'EL2', 'EL3'}, ...
                    {0.97, 2.11, 4.23}), ...
                containers.Map( ...
                    {'EL1', 'EL2', 'EL3'}, ...
                    {0.98, 2.06, 4.09}), ...
                containers.Map( ...
                    {'EL1', 'EL2', 'EL3'}, ...
                    {0.99, 2.14, 4.29}), ...
                containers.Map( ...
                    {'EL1', 'EL2', 'EL3'}, ...
                    {0.99, 2.16, 4.40})}));
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_auto_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_red_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_green_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_blue_flux_factors.txt')}));
            lightCrafter.addConfigurationSetting('lightPath', 'above', 'isReadOnly', true);
            lightCrafter.addResource('spectrum', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_auto_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_green_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_blue_spectrum.txt'))}));
            obj.addDevice(lightCrafter);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM4');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            daq = obj.daqController;
            filterWheel.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(filterWheel, 15);
            
            obj.addDevice(filterWheel);
        end
        
    end
    
end

