classdef HexagonalPrism
    %HEXAGONALPRISM Representation of a prism with two hexagonal faces

    properties (SetAccess = immutable)
        thickness (1,1) double {mustBePositive}
        volume (1,1) double {mustBePositive}
        position (1,3) double 
        radius (1,1) double {mustBePositive}
        normal (1,3) double {mustBeNormalized}
        area (1,1) double {mustBePositive}
    end

    properties (Access = private)
        triangulation
    end
    
    methods
        function obj = HexagonalPrism(position,radius,thickness,normal)
            arguments
                position (1,3) double
                radius (1,1) double {mustBePositive}
                thickness (1,1) double {mustBePositive}
                normal  (1,3) double {mustBeNormalized}
            end
            %HEXAGONALPRISM Construct an instance of this class

            obj.thickness = thickness;
            obj.radius = radius;
            obj.position = position;
            obj.normal = normal;
            obj.area = 3/2*sqrt(3)*obj.radius^2;
            obj.volume = obj.area * obj.thickness;
        end

        function write(obj,filename)
            %WRITE Write the object triangulation to the filename STL file.

            stlwrite(obj.triangulation,filename)
        end
    end
end

function mustBeNormalized(v)
tol = 1e-4;
if abs(norm(v,2)-1.0) >= tol
    error("Vector must be normalized")
end
end