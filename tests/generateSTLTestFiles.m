function generateSTLTestFiles()
% GENERATESTLTESTFILES Create a bunch of STL files with one hexagon in different 
%  orientations

% Generated with claude.ai

    % Create directory for test STL files if it doesn't exist
    if ~exist('test_stl_files', 'dir')
        mkdir('test_stl_files');
    end
    
    % Test case 1: Basic vertical hexagonal prism
    radius = 10; height = 20; orientation = [0, 0, 1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 2: Tall and thin vertical prism
    radius = 5; height = 50; orientation = [0, 0, 1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 3: Short and wide vertical prism
    radius = 25; height = 5; orientation = [0, 0, 1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 4: X-axis oriented prism
    radius = 10; height = 20; orientation = [1, 0, 0];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 5: Y-axis oriented prism
    radius = 10; height = 20; orientation = [0, 1, 0];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 6: Arbitrary orientation
    radius = 15; height = 25; orientation = [1, 1, 1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 7: Different center location
    radius = 10; height = 20; orientation = [0, 0, 1]; center = [10, 10, 10];
    prism = create_hexagonal_prism(radius, height, orientation, center);
    filename = generate_filename(radius, height, orientation, center);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 8: Near-flat prism
    radius = 20; height = 0.5; orientation = [0, 0, 1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 9: Very small prism
    radius = 0.5; height = 1; orientation = [0, 0, 1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 10: Extreme orientation
    radius = 12; height = 24; orientation = [0.1, 0.1, 0.99];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 11: Nearly horizontal orientation
    radius = 8; height = 16; orientation = [0.99, 0.1, 0.1];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test case 12: Complex orientation
    radius = 18; height = 15; orientation = [0.5, -0.7, 0.3];
    prism = create_hexagonal_prism(radius, height, orientation);
    filename = generate_filename(radius, height, orientation);
    stlwrite(['test_stl_files/' filename], prism.faces, prism.vertices);
    
    % Test parsing capability
    disp('Testing filename parsing:');
    for i = 1:3
        % Get a filename and parse it
        if i == 1
            testfilename = generate_filename(10, 20, [0, 0, 1]);
        elseif i == 2
            testfilename = generate_filename(15, 25, [1, 1, 1]);
        else
            testfilename = generate_filename(18, 15, [0.5, -0.7, 0.3]);
        end
        
        % Parse the filename
        [parsed_radius, parsed_height, parsed_orientation, parsed_center] = parse_filename(testfilename);
        
        % Display results
        disp(['File: ' testfilename]);
        disp(['  Radius: ' num2str(parsed_radius)]);
        disp(['  Height: ' num2str(parsed_height)]);
        disp(['  Orientation: [' num2str(parsed_orientation) ']']);
        if ~isempty(parsed_center)
            disp(['  Center: [' num2str(parsed_center) ']']);
        else
            disp('  Center: [0, 0, 0] (default)');
        end
        disp(' ');
    end
    
    disp('Generated 12 test STL files in the ''test_stl_files'' directory.');
    disp('Filenames encode radius, height, orientation, and center parameters.');
    disp('Use parse_filename() to extract parameters from any filename.');
end





function prism = create_hexagonal_prism(radius, height, orientation, center)
    % Create a hexagonal prism mesh
    %
    % Args:
    %   radius: Distance from center to vertex (outer radius)
    %   height: Height of the prism
    %   orientation: 3D vector representing the axis of the prism (default [0,0,1])
    %   center: Center coordinates of the prism (default [0,0,0])
    %
    % Returns:
    %   A structure with vertices and faces representing the hexagonal prism
    
    % Set default values if not provided
    if nargin < 3 || isempty(orientation)
        orientation = [0, 0, 1];
    end
    if nargin < 4 || isempty(center)
        center = [0, 0, 0];
    end
    
    % Ensure inputs are in the right format
    orientation = orientation(:)';  % Make sure it's a row vector
    center = center(:)';            % Make sure it's a row vector
    
    % Normalize orientation vector
    orientation_norm = norm(orientation);
    if orientation_norm > 0
        orientation = orientation / orientation_norm;
    else
        orientation = [0, 0, 1];  % Default to z-axis
    end
    
    % Create orthogonal vectors for the orientation
    if abs(orientation(3)) < 0.9  % If not close to z-axis
        perpendicular = cross(orientation, [0, 0, 1]);
    else
        perpendicular = cross(orientation, [1, 0, 0]);
    end
    
    perpendicular = perpendicular / norm(perpendicular);
    third_vector = cross(orientation, perpendicular);
    
    % Create vertices for the hexagon in the local coordinate system
    angles = linspace(0, 2*pi, 7);  % 7 points (with duplicate for complete loop)
    angles = angles(1:6);           % Remove the duplicate
    
    vertices_bottom = zeros(6, 3);
    vertices_top = zeros(6, 3);
    
    % Calculate vertices
    for i = 1:6
        angle = angles(i);
        x = radius * cos(angle);
        y = radius * sin(angle);
        
        % Calculate vertex in global coordinate system for bottom face
        vertex_bottom = x * perpendicular + ...
                       y * third_vector + ...
                       center - (height/2) * orientation;
        vertices_bottom(i, :) = vertex_bottom;
        
        % Calculate vertex in global coordinate system for top face
        vertex_top = x * perpendicular + ...
                    y * third_vector + ...
                    center + (height/2) * orientation;
        vertices_top(i, :) = vertex_top;
    end
    
    % Combine all vertices
    vertices = [vertices_bottom; vertices_top];
    
    % Create triangular faces
    faces = zeros(20, 3);  % 8 triangles for top/bottom + 12 for sides
    
    % Bottom face triangles (fan triangulation)
    for i = 1:4
        faces(i, :) = [1, i+1, i+2];
    end
    faces(5, :) = [1, 6, 2];
    
    % Top face triangles (fan triangulation)
    for i = 1:4
        faces(5+i, :) = [7, 7+i+1, 7+i];
    end
    faces(10, :) = [7, 7+1, 7+5];
    
    % Adjust indices for MATLAB's 1-based indexing
    faces(1:10, :) = faces(1:10, :);
    
    % Side faces (each rectangular face is made of 2 triangles)
    for i = 1:6
        next_i = mod(i, 6) + 1;
        faces(10+2*(i-1)+1, :) = [i, i+6, next_i+6];
        faces(10+2*(i-1)+2, :) = [i, next_i+6, next_i];
    end
    
    % Return structure with vertices and faces
    prism = struct('vertices', vertices, 'faces', faces);
end

function stlwrite(filename, faces, vertices)
    % Simple STL writer function
    % This is a simplified version that writes binary STL files
    
    % Open file for writing
    fid = fopen(filename, 'w');
    
    % Write STL header (80 bytes)
    fprintf(fid, '%-80s', 'STL generated by MATLAB');
    
    % Write number of triangles (4 bytes)
    fwrite(fid, size(faces, 1), 'uint32');
    
    % Prepare normals
    normals = zeros(size(faces, 1), 3);
    
    % Calculate normals for each face
    for i = 1:size(faces, 1)
        v1 = vertices(faces(i, 1), :);
        v2 = vertices(faces(i, 2), :);
        v3 = vertices(faces(i, 3), :);
        
        % Calculate face normal
        normal = cross(v2 - v1, v3 - v1);
        if norm(normal) > 0
            normal = normal / norm(normal);
        end
        normals(i, :) = normal;
    end
    
    % Write triangles
    for i = 1:size(faces, 1)
        % Write normal (3 floats)
        fwrite(fid, normals(i, :), 'float32');
        
        % Write vertices (9 floats)
        fwrite(fid, vertices(faces(i, 1), :), 'float32');
        fwrite(fid, vertices(faces(i, 2), :), 'float32');
        fwrite(fid, vertices(faces(i, 3), :), 'float32');
        
        % Write attribute byte count (2 bytes) - usually zero
        fwrite(fid, 0, 'uint16');
    end
    
    % Close file
    fclose(fid);
end