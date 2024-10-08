classdef MeaNiLcrPatternMode < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MeaNiLcrPatternMode()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;

            % Add the NiDAQ A/D board.
            daq = NiDaqController();
            obj.daqController = daq;
            
            daq = obj.daqController;
            
            % Add the Multiclamp device (demo mode).
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ao0')).bindStream(daq.getStream('ai0'));
            obj.addDevice(amp1);
            
            % Bath temperature
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ai2'));
            obj.addDevice(temperature);

            % Add the LightCrafter (pattern mode)
            lightCrafter = edu.washington.riekelab.devices.LightCrafterDevice(...
                'micronsPerPixel', 3.24, ...
                'host', '192.168.0.102', ...
                'ledCurrents',[10,7,30],...
                'local_movie_directory','C:\Users\Public\Documents\GitRepos\Symphony2\movies\',...
                'stage_movie_directory','Y:\\movies\',...
                'customLightEngine',true);
            
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_auto_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_red_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_green_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'tiny_mea', 'lightcrafter_below_blue_flux_factors.txt')}));
            lightCrafter.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            
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
            
            % Compute the quantal catch and add it to the rig config.
            paths = lightCrafter.getResource('fluxFactorPaths');
            spectrum = lightCrafter.getResource('spectrum');
            qCatch = manookinlab.util.computePhotoreceptorCatch(paths, spectrum, 'species', 'macaque') * 4;
            
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
