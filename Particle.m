classdef (Abstract) Particle < matlab.mixin.Heterogeneous
  %PARTICLE Abstract base class for all extracted particle types.
  %
  % All concrete particle classes must provide these properties and methods.
  % ExtractedPacking, PackingFigureRenderer, and GeometricType depend only
  % on this interface.
  %
  % Using matlab.mixin.Heterogeneous allows a single array to hold mixed
  % subtypes (e.g. Prism and Sphere objects in the same ExtractedPacking).
  %
  % See also PRISM, HEXAGONALPRISM, SPHERE

  properties (Abstract, SetAccess = immutable)
    position     (1,3) double   % centroid in world coordinates
    normal       (1,3) double   % unit axis vector (convention: [0,0,1] for spheres)
    volume       (1,1) double   % scalar volume
    area         (1,1) double   % cross-sectional area
    vertices     (:,3) double   % all surface vertices
    triangulation               % triangulation-compatible object
  end

  methods (Abstract)
    write(obj, filename)        % write geometry to an STL file
    k = colorKey(obj)           % string key used by PackingFigureRenderer
  end

end
