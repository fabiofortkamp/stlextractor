# Known-Untested Code

Companion to the failure-mode tests added for issue #13. Coverage is measured by
running `coverage` in the MATLAB Command Window; the HTML report under
`coverageReport/` is not checked in, so this file is the durable record of what
the suite deliberately does not exercise.

Measured on 2026-08-13 with MATLAB R2024b, on branch `develop` at commit
`1325279`. All 34 tests pass. Overall statement coverage of the measured files
is **83.5%** (the same file set `coverage.m` measures, i.e. every top-level `.m`
except `coverage.m`, `Contents.m`, `CutoffMethod.m`, and `CutoffProcedure.m`).

| File | Statements covered |
| --- | --- |
| `STLExtractor.m` | 128/131 |
| `STLExtractorError.m` | 42/45 |
| `ExtractedPacking.m` | 103/152 |
| `STLextractToJSON.m` | 23/30 |
| `HexagonalPrism.m` | 17/19 |
| `ColorFromHorPsiTheta01.m` | 0/13 |
| `HexagonalPrismFanTriangulation.m` | 37/37 |
| `PackingFigureRenderer.m` | 32/32 |
| `GeometricType.m` | 5/5 |
| `projectDir.m` | 1/1 |
| `vecnormalize.m` | 3/3 |

## Untested by design

These branches are known gaps, not oversights. Each is either untestable without
a display, redundant with a covered path, or gated on a decision that has not
been made yet.

### Figure and colour rendering

- `ExtractedPacking.m:94-124` — `plot`. Opens a figure and calls `trisurf` per
  particle. Needs a display and produces no assertable return value; the colour
  logic it delegates to is covered separately by `testPackingFigureRenderer`.
- `ColorFromHorPsiTheta01.m` (whole file, 0/13) — legacy colour helper. Grepping
  the repository finds no caller at all, including from `PackingFigureRenderer`,
  so it is unreachable rather than merely untested. This is a removal candidate,
  not a testing gap; see "Open questions" below.

### Disk output

- `STLExtractor.m:317-319` — the `shouldSave` branch of the per-particle STL
  writer. Every test constructs `STLExtractor` with `"ShouldSave", false` to keep
  the suite from writing to disk. The triangulation being written is the same
  object asserted on in the covered path.

### Redundant validation branches

- `STLExtractorError.m:85-86` — `mustBeFolder` with a non-empty `context`. The
  no-context message on the same code path is covered by `testMustBeFolder`; only
  the string interpolation differs.
- `STLExtractorError.m:212` — same pattern for `mustBeValidTriangulation`.
- `HexagonalPrism.m:23` and `HexagonalPrism.m:50` — the `faceRotation` argument
  default (never omitted by any caller under test) and `write`, which is a
  one-line `stlwrite` wrapper.
- `ExtractedPacking.m:252-253` — `filterPacking` argument defaults for `vmin` and
  `vmax`; every caller passes both explicitly.

### Untested error paths

These are reachable and worth covering eventually, but no test drives them yet.

- `ExtractedPacking.m:148-149` — `InvalidDirection` in `cutoff`. Unreachable
  through the public API as written, because `startDirection` is already
  constrained by `mustBeMember` upstream; the `otherwise` arm is defensive.
- `ExtractedPacking.m:286-287` — `NoParticlesInRange` in `filterPacking`. Firing
  this needs a packing plus a range that excludes every particle.
- `STLextractToJSON.m:41-42` — `FileOpenFailed`. Needs an unwritable output path.
- `STLextractToJSON.m:46-52` — the `catch` block, both the wrap-as-`UnhandledError`
  arm and the `rethrow` arm.
- `STLextractToJSON.m:27` — the `zMinLimit = NaN` arm, i.e. calling with
  `RemoveOutlierRangeZ` false.

### Untested feature paths

- `ExtractedPacking.m:68-75` — the `BoundingBoxLength` filter in `process`. The
  option is threaded through `STLextractToJSON` but no test supplies a value that
  actually trips the `xlim`/`ylim` comparisons.
- `ExtractedPacking.m:143-146` — the `"y"` and `"z"` arms of `cutoff`. Only `"x"`
  is exercised; the arms are structurally identical.
- `ExtractedPacking.m:178-188` — `cutoffz` in its entirety. No test calls it.

## Open questions

Two items found while measuring this are not just coverage gaps and should be
resolved rather than recorded:

1. **`CutoffMethod.vertices` is dead.** `ExtractedPacking.m:265-266` is reported
   as never executed even though `vertices` is the default method used by every
   cutoff test. The guard at line 264 is
   `strcmp(options.Method, CutoffMethod.vertices)`, and `strcmp` returns `0` for
   enumeration members (verified: `strcmp(CutoffMethod.vertices,
   CutoffMethod.vertices)` is `0`). Every call therefore falls through to the
   `centers` branch, so `"vertices"` silently behaves as `"centers"`. The fix is
   to compare with `==` instead, but that changes cutoff results for existing
   callers, so it needs its own issue and its own test.
2. **`ColorFromHorPsiTheta01.m` is orphaned.** No file in the repository calls it.
   It looks like leftover code from before `PackingFigureRenderer` existed and can
   probably be deleted.
