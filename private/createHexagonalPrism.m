function prism = createHexagonalPrism(radius, height, orientation, center)
% CREATEHEXAGONALPRISM Generate a prism with given geometric information
%
%   prism = CREATEHEXAGONALPRISM(R,H) creates a prism with given radius R and height H,
%      oriented towards the z-axis and centered in the origin
%   prism = CREATEHEXAGONALPRISM(R,H,N) allows specifies the  normal N of the prism.
%      This vector will be automatically normalized.
%   prism = CREATEHEXAGONALPRISM(R,H,N,C) puts the center at C

% Generated with claude.ai
arguments
  radius (1,1) double {mustBePositive}
  height (1,1) double {mustBePositive}
  orientation (1,3) double {mustBeFinite,mustBeVector} = [0,0,1]
  center (1,3) double {mustBeFinite} = [0,0,0]
end

% Normalize orientation vector
orientation_norm = norm(orientation);
orientation = orientation / orientation_norm;


% Create orthogonal vectors for the orientation
if abs(orientation(3)) < 0.9  % If not close to z-axis
  perpendicular = cross(orientation, [0, 0, 1]);
else
  perpendicular = cross(orientation, [1, 0, 0]);
end

perpendicular = perpendicular / norm(perpendicular);
third_vector = cross(orientation, perpendicular);

% Create vertices for the hexagon in the local coordinate system
angles = linspace(0, 2*pi, 7);  % 7 points (with duplicate for complete loop)
angles = angles(1:6);           % Remove the duplicate

vertices_bottom = zeros(6, 3);
vertices_top = zeros(6, 3);

% Calculate vertices
for i = 1:6
  angle = angles(i);
  x = radius * cos(angle);
  y = radius * sin(angle);

  % Calculate vertex in global coordinate system for bottom face
  vertex_bottom = x * perpendicular + ...
    y * third_vector + ...
    center - (height/2) * orientation;
  vertices_bottom(i, :) = vertex_bottom;

  % Calculate vertex in global coordinate system for top face
  vertex_top = x * perpendicular + ...
    y * third_vector + ...
    center + (height/2) * orientation;
  vertices_top(i, :) = vertex_top;
end

% Combine all vertices
vertices = [vertices_bottom; vertices_top];

% Create triangular faces
faces = zeros(20, 3);  % 8 triangles for top/bottom + 12 for sides

% Bottom face triangles (fan triangulation)
for i = 1:4
  faces(i, :) = [1, i+1, i+2];
end
faces(5, :) = [1, 6, 2];

% Top face triangles (fan triangulation)
for i = 1:4
  faces(5+i, :) = [7, 7+i+1, 7+i];
end
faces(10, :) = [7, 7+1, 7+5];

% Adjust indices for MATLAB's 1-based indexing
faces(1:10, :) = faces(1:10, :);

% Side faces (each rectangular face is made of 2 triangles)
for i = 1:6
  next_i = mod(i, 6) + 1;
  faces(10+2*(i-1)+1, :) = [i, i+6, next_i+6];
  faces(10+2*(i-1)+2, :) = [i, next_i+6, next_i];
end

% Return structure with vertices and faces
prism = struct('vertices', vertices, 'faces', faces);
end