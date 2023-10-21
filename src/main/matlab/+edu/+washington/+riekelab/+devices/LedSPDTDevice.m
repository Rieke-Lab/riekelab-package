% Device class for controlling custom single-pole double-throw switch (SPDT).
classdef LedSPDTDevice < symphonyui.core.Device
    properties (Access = private)
        spdt_switch
        switchPosition
        ledNames
        isOpen
    end

    methods
        function obj = LedSPDTDevice(varargin)
            ip = inputParser();
            ip.addParameter('comPort', 'COM3', @ischar);
            ip.addParameter('ledNames', {'Green_570nm','Green_505nm'}, @iscell);
            ip.parse(varargin{:});

            cobj = Symphony.Core.UnitConvertingExternalDevice('LedSPDTDevice', 'Custom', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
            obj@symphonyui.core.Device(cobj);
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;

            obj.ledNames = ip.Results.ledNames;
            obj.switchPosition = 1;
            
            % Try to connect.
            obj.connect(ip.Results.comPort);
            if obj.isOpen
                obj.set_LED( obj.ledNames{ obj.switchPosition } );
            end

            obj.addConfigurationSetting('switchPosition', obj.switchPosition);
            obj.addConfigurationSetting('ledNames', obj.ledNames);
            obj.addConfigurationSetting('selectedLED', obj.ledNames{obj.switchPosition});
        end

        function connect(obj, comPort)
              try 
                  obj.spdt_switch = serial(comPort, 'BaudRate', 115200, 'DataBits', 8, 'StopBits', 1, 'Terminator', 'CR');
                  fopen(obj.spdt_switch);
                  obj.isOpen = true;
              catch
                  obj.isOpen = false;
              end
          end

          function close(obj)
              if obj.isOpen
                  fclose(obj.spdt_switch);
                  obj.isOpen = false;
              end
          end
          
          function names = get_LED_names(obj)
              names = obj.ledNames;
          end

          function set_LED(obj, led_name)
              % Check the index of the target LED.
              [tf, index] = ismember(led_name,obj.ledNames);
              if tf
                  if obj.switchPosition ~= index
                      % Switch both the anode and cathode switches.
                      if index == 1
                          fprintf(obj.spdt_switch, 'relays -s off');
%                           fprintf(obj.spdt_switch, 'relay -n 1 -s off');
%                           fprintf(obj.spdt_switch, 'relay -n 2 -s off');
                      else
                          fprintf(obj.spdt_switch, 'relays -s on');
%                           fprintf(obj.spdt_switch, 'relay -n 1 -s on');
%                           fprintf(obj.spdt_switch, 'relay -n 2 -s on');
                      end
                      obj.switchPosition = index;

                      obj.setReadOnlyConfigurationSetting('switchPosition', obj.switchPosition);
                      obj.setReadOnlyConfigurationSetting('selectedLED', obj.ledNames{obj.switchPosition});
                  end
              end
          end

    end
end
