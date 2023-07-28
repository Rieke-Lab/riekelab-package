classdef TriggerDevice < symphonyui.core.Device
    % Device for TTL triggering to synchronize the Symphony clock with that of other external devices.

    properties (Access = private)
        adc_type
    end
    
    methods
        
        function obj = TriggerDevice(varargin)
            ip = inputParser();
            ip.addParameter('adc_type', 'analog', @ischar);
            ip.parse(varargin{:});

            if strcmpi(ip.Results.adc_type, 'analog')
                adc_type = 'ANALOG';
            else
                adc_type = 'DIGITAL';
            end
            obj.adc_type = adc_type;

            if strcmp(adc_type, 'DIGITAL')
                cobj = Symphony.Core.UnitConvertingExternalDevice('ExternalTrigger', 'none', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
                obj@symphonyui.core.Device(cobj);
                obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;
            else
            end

            % Add configuration settings.
            obj.addConfigurationSetting('adc_type', adc_type);
        end

        function nm = get_adc_type(obj)
            nm = obj.getConfigurationSetting('adc_type');
        end

        
    end
    
end
