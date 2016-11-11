classdef LightCrafterControl < symphonyui.ui.Module
    
    properties (Access = private)
        log
        settings
        lightCrafter
        ledEnablesCheckboxes
        patternRatePopupMenu
        prerenderCheckbox
    end
    
    methods
        
        function obj = LightCrafterControl()
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = edu.washington.riekelab.modules.settings.LightCrafterControlSettings();
        end
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'LightCrafter Control', ...
                'Position', screenCenter(320, 105), ...
                'Resize', 'off');
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            lightCrafterLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', lightCrafterLayout, ...
                'String', 'LED enables:');
            Label( ...
                'Parent', lightCrafterLayout, ...
                'String', 'Pattern rate:');
            Label( ...
                'Parent', lightCrafterLayout, ...
                'String', 'Prerender:');
            ledEnablesLayout = uix.HBox( ...
                'Parent', lightCrafterLayout, ...
                'Spacing', 3);
            obj.ledEnablesCheckboxes.auto = uicontrol( ...
                'Parent', ledEnablesLayout, ...
                'Style', 'checkbox', ...
                'String', 'Auto', ...
                'Callback', @obj.onSelectedLedEnable);
            obj.ledEnablesCheckboxes.red = uicontrol( ...
                'Parent', ledEnablesLayout, ...
                'Style', 'checkbox', ...
                'HorizontalAlignment', 'left', ...
                'String', 'Red', ...
                'Callback', @obj.onSelectedLedEnable);
            obj.ledEnablesCheckboxes.green = uicontrol( ...
                'Parent', ledEnablesLayout, ...
                'Style', 'checkbox', ...
                'HorizontalAlignment', 'left', ...
                'String', 'Green', ...
                'Callback', @obj.onSelectedLedEnable);
            obj.ledEnablesCheckboxes.blue = uicontrol( ...
                'Parent', ledEnablesLayout, ...
                'Style', 'checkbox', ...
                'HorizontalAlignment', 'left', ...
                'String', 'Blue', ...
                'Callback', @obj.onSelectedLedEnable);
            obj.patternRatePopupMenu = MappedPopupMenu( ...
                'Parent', lightCrafterLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedPatternRate);
            obj.prerenderCheckbox = uicontrol( ...
                'Parent', lightCrafterLayout, ...
                'Style', 'checkbox', ...
                'String', '', ...
                'Callback', @obj.onSelectedPrerender);
            
            set(lightCrafterLayout, ...
                'Widths', [70 -1], ...
                'Heights', [23 23 23]);
        end
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            devices = obj.configurationService.getDevices('LightCrafter');
            if isempty(devices)
                error('No LightCrafter device found');
            end
            
            obj.lightCrafter = devices{1};
            
            obj.populateLedEnablesCheckboxes();
            obj.populatePatternRateList();
            obj.populatePrerenderCheckbox();
            
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
        
        function populateLedEnablesCheckboxes(obj)
            [auto, red, green, blue] = obj.lightCrafter.getLedEnables();
            set(obj.ledEnablesCheckboxes.auto, 'Value', auto);
            set(obj.ledEnablesCheckboxes.red, 'Value', red);
            set(obj.ledEnablesCheckboxes.green, 'Value', green);
            set(obj.ledEnablesCheckboxes.blue, 'Value', blue);
        end
        
        function onSelectedLedEnable(obj, ~, ~)
            auto = get(obj.ledEnablesCheckboxes.auto, 'Value');
            red = get(obj.ledEnablesCheckboxes.red, 'Value');
            green = get(obj.ledEnablesCheckboxes.green, 'Value');
            blue = get(obj.ledEnablesCheckboxes.blue, 'Value');
            obj.lightCrafter.setLedEnables(auto, red, green, blue);
        end
        
        function populatePatternRateList(obj)
            rates = obj.lightCrafter.availablePatternRates();
            names = cellfun(@(r)[num2str(r) ' Hz'], rates, 'UniformOutput', false); 
            
            set(obj.patternRatePopupMenu, 'String', names);
            set(obj.patternRatePopupMenu, 'Values', rates);
            
            set(obj.patternRatePopupMenu, 'Value', obj.lightCrafter.getPatternRate());
        end
        
        function onSelectedPatternRate(obj, ~, ~)
            rate = get(obj.patternRatePopupMenu, 'Value');
            obj.lightCrafter.setPatternRate(rate);
        end
        
        function populatePrerenderCheckbox(obj)
            set(obj.prerenderCheckbox, 'Value', obj.lightCrafter.getPrerender());
        end
        
        function onSelectedPrerender(obj, ~, ~)
            prerender = get(obj.prerenderCheckbox, 'Value');
            obj.lightCrafter.setPrerender(prerender);
        end
        
        function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                obj.view.position = obj.settings.viewPosition;
            end
        end

        function saveSettings(obj)
            obj.settings.viewPosition = obj.view.position;
            obj.settings.save();
        end
        
    end
    
end

