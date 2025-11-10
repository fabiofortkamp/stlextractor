classdef CutoffMethod
    %CUTOFFMETHOD Method to select which items should be cutoff from an ExtractedPacking
   enumeration
      vertices % items with any vertice that surpasses the cut plane are cut off
      centers % items whose center point surpasses the cut plane are cut off
   end
end