function [Packing,geometricInfo] = AnalyzeSTL(STL_filename,   workingDir,ScaleFactor_Distancing)
% ANALYZESTL Proceess the STL file to calculate geometric parameters and
%   produce individual files.
%
%   PACKING = ANALYZESTL(STL_FILENAME, MAGNETIZATION_DATA_FILE,
%       N_PARTICLES, STLTOMAGTENSESCALE, WORKINGDIR,
%       SCALEFACTOR_DISTANCING)
%      will create a struct with the following fields:
%         - AllTheAxes
%         - AllTheRadii
%         - AllTheHeights
%         - iRadius
%         - iHeight
%         - AllTheTypes
%         - UniqueCombinationsRadii
%         - UniqueCombinationsHeights
%      based on triangulation information contained in STL_FILENAME and
%      also in MAGNETIZATION_DATA_FILE. At most, N_PARTICLES will be
%      included in the output struct. For easier mesh generation, a scaling
%      of STLTOMAGTENSESCALE will be applied. Individual files will be
%      generated in subfolders of WORKINGDIR.
%      SCALEFACTOR_DISTANCING - ????.

TR = stlread(STL_filename) ;

[bins,n_actual_particles] = extractIndividualParticles(TR);

[Packing,geometricInfo] = processParticles(n_actual_particles,bins,TR,ScaleFactor_Distancing,workingDir);

end

function [particles,n_actual_particles] = extractIndividualParticles(TR)
% EXTRACTINDIVIDUALPARTICLES Separate all triangles into connected ones
%
%   [particles, n_actual_particles] = EXTRACTINDIVIDUALPARTICLES(TR) will
%      load a triangulation object TR and divide the contained triangles into individual
%      "particles" that contain connected triangles.
%      The returned particles is a vector with the IDs of "groups" of triangles.

A = createConnectivityMatrix(TR);
G = graph(A) ;
particles = conncomp(G) ;

n_actual_particles = max(particles) ; % platelets
end

function A = createConnectivityMatrix(TR)
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


n_points = size(TR.Points,1) ; % points
n_triangles = size(TR.ConnectivityList,1) ; % triangles

A = zeros(n_points,n_points) ;
for k=1:n_triangles
  A(TR.ConnectivityList(k,1),TR.ConnectivityList(k,2)) = 1 ;
  A(TR.ConnectivityList(k,2),TR.ConnectivityList(k,3)) = 1 ;
  A(TR.ConnectivityList(k,3),TR.ConnectivityList(k,1)) = 1 ;

end
end

function [Packing,geometricInfo] = processParticles(n_actual_particles,bins,TR,ScaleFactor_Distancing,workingDir)


Packing = {};


for iParticle=1:n_actual_particles

  [TheAxis, TheRadius,TheAxialHeight, center] = processIndividualParticle(iParticle,TR,bins,workingDir,ScaleFactor_Distancing);
  Packing.AllTheAxes{iParticle} = TheAxis ;
  Packing.AllTheRadii(iParticle) = TheRadius(1) ;
  Packing.AllTheHeights(iParticle) = TheAxialHeight ;

  thisInfo.volume = calculateHexagonalArea(TheRadius(1))*TheAxialHeight;
  thisInfo.center = center;
  thisInfo.axes = TheAxis;
  geometricInfo(iParticle) = thisInfo;
end

end

function A = calculateHexagonalArea(r)
A = 3/2*sqrt(3)*r^2;
end

function [TheAxis, TheRadius,TheAxialHeight,center]  = processIndividualParticle(iParticle,TR,bins,dirname,scale)

% find the triangles that were grouped into given iParticle
particleTriangles = find(bins==iParticle) ;

% build a connectivity list for this particle
particleConnectivityList = 0.*TR.ConnectivityList ;
nTriangles = numel(particleTriangles);
for i=1:nTriangles
  particleConnectivityList = particleConnectivityList | (TR.ConnectivityList==particleTriangles(i)) ;
end
particleConnectivityList = particleConnectivityList(:,1) & particleConnectivityList(:,1) & particleConnectivityList(:,1) ;
particleConnectivityList = find(particleConnectivityList) ;

T = TR.ConnectivityList(particleConnectivityList,:) ;
T2 = 0.*T ;
for i=1:nTriangles
  T2(T==particleTriangles(i)) = i ;
end

P = TR.Points(particleTriangles,:) ;

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

P = (P-xC).*scale + xC ;  % SCALING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Tri2 = triangulation(T2,P) ;
center = xC(1,:);

thisFilename = fullfile(dirname, ...
    ['hexagon_',num2str(iParticle,'%04.0f'),'.stl']);
stlwrite(Tri2,thisFilename)
end

