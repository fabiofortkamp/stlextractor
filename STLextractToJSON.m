function STLextractToJSON(input, output, options)
%STLEXTRACTTOJSON Write a JSON file after running STL extraction process on filename
arguments
    input (1,1) string {mustBeFile}
    output (1,1) string
    options.RemoveOutlierRangeZ (1,1) logical = true
    options.OutlierZThreshold (1,1) double = 0.0
    options.Cutoff (1,1) double {mustBeNonnegative} = 0.0
    options.CutoffDirection (1,1) string  = "x"
    options.BoundingBoxLength (1,1) double = NaN
end

e = STLExtractor(input,[],"ShouldSave",false);
ep = e.process( ...
    'RemoveOutlierRangeZ', options.RemoveOutlierRangeZ, ...
    'OutlierZThreshold', options.OutlierZThreshold, ...
    'BoundingBoxLength', options.BoundingBoxLength);
if options.Cutoff > 0
    ep = ep.cutoff(options.Cutoff,options.CutoffDirection);
end
jsonOutput = jsonencode(ep);


f = fopen(output,"w");
fprintf(f,"%s",jsonOutput);
fclose(f);
end