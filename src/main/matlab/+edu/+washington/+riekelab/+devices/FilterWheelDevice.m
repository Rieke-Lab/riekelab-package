classdef FilterWheelDevice < symphonyui.core.Device
    
    properties (Access = private)
        wheelPosition
        ndf
    end
    
    
    properties (Access = private)
        filterWheel
        ndfValues % = [0 0.5 1.0 2.0 3.0 4.0];
        isOpen
    end
    
    methods
        function obj = FilterWheelDevice(varargin)
            
            ip = inputParser();
            ip.addParameter('comPort', 'COM13', @ischar);
            ip.addParameter('NDF', 4.0, @isnumeric);
            ip.addParameter('ndfValues', [0 0.5 1.0 2.0 3.0 4.0], @isnumeric);
            ip.parse(varargin{:});
            
            cobj = Symphony.Core.UnitConvertingExternalDevice('FilterWheel', 'ThorLabs', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
            obj@symphonyui.core.Device(cobj);
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;
            
            obj.addConfigurationSetting('NDF', 4.0);
            obj.ndfValues = ip.Results.ndfValues;

            obj.addConfigurationSetting('ndfValues', obj.ndfValues);

            % Try to connect.
            obj.connect(ip.Results.comPort);
            
            if obj.isOpen
                obj.setNDF(ip.Results.NDF);
                obj.ndf = 4;
            end
        end
        
        function connect(obj, comPort)
            try
                obj.filterWheel = serialport(comPort, 115200, ...
                    'DataBits', 8, 'StopBits', 1, 'Timeout', 5);
                configureTerminator(obj.filterWheel, 'CR');
                obj.isOpen = true;
            catch
                obj.isOpen = false;
            end
        end

        function close(obj)
            if obj.isOpen
                try
                    delete(obj.filterWheel);
                catch
                end
                obj.isOpen = false;
            end
        end

        function moveWheel(obj, position)
            writeline(obj.filterWheel, ['pos=' num2str(position)]);
            obj.wheelPosition = position;
        end
        
        function setNDF(obj, nd)
            try
                obj.moveWheel(find(obj.ndfValues == nd, 1));
                obj.setReadOnlyConfigurationSetting('NDF', nd);
            catch e
                disp(e.message);
            end
        end
        
        function nd = getNDF(obj)
            nd = obj.getConfigurationSetting('NDF');
        end

        function ndfValues = getNdfValues(obj)
            ndfValues = obj.getConfigurationSetting('ndfValues');
        end

        
        function position = getCurrentPosition(obj)
            if obj.isOpen
                writeline(obj.filterWheel, 'pos=?');
                position = readline(obj.filterWheel);
            end
        end
    end
end
