classdef STLExtractor < handle
  %STLEXTRACTOR Extract individual objects from an STL FILE
  %   Objects of this class can process an STL file and retrieve individual hexagonal
  %      prims. The goal is to extract individual "particles" from a "packing".


  properties (SetAccess = private)
    baseFilename string {mustBeFile}
    saveDir string {mustBeFolder}
    scale double {mustBePositive} = 0.95;
    shouldPlot (1,1) logical
  end



  properties (Access = private)
    
    globalTriangulation 
    trianglesInParticle
    nParticles
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
      end

      obj.baseFilename = filename;
      obj.saveDir = saveDir;
      % Create figue for holding the packing plot
      
      obj.shouldPlot = options.ShouldPlot;
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
        thickness = Packing.AllTheRadii(iParticle);
        normal = geometricInfo(iParticle).axes;
        l(iParticle) = HexagonalPrism(position, radius, thickness,normal);
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
      obj.trianglesInParticle = conncomp(G) ;

      obj.nParticles = max(obj.trianglesInParticle) ; % platelets
      obj.colormap  = jet(obj.nParticles);
      obj.particleTypes = ones(1,obj.nParticles);
      obj.particleGeometry = GeometricType.empty;
    end

    function A = createConnectivityMatrix(obj)
      % CREATECONNECTIVITYMATRIX Parse triangulation matrix and connect the dots.
      %
      %   A = CREATECONNECTIVITYMATRIX(TR) loads a triangulation object TR
      %      and generates a connectivity matrix A.
      %      The TR object has the following fields:
      %         - Points: a matrix where each row is the coordinate vector of a
      %            vertex
      %         - ConnectivityList: a matrix where:
      %            - Each element is a vertex ID;
      %            - Each row represents a triangle or tetrahedron in the
      %               triangulation;
      %            - Each row number of TR.ConnectivityList is a triangle or
      %               tetrahedron ID
      %      The A matrix has 1 in the (i,j) position if there is an edge between
      %         points whose IDS are i and j, and 0 otherwise.


      n_points = size(obj.globalTriangulation.Points,1) ; % points
      n_triangles = size(obj.globalTriangulation.ConnectivityList,1) ; % triangles

      A = zeros(n_points,n_points) ;
      for k=1:n_triangles
        A(obj.globalTriangulation.ConnectivityList(k,1),obj.globalTriangulation.ConnectivityList(k,2)) = 1 ;
        A(obj.globalTriangulation.ConnectivityList(k,2),obj.globalTriangulation.ConnectivityList(k,3)) = 1 ;
        A(obj.globalTriangulation.ConnectivityList(k,3),obj.globalTriangulation.ConnectivityList(k,1)) = 1 ;

      end
    end

    function [Packing,geometricInfo] = processParticles(obj)


      Packing = {};


      for iParticle=1:obj.nParticles

        [TheAxis, TheRadius,TheAxialHeight, center] = obj.processIndividualParticle(iParticle);
        Packing.AllTheAxes{iParticle} = TheAxis ;
        Packing.AllTheRadii(iParticle) = TheRadius(1) ;
        Packing.AllTheHeights(iParticle) = TheAxialHeight ;

        thisInfo.volume = calculateHexagonalArea(TheRadius(1))*TheAxialHeight;
        thisInfo.center = center;
        thisInfo.axes = TheAxis;
        geometricInfo(iParticle) = thisInfo;
      end

    end



    function [TheAxis, TheRadius,TheAxialHeight,center]  = processIndividualParticle(obj,iParticle)

        if obj.shouldPlot
      figure(obj.packingFigure);
      hold on
        end
      % find the triangles that were grouped into given particle whose index is iParticle
      particleTriangles = find(obj.trianglesInParticle==iParticle) ;

      % build a connectivity list for this particle
      particleConnectivityList = 0.*obj.globalTriangulation.ConnectivityList ;
      nTriangles = numel(particleTriangles);
      for i=1:nTriangles
        particleConnectivityList = particleConnectivityList | (obj.globalTriangulation.ConnectivityList==particleTriangles(i)) ;
      end
      particleConnectivityList = particleConnectivityList(:,1) & particleConnectivityList(:,1) & particleConnectivityList(:,1) ;
      particleConnectivityList = find(particleConnectivityList) ;

      T = obj.globalTriangulation.ConnectivityList(particleConnectivityList,:) ;
      T2 = 0.*T ;
      for i=1:nTriangles
        T2(T==particleTriangles(i)) = i ;
      end

      P = obj.globalTriangulation.Points(particleTriangles,:) ;

      xC = repmat(mean(P,1),size(P,1),1) ;
      TheEdges = [T2(:,1),T2(:,2);T2(:,2),T2(:,3);T2(:,3),T2(:,1)] ;
      TheDx = P(TheEdges(:,2),1)-P(TheEdges(:,1),1) ;
      TheDy = P(TheEdges(:,2),2)-P(TheEdges(:,1),2) ;
      TheDz = P(TheEdges(:,2),3)-P(TheEdges(:,1),3) ;
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
        P(TheEdges(twelveParallelEdges(k),2),1)-P(TheEdges(twelveParallelEdges(k),1),1),...
        P(TheEdges(twelveParallelEdges(k),2),2)-P(TheEdges(twelveParallelEdges(k),1),2),...
        P(TheEdges(twelveParallelEdges(k),2),3)-P(TheEdges(twelveParallelEdges(k),1),3)] ;
      TheAxialHeight = norm(TheAxis) ;


      DistFromCenter = sqrt(sum((P-xC).^2,2)) ;
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


        P = (P-xC).*obj.scale + xC ;  % SCALING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Tri2 = triangulation(T2,P) ;
      center = xC(1,:);
      xC = mean(P,1) ;
      CenterToVertex = P(1,:)-xC ;
      TheAxis2 = CenterToVertex - dot(CenterToVertex,TheAxis).*TheAxis ;
      TheAxis2 = TheAxis2./norm(TheAxis2) ;
      TheAxis3 = cross(TheAxis,TheAxis2) ;

            
      if obj.shouldPlot
          % PLOTTING
          if all(-P(:,3)>-8)
    
            % Compute color associated with this particle
            c = obj.colormap(obj.particleTypes(iParticle),:);
            trisurf(T2,P(:,1),P(:,2),P(:,3),'FaceColor',c,'linestyle','none','facealpha',.6) ;
          end
    
          % Finish filling up the hexagons
          line(xC(1)+[0,1].*TheAxis2(1),xC(2)+[0,1].*TheAxis2(2),xC(3)+[0,1].*TheAxis2(3))
          line(xC(1)+[0,1].*TheAxis3(1),xC(2)+[0,1].*TheAxis3(2),xC(3)+[0,1].*TheAxis3(3))
      end

      thisFilename = fullfile(obj.saveDir, ...
        ['hexagon_',num2str(iParticle,'%04.0f'),'.stl']);
      stlwrite(Tri2,thisFilename)
    end

  end
end
