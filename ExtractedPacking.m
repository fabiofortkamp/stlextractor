classdef ExtractedPacking < handle
    %EXTRACTEDPACKING Packing of particles extracted from some mesh file

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

    properties (Access = private)
        triangulations (1,:)
    end


    methods
        function obj = ExtractedPacking(prisms, triangulations)
            %EXTRACTEDPACKING Construct an instance of this class
            arguments
                prisms (1,:) HexagonalPrism
                triangulations
            end
            obj.items = prisms;
            obj.triangulations = triangulations;
            obj.initializeLimitsAndStatistics;
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
            hold on

            axis equal
            light('position',[2,2,2])
            view(30,30) ;
            xlabel("x");
            ylabel("y");
            zlabel("z");

            for i = 1:length(obj)
                TR = obj.triangulations{i};
                T = TR.ConnectivityList;
                P = TR.Points;
                trisurf(T,P(:,1),P(:,2),P(:,3),"FaceColor","blue",'linestyle','none','facealpha',1)
            end

            hold off

        end



        function ep = cutoff(obj,margin,startDirection)
            %CUTOFF Create cutoff of another packing, starting by subtracting a margin
            % from startDirection


            switch startDirection
                case "x"
                    Lnew = obj.Lx*(1-margin);
                case "y"
                    Lnew = obj.Ly*(1-margin);
                case "z"
                    Lnew = obj.Lz*(1-margin);
                otherwise
                    error("Unrecognized direction to start cutoff process")
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



            ep = filterPacking(obj,"x",xminpost,xmaxpost);
            ep = filterPacking(ep,"y",yminpost,ymaxpost);
            ep = filterPacking(ep,"z",zminpost,zmaxpost);



        end

    end

    methods (Access = private)

        function initializeLimitsAndStatistics(obj)
            % INITIALIZELIMITS Define the i-{min,max} attributes (e.g. "xmin","ymax" etc)

            % map through the items to get the position coordinates
            % hp = HexagonalPrism instance

            xvalues = arrayfun(@(hp) hp.position(1),obj.items);
            yvalues = arrayfun(@(hp) hp.position(2),obj.items);
            zvalues = arrayfun(@(hp) hp.position(3),obj.items);

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

        function ep = filterPacking(obj,direction,vmin,vmax)
            pre = obj.items;
            nHexagons = numel(pre);
            hexagonPositions = zeros(nHexagons,3);
            for i = 1:nHexagons
                hexagonPositions(i,:) = pre(i).position;
            end
            switch direction
                case "x"
                    ax = 1;
                case "y"
                    ax = 2;
                case "z"
                    ax = 3;
            end
            indx = find(hexagonPositions(:,ax) > vmin & hexagonPositions(:,ax) < vmax);
            nl = pre(indx);
            ntr = obj.triangulations(indx);
            ep = ExtractedPacking(nl,ntr);
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
            alignments = arrayfun(@(hp) hp.volume*dot(hp.normal,v),obj.items);
            out = mean(alignments);
        end

        function out = volumeWeightedStandardDeviationAlignment(obj,direction)
            % VOLUMEWEIGHTEDSTANDARDDEVIATIONALIGNMENT Compute mean of alignments of
            % items along given direction, weighted by the volume of each item
            v = getDirectionVector(direction);
            alignments = arrayfun(@(hp) hp.volume*dot(hp.normal,v),obj.items);
            out = std(alignments);
        end
    end


end


