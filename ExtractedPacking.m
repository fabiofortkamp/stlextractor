classdef ExtractedPacking
    %EXTRACTEDPACKING Packing of particles extracted from some mesh file

    properties (SetAccess = private)
        items (1,:) HexagonalPrism
        
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

    end
end