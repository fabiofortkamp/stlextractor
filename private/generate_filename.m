function filename = generate_filename(radius, height, orientation, center)
    % Generate a filename that encodes the parameters
    % Format: hex_r[radius]_h[height]_o[x]_[y]_[z]_c[x]_[y]_[z].stl
    
    % Normalize orientation for consistent filenames
    orientation = orientation / norm(orientation);
    
    % Format orientation with 2 decimal places
    ox = sprintf('%.2f', orientation(1));
    oy = sprintf('%.2f', orientation(2));
    oz = sprintf('%.2f', orientation(3));
    
    % Replace decimal point with 'p' to avoid filename issues
    ox = strrep(ox, '.', 'p');
    oy = strrep(oy, '.', 'p');
    oz = strrep(oz, '.', 'p');
    
    % Replace negative sign with 'n' to avoid filename issues
    ox = strrep(ox, '-', 'n');
    oy = strrep(oy, '-', 'n');
    oz = strrep(oz, '-', 'n');
    
    % Basic filename with radius, height, and orientation
    filename = sprintf('hex_r%g_h%g_o%s_%s_%s', radius, height, ox, oy, oz);
    
    % Add center if provided
    if nargin > 3 && ~isempty(center)
        % Format center coordinates
        cx = sprintf('%.1f', center(1));
        cy = sprintf('%.1f', center(2));
        cz = sprintf('%.1f', center(3));
        
        % Replace decimal point with 'p'
        cx = strrep(cx, '.', 'p');
        cy = strrep(cy, '.', 'p');
        cz = strrep(cz, '.', 'p');
        
        % Replace negative sign with 'n'
        cx = strrep(cx, '-', 'n');
        cy = strrep(cy, '-', 'n');
        cz = strrep(cz, '-', 'n');
        
        filename = sprintf('%s_c%s_%s_%s', filename, cx, cy, cz);
    end
    
    % Add file extension
    filename = [filename '.stl'];
end