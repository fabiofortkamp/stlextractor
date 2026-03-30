classdef Prism < Particle
  %PRISM Regular n-gonal prism with arbitrary orientation.
  %
  % Parameterized by the number of lateral faces n (n >= 3).
  % For n=6, this describes a hexagonal prism.
  %
  % See also PARTICLE, HEXAGONALPRISM, PRISMFANTRIANGULATION

  properties (SetAccess = immutable)
    position     (1,3) double
    normal       (1,3) double   % unit axis vector
    volume       (1,1) double
    area         (1,1) double   % cross-sectional polygon area
    vertices     (:,3) double
    triangulation
    nSides       (1,1) double   % number of lateral faces
    circumradius (1,1) double   % circumscribed circle radius of the polygon face
    height       (1,1) double   % axial height (distance between the two faces)
    faceRotation (1,3) double   % unit vector: direction from center to first vertex in face plane
  end

  methods
    function obj = Prism(position, nSides, circumradius, height, normal, faceRotation, triangulation)
      %PRISM Construct an instance of this class.
      %
      %   p = PRISM(position, nSides, circumradius, height, normal)
      %   p = PRISM(position, nSides, circumradius, height, normal, faceRotation)
      %   p = PRISM(position, nSides, circumradius, height, normal, faceRotation, triangulation)
      arguments
        position     (1,3) double
        nSides       (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(nSides, 3)}
        circumradius (1,1) double {mustBePositive}
        height       (1,1) double {mustBePositive}
        normal       (1,3) double
        faceRotation (1,3) double = [1, 0, 0]
        triangulation = []
      end

      obj.position  = position;
      obj.nSides    = nSides;
      obj.circumradius = circumradius;
      obj.height    = height;
      STLExtractorError.mustBeNonZeroNorm(normal, "normal");
      obj.normal    = normal ./ norm(normal);
      obj.area      = regularPolygonArea(nSides, circumradius);
      obj.volume    = obj.area * obj.height;
      STLExtractorError.mustBeNonZeroNorm(faceRotation, "faceRotation");
      obj.faceRotation = faceRotation ./ norm(faceRotation);

      if isempty(triangulation)
        triangulation = PrismFanTriangulation(position, nSides, circumradius, height, obj.normal);
      end
      STLExtractorError.mustBeValidTriangulation(triangulation, "Prism constructor");
      obj.triangulation = triangulation;
      obj.vertices = triangulation.Points;
    end

    function write(obj, filename)
      %WRITE Write the prism triangulation to an STL file.
      stlwrite(obj.triangulation, filename);
    end

    function k = colorKey(obj)
      %COLORKEY Return a unique string key for this prism type.
      k = sprintf('n%d_r%.6f_h%.6f', obj.nSides, obj.circumradius, obj.height);
    end
  end
end
