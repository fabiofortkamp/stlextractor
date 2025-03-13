% demo script to show instantiation of the objects and subsequent extraction of
% triangles

exampleFile = fullfile("tests","particles_200.stl");
outputDir = "tmp";
if ~isfolder(outputDir)
    mkdir(outputDir);
end
extractor = STLExtractor(exampleFile,outputDir);
l = extractor.process();
disp(l);
