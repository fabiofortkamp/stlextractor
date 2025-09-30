classdef ExtractedPacking < handle
    %EXTRACTEDPACKING Packing of particles extracted from some mesh file

    properties
        renderer (1,1) PackingFigureRenderer
    end

    properties (SetAccess = private)
        items (1,:) HexagonalPrism
        xmin (1,1) double
        xmax (1,1) double
        ymin (1,1) double
        ymax (1,1) double
        zmin (1,1) double
        zmax (1,1) double
        Lx (1,1) double
        Ly (1,1) double
        Lz (1,1) double
        volume (1,1) double
        volumetricFillingFraction (1,1) double
        averageAlignmentX (1,1) double
        standardDeviationAlignmentX (1,1) double
        volumeWeightedAverageAlignmentX (1,1) double
        volumeWeightedStandardDeviationAlignmentX (1,1) double
        averageAlignmentY (1,1) double
        standardDeviationAlignmentY (1,1) double
        volumeWeightedAverageAlignmentY (1,1) double
        volumeWeightedStandardDeviationAlignmentY (1,1) double
        averageAlignmentZ (1,1) double
        standardDeviationAlignmentZ (1,1) double
        volumeWeightedAverageAlignmentZ (1,1) double
        volumeWeightedStandardDeviationAlignmentZ (1,1) double
    end



    methods
        function obj = ExtractedPacking(prisms,options)
            %EXTRACTEDPACKING Construct an instance of this class
            %
            %   ep = EXTRACTEDPACKING(prisms) will create a packing from a given
            %       array of HEXAGONALPRISM objects. By default, the extracted packing
            %       will filter out the prisms whose z-position is less than zero.
            %
            %       This behavious can be disabled by passing the "RemoveOutlierRangez"
            %       as false. The actual value of z below which prisms will be removed
            %       can be set with the "OutlierZThreshold" option.
            arguments
                prisms (1,:) HexagonalPrism
                options.RemoveOutlierRangeZ (1,1) logical = false
                options.OutlierZThreshold (1,1) double = 0
                options.BoundingBoxLength (1,1) double = NaN
            end
            obj.items = prisms;
            obj.initializeLimitsAndStatistics;
            obj.renderer = PackingFigureRenderer;

            if options.RemoveOutlierRangeZ
                if obj.zmin < options.OutlierZThreshold
                    obj = obj.filterPacking("z",options.OutlierZThreshold,obj.zmax);
                end
            end

            % apply bounding box length filter
            if ~isnan(options.BoundingBoxLength)
                xlim = options.BoundingBoxLength/2;
                if (obj.xmax > xlim) || (obj.xmin < -xlim)
                    obj = obj.filterPacking("x",-xlim,xlim);
                end
                % we can use the same xlim for y, because we assume
                % that the packing is roughly cubic
                if (obj.ymax > xlim) || (obj.ymin < -xlim)
                    obj = obj.filterPacking("y",-xlim,xlim);
                end
            end
        end

        function outputArg = length(obj)
            %LENGTH Return the number of extracted particles
            %   Detailed explanation goes here
            outputArg = length(obj.items);
        end


        function f = plot(obj)
            %PLOTPARTICLES Plot a rendering of the packing.

            % change width and height
            % from: https://se.mathworks.com/help/releases/R2024b/matlab/ref/figure.html#bvjs6cb-3

            f = figure;
            f.Units = "centimeters";
            f.Position(3:4) = [16,9];
            r = obj.renderer;
            hold on

            axis equal
            light('position',[2,2,2])
            view(30,30) ;
            xlabel("x");
            ylabel("y");
            zlabel("z");

            for i = 1:length(obj)
                hp = obj.items(i);
                TR = hp.triangulation;
                T = TR.ConnectivityList;
                P = TR.Points;
                trisurf(T,P(:,1),P(:,2),P(:,3),"FaceColor",r.colorOf(hp),'linestyle','none','facealpha',1)
            end

            hold off

        end



        function ep = cutoff(obj,margin,startDirection,options)
            %CUTOFF Create cutoff of another packing, starting by subtracting a margin
            % from startDirection.
            arguments
                obj 
                margin (1,1) double % Fraction of the side length to remove
                startDirection (1,1) string {mustBeMember(startDirection, ["x","y","z"])} = "x" % From which direction to start cutting
                options.Method (1,1) string {mustBeMember(options.Method, ["vertices", "centers"])} = "vertices"; % Method to use to select items to cut. If "vertices", items with any vertice that is beyond the cutplane are removed; if "centers", then only items whose center are beyond the cut planes are removed.
            end

            switch startDirection
                case "x"
                    Lnew = obj.Lx*(1-margin);
                case "y"
                    Lnew = obj.Ly*(1-margin);
                case "z"
                    Lnew = obj.Lz*(1-margin);
                otherwise
                    STLExtractorError.throwError('ExtractedPacking', 'InvalidDirection', ...
                        'Unrecognized direction to start cutoff process')
            end

            dx = (obj.Lx - Lnew)/2;
            dy = (obj.Ly - Lnew)/2;
            dz = (obj.Lz - Lnew)/2;


            xmaxpost = obj.xmax - dx;
            xminpost = obj.xmin + dx;
            ymaxpost = obj.ymax - dy;
            yminpost = obj.ymin + dy;
            zmaxpost = obj.zmax - dz;
            zminpost = obj.zmin + dz;



            ep = filterPacking(obj,"x",xminpost,xmaxpost, "Method",options.Method);
            ep = filterPacking(ep,"y",yminpost,ymaxpost, "Method",options.Method);
            ep = filterPacking(ep,"z",zminpost,zmaxpost, "Method",options.Method);



        end

        function ep = cutoffz(obj,options)
            %CUTOFFZ Create cutoff of packing by trimming in the z-direction to make it cube-like.
            arguments
                obj 
                options.Method (1,1) string {mustBeMember(options.Method, ["vertices", "centers"])} = "vertices"; % Method to use to select items to cut. If "vertices", items with any vertice that is beyond the cutplane are removed; if "centers", then only items whose center are beyond the cut planes are removed.
            end
            Lznew = 0.5*(obj.Lx + obj.Ly);

            dz = (obj.Lz - Lznew)/2;

            zmaxpost = obj.zmax - dz;
            zminpost = obj.zmin + dz;

            ep = filterPacking(obj,"z",zminpost,zmaxpost,"Method",options.Method);

        end

    end

    methods (Access = private)

        function initializeLimitsAndStatistics(obj)
            % INITIALIZELIMITS Define the i-{min,max} attributes (e.g. "xmin","ymax" etc)

            % 12 because there 2 faces of 6 vertices in each prism;
            nVertices = 12 * length(obj);
            xvalues = zeros(1,nVertices);
            yvalues = zeros(1,nVertices);
            zvalues = zeros(1,nVertices);

            for iPrism = 1:length(obj)
                hp = obj.items(iPrism);
                idxmin = 12*(iPrism-1)+1;
                idxmax = 12*(iPrism-1)+12;
                xvalues(idxmin:idxmax) = hp.vertices(:,1);
                yvalues(idxmin:idxmax) = hp.vertices(:,2);
                zvalues(idxmin:idxmax) = hp.vertices(:,3);

            end

            obj.xmin = min(xvalues);
            obj.xmax = max(xvalues);
            obj.ymin = min(yvalues);
            obj.ymax = max(yvalues);
            obj.zmin = min(zvalues);
            obj.zmax = max(zvalues);
            obj.Lx = obj.xmax - obj.xmin;
            obj.Ly = obj.ymax - obj.ymin;
            obj.Lz = obj.zmax - obj.zmin;
            obj.volume = obj.Lx * obj.Ly * obj.Lz;

            volumes = arrayfun(@(hp) hp.volume,obj.items);
            prismsVolume = sum(volumes);

            obj.volumetricFillingFraction = prismsVolume/obj.volume;

            obj.averageAlignmentX = obj.averageAlignment("x");
            obj.standardDeviationAlignmentX = obj.standardDeviationAlignment("x");
            obj.volumeWeightedAverageAlignmentX = obj.volumeWeightedAverageAlignment("x");
            obj.volumeWeightedStandardDeviationAlignmentX = obj.volumeWeightedStandardDeviationAlignment("x");

            obj.averageAlignmentY = obj.averageAlignment("y");
            obj.standardDeviationAlignmentY = obj.standardDeviationAlignment("y");
            obj.volumeWeightedAverageAlignmentY = obj.volumeWeightedAverageAlignment("y");
            obj.volumeWeightedStandardDeviationAlignmentY = obj.volumeWeightedStandardDeviationAlignment("y");

            obj.averageAlignmentZ = obj.averageAlignment("z");
            obj.standardDeviationAlignmentZ = obj.standardDeviationAlignment("z");
            obj.volumeWeightedAverageAlignmentZ = obj.volumeWeightedAverageAlignment("z");
            obj.volumeWeightedStandardDeviationAlignmentZ = obj.volumeWeightedStandardDeviationAlignment("z");

        end

        function ep = filterPacking(obj,direction,vmin,vmax,options)
           arguments
                obj 
                direction (1,1) string {mustBeMember(direction, ["x","y","z"])} = "x"; % From which direction to start cutting
                vmin (1,1) double = 0; % minimum value of the "direction" above, above which items will remain
                vmax (1,1) double = 0; % maximum value of the "direction" above, below which items will remain
                options.Method (1,1) string {mustBeMember(options.Method, ["vertices", "centers"])} = "vertices"; % Method to use to select items to cut. If "vertices", items with any vertice that is beyond the cutplane are removed; if "centers", then only items whose center are beyond the cut planes are removed.
            end
            pre = obj.items;
            nHexagons = numel(pre);
            hexagonPositionsMin = zeros(nHexagons,3);
            hexagonPositionsMax = zeros(nHexagons,3);
            for iPrism = 1:length(obj)
                hp = obj.items(iPrism);
                for j = [1,2,3]
                    if strcmp(options.Method, "vertices")
                        hexagonPositionsMin(iPrism,j) = min(hp.vertices(:,j));
                        hexagonPositionsMax(iPrism,j) = max(hp.vertices(:,j));
                    else
                       % For the 'centers' method, both min and max are set to the center position.
                       % This allows the filtering logic to work uniformly for both methods.
                       hexagonPositionsMin(iPrism,j) = hp.position(j);
                       hexagonPositionsMax(iPrism,j) = hp.position(j);
                    end
                end
            end

            switch direction
                case "x"
                    ax = 1;
                case "y"
                    ax = 2;
                case "z"
                    ax = 3;
            end
            indx = find(hexagonPositionsMin(:,ax) >= vmin & hexagonPositionsMax(:,ax) <= vmax);
            if isempty(indx)
                STLExtractorError.throwError('ExtractedPacking', 'NoParticlesInRange', ...
                    sprintf('No particles found in the specified %s range (%.3g, %.3g).', direction, vmin, vmax));
            end
            nl = pre(indx);
            ep = ExtractedPacking(nl,"RemoveOutlierRangeZ",false);
        end

        function out = averageAlignment(obj,direction)
            % AVERAGEALIGNMENT Compute mean of alignments of items along given direction
            v = getDirectionVector(direction);
            alignments = arrayfun(@(hp) dot(hp.normal,v),obj.items);
            out = mean(alignments);
        end

        function out = standardDeviationAlignment(obj,direction)
            % STANDARDDEVIATIONALIGNMENT Compute standard deviation of alignments of items along
            % given direction
            v = getDirectionVector(direction);
            alignments = arrayfun(@(hp) dot(hp.normal,v),obj.items);
            out = std(alignments);
        end

        function out = volumeWeightedAverageAlignment(obj,direction)
            % VOLUMEWEIGHTEDAVERAGEALIGNMENT Compute mean of alignments of items along
            % given direction, weighted by the volume of each item
            v = getDirectionVector(direction);
            alignments = arrayfun(@(hp) dot(hp.normal,v),obj.items);
            weights = arrayfun(@(hp) hp.volume,obj.items);
            % we need the conversion factor below because our definition
            % use the cube volume, and not the total volume, in the
            % denominator
            out = mean(alignments,"Weights",weights)*obj.volumetricFillingFraction;
        end

        function out = volumeWeightedStandardDeviationAlignment(obj,direction)
            % VOLUMEWEIGHTEDSTANDARDDEVIATIONALIGNMENT Compute mean of alignments of
            % items along given direction, weighted by the volume of each item
            v = getDirectionVector(direction);
            alignments = arrayfun(@(hp) dot(hp.normal,v),obj.items);
            weights = arrayfun(@(hp) hp.volume,obj.items);
            % we need the conversion factor below because our definition
            % use the cube volume, and not the total volume, in the
            % denominator
            out = std(alignments,weights)*sqrt(obj.volumetricFillingFraction);
        end
    end


end


