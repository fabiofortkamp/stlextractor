classdef STLExtractor
  %STLEXTRACTOR Extract individual objects from an STL FILE
  %   Objects of this class can process an STL file and retrieve individual hexagonal
  %      prims. The goal is to extract individual "particles" from a "packing".

  properties
    baseFilename string {mustBeFile}
    workingDir string {mustBeFolder}
    scale double {mustBePositive} = 2.5;
  end

  methods
    function obj = STLExtractor(filename,workingDir)
      %STLEXTRACTOR Construct an instance of this class

      obj.baseFilename = filename;
      obj.workingDir = workingDir;
    end

    function l = process(obj)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      [Packing,geometricInfo] = AnalyzeSTL(obj.baseFilename, obj.workingDir,obj.scale);

      nParticles = numel(geometricInfo);
      l = HexagonalPrism.empty;
      for iParticle = 1:nParticles
        position = geometricInfo(iParticle).center;
        radius = Packing.AllTheRadii(iParticle);
        thickness = Packing.AllTheRadii(iParticle);
        normal = geometricInfo(iParticle).axes;
        l(iParticle) = HexagonalPrism(position, radius, thickness,normal);
      end
    end
  end
end
