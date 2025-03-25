classdef Rat < edu.washington.riekelab.sources.Subject

    methods

        function obj = Rat()
            import symphonyui.core.*;
            import edu.washington.*;

            obj.addProperty('genotype', {}, ...
                'type', PropertyType('cellstr', 'row', {'wild-type'}), ...
                'description', 'Genetic strain');

            photoreceptors = containers.Map();
            photoreceptors('mCone') = struct( ...
                'collectingArea', containers.Map({'photoreceptorSide', 'ganglionCellSide'}, {0.20, 1.00}), ...
                'spectrum', importdata(riekelab.Package.getCalibrationResource('sources', 'mouse', 'm_cone_spectrum.txt')));
            photoreceptors('rod') = struct( ...
                'collectingArea', containers.Map({'photoreceptorSide', 'ganglionCellSide'}, {0.50, 0.87}), ...
                'spectrum', importdata(riekelab.Package.getCalibrationResource('sources', 'mouse', 'rod_spectrum.txt')));
            photoreceptors('sCone') = struct( ...
                'collectingArea', containers.Map({'photoreceptorSide', 'ganglionCellSide'}, {0.20, 1.00}), ...
                'spectrum', importdata(riekelab.Package.getCalibrationResource('sources', 'mouse', 's_cone_spectrum.txt')));
            obj.addResource('photoreceptors', photoreceptors);

            obj.addAllowableParentType([]);
        end

    end

end
