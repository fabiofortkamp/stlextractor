classdef ExtractedPacking
    %EXTRACTEDPACKING Packing of particles extracted from some mesh file

    properties
        items (1,:) HexagonalPrism
    end

    methods
        function obj = ExtractedPacking(prisms)
            %EXTRACTEDPACKING Construct an instance of this class from array of prisms
            arguments
                prisms (1,:) HexagonalPrism
            end
            obj.items = prisms;
        end

        function outputArg = length(obj)
            %LENGTH Return the number of extracted particles 
            %   Detailed explanation goes here
            outputArg = length(obj.items);
        end
    end
end