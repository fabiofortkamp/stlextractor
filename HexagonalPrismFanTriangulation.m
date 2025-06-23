classdef HexagonalPrismFanTriangulation
    %HEXAGONALPRISMFANTRIANGULATION Strategy for creating a simple triangulation for 
    % a prism from its geometric information

    methods
        function obj = HexagonalPrismFanTriangulation(position,radius,thickness,normal)
            %HEXAGONALPRISMFANTRIANGULATION Construct an instance of this class
            arguments
                position (1,3) double
                radius (1,1) double {mustBePositive}
                thickness (1,1) double {mustBePositive}
                normal  (1,3) double {mustBeNormalized}
            end

        end

    end
end