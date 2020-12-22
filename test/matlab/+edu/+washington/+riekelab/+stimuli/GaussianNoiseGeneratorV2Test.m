classdef GaussianNoiseGeneratorV2Test < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = edu.washington.riekelab.stimuli.GaussianNoiseGeneratorV2();
            gen.preTime = 20;
            gen.stimTime = 520.7;
            gen.tailTime = 22.7;
            gen.stDev = 2;
            gen.mean = 1;
            gen.freqCutoff = 60;
            gen.numFilters = 0;
            gen.seed = 1;
            gen.sampleRate = 10000;
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
            
            [q, u] = stim.getData();
            obj.verifyEqual(length(q), prePts + stimPts + tailPts);
            obj.verifyEveryDoubleElementEqualTo(q(1:prePts), gen.mean);
            %obj.verifyEqual(chi2gof(q(prePts+1:prePts+stimPts)), 0);
            obj.verifyEveryDoubleElementEqualTo(q(prePts+stimPts+1:end), gen.mean);
            obj.verifyEqual(u, gen.units);
        end
        
        function testGenerateStDev(obj)
            gen = obj.generator;
            gen.numFilters = 4;
            
            timeToPts = @(t)(round(t / 1e3 * gen.sampleRate));
            
            prePts = timeToPts(gen.preTime);
            stimPts = timeToPts(gen.stimTime);
            
            avgStDev = [];
            for i = 1:50
                gen.seed = randi(intmax);
                
                stim = gen.generate();
                
                q = stim.getData();
                s = std(q(prePts+1:prePts+stimPts));
                if isempty(avgStDev)
                    avgStDev = s;
                else
                    avgStDev = avgStDev + ((s - avgStDev) / i);
                end
            end
            
            obj.verifyEqual(avgStDev, gen.stDev, 'RelTol', 0.05);
        end
        
        function testRegenerate(obj)
            gen1 = obj.generator;
            stim1 = gen1.generate();
            q1 = stim1.getData();
            
            gen2 = edu.washington.riekelab.stimuli.GaussianNoiseGeneratorV2(gen1.propertyMap);
            stim2 = gen2.generate();
            q2 = stim2.getData();
            
            obj.verifyEqual(q1, q2);
        end
        
    end
    
end

