function STLextractToJSON(input, output)
%STLEXTRACTTOJSON Write a JSON file after running STL extraction process on filename

e = STLExtractor(input,[],"ShouldSave",false);
ep = e.process;
jsonOutput = jsonencode(ep);


f = fopen(output,"w");
fprintf(f,"%s",jsonOutput);
fclose(f);
end