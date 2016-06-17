classdef TwoPhoton < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = TwoPhoton()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = HekaDaqController();
            obj.daqController = daq;
            
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            obj.addDevice(amp1);
            
            red = UnitConvertingDevice('Red LED', 'V').bindStream(daq.getStream('ANALOG_OUT.1'));
            red.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'B1', 'B2', 'B3', 'B4', 'B5', 'B11'}));
            red.addResource('ndfAttenuations', containers.Map( ...
                {'B1', 'B2', 'B3', 'B4', 'B5', 'B11'}, ...
                {0.29, 0.61, 1.01, 2.08, 4.41, 3.94}));
            red.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            red.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'two_photon', 'red_led_spectrum.txt')));
            obj.addDevice(red);
            
            uv = UnitConvertingDevice('UV LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            uv.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7'}));
            uv.addResource('ndfAttenuations', containers.Map( ...
                {'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7'}, ...
                {0.29, 0.71, 1.21, 2.54, 2.48, 2.71, 5.13}));
            uv.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            uv.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'two_photon', 'uv_led_spectrum.txt')));
            obj.addDevice(uv);
            
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            blue.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'B1', 'B2', 'B3', 'B4', 'B5', 'B8', 'B9'}));
            blue.addResource('ndfAttenuations', containers.Map( ...
                {'B1', 'B2', 'B3', 'B4', 'B5', 'B8', 'B9'}, ...
                {0.29, 0.60, 1.02, 2.41, 4.58, 2.20, 4.32}));
            blue.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            blue.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'two_photon', 'blue_led_spectrum.txt')));
            obj.addDevice(blue);
            
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ANALOG_IN.6'));
            obj.addDevice(temperature);
            
            trigger = UnitConvertingDevice('Oscilloscope Trigger', Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger, 0);
            obj.addDevice(trigger);        
        end
        
    end
    
end
