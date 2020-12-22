classdef ProgressFigure < symphonyui.core.FigureHandler
    
    properties (SetAccess = private)
        totalNumEpochs
    end
    
    properties (Access = private)
        numEpochsCompleted
        numIntervalsCompleted
        averageEpochDuration
        averageIntervalDuration
        statusText
        progressBar
        timeText
    end
    
    methods
        
        function obj = ProgressFigure(totalNumEpochs)            
            obj.totalNumEpochs = double(totalNumEpochs);
            obj.numEpochsCompleted = 0;
            obj.numIntervalsCompleted = 0;
            
            obj.createUi();
            
            obj.updateProgress();
        end
        
        function createUi(obj)
            import appbox.*;
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11);
            
            uix.Empty('Parent', mainLayout);
            
            progressLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 5);
            obj.statusText = Label( ...
                'Parent', progressLayout, ...
                'String', '', ...
                'HorizontalAlignment', 'left');
            obj.progressBar = javacomponent(javax.swing.JProgressBar(), [], progressLayout);
            obj.progressBar.setMaximum(obj.totalNumEpochs);
            obj.timeText = Label( ...
                'Parent', progressLayout, ...
                'String', '', ...
                'HorizontalAlignment', 'left');
            set(progressLayout, 'Heights', [23 20 23]);
            
            uix.Empty('Parent', mainLayout);
            
            set(mainLayout, 'Heights', [-1 23+5+20+5+23 -1]);
            
            set(obj.figureHandle, 'Name', 'Progress');
            set(obj.figureHandle, 'Toolbar', 'none');
            
            if isempty(obj.settings.figurePosition)
                p = get(obj.figureHandle, 'Position');
                set(obj.figureHandle, 'Position', [p(1) p(2) p(3) 103]);
            end
        end
        
        function handleEpochOrInterval(obj, epochOrInterval)
            if epochOrInterval.isInterval()
                obj.numIntervalsCompleted = obj.numIntervalsCompleted + 1;
                
                interval = epochOrInterval;
                if isempty(obj.averageIntervalDuration)
                    obj.averageIntervalDuration = interval.duration;
                else
                    obj.averageIntervalDuration = obj.averageIntervalDuration * (obj.numIntervalsCompleted - 1)/obj.numIntervalsCompleted + interval.duration/obj.numIntervalsCompleted;
                end
            else
                obj.numEpochsCompleted = obj.numEpochsCompleted + 1;

                epoch = epochOrInterval;
                if isempty(obj.averageEpochDuration)
                    obj.averageEpochDuration = epoch.duration;
                else
                    obj.averageEpochDuration = obj.averageEpochDuration * (obj.numEpochsCompleted - 1)/obj.numEpochsCompleted + epoch.duration/obj.numEpochsCompleted;
                end
                
                obj.updateProgress();
            end
        end
        
        function clear(obj)            
            obj.numEpochsCompleted = 0;
            obj.numIntervalsCompleted = 0;
            obj.averageEpochDuration = [];
            obj.averageIntervalDuration = [];
            
            obj.updateProgress();
        end
        
        function updateProgress(obj)
            set(obj.statusText, 'String', [num2str(obj.numEpochsCompleted) ' of ' num2str(obj.totalNumEpochs) ' epochs have completed']);
            
            obj.progressBar.setValue(obj.numEpochsCompleted);
            
            timeLeft = '';
            if ~isempty(obj.averageEpochDuration) && ~isempty(obj.averageIntervalDuration)
                n = obj.totalNumEpochs - obj.numEpochsCompleted;
                d = obj.averageEpochDuration * n;
                if n > 0
                    d = d + obj.averageIntervalDuration * n;
                end
                [h, m, s] = hms(d);
                if h >= 1
                    timeLeft = sprintf('%.0f hours, %.0f minutes', h, m);
                elseif m >= 1
                    timeLeft = sprintf('%.0f minutes, %.0f seconds', m, s);
                else
                    timeLeft = sprintf('%.0f seconds', s);
                end
            end
            set(obj.timeText, 'String', sprintf('Estimated time left: %s', timeLeft));
        end
        
    end
    
end
