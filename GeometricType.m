classdef GeometricType < handle
    %GEOMETRICTYPE Rotation and position-indepedent geometric type of a prism
    %   This type ensures that two prisms are identical if their radii and 
    %   height are the same

    properties
        radius
        height
        tol = 1e-3;
    end

    methods
        function obj = GeometricType(radius, height)
            %GEOMETRICTYPE Construct an instance of this class

            obj.radius = radius;
            obj.height = height;
        end

        function is_eq = eq(obj,other)
            %EQ Compare equality of two instances of GEOMETRICTYPE
            %   Two instances are considered equal if their radii
            %   and their heights are approximately equal, withing
            %   the absolute tolerance given by the 'tol' property
            is_eq_radius = abs(1-obj.radius/other.radius) < obj.tol;
            is_eq_height = abs(1-obj.height/other.height) < obj.tol;
            is_eq = is_eq_radius && is_eq_height;
        end
    end
end