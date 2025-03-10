% demo script to show instantiation of the objects and subsequent extraction of
% triangles

exampleFile = fullfile("tests","particles_200.stl");
outputDir = "tmp";
mkdir(outputDir);
extractor = STLExtractor(exampleFile,outputDir);
