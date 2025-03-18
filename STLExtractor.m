classdef STLExtractor < handle
  %STLEXTRACTOR Extract individual objects from an STL FILE
  %   Objects of this class can process an STL file and retrieve individual hexagonal
  %      prims. The goal is to extract individual "particles" from a "packing".

  properties (SetAccess = private)
    baseFilename string {mustBeFile}
    saveDir string {mustBeFolder}
    scale double {mustBePositive} = 2.5;
  end

  properties (Access = private)
    TR
    trianglesInParticle
    nParticles
    colormap
    fig
  end

  methods
    function obj = STLExtractor(filename,saveDir)
      %STLEXTRACTOR Construct an extractor that process a STL file and partitions
      %     into individual STL objects.
      %
      % ex = STLEXTRACTOR(filename,saveDir) will instantiate an extractor
      %     based on the STL file named 'filename', and will save the resulting
      %     individual STL files of the hexagonal prisms into 'saveDir'
      %
      % See also HEXAGONALPRISM

      obj.baseFilename = filename;
      obj.saveDir = saveDir;
    end

    function l = process(obj)
      %PROCESS Run the extraction process and save individual files.
      %   l = obj.PROCESS() returns a list of HEXAGONALPRISM objects, with each one
      %     being saved in individual STL files in obj.saveDir
            obj.fig = figure("Name","blah") ;
      hold on;
      [Packing,geometricInfo] = obj.AnalyzeSTL;

      l = HexagonalPrism.empty;


      for iParticle = 1:obj.nParticles
        position = geometricInfo(iParticle).center;
        radius = Packing.AllTheRadii(iParticle);
        thickness = Packing.AllTheRadii(iParticle);
        normal = geometricInfo(iParticle).axes;
        l(iParticle) = HexagonalPrism(position, radius, thickness,normal);
      end

              axis equal
                light('position',[2,2,2])
                view(30,30) ;

    end
  end

  methods (Access = private)
      function [Packing,geometricInfo] = AnalyzeSTL(obj)
        % ANALYZESTL Process the STL file to calculate geometric parameters and
        %   produce individual files.
        
        obj.TR = stlread(obj.baseFilename) ;
        
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
        G = graph(A) ;
        obj.trianglesInParticle = conncomp(G) ;
        
        obj.nParticles = max(obj.trianglesInParticle) ; % platelets
        obj.colormap  = jet(obj.nParticles);
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
        
        
        n_points = size(obj.TR.Points,1) ; % points
        n_triangles = size(obj.TR.ConnectivityList,1) ; % triangles
        
        A = zeros(n_points,n_points) ;
        for k=1:n_triangles
          A(obj.TR.ConnectivityList(k,1),obj.TR.ConnectivityList(k,2)) = 1 ;
          A(obj.TR.ConnectivityList(k,2),obj.TR.ConnectivityList(k,3)) = 1 ;
          A(obj.TR.ConnectivityList(k,3),obj.TR.ConnectivityList(k,1)) = 1 ;
        
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
        
 
        figure(obj.fig);
        hold on
        % find the triangles that were grouped into given particle whose index is iParticle
        particleTriangles = find(obj.trianglesInParticle==iParticle) ;
        
        % build a connectivity list for this particle
        particleConnectivityList = 0.*obj.TR.ConnectivityList ;
        nTriangles = numel(particleTriangles);
        for i=1:nTriangles
          particleConnectivityList = particleConnectivityList | (obj.TR.ConnectivityList==particleTriangles(i)) ;
        end
        particleConnectivityList = particleConnectivityList(:,1) & particleConnectivityList(:,1) & particleConnectivityList(:,1) ;
        particleConnectivityList = find(particleConnectivityList) ;
        
        T = obj.TR.ConnectivityList(particleConnectivityList,:) ;
        T2 = 0.*T ;
        for i=1:nTriangles
          T2(T==particleTriangles(i)) = i ;
        end
        
        P = obj.TR.Points(particleTriangles,:) ;
        
        % TODO: Check with Andrea if this is where the center is calculated
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
        
        TheAxis = TheAxis./TheAxialHeight ;
        
        TheAxis = sign(dot(TheAxis,[0,0,1])).*TheAxis ;
        
        P = (P-xC).*obj.scale + xC ;  % SCALING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        % PLOTTING
        if all(-P(:,3)>-8)
            trisurf(T2,P(:,1),P(:,2),P(:,3),'linestyle','none','facecolor',obj.colormap(iParticle,:),'facealpha',.6) ;
        end
        
        Tri2 = triangulation(T2,P) ;
        center = xC(1,:);
        xC = mean(P,1) ;
        CenterToVertex = P(1,:)-xC ;
        TheAxis2 = CenterToVertex - dot(CenterToVertex,TheAxis).*TheAxis ;
        TheAxis2 = TheAxis2./norm(TheAxis2) ;
        TheAxis3 = cross(TheAxis,TheAxis2) ;

        line(xC(1)+[0,1].*TheAxis2(1),xC(2)+[0,1].*TheAxis2(2),xC(3)+[0,1].*TheAxis2(3))
        line(xC(1)+[0,1].*TheAxis3(1),xC(2)+[0,1].*TheAxis3(2),xC(3)+[0,1].*TheAxis3(3))

        
        thisFilename = fullfile(obj.saveDir, ...
            ['hexagon_',num2str(iParticle,'%04.0f'),'.stl']);
        stlwrite(Tri2,thisFilename)
        end
      
  end
end
