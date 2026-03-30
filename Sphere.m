classdef Sphere < Particle
  %SPHERE Representation of a spherical particle.
  %
  % The 'normal' property is set to [0,0,1] by convention — it is required
  % by the Particle interface but has no geometric meaning for a sphere.
  % Alignment statistics computed from 'normal' are not meaningful for
  % packings of spheres.
  %
  % See also PARTICLE, PRISM, HEXAGONALPRISM

  properties (SetAccess = immutable)
    position     (1,3) double
    normal       (1,3) double   % always [0,0,1] by convention
    radius       (1,1) double
    volume       (1,1) double
    area         (1,1) double   % equatorial cross-section: pi*r^2
    vertices     (:,3) double
    triangulation
  end

  methods
    function obj = Sphere(position, radius, triangulation)
      %SPHERE Construct an instance of this class.
      %
      %   s = SPHERE(position, radius, triangulation) creates a sphere with
      %       center at 'position' and circumscribed radius 'radius'.
      arguments
        position     (1,3) double
        radius       (1,1) double {mustBePositive}
        triangulation
      end

      STLExtractorError.mustBeValidTriangulation(triangulation, "Sphere constructor");
      obj.position     = position;
      obj.radius       = radius;
      obj.normal       = [0, 0, 1];
      obj.area         = pi * radius^2;
      obj.volume       = (4/3) * pi * radius^3;
      obj.triangulation = triangulation;
      obj.vertices     = triangulation.Points;
    end

    function write(obj, filename)
      %WRITE Write the sphere triangulation to an STL file.
      stlwrite(obj.triangulation, filename);
    end

    function k = colorKey(obj)
      %COLORKEY Return a unique string key for this sphere type.
      k = sprintf('sphere_r%.6f', obj.radius);
    end
  end
end
