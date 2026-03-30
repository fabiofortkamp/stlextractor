classdef HexagonalPrism < Prism
  %HEXAGONALPRISM Prism with two hexagonal faces.
  %
  % Backward-compatible subclass of Prism with nSides=6.
  % The 'radius' and 'thickness' properties are Dependent aliases for
  % 'circumradius' and 'height' inherited from Prism.
  %
  % Constructor signature is identical to the original HexagonalPrism.
  %
  % See also PRISM, PARTICLE, HEXAGONALPRISMFANTRIANGULATION

  properties (Dependent)
    radius    % alias for circumradius
    thickness % alias for height
  end

  methods
    function obj = HexagonalPrism(position, radius, thickness, normal, faceRotation, triangulation)
      %HEXAGONALPRISM Construct an instance of this class.
      %
      %   hp = HEXAGONALPRISM(position, radius, thickness, normal)
      %   hp = HEXAGONALPRISM(position, radius, thickness, normal, faceRotation)
      %   hp = HEXAGONALPRISM(position, radius, thickness, normal, faceRotation, triangulation)
      arguments
        position     (1,3) double
        radius       (1,1) double {mustBePositive}
        thickness    (1,1) double {mustBePositive}
        normal       (1,3) double
        faceRotation (1,3) double = [1, 0, 0]
        triangulation = []
      end

      % Use HexagonalPrismFanTriangulation to preserve original vertex ordering
      if isempty(triangulation)
        normalNorm = normal ./ norm(normal);
        triangulation = HexagonalPrismFanTriangulation(position, radius, thickness, normalNorm);
      end

      obj@Prism(position, 6, radius, thickness, normal, faceRotation, triangulation);
    end

    function r = get.radius(obj)
      r = obj.circumradius;
    end

    function t = get.thickness(obj)
      t = obj.height;
    end
  end
end
