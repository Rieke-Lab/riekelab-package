classdef MicrodisplayControl < symphonyui.ui.Module
    
    properties (Access = private)
        microdisplay
        brightnessPopupMenu
        prerenderCheckbox
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Microdisplay Control', ...
                'Position', screenCenter(250, 75));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            microdisplayLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', microdisplayLayout, ...
                'String', 'Brightness:');
            Label( ...
                'Parent', microdisplayLayout, ...
                'String', 'Prerender:');
            obj.brightnessPopupMenu = MappedPopupMenu( ...
                'Parent', microdisplayLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedBrightness);
            obj.prerenderCheckbox = uicontrol( ...
                'Parent', microdisplayLayout, ...
                'Style', 'checkbox', ...
                'String', '', ...
                'Callback', @obj.onSelectedPrerender);
            
            set(microdisplayLayout, ...
                'Widths', [60 -1], ...
                'Heights', [23 23]);
        end
        
    end
        
    methods (Access = protected)

        function willGo(obj)
            devices = obj.configurationService.getDevices('Microdisplay');
            if isempty(devices)
                error('No Microdisplay device found');
            end
            
            obj.microdisplay = devices{1};
            obj.populateBrightnessList();
            obj.populatePrerenderCheckbox();
        end

    end
    
    methods (Access = private)
        
        function populateBrightnessList(obj)
            import edu.washington.riekelab.devices.MicrodisplayBrightness;
            
            names = {'Minimum', 'Low', 'Medium', 'High', 'Maximum'};
            values = {MicrodisplayBrightness.MINIMUM, MicrodisplayBrightness.LOW, MicrodisplayBrightness.MEDIUM, MicrodisplayBrightness.HIGH, MicrodisplayBrightness.MAXIMUM};
            set(obj.brightnessPopupMenu, 'String', names);
            set(obj.brightnessPopupMenu, 'Values', values);
            
            brightness = obj.microdisplay.getBrightness();
            set(obj.brightnessPopupMenu, 'Value', brightness);
        end
        
        function onSelectedBrightness(obj, ~, ~)
            brightness = get(obj.brightnessPopupMenu, 'Value');
            obj.microdisplay.setBrightness(brightness);
        end
        
        function populatePrerenderCheckbox(obj)
            set(obj.prerenderCheckbox, 'Value', obj.microdisplay.getPrerender());
        end
        
        function onSelectedPrerender(obj, ~, ~)
            prerender = get(obj.prerenderCheckbox, 'Value');
            obj.microdisplay.setPrerender(prerender);
        end
        
    end
    
end
