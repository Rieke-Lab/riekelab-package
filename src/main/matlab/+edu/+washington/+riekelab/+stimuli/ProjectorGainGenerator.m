classdef ProjectorGainGenerator < symphonyui.core.StimulusGenerator
    % Generates a gaussian noise stimulus. This is version 2 of GaussianNoiseGenerator. Version 1 does not apply 
    % multiple filter poles correctly or scale the post-smoothed noise correctly.
    
    properties
        preTime             % Leading duration (ms)
        stimTime            % Noise duration (ms)
        tailTime            % Trailing duration (ms)
        stepDuration        % Duration of gain step (ms)
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
            stepPts = timeToPts(obj.stepDuration); %obj.stepDuration * 1e-3 * obj.sampleRate;
            
            % Set the gain values.
            data = ones(1, prePts + stimPts + tailPts);
            for ii = 1 : length(obj.gainValues)
                idx = prePts + ( round((ii-1)*stepPts) : round(ii*stepPts) );
                data(idx) = obj.gainValues( ii );
            end
            data = data(1 : prePts + stimPts + tailPts);
            data(end)=1;
            
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

