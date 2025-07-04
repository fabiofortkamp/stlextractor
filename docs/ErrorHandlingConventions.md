# STLExtractor Error Handling Conventions

This document describes the error handling conventions and best practices for the STLExtractor project.

## Overview

The STLExtractor project uses a centralized error handling system through the `STLExtractorError` utility class. This approach ensures consistent error messages, standardized error IDs, and reduces code duplication across the codebase.

## Error ID Format

All errors follow the standardized format:
```
STLExtractor:<Class>:<Issue>
```

Where:
- **STLExtractor**: Project namespace prefix
- **Class**: The class or module where the error occurs (e.g., `HexagonalPrism`, `Validation`, `ExtractedPacking`)
- **Issue**: A descriptive name for the specific error type (e.g., `NullVector`, `FileNotFound`, `InvalidInput`)

## Common Validation Functions

The `STLExtractorError` class provides several common validation functions:

### File and Directory Validation
```matlab
% Validate file existence
STLExtractorError.mustBeFile('/path/to/file.stl');
STLExtractorError.mustBeFile('/path/to/file.stl', 'STL input');

% Validate directory existence  
STLExtractorError.mustBeFolder('/path/to/directory');
STLExtractorError.mustBeFolder('/path/to/directory', 'output directory');
```

### Numeric Validation
```matlab
% Validate positive values
STLExtractorError.mustBePositive(radius, 'radius');

% Validate finite values (no NaN/Inf)
STLExtractorError.mustBeFinite(coordinates, 'vertex coordinates');
```

### Vector Validation
```matlab
% Validate non-zero norm vectors
STLExtractorError.mustBeNonZeroNorm([1,0,0], 'normal vector');
STLExtractorError.mustBeNonZeroNorm(direction, 'direction', 1e-6); % custom tolerance

% Validate normalized vectors
STLExtractorError.mustBeNormalized([1,0,0], 'unit vector');
STLExtractorError.mustBeNormalized(normal, 'normal', 1e-6); % custom tolerance
```

### Direction Validation
```matlab
% Validate direction strings (x, y, z)
STLExtractorError.mustBeValidDirection("x");
```

### Object Validation
```matlab
% Validate triangulation objects
STLExtractorError.mustBeValidTriangulation(tri);
STLExtractorError.mustBeValidTriangulation(tri, 'mesh generation');
```

## Custom Error Throwing

For specific error cases not covered by the validation functions:

```matlab
% Throw custom errors with standardized format
STLExtractorError.throwError('ClassName', 'IssueType', 'Detailed error message');

% Examples:
STLExtractorError.throwError('HexagonalPrism', 'InvalidGeometry', ...
    'Hexagonal prism dimensions are inconsistent');

STLExtractorError.throwError('STLExtractor', 'ProcessingFailed', ...
    'Unable to extract particles from STL file');
```

## Migration from Legacy Error Handling

### Before (Legacy)
```matlab
if norm(vector) < eps
    error("STLExtractor:HexagonalPrism:nullVectorInputError", ...
        "`normal` argument must have non-zero norm.");
end

if ~isfile(filename)
    error('File %s does not exist', filename);
end
```

### After (Centralized)
```matlab
STLExtractorError.mustBeNonZeroNorm(vector, "normal");

STLExtractorError.mustBeFile(filename, "STL input");
```

## Benefits

1. **Consistency**: All errors follow the same ID format and structure
2. **Maintainability**: Error handling logic is centralized and reusable
3. **Documentation**: Self-documenting validation functions with clear names
4. **Debugging**: Standardized error messages with context information
5. **Testing**: Easier to test error conditions with predictable error IDs

## Best Practices

1. **Use validation functions** for common checks instead of writing custom error logic
2. **Provide context** when calling validation functions (e.g., parameter names, operation context)
3. **Follow naming conventions** for error classes and issues:
   - Class names should match the actual MATLAB class or logical module
   - Issue names should be descriptive and use PascalCase (e.g., `InvalidInput`, `FileNotFound`)
4. **Include helpful messages** that guide users toward resolution
5. **Use custom tolerances** when default tolerances are not appropriate for your use case

## Error Classes Used in STLExtractor

- **Validation**: Generic validation errors (file/folder existence, numeric validation, etc.)
- **HexagonalPrism**: Errors specific to hexagonal prism construction and validation
- **ExtractedPacking**: Errors related to packing operations and filtering
- **STLExtractor**: Main extractor class errors (file processing, particle extraction)

## Example Usage in Classes

```matlab
classdef MyClass
    methods
        function obj = MyClass(inputFile, radius, normal)
            % Validate inputs using centralized utilities
            STLExtractorError.mustBeFile(inputFile, "input STL file");
            STLExtractorError.mustBePositive(radius, "radius");
            STLExtractorError.mustBeNonZeroNorm(normal, "normal vector");
            
            % ... rest of constructor
        end
        
        function result = processData(obj, direction)
            STLExtractorError.mustBeValidDirection(direction);
            
            % ... processing logic
            
            if someConditionFails
                STLExtractorError.throwError('MyClass', 'ProcessingFailed', ...
                    'Unable to process data due to insufficient input');
            end
        end
    end
end
```

This centralized approach makes the codebase more maintainable and provides a consistent user experience when errors occur.
