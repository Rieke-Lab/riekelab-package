classdef TriggerDevice < symphonyui.core.Device
    % Device for TTL triggering to synchronize the Symphony clock with that of other external devices.
    
    
    methods
        
        function obj = TriggerDevice()
            
            cobj = Symphony.Core.UnitConvertingExternalDevice('ExternalTrigger', 'none', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
            obj@symphonyui.core.Device(cobj);
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;
        end

        
    end
    
end
