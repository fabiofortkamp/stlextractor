classdef STLExtractor < handle
  %STLEXTRACTOR Extract individual objects from an STL FILE
  %   Objects of this class can process an STL file and retrieve individual hexagonal
  %      prims. The goal is to extract individual "particles" from a "packing".


  properties (SetAccess = private)
    baseFilename string {mustBeFile}
    saveDir string {mustBeFolder}
    scale double {mustBePositive} = 0.95;
    shouldPlot (1,1) logical
    shouldSave (1,1) logical
  end



  properties (Access = private)
    nParticles % number of individual particles recognized from the input STL file
    pointsInParticle    % vector of particle indexes; the i-th element is the particle
                        % index of the i-th point extracted from the input STL file
    globalTriangulation % global triangulation objected extracted from the input STL
                        % This object has the following fields:   
                        %   - Points: a matrix where each row is the coordinate 
                        %       vector of a vertex        
                        %   - ConnectivityList: a matrix where:
                        %       - Each element is a vertex ID;
                        %       - Each row represents a triangle or tetrahedron in the
                        %         triangulation;
                        %       - Row numbers of are a triangle or tetrahedron IDs
    packingFigure
    colormap
    particleTypes
    particleGeometry
  end

  methods
    function obj = STLExtractor(filename,saveDir,options)
      %STLEXTRACTOR Construct an extractor that process a STL file and partitions
      %     into individual STL objects.
      %
      % ex = STLEXTRACTOR(filename,saveDir) will instantiate an extractor
      %     based on the STL file named 'filename', and will save the resulting
      %     individual STL files of the hexagonal prisms into 'saveDir'
      %
      % See also HEXAGONALPRISM
      arguments
        filename
        saveDir
        options.ShouldPlot (1,1) logical = false
        options.ShouldSave (1,1) logical = false
      end

      obj.baseFilename = filename;
      obj.saveDir = saveDir;


      obj.shouldPlot = options.ShouldPlot;
      obj.shouldSave = options.ShouldSave;
      if obj.shouldPlot
        obj.initializeFigure;
      end

    end

    function l = process(obj)
      %PROCESS Run the extraction process and save individual files.
      %   l = obj.PROCESS() returns a list of HEXAGONALPRISM objects, with each one
      %     being saved in individual STL files in obj.saveDir

      [Packing,geometricInfo] = obj.AnalyzeSTL;

      l = HexagonalPrism.empty;

      for iParticle = 1:obj.nParticles
        position = geometricInfo(iParticle).center;
        radius = Packing.AllTheRadii(iParticle);
        thickness = Packing.AllTheHeights(iParticle);
        normal = geometricInfo(iParticle).axes;
        faceRotation = Packing.AllTheAxes2{iParticle};
        l(iParticle) = HexagonalPrism(position, radius, thickness,normal,faceRotation);
      end




    end
  end

  methods (Access = private)

    function f = initializeFigure(obj)
      obj.packingFigure = figure;

      % change width and height
      % from: https://se.mathworks.com/help/releases/R2024b/matlab/ref/figure.html#bvjs6cb-3

      f.Units = "centimeters";
      f.Position(3:4) = [16,9];

      axis equal
      light('position',[2,2,2])
      view(30,30) ;
      xlabel("x");
      ylabel("y");
      zlabel("z");
    end
    function [Packing,geometricInfo] = AnalyzeSTL(obj)
      % ANALYZESTL Process the STL file to calculate geometric parameters and
      %   produce individual files.

      obj.globalTriangulation = stlread(obj.baseFilename) ;

      obj.extractIndividualParticles;

      [Packing,geometricInfo] = obj.processParticles;

    end

    function extractIndividualParticles(obj)
      % EXTRACTINDIVIDUALPARTICLES Separate all triangles into connected ones
      %
      %   [particles, n_actual_particles] = EXTRACTINDIVIDUALPARTICLES(TR) will
      %      load a triangulation object TR and divide the contained triangles into individual
      %      "particles" that contain connected triangles.
      %      The returned particles is a vector with the IDs of "groups" of triangles.

      A = obj.createConnectivityMatrix;

      % correct cases where the order of edges are incorrect between
      % adjacent triangles
      A = A + A.';
      A = A ~= 0;

      G = graph(A) ;
      obj.pointsInParticle = conncomp(G) ;

      obj.nParticles = max(obj.pointsInParticle);
      obj.colormap  = jet(obj.nParticles);
      obj.particleTypes = ones(1,obj.nParticles);
      obj.particleGeometry = GeometricType.empty;
    end

    function A = createConnectivityMatrix(obj)
      % CREATECONNECTIVITYMATRIX Parse triangulation matrix and connect the dots.
      %

      %      The A matrix has 1 in the (i,j) position if there is an edge between
      %         points whose IDS are i and j, and 0 otherwise.


      n_points = size(obj.globalTriangulation.Points,1) ; % points
      n_triangles = size(obj.globalTriangulation.ConnectivityList,1) ; % triangles

      A = zeros(n_points,n_points) ;
      for k=1:n_triangles
        vertices = obj.globalTriangulation.ConnectivityList(k,:);
        A(vertices(1),vertices(2)) = 1 ;
        A(vertices(2),vertices(3)) = 1 ;
        A(vertices(3),vertices(1)) = 1 ;

      end
    end

    function [Packing,geometricInfo] = processParticles(obj)


      Packing = {};


      for iParticle=1:obj.nParticles

        [TheAxis, TheRadius,TheAxialHeight, center,TheAxis2] = obj.processIndividualParticle(iParticle);
        Packing.AllTheAxes{iParticle} = TheAxis ;
        Packing.AllTheAxes2{iParticle} = TheAxis2 ;
        Packing.AllTheRadii(iParticle) = TheRadius(1) ;
        Packing.AllTheHeights(iParticle) = TheAxialHeight ;

        thisInfo.volume = calculateHexagonalArea(TheRadius(1))*TheAxialHeight;
        thisInfo.center = center;
        thisInfo.axes = TheAxis;
        geometricInfo(iParticle) = thisInfo;
      end

    end


    function holdFigure(obj)
        %HOLDFIGURE Retrive the main packing figure for plotting, if plotting is
        %enabled.
        %
        %   HOLDFIGURE will access the object's plotting figure for subsequent
        %       plotting commands
        if obj.shouldPlot
            figure(obj.packingFigure);
            hold on
        end
    end


    function [TheAxis, TheRadius,TheAxialHeight,center, TheAxis2]  = processIndividualParticle(obj,iParticle)
        arguments
            obj STLExtractor
            iParticle (1,1) double % particle index to process
        end

      obj.holdFigure;

      % build a connectivity list for this particle
      localTR = obj.buildLocalTriangulation(iParticle);
      localPoints = localTR.Points;
      localTriangles = localTR.ConnectivityList;

      xC = repmat(mean(localPoints,1),size(localPoints,1),1) ;
      TheEdges = [localTriangles(:,1),localTriangles(:,2);localTriangles(:,2),localTriangles(:,3);localTriangles(:,3),localTriangles(:,1)] ;
      TheDx = localPoints(TheEdges(:,2),1)-localPoints(TheEdges(:,1),1) ;
      TheDy = localPoints(TheEdges(:,2),2)-localPoints(TheEdges(:,1),2) ;
      TheDz = localPoints(TheEdges(:,2),3)-localPoints(TheEdges(:,1),3) ;
      [TheDX1,TheDX2] = meshgrid(TheDx,TheDx) ;
      [TheDY1,TheDY2] = meshgrid(TheDy,TheDy) ;
      [TheDZ1,TheDZ2] = meshgrid(TheDz,TheDz) ;


      TheDN1 = sqrt(TheDX1.^2+TheDY1.^2+TheDZ1.^2) ;
      TheDN2 = sqrt(TheDX2.^2+TheDY2.^2+TheDZ2.^2) ;
      TheDots = (TheDX1.*TheDX2 + TheDY1.*TheDY2 + TheDZ1.*TheDZ2)./(TheDN1.*TheDN2) ;
      SameDir = abs(TheDots)>.999 ;
      Gedges = graph(SameDir) ;

      [binsEdges,binsizes] = conncomp(Gedges) ;
      twelveParallelbin = find(binsizes==12) ;
      twelveParallelEdges = find(binsEdges==twelveParallelbin) ;

      k = 1 ;
      TheAxis = [...
        localPoints(TheEdges(twelveParallelEdges(k),2),1)-localPoints(TheEdges(twelveParallelEdges(k),1),1),...
        localPoints(TheEdges(twelveParallelEdges(k),2),2)-localPoints(TheEdges(twelveParallelEdges(k),1),2),...
        localPoints(TheEdges(twelveParallelEdges(k),2),3)-localPoints(TheEdges(twelveParallelEdges(k),1),3)] ;
      TheAxialHeight = norm(TheAxis) ;


      DistFromCenter = sqrt(sum((localPoints-xC).^2,2)) ;
      TheRadius = sqrt(DistFromCenter.^2-(TheAxialHeight/2)^2) ;

      % compute the GeometricType associated with this particle
      gt = GeometricType(TheRadius(1),TheAxialHeight);
      obj.particleGeometry(iParticle) = gt;

      % starting from the second particle, we should compare its
      % geometric type with the others
      if iParticle > 1

        % this is terribly inefficient, but I have yet to find a way
        % to properly overload the comparison operators
        for j = 1:iParticle-1
          if gt == obj.particleGeometry(j)
            % we have found an "identical" particle type,
            % so we assign the same type and exit out of the loop
            obj.particleTypes(iParticle) = obj.particleTypes(j);
            break
          else
            % in this case, change the type
            obj.particleTypes(iParticle) = max(obj.particleTypes) + 1;
            break
          end
        end
      end


      TheAxis = TheAxis./TheAxialHeight ;

      zProjection = dot(TheAxis,[0,0,1]);
      upSign = sign(zProjection);

      if upSign ~= 0
        TheAxis = upSign.*TheAxis ;
      end


      localPoints = (localPoints-xC).*obj.scale + xC ;  % SCALING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Tri2 = triangulation(localTriangles,localPoints) ;
      center = xC(1,:);
      xC = mean(localPoints,1) ;
      CenterToVertex = localPoints(1,:)-xC ;
      TheAxis2 = CenterToVertex - dot(CenterToVertex,TheAxis).*TheAxis ;
      TheAxis2 = TheAxis2./norm(TheAxis2) ;
      TheAxis3 = cross(TheAxis,TheAxis2) ;

    
      obj.plotPacking(TheAxis,localTriangles,localPoints);


      if obj.shouldSave
        thisFilename = fullfile(obj.saveDir, ...
          ['hexagon_',num2str(iParticle,'%04.0f'),'.stl']);
        stlwrite(Tri2,thisFilename)
      end
    end

    function plotPacking(obj,TheAxis,T2,P)
        if obj.shouldPlot
        % PLOTTING
            if all(-P(:,3)>-8)
    
              % Compute color associated with this particle
              c = ColorFromHorPsiTheta01(TheAxis(1),TheAxis(2),-TheAxis(3));
              trisurf(T2,P(:,1),P(:,2),P(:,3),'FaceColor',c,'linestyle','none','facealpha',1) ;
            end

        end
    end

    function TR = buildLocalTriangulation(obj,iParticle)
                  
          % find the triangle IDs that were grouped into given particle 
          % whose index is iParticle
          particlePoints = find(obj.pointsInParticle==iParticle) ;
          
          nPoints = numel(particlePoints);
          
          % from the global connectivity list, which lists all triangles and points
          % extracted from the STL file, find only the rows which are pertinent
          % to this particle
          particleConnectivityList = 0.*obj.globalTriangulation.ConnectivityList ;
          for i=1:nPoints
            % particlePoints(i) will return the i-th point index in this particle
            % so we observe where this same index appears in the global matrix
            particleConnectivityList = (particleConnectivityList | ...
                (obj.globalTriangulation.ConnectivityList==particlePoints(i))) ;
          end
          
          % TODO: Check with Andrea Insinga what's the purpose of this
          particleConnectivityList = (...
               particleConnectivityList(:,1) & ...
               particleConnectivityList(:,1) & ...
               particleConnectivityList(:,1)) ;
          trianglesList = find(particleConnectivityList) ;
    
          % get only the subset of of global triangulation that contains
          % points in this particle
          T = obj.globalTriangulation.ConnectivityList(trianglesList,:) ;
          % transform from the global point numbering to a local numbering
          T2 = 0.*T ;
          for i=1:nPoints
            T2(T==particlePoints(i)) = i ;
          end
    
          P = obj.globalTriangulation.Points(particlePoints,:) ;
          TR.Points = P;
          TR.ConnectivityList = T2;
        
    end

  end
end
