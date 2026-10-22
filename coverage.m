%COVERAGE - Run test suite and measure code coverage in the "src" folder

% Make CodeCoveragePlugin and CoverageReport directly accessible in the namespace
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport

% Create test suite based on files in the "tests" folder
suite = testsuite("tests");

% create a runner that will actually output text with information on the test results
runner = testrunner("textoutput");

% create a report under the specified folder
reportFormat = CoverageReport("coverageReport");

% collect all scripts that are tested, excluding report-only files
currentScript = string(mfilename) + ".m";
codeFiles = string({dir("*.m").name});
excludedFiles = [
    currentScript
    "Contents.m"
    "CutoffMethod.m"
    "CutoffProcedure.m"
];
codeFiles(ismember(codeFiles, excludedFiles)) = [];

% attach the coverage plugin and run the test
p = CodeCoveragePlugin.forFile(codeFiles,"Producing",reportFormat);
runner.addPlugin(p);
results = runner.run(suite);

% open the HTML report
open(fullfile("coverageReport","index.html"))
