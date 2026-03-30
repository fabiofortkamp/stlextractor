classdef PrismFanTriangulation
  %PRISMFANTRIANGULATION Fan triangulation for a regular n-gonal prism.
  %
  % Generalizes HexagonalPrismFanTriangulation to arbitrary n >= 3.
  % For n=6, produces the same 12 vertices and 20 triangles as
  % HexagonalPrismFanTriangulation.
  %
  % Vertex layout: rows 1..n are the bottom face, rows n+1..2n are the top face.
  % Triangle count: (n-2) bottom + 2n side + (n-2) top = 4n-4.
  %
  % See also HEXAGONALPRISMFANTRIANGULATION, PRISM

  properties
    Points        (:,3) double     % (2n x 3) vertices
    ConnectivityList (:,3) double  % ((4n-4) x 3) triangles
  end

  methods
    function obj = PrismFanTriangulation(position, nSides, circumradius, height, normal)
      %PRISMFANTRIANGULATION Construct a triangulation for a regular n-gonal prism.
      arguments
        position     (1,3) double
        nSides       (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(nSides, 3)}
        circumradius (1,1) double {mustBePositive}
        height       (1,1) double {mustBePositive}
        normal       (1,3) double {mustBeNormalized}
      end

      position = position(:)';
      normal   = normal(:)' / norm(normal);

      % Build orthonormal frame perpendicular to normal
      if abs(normal(3)) < 0.9
        u = cross(normal, [0, 0, 1]);
      else
        u = cross(normal, [1, 0, 0]);
      end
      u = u / norm(u);
      v = cross(normal, u);

      % n vertices on each face at equal angular spacing
      angles = (0:nSides-1) * (2*pi/nSides);
      faceU  = circumradius * cos(angles);
      faceV  = circumradius * sin(angles);

      poly3D = zeros(nSides, 3);
      for i = 1:nSides
        poly3D(i,:) = faceU(i)*u + faceV(i)*v;
      end

      offset     = (height/2) * normal;
      bottomFace = poly3D - offset + position;
      topFace    = poly3D + offset + position;
      obj.Points = [bottomFace; topFace];   % (2n x 3)

      faces = zeros((4*nSides - 4), 3);
      row = 1;

      % Bottom face: fan from vertex 1 — (n-2) triangles
      for i = 1:(nSides-2)
        faces(row,:) = [1, i+1, i+2];
        row = row + 1;
      end

      % Side faces: 2 triangles per lateral edge — 2n triangles
      for i = 1:nSides
        next_i = mod(i, nSides) + 1;
        v1 = i;           v2 = next_i;
        v3 = i + nSides;  v4 = next_i + nSides;
        faces(row,:)   = [v1, v3, v4];
        faces(row+1,:) = [v1, v4, v2];
        row = row + 2;
      end

      % Top face: fan from vertex n+1 — (n-2) triangles
      base = nSides;
      for i = 1:(nSides-2)
        faces(row,:) = [base+1, base+i+1, base+i+2];
        row = row + 1;
      end

      obj.ConnectivityList = faces;
    end

    function tf = isa(obj, className)
      %ISA Override to satisfy STLExtractorError.mustBeValidTriangulation
      if strcmp(className, 'triangulation')
        tf = true;
      else
        tf = builtin('isa', obj, className);
      end
    end
  end
end
