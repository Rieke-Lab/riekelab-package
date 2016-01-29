classdef Calibrator < symphonyui.ui.Module
    
    properties (Access = private)
        deviceListBox
        detailCardPanel
        ledCard
    end
    
    methods     
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Calibrator', ...
                'Position', screenCenter(350, 200));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            masterLayout = uix.VBox( ...
                'Parent', mainLayout);
            
            obj.deviceListBox = MappedListBox( ...
                'Parent', masterLayout, ...
                'Callback', @obj.onSelectedDevice);
            
            detailLayout = uix.VBox( ...
                'Parent', mainLayout);

            obj.detailCardPanel = uix.CardPanel( ...
                'Parent', detailLayout);
            
            % LED card.
            ledLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            ledGrid = uix.Grid( ...
                'Parent', ledLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', ledGrid, ...
                'String', 'Name:');
            Label( ...
                'Parent', ledGrid, ...
                'String', 'Calibrated:');
            uix.Empty('Parent', ledGrid);
            obj.ledCard.nameField = uicontrol( ...
                'Parent', ledGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ....
                'HorizontalAlignment', 'left');
            obj.ledCard.calibratedField = uicontrol( ...
                'Parent', ledGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ....
                'HorizontalAlignment', 'left');
            uix.Empty('Parent', ledGrid);
            set(ledGrid, ...
                'Widths', [60 -1], ...
                'Heights', [23 23 -1]);
            
            ledControlsLayout = uix.HBox( ...
                'Parent', ledLayout, ...
                'Spacing', 2);
            uix.Empty('Parent', ledControlsLayout);
            obj.ledCard.acceptButton = uicontrol( ...
                'Parent', ledControlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Accept', ...
                'Interruptible', 'off');
            obj.ledCard.calibrateButton = uicontrol( ...
                'Parent', ledControlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Calibrate', ...
                'Interruptible', 'off');
            set(ledControlsLayout, 'Widths', [-1 75 75]);
            
            set(ledLayout, 'Heights', [-1 23]);
            
            
            set(mainLayout, 'Widths', [-1 -2]);
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateDeviceList();
        end
        
    end
    
    methods (Access = private)
        
        function populateDeviceList(obj)
            devices = obj.configurationService.getDevices('LED');
            names = cellfun(@(d)d.name, devices, 'UniformOutput', false);
            set(obj.deviceListBox, 'String', names);
            set(obj.deviceListBox, 'Values', devices);
            
            if ~isempty(devices)
                obj.populateDetailsWithDevice(devices{1});
            end
        end
        
        function onSelectedDevice(obj, ~, ~)
            devices = get(obj.deviceListBox, 'Value');
            device = devices{1};
            obj.populateDetailsWithDevice(device);
        end
        
        function populateDetailsWithDevice(obj, device)
            obj.populateDetailsWithLed(device);
        end
        
        function populateDetailsWithLed(obj, led)
            set(obj.ledCard.nameField, 'String', led.name);
        end
        
    end
    
end

