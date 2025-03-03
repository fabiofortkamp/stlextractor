function [x1,y1,z1] = createOrthonormalSystem(z)
% CREATEORTHONORMALSYSTEM Create three orthonormal vectors aligned with input vector
%
%   [x1,y1,z1] = CREATEORTHONORMALSYSTEM(z) returns 3 orthonormal vectors where z1
%       is a normalized version of z.

z1 = vecnormalize(z);
y1 = cross(z1, [1, 0, 0]);
y1 = vecnormalize(y1);
x1 = cross(y1, z1);
x1 = vecnormalize(x1);
end