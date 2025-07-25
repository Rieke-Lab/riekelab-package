classdef FilterWheelControl < symphonyui.ui.Module
    
    properties (Access = private)
        log
        settings
        filterWheel
        ndf
        ndfSettingPopupMenu
    end
    
    methods
        
        function obj = FilterWheelControl()
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = edu.washington.riekelab.modules.settings.FilterWheelControlSettings();
        end
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'ND Wheel Control', ...
                'Position', screenCenter(200, 50));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            filterWheelLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 2);
            Label( ...
                'Parent', filterWheelLayout, ...
                'String', 'NDF value:');

            obj.ndfSettingPopupMenu = MappedPopupMenu( ...
                'Parent', filterWheelLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedNdfSetting);

        end
        
       
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            devices = obj.configurationService.getDevices('FilterWheel');
            if isempty(devices)
                error('No filterWheel device found');
            end
            
            obj.filterWheel = devices{1};
            
            obj.populateNdfSettingList();
            
            % Set the NDF to 4.0 on startup.
            obj.filterWheel.setNDF(4);
            set(obj.ndfSettingPopupMenu, 'Value', 4);
            
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
        function populateNdfSettingList(obj)
            % ndfNums = {0.0, 0.5, 1.0, 2.0, 3.0, 4.0};
            % ndfs = {'0.0', '0.5', '1.0', '2.0', '3.0', '4.0'};
            ndfValues = obj.filterWheel.getNdfValues();
            ndfNums = cell(size(ndfValues));
            ndfs = cell(size(ndfValues));
            for ii = 1 : length(ndfValues)
                ndfNums{ii} = ndfValues(ii);
                ndfs{ii} = num2str(ndfValues(ii));
            end
            
            set(obj.ndfSettingPopupMenu, 'String', ndfs);
            set(obj.ndfSettingPopupMenu, 'Values', ndfNums);
        end
        
        function onSelectedNdfSetting(obj, ~, ~)
            position = get(obj.ndfSettingPopupMenu, 'Value');
            obj.filterWheel.setNDF(position);
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
