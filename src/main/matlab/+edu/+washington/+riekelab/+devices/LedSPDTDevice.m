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

      obj.switchPosition = 'closed';
      obj.ledNames = ip.Results.ledNames;
      
      obj.addConfigurationSetting('switchPosition', obj.switchPosition);
      obj.addConfigurationSetting('ledNames', ip.Results.ledNames);
      obj.addConfigurationSetting('selectedLED', ip.Results.ledNames{1});
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

      function throw_switch(obj, led_name)
          fprintf(obj.spdt_switch, 'relay -n 1 -s on');
          obj.wheelPosition = position;
      end
      
  end
end
