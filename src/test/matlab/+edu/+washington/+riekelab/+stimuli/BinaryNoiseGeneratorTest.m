classdef BinaryNoiseGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = edu.washington.riekelab.stimuli.BinaryNoiseGenerator();
            gen.preTime = 20;
            gen.stimTime = 520.3;
            gen.tailTime = 22.7;
            gen.segmentTime = 11;
            gen.amplitude = 20;
            gen.mean = -40;
            gen.seed = 1;
            gen.sampleRate = 150;
            gen.units = 'units';
            obj.generator = gen;
        end
        
    end
    
    methods (Test)
        
        function testGenerate(obj)
            import matlab.unittest.constraints.*;
            
            gen = obj.generator;
            stim = gen.generate();
            
            obj.verifyEqual(stim.sampleRate.quantityInBaseUnits, gen.sampleRate);
            obj.verifyEqual(stim.sampleRate.baseUnits, 'Hz');
            obj.verifyEqual(stim.units, gen.units);
            
            timeToPts = @(t)(round(t / 1e3 * gen.sampleRate));
            
            prePts = timeToPts(gen.preTime);
            stimPts = timeToPts(gen.stimTime);
            tailPts = timeToPts(gen.tailTime);
            segmentPts = timeToPts(gen.segmentTime);
            
            [q, u] = stim.getData();
            obj.verifyEqual(length(q), prePts + stimPts + tailPts);
            obj.verifyEveryDoubleElementEqualTo(q(1:prePts), gen.mean);
            
            numSegments = stimPts / segmentPts;
            for i = 1:numSegments
                segmentStartPt = prePts + 1 + (i - 1) * segmentPts;
                segment = q(segmentStartPt:segmentStartPt+segmentPts-1);
                
                obj.verifyThat(segment(1), IsEqualTo(gen.mean + gen.amplitude) | IsEqualTo(gen.mean - gen.amplitude));
                obj.verifyEqual(segment, ones(1, length(segment)) * segment(1));
            end
            
            obj.verifyEveryDoubleElementEqualTo(q(prePts+stimPts+1:end), gen.mean);
            obj.verifyEqual(u, gen.units);
        end
        
    end
    
end

