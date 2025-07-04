classdef STLExtractorError
    %STLEXTRACTORERROR Centralized error handling utilities for STLExtractor
    %
    % This class provides static methods for creating and throwing MException
    % objects following the pattern STLExtractor:<Class>:<Issue>
    %
    % NAMING CONVENTIONS:
    %   - Error IDs follow the format: STLExtractor:<Class>:<Issue>
    %   - Class: The class or module where the error occurs
    %   - Issue: A descriptive name for the specific error type
    %
    % USAGE EXAMPLES:
    %   STLExtractorError.throwError('HexagonalPrism', 'InvalidInput', 'Message');
    %   STLExtractorError.mustBeFile('/path/to/file.stl');
    %   STLExtractorError.mustBeFolder('/path/to/directory');
    %   STLExtractorError.mustBeNonZeroNorm([1,0,0], 'normal vector');
    %
    % See also: MException, error

    methods (Static)
        function throwError(className, issue, message)
            %THROWERROR Construct and throw an MException with standardized ID
            %
            % THROWERROR(className, issue, message) creates an MException
            % with ID 'STLExtractor:className:issue' and throws it with
            % the specified message.
            %
            % Example:
            %   STLExtractorError.throwError('HexagonalPrism', 'InvalidInput', ...
            %       'The radius must be positive');
            
            arguments
                className (1,1) string
                issue (1,1) string
                message (1,1) string
            end
            
            errorId = sprintf('STLExtractor:%s:%s', className, issue);
            error(errorId, '%s', message);
        end

        function mustBeFile(filePath, context)
            %MUSTBEFILE Validate that a file exists
            %
            % MUSTBEFILE(filePath) checks if the specified file exists.
            % If not, throws an STLExtractor:Validation:FileNotFound error.
            %
            % MUSTBEFILE(filePath, context) includes context information
            % in the error message for better debugging.
            
            arguments
                filePath (1,1) string
                context (1,1) string = ""
            end
            
            if ~isfile(filePath)
                if context == ""
                    msg = sprintf('File "%s" does not exist.', filePath);
                else
                    msg = sprintf('File "%s" does not exist (context: %s).', ...
                        filePath, context);
                end
                STLExtractorError.throwError('Validation', 'FileNotFound', msg);
            end
        end

        function mustBeFolder(folderPath, context)
            %MUSTBEFOLDER Validate that a folder exists
            %
            % MUSTBEFOLDER(folderPath) checks if the specified folder exists.
            % If not, throws an STLExtractor:Validation:FolderNotFound error.
            %
            % MUSTBEFOLDER(folderPath, context) includes context information
            % in the error message for better debugging.
            
            arguments
                folderPath (1,1) string
                context (1,1) string = ""
            end
            
            if ~isfolder(folderPath)
                if context == ""
                    msg = sprintf('Folder "%s" does not exist.', folderPath);
                else
                    msg = sprintf('Folder "%s" does not exist (context: %s).', ...
                        folderPath, context);
                end
                STLExtractorError.throwError('Validation', 'FolderNotFound', msg);
            end
        end

        function mustBeNonZeroNorm(vector, vectorName, tolerance)
            %MUSTBENONZERONORM Validate that a vector has non-zero norm
            %
            % MUSTBENONZERONORM(vector, vectorName) checks if the vector
            % has a non-zero norm (> eps). If not, throws an
            % STLExtractor:Validation:NullVector error.
            %
            % MUSTBENONZERONORM(vector, vectorName, tolerance) uses a
            % custom tolerance instead of eps.
            
            arguments
                vector (1,:) double
                vectorName (1,1) string
                tolerance (1,1) double = eps
            end
            
            if norm(vector) < tolerance
                msg = sprintf('Vector "%s" must have non-zero norm (current norm: %g).', ...
                    vectorName, norm(vector));
                STLExtractorError.throwError('Validation', 'NullVector', msg);
            end
        end

        function mustBeNormalized(vector, vectorName, tolerance)
            %MUSTBENORMALIZED Validate that a vector is normalized
            %
            % MUSTBENORMALIZED(vector, vectorName) checks if the vector
            % is normalized (norm = 1 within tolerance). If not, throws an
            % STLExtractor:Validation:NotNormalized error.
            %
            % MUSTBENORMALIZED(vector, vectorName, tolerance) uses a
            % custom tolerance (default: 1e-4).
            
            arguments
                vector (1,:) double
                vectorName (1,1) string
                tolerance (1,1) double = 1e-4
            end
            
            if abs(norm(vector) - 1.0) > tolerance
                msg = sprintf('Vector "%s" must be normalized (current norm: %g).', ...
                    vectorName, norm(vector));
                STLExtractorError.throwError('Validation', 'NotNormalized', msg);
            end
        end

        function mustBePositive(value, valueName)
            %MUSTBEPOSITIVE Validate that a value is positive
            %
            % MUSTBEPOSITIVE(value, valueName) checks if the value is
            % positive. If not, throws an STLExtractor:Validation:NotPositive error.
            
            arguments
                value (1,1) double
                valueName (1,1) string
            end
            
            if value <= 0
                msg = sprintf('Value "%s" must be positive (current value: %g).', ...
                    valueName, value);
                STLExtractorError.throwError('Validation', 'NotPositive', msg);
            end
        end

        function mustBeFinite(value, valueName)
            %MUSTBEFINITE Validate that a value is finite
            %
            % MUSTBEFINITE(value, valueName) checks if the value is finite
            % (not NaN or Inf). If not, throws an STLExtractor:Validation:NotFinite error.
            
            arguments
                value double
                valueName (1,1) string
            end
            
            if ~all(isfinite(value), "all")
                msg = sprintf('Value "%s" must be finite (contains NaN or Inf).', ...
                    valueName);
                STLExtractorError.throwError('Validation', 'NotFinite', msg);
            end
        end

        function mustBeValidDirection(direction)
            %MUSTBEVALIDDIRECTION Validate that a direction is x, y, or z
            %
            % MUSTBEVALIDDIRECTION(direction) checks if the direction is
            % one of "x", "y", or "z". If not, throws an
            % STLExtractor:Validation:InvalidDirection error.
            
            arguments
                direction (1,1) string
            end
            
            validDirections = ["x", "y", "z"];
            if ~any(direction == validDirections)
                msg = sprintf('Direction must be one of %s, got "%s".', ...
                    strjoin(validDirections, ', '), direction);
                STLExtractorError.throwError('Validation', 'InvalidDirection', msg);
            end
        end

        function mustBeValidTriangulation(triangulation, context)
            %MUSTBEVALIDTRIANGULATION Validate that input is a triangulation object
            %
            % MUSTBEVALIDTRIANGULATION(triangulation) checks if the input
            % is a valid triangulation object. If not, throws an
            % STLExtractor:Validation:InvalidTriangulation error.
            %
            % MUSTBEVALIDTRIANGULATION(triangulation, context) includes
            % context information in the error message.
            
            arguments
                triangulation
                context (1,1) string = ""
            end
            
            if ~isa(triangulation, 'triangulation')
                if context == ""
                    msg = 'Input must be a triangulation object.';
                else
                    msg = sprintf('Input must be a triangulation object (context: %s).', context);
                end
                STLExtractorError.throwError('Validation', 'InvalidTriangulation', msg);
            end
        end
    end
end
