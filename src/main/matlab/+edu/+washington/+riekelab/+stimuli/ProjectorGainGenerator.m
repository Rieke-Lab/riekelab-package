classdef ProjectorGainGenerator < symphonyui.core.StimulusGenerator
    % Generates a gaussian noise stimulus. This is version 2 of GaussianNoiseGenerator. Version 1 does not apply 
    % multiple filter poles correctly or scale the post-smoothed noise correctly.
    
    properties
        preTime             % Leading duration (ms)
        stimTime            % Noise duration (ms)
        tailTime            % Trailing duration (ms)
        stepDurations        % Duration of gain step (ms)
        gainValues          % Mean amplitude (units)
        upperLimit = 1.8    % Upper bound on signal, signal is clipped to this value (units)
        lowerLimit = -1.8   % Lower bound on signal, signal is clipped to this value (units)
        sampleRate          % Sample rate of generated stimulus (Hz)
        units               % Units of generated stimulus
    end
    
    methods
        
        function obj = ProjectorGainGenerator(map)
            if nargin < 1
                map = containers.Map();
            end
            obj@symphonyui.core.StimulusGenerator(map);
        end
        
    end
    
    methods (Access = protected)
        
        function s = generateStimulus(obj)
            import Symphony.Core.*;
            
            timeToPts = @(t)(round(t / 1e3 * obj.sampleRate));
            
            prePts = timeToPts(obj.preTime);
            stimPts = timeToPts(obj.stimTime);
            tailPts = timeToPts(obj.tailTime);
            stepPts = timeToPts(obj.stepDurations); 
            
            % Set the gain values.
            data = ones(1, prePts + stimPts + tailPts);
            for ii = 1 : length(obj.gainValues)
                if ii == 1
                    idx = 1 : stepPts(1);
                else
                    idx = sum(stepPts(1:ii-1)) + (1:stepPts(ii)); 
                end
                data(idx) = obj.gainValues( ii );
            end
            data = data(1 : prePts + stimPts + tailPts);
            % Force the gain device to go high at beginning and end for the frame monitor.
            data(1 : 33/1000.0*obj.sampleRate) = obj.upperLimit;
            data(end)=obj.upperLimit;
            
            % Clip signal to upper and lower limit.
            data(data > obj.upperLimit) = obj.upperLimit;
            data(data < obj.lowerLimit) = obj.lowerLimit;
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

