# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MATLAB package (v0.11.0) that processes STL files containing packings of hexagonal prisms, extracting geometric parameters (radius, axis, volume, orientation) from the triangulated mesh.

## Commands

**Run all tests** (in MATLAB Command Window):
```matlab
runtests("tests")
```

**Run a single test file:**
```matlab
runtests("tests/testSTLExtractor")
```

**Interactive usage:**
```matlab
ex = STLExtractor("input.stl", "output_dir");
extracted_packing = ex.process();
extracted_packing.plot();
```

**CLI/batch usage:**
```bash
matlab -batch 'STLextractToJSON("input.stl","output.json")'
matlab -batch 'STLextractToJSON("input.stl","output.json","Cutoff",0.1,"CutoffDirection","y")'
```

**Add to MATLAB path:**
```matlab
addpath('/path/to/stlextractor')
```

## Architecture

### Data Flow

1. `STLExtractor` reads an STL file via `stlread()`, then builds a sparse adjacency matrix from triangle connectivity to find connected components (individual prisms).
2. Per-particle geometric analysis identifies 12 parallel edges (the hexagonal prism signature), extracting axis, height, radius, and center.
3. Each particle becomes a `HexagonalPrism` object stored in an `ExtractedPacking` collection.

### Key Classes

| Class | Role |
|-------|------|
| `STLExtractor` | Main processing class; reads STL, clusters triangles, drives extraction |
| `ExtractedPacking` | Result container with filtering (`cutoff`, `filterPacking`) and statistics (alignment, density) |
| `HexagonalPrism` | Immutable data structure for a single prism (position, radius, thickness, normal, vertices) |
| `HexagonalPrismFanTriangulation` | Generates 12 vertices + 20 triangular faces for a prism at arbitrary orientation |
| `STLExtractorError` | Centralized validation and error throwing |
| `PackingFigureRenderer` | Assigns colors by prism type for visualization |
| `GeometricType` | Compares prisms by radius+height within tolerance (1e-3) |
| `STLextractToJSON` | CLI entry point; serializes `ExtractedPacking` to JSON |

### Enumerations

- `CutoffMethod`: `vertices` or `centers` — controls which prisms are removed at the boundary
- `CutoffProcedure`: used internally by `ExtractedPacking.cutoff()`

### Private Helpers (`private/`)

- `getDirectionVector`: maps `"x"/"y"/"z"` string to unit vector
- `calculateHexagonalArea`: area from circumradius
- `mustBeNormalized`: validator for unit vectors

## Error Handling Conventions

All errors use centralized `STLExtractorError` static methods — do not use raw `error()` calls.

**Error ID format:** `STLExtractor:<Class>:<Issue>` (PascalCase for both `<Class>` and `<Issue>`)

```matlab
% Preferred validation pattern
STLExtractorError.mustBeFile(filename, "STL input");
STLExtractorError.mustBeNonZeroNorm(vector, "normal vector");
STLExtractorError.mustBePositive(radius, "radius");

% Custom errors
STLExtractorError.throwError('ClassName', 'IssueType', 'Detailed message');
```

See `docs/ErrorHandlingConventions.md` for the full reference.
