classdef HexagonalPrismFanTriangulation
    %HEXAGONALPRISMFANTRIANGULATION Strategy for creating a simple triangulation for
    % a prism from its geometric information

    properties
        Points (12,3) double
        ConnectivityList (20,3) double
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

            position = position(:)';  % Ensure row vector
            normal = normal(:)' / norm(normal);  % Normalize and ensure row vector

            % Create local coordinate system
            % Find two orthogonal vectors perpendicular to normal
            if abs(normal(3)) < 0.9
                u = cross(normal, [0, 0, 1]);
            else
                u = cross(normal, [1, 0, 0]);
            end
            u = u / norm(u);
            v = cross(normal, u);

            % Generate hexagon vertices in local 2D coordinates
            angles = (0:5) * pi/3;  % 60-degree increments
            hexU = radius * cos(angles);
            hexV = radius * sin(angles);



            % Transform hexagon to 3D space
            hex3D = zeros(6, 3);
            for i = 1:6
                hex3D(i, :) = hexU(i) * u + hexV(i) * v;
            end

            % Create vertices for both faces
            offset = (thickness / 2) * normal;
            topFace = hex3D + offset + position;
            bottomFace = hex3D - offset + position;

            % Combine all vertices
            obj.Points = [bottomFace; topFace];  % 12 vertices total



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