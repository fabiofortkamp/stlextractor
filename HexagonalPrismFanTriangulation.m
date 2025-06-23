classdef HexagonalPrismFanTriangulation
    %HEXAGONALPRISMFANTRIANGULATION Strategy for creating a simple triangulation for
    % a prism from its geometric information

    properties
        Points
        ConnectivityList
    end


    methods
        function obj = HexagonalPrismFanTriangulation(position,radius,thickness,normal)
            %HEXAGONALPRISMFANTRIANGULATION Construct an instance of this class
            arguments
                position (1,3) double
                radius (1,1) double {mustBePositive}
                thickness (1,1) double {mustBePositive}
                normal  (1,3) double {mustBeNormalized}
            end

            obj.Points = zeros([12,3]);
            obj.ConnectivityList = zeros([20,3]);



        end

        % Override isa to return true for triangulation
        function tf = isa(obj, className)
            if strcmp(className, 'triangulation')
                tf = true;
            else
                tf = builtin('isa', obj, className);
            end
        end

    end
end