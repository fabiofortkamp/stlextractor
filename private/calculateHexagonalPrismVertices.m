function vertices = calculateHexagonalPrismVertices(radius,height,orientation,center)
% CALCULATEHEXAGONALPRISMVERTICES Generate matrix of vertices of an hexagonal prism
% V = CALCULATEHEXAGONALPRISMVERTICES(R,H,O,C) calculates a matrix of vertices of
%   an prism with radius R, height H, orientation vector O and centerpoint C.
arguments
    radius (1,1) double {mustBePositive}
    height (1,1) double {mustBePositive}
    orientation (1,3) double {mustBeFinite}
    center (1,3) double {mustBeFinite}
end

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
end