classdef LedSPDTControl < symphonyui.ui.Module
    
    properties (Access = private)
        log
        settings
        led_switch
        led_names
        ndf
        settingPopupMenu
    end
    
    methods
        
        function obj = LedSPDTControl()
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = edu.washington.riekelab.modules.settings.LedSPDTControlSettings();
        end
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'LED Switch Control', ...
                'Position', screenCenter(200, 50));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            subLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 2);
            Label( ...
                'Parent', subLayout, ...
                'String', 'LED value:');

            obj.settingPopupMenu = MappedPopupMenu( ...
                'Parent', subLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedSetting);
        end
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            devices = obj.configurationService.getDevices('LedSPDTDevice');
            if isempty(devices)
                error('No LED switch device found');
            end
            
            obj.led_switch = devices{1};
            
            % Get the LED names from the SPDT device.
            obj.led_names = obj.led_switch.get_LED_names();
            
            obj.populateSettingList();
            
            % Set to channel one on startup
            obj.led_switch.set_LED(obj.led_names{1});
            set(obj.settingPopupMenu, 'Value', 1);
            
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load settings: ' x.message], x);
            end
        end
        
        function willStop(obj)
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save settings: ' x.message], x);
            end
        end
        
    end
    
    methods (Access = private)
        function populateSettingList(obj)
            positions = {1,2};
            set(obj.settingPopupMenu, 'String', obj.led_names);
            set(obj.settingPopupMenu, 'Values', positions);
        end
        
        function onSelectedSetting(obj, ~, ~)
            position = get(obj.settingPopupMenu, 'Value');
            obj.led_switch.set_LED( obj.led_names{position} );
        end
        
         function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                p1 = obj.view.position;
                p2 = obj.settings.viewPosition;
                obj.view.position = [p2(1) p2(2) p1(3) p1(4)];
            end
        end

        function saveSettings(obj)
            obj.settings.viewPosition = obj.view.position;
            obj.settings.save();
        end
    end
end