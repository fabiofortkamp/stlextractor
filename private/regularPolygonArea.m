function A = regularPolygonArea(n, r)
%REGULARPOLYGONAREA Area of a regular n-gon with circumradius r
%
%   A = REGULARPOLYGONAREA(n, r) returns the area of a regular n-gon
%   whose vertices lie on a circle of radius r.
%
%   For n=6 (hexagon): A = (3/2)*sqrt(3)*r^2

A = (n/2) * r^2 * sin(2*pi/n);
end
