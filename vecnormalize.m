function out = vecnormalize(in)
    %VECNORMALIZE Return new vector with norm 1 and same orientation as in
    arguments
        in (1,:) double {mustBeFinite}
    end
    STLExtractorError.mustBeNonZeroNorm(in, "input vector");
    out = in ./ norm(in);
end