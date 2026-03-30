classdef GeometricType < handle
  %GEOMETRICTYPE Rotation and position-independent geometric type of a particle.
  %
  % Two particles are considered the same type if their radii and heights are
  % approximately equal (within relative tolerance 'tol') and their shape
  % descriptors match.
  %
  % The optional 'shapeDescriptor' field distinguishes between shapes that
  % happen to share the same size dimensions (e.g. a triangular prism vs a
  % hexagonal prism of equal circumradius and height).
  %
  % Convention for spheres: height = 0, shapeDescriptor = "sphere".

  properties
    radius
    height
    shapeDescriptor (1,1) string = ""
    tol = 1e-3;
  end

  methods
    function obj = GeometricType(radius, height, shapeDescriptor)
      %GEOMETRICTYPE Construct an instance of this class.
      arguments
        radius          (1,1) double
        height          (1,1) double
        shapeDescriptor (1,1) string = ""
      end

      obj.radius          = radius;
      obj.height          = height;
      obj.shapeDescriptor = shapeDescriptor;
    end

    function is_eq = eq(obj, other)
      %EQ Compare equality of two instances of GEOMETRICTYPE.

      % Shape descriptor must agree (empty descriptor is a wildcard)
      is_eq_shape = obj.shapeDescriptor == "" || ...
                    other.shapeDescriptor == "" || ...
                    obj.shapeDescriptor == other.shapeDescriptor;

      if ~is_eq_shape
        is_eq = false;
        return;
      end

      is_eq_radius = abs(1 - obj.radius/other.radius) < obj.tol;

      % Height = 0 is the sentinel for shapes with no axial dimension (spheres).
      % Two such shapes are equal in height iff both have height = 0.
      if obj.height == 0 || other.height == 0
        is_eq_height = (obj.height == other.height);
      else
        is_eq_height = abs(1 - obj.height/other.height) < obj.tol;
      end

      is_eq = is_eq_radius && is_eq_height;
    end
  end
end
