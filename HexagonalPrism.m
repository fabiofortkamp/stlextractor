classdef HexagonalPrism
  %HEXAGONALPRISM Representation of a prism with two hexagonal faces

  properties (SetAccess = immutable)
    thickness (1,1) double
    volume (1,1) double
    position (1,3) double 
    radius (1,1) double
    normal (1,3) double
    area (1,1) double
    faceRotation(1,3) double
    vertices (12,3) double
    triangulation
  end

  methods
      function obj = HexagonalPrism(position,radius,thickness,normal,faceRotation,triangulation)
      arguments
        position (1,3) double
        radius (1,1) double {mustBePositive}
        thickness (1,1) double {mustBePositive}
        normal  (1,3) double {mustBeNormalized}
        faceRotation (1,3) double {mustBeNormalized} = [1,0,0]
        triangulation = []
      end
      %HEXAGONALPRISM Construct an instance of this class

      obj.thickness = thickness;
      obj.radius = radius;
      obj.position = position;
      obj.normal = normal;
      obj.area = 3/2*sqrt(3)*obj.radius^2;
      obj.faceRotation = faceRotation;
      obj.volume = obj.area * obj.thickness;

      if isempty(triangulation)
          triangulation = FanTriangulation(position,radius,thickness,normal);
      end

      if ~isa(triangulation,'triangulation')
          msg = ...
              'Invalid triangulation argument passed to HexagonalPrism constructor.';
          error("STLExtractor:HexagonalPrism:inputError",msg);
      end
      obj.triangulation = triangulation;
      obj.vertices = obj.triangulation.Points;
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
