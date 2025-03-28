function out = vecnormalize(in)
    %VECNORMALIZE Return new vector with norm 1 and same orientation as in
    arguments
        in (1,:) double {mustBeFinite}
    end
    if isapprox(norm(in),0.0)
        error("Input to vecnormalize must have non-zero norm")
    end
    out = in ./ norm(in);
end