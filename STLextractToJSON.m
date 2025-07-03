function STLextractToJSON(input, output, cutoff, cutoffDirection)
%STLEXTRACTTOJSON Write a JSON file after running STL extraction process on filename
arguments
    input (1,1) string {mustBeFile}
    output (1,1) string
    cutoff (1,1) double {mustBeNonnegative} = 0.0
    cutoffDirection (1,1) string  = "x"
end

e = STLExtractor(input,[],"ShouldSave",false);
ep = e.process;
if cutoff > 0
    ep = ep.cutoff(cutoff,cutoffDirection);
end
jsonOutput = jsonencode(ep);


f = fopen(output,"w");
fprintf(f,"%s",jsonOutput);
fclose(f);
end