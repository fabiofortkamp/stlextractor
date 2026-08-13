# Issue Evaluation

Evaluated on 2026-08-13.

## Repository Scope

- Local working tree: `cmt-dtu-energy/stlextractor`
- Current branch: `develop`
- Upstream issue tracker: <https://github.com/cmt-dtu-energy/stlextractor/issues>
- Fork/origin: `fabiofortkamp/stlextractor`
- Fork issue tracker status: issues disabled

The upstream repository has 11 open issues, numbered #13 through #23. No closed
issues were returned in the first 100 issues queried.

## Open Issue Themes

### Correctness and CI

- #13 Add tests for known failure modes
- #14 Verify or document Windows support
- #15 Define supported MATLAB version matrix and toolbox dependencies
- #16 Add CI with `matlab-actions/run-tests`

These issues establish the minimum confidence needed before release. Issue #16
is still open from the codebase perspective: `.github/workflows/release.yml`
exists, but it only creates GitHub releases from `Contents.m`; it does not run
the MATLAB test suite.

### Documentation and Usability

- #17 Polish README for package-facing use
- #18 Complete MATLAB help text and function reference
- #19 Expand tutorial Live Script into a full worked guide

These issues make the package usable by someone who is not already familiar with
the project. They are mostly local documentation work, although #19 involves the
MATLAB Live Script tutorial and may require MATLAB to verify the rendered result.

### Release Readiness

- #20 Add release metadata: `LICENSE`, `CITATION.cff`, maintainer note
- #21 Package as MATLAB Toolbox (`.mltbx`)
- #22 Tag `v1.0.0` release and archive with Zenodo DOI
- #23 Publish to MATLAB File Exchange

These issues are the final release chain. Issue #23 is explicitly blocked by DTU
permission and by #22.

## Suggested Implementation Order

1. #13 Add failure-mode tests.
2. #15 Define supported MATLAB versions and toolbox dependencies.
3. #14 Verify or document Windows support.
4. #16 Add MATLAB test CI.
5. #17 Polish README.
6. #18 Complete MATLAB help text and function reference.
7. #19 Expand the tutorial Live Script.
8. #20 Add release metadata.
9. #21 Package as a MATLAB Toolbox.
10. #22 Tag `v1.0.0` and archive with Zenodo.
11. #23 Publish to MATLAB File Exchange.

This order keeps external release actions at the end and resolves the main
quality gates before documentation and packaging.

## Local Repository Observations

- `README.md`, `Contents.m`, and `CHANGELOG.md` are synchronized at version
  `0.12.0`.
- Local tags exist through `v0.12.0`; there is no local `v1.0.0` tag.
- `LICENSE` and `CITATION.cff` are not present.
- `.github/workflows/release.yml` exists, but it is a release automation
  workflow, not a MATLAB test CI workflow.
- README typos matching the documentation issues were found:
  - `installting`
  - `faill`
- `ExtractedPacking.m` contains a placeholder help comment:
  `Detailed explanation goes here`.

## Work Classification

### Can Mostly Be Done Locally

- #13 failure-mode tests
- #17 README polish
- #18 MATLAB help text
- #20 release metadata files and README maintainer note

### Needs MATLAB or Platform Verification

- #14 Windows verification
- #15 MATLAB version and toolbox matrix
- #16 MATLAB test CI validation
- #19 Live Script tutorial verification
- #21 `.mltbx` packaging and install/uninstall verification

### Needs External Project or Account Action

- #22 Zenodo integration and final release tagging
- #23 DTU permission and MATLAB File Exchange publication

