function mustBeNormalized(v)
tol = 1e-4;
if abs(norm(v,2)-1.0) >= tol
  error("Vector must be normalized")
end
end