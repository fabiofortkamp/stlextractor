function ThisColSegment = ColorFromHorPsiTheta01(a1,a2,a3)
if exist('a3')
    
    HxSegment = a1 ;
    HySegment = a2 ;
    HzSegment = a3 ;
%     thisThetaMean = acos(HzSegment./norm([HxSegment,HySegment,HzSegment])) ;
        thisThetaMean = acos(HzSegment./sqrt(HxSegment.^2+HySegment.^2+HzSegment.^2)) ;
    thisPhiMean = atan2(HySegment,HxSegment) ;
    
else
    
    thisPhiMean = a1 ;
    thisThetaMean = a2 ;
end



ThisHSV = [wrapTo2Pi(thisPhiMean+pi)./(2*pi),(thisThetaMean<=pi/2).*(1)+(thisThetaMean>pi/2).*(1-(thisThetaMean-pi/2)/(pi/2))  ,(thisThetaMean<=pi/2).*(thisThetaMean./(pi/2))+(thisThetaMean>pi/2).*(1)] ;
ThisColSegment = hsv2rgb(ThisHSV) ;
% ThisColSegment = hsv2rgb(wrapTo2Pi(thisPhiMean+pi)./(2*pi),(thisThetaMean<=pi/2).*(1)+(thisThetaMean>=pi/2).*(1-(thisThetaMean-pi/2)/(pi/2))  ,(thisThetaMean<=pi/2).*(thisThetaMean./(pi/2))+(thisThetaMean>=pi/2).*(1)) ;
if ~all(~isnan(ThisColSegment))
    ThisColSegment = .5.*[1,1,1] ;
end

'' ;