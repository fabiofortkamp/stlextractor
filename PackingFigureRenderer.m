classdef PackingFigureRenderer < handle
    %PACKINGFIGURERENDERER Renderer class for visualizing hexagonal prism packings
    %
    % Instances of this class provide instances of EXTRACTEDPACKING with configuration
    % on how to plot the packing.
    %
    % This class was designed with the help of Claude AI.

    properties (Access = private)
        colorMap containers.Map % a mapping of char vectors to a row of `colorScheme` (see below)
        colorScheme (:,3) double % a matrix of possible RGB vectors to color the particles
        colorIndex (1,1) double = 0 % current row of the matrix above
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
                0.1216, 0.4667, 0.7059;  % Bright Blue
                1.0000, 0.4980, 0.0549;  % Bright Orange
                0.1725, 0.6275, 0.1725;  % Bright Green
                0.8392, 0.1529, 0.1569;  % Bright Red
                0.5804, 0.4039, 0.7412;  % Bright Purple
                0.5490, 0.3373, 0.2941;  % Bright Brown
                0.8902, 0.4667, 0.7608;  % Bright Pink
                0.4980, 0.4980, 0.4980;  % Bright Gray
                0.7373, 0.7412, 0.1333;  % Bright Olive
                0.0902, 0.7451, 0.8118;  % Bright Cyan
                1.0000, 0.7333, 0.4706;  % Light Orange
                0.6000, 0.8000, 0.1961;  % Lime Green
                1.0000, 0.2000, 0.6000;  % Hot Pink
                0.4000, 0.8000, 1.0000;  % Sky Blue
                1.0000, 0.8000, 0.2000;  % Bright Yellow
                0.8000, 0.2000, 1.0000;  % Bright Magenta
                ];
        end
    end
end