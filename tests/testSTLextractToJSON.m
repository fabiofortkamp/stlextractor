function tests = testSTLextractToJSON
tests = functiontests(localfunctions);
end

function testWritesJSONForDocumentedEntryPoint(testCase)
inputFile = fullfile(projectDir, "tests", "test_stl_files", ...
    "particle_r_1_t_1_c_0_0_0_n_0_0_1.stl");
outputFile = tempname + ".json";
cleanup = onCleanup(@() deleteIfExists(outputFile));

STLextractToJSON(inputFile, outputFile);

testCase.verifyTrue(isfile(outputFile));
decoded = jsondecode(fileread(outputFile));
testCase.verifyTrue(isfield(decoded, "items"));
testCase.verifyNumElements(decoded.items, 1);
end

function deleteIfExists(filename)
if isfile(filename)
    delete(filename);
end
end
