function [radius, height, orientation, center] = parseSTLTestFilename(filename)
% PARSESTLTESTFILENAME Parse geometric information from a test STL file
%
%   [R,H,O,C] = PARSESTLTESTFILENAME(filename) extracts the radius, height,
%      orientation and centerpoint of the object contained in the STL file 'filename'

arguments
    filename string {mustBeFile}
end
    % Extract just the filename without path and extension
    [~, name, ~] = fileparts(filename);
    
    % Initialize output
    radius = [];
    height = [];
    orientation = [];
    center = [];
    
    % Extract radius
    r_match = regexp(name, 'r(\d+\.?\d*)', 'tokens');
    if ~isempty(r_match)
        radius = str2double(r_match{1}{1});
    end
    
    % Extract height
    h_match = regexp(name, 'h(\d+\.?\d*)', 'tokens');
    if ~isempty(h_match)
        height = str2double(h_match{1}{1});
    end
    
    % Extract orientation
    o_match = regexp(name, 'o([np]?\d+p\d+)_([np]?\d+p\d+)_([np]?\d+p\d+)', 'tokens');
    if ~isempty(o_match)
        % Convert from string format to numeric
        ox_str = o_match{1}{1};
        oy_str = o_match{1}{2};
        oz_str = o_match{1}{3};
        
        % Replace 'p' with '.' and 'n' with '-'
        ox_str = strrep(ox_str, 'p', '.');
        oy_str = strrep(oy_str, 'p', '.');
        oz_str = strrep(oz_str, 'p', '.');
        
        ox_str = strrep(ox_str, 'n', '-');
        oy_str = strrep(oy_str, 'n', '-');
        oz_str = strrep(oz_str, 'n', '-');
        
        % Convert to numeric values
        orientation = [str2double(ox_str), str2double(oy_str), str2double(oz_str)];
    end
    
    % Extract center if present
    c_match = regexp(name, 'c([np]?\d+p\d+)_([np]?\d+p\d+)_([np]?\d+p\d+)', 'tokens');
    if ~isempty(c_match)
        % Convert from string format to numeric
        cx_str = c_match{1}{1};
        cy_str = c_match{1}{2};
        cz_str = c_match{1}{3};
        
        % Replace 'p' with '.' and 'n' with '-'
        cx_str = strrep(cx_str, 'p', '.');
        cy_str = strrep(cy_str, 'p', '.');
        cz_str = strrep(cz_str, 'p', '.');
        
        cx_str = strrep(cx_str, 'n', '-');
        cy_str = strrep(cy_str, 'n', '-');
        cz_str = strrep(cz_str, 'n', '-');
        
        % Convert to numeric values
        center = [str2double(cx_str), str2double(cy_str), str2double(cz_str)];
    else
        center = [0,0,0];
    end
end