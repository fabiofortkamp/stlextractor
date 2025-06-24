classdef PackingFigureRenderer < handle
    %PACKINGFIGURERENDERER Renderer class for visualizing hexagonal prism packings
    
    properties (Access = private)
        
        colorMap containers.Map
        colorScheme (:,3) double
        colorIndex (1,1) double = 0
    end
    
    methods
        function obj = PackingFigureRenderer
            %PACKINGFIGURERENDERER Construct an instance of this class
            
            
            % Initialize color map and scheme
            obj.colorMap = containers.Map();
            obj.colorScheme = obj.getCategoricalColorScheme();
        end
        
        function color = colorOf(obj, hexPrism)
            %COLOROF Return a unique color for each different prism type
            %
            % Two prisms are considered different if their radius or
            % thickness properties differ
            
            arguments
                obj PackingFigureRenderer
                hexPrism HexagonalPrism
            end
            
            % Create unique key based on radius and thickness
            key = sprintf('r%.6f_t%.6f', hexPrism.radius, hexPrism.thickness);
            
            % Check if we already have a color for this prism type
            if isKey(obj.colorMap, key)
                color = obj.colorMap(key);
            else
                % Assign new color from scheme
                obj.colorIndex = obj.colorIndex + 1;
                colorIdx = mod(obj.colorIndex - 1, size(obj.colorScheme, 1)) + 1;
                color = obj.colorScheme(colorIdx, :);
                
                % Store in map
                obj.colorMap(key) = color;
            end
        end
    end
    
    methods (Access = private)
        function colors = getCategoricalColorScheme(~)
            %GETCATEGORICALCOLORSCHEME Return a visually distinct color scheme
            %
            % Uses a combination of qualitative color schemes optimized
            % for categorical data visualization
            
            colors = [
                0.2422, 0.1504, 0.6603;  % Deep Blue
                0.9961, 0.4961, 0.0000;  % Orange
                0.2500, 0.8789, 0.8164;  % Cyan
                1.0000, 0.0000, 0.5000;  % Magenta
                0.5859, 0.8281, 0.3086;  % Light Green
                1.0000, 0.8477, 0.0000;  % Gold
                0.8359, 0.3691, 0.0000;  % Dark Orange
                0.8594, 0.0781, 0.2344;  % Crimson
                0.0000, 0.5078, 0.7812;  % Steel Blue
                0.4609, 0.7188, 0.2227;  % Olive Green
                0.9023, 0.6719, 0.0078;  % Dark Gold
                0.6406, 0.0781, 0.1836;  % Maroon
                0.0000, 0.7500, 0.7500;  % Teal
                0.5000, 0.0000, 1.0000;  % Purple
                0.7500, 0.7500, 0.0000;  % Olive
                1.0000, 0.0000, 1.0000;  % Fuchsia
            ];
        end
    end
end