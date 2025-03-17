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

vertices = calculateHexagonalPrismVertices(radius,height,orientation,center);

faces = calculateHexagonalPrismFaces;

% Return structure with vertices and faces
prism = struct('vertices', vertices, 'faces', faces);
end