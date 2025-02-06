classdef MeaHekaLcrVideoModeAndOptometer < edu.washington.riekelab.rigs.MeaHekaLcrVideoMode
    
    methods
        
        function obj = MeaHekaLcrVideoModeAndOptometer()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = obj.daqController;
            
            optometer = UnitConvertingDevice('Optometer', 'V').bindStream(daq.getStream('ai0'));
            obj.addDevice(optometer);  
        end
        
    end
    
end