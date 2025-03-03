function faces = calculateHexagonalPrismFaces

% generated with claude.ai

% This uses fan triangulation to split a list of vertices of an hexagonal prism
% into triangules
% See  https://en.wikipedia.org/wiki/Fan_triangulation

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
end