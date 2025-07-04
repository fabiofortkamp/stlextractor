function tests = testSTLExtractorError
    %TESTSTLEXTRACTORERROR Test suite for STLExtractorError utility class
    %
    % This test suite verifies that the STLExtractorError class properly
    % validates inputs and throws standardized error messages.
    
    tests = functiontests(localfunctions);
end

function testThrowError(testCase)
    %TESTHROWERROR Test custom error throwing with standardized format
    
    % Test that error ID is properly formatted
    try
        STLExtractorError.throwError('TestClass', 'TestIssue', 'Test message');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:TestClass:TestIssue');
        testCase.verifyEqual(ME.message, 'Test message');
    end
end

function testMustBeFile(testCase)
    %TESTMUSTBEFILE Test file existence validation
    
    % Test with non-existent file
    try
        STLExtractorError.mustBeFile('/non/existent/file.stl');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:FileNotFound');
        testCase.verifyTrue(contains(ME.message, '/non/existent/file.stl'));
    end
    
    % Test with context
    try
        STLExtractorError.mustBeFile('/non/existent/file.stl', 'test input');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:FileNotFound');
        testCase.verifyTrue(contains(ME.message, 'test input'));
    end
    
    % Test with existing file (this should pass without error)
    % First create a temporary file
    tempFile = tempname;
    fid = fopen(tempFile, 'w');
    fclose(fid);
    
    try
        STLExtractorError.mustBeFile(tempFile);
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for existing file');
    end
    
    % Clean up
    delete(tempFile);
end

function testMustBeFolder(testCase)
    %TESTMUSTBEFOLDER Test folder existence validation
    
    % Test with non-existent folder
    try
        STLExtractorError.mustBeFolder('/non/existent/folder');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:FolderNotFound');
        testCase.verifyTrue(contains(ME.message, '/non/existent/folder'));
    end
    
    % Test with existing folder (should pass)
    try
        STLExtractorError.mustBeFolder(tempdir);
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for existing folder');
    end
end

function testMustBeNonZeroNorm(testCase)
    %TESTMUSTBENONZERONORM Test non-zero norm validation
    
    % Test with zero vector
    try
        STLExtractorError.mustBeNonZeroNorm([0, 0, 0], 'zero vector');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NullVector');
        testCase.verifyTrue(contains(ME.message, 'zero vector'));
    end
    
    % Test with non-zero vector (should pass)
    try
        STLExtractorError.mustBeNonZeroNorm([1, 0, 0], 'unit vector');
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for non-zero vector');
    end
    
    % Test with custom tolerance
    try
        STLExtractorError.mustBeNonZeroNorm([1e-10, 0, 0], 'small vector', 1e-9);
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NullVector');
    end
end

function testMustBeNormalized(testCase)
    %TESTMUSTBENORMALIZED Test normalized vector validation
    
    % Test with non-normalized vector
    try
        STLExtractorError.mustBeNormalized([2, 0, 0], 'non-unit vector');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NotNormalized');
        testCase.verifyTrue(contains(ME.message, 'non-unit vector'));
    end
    
    % Test with normalized vector (should pass)
    try
        STLExtractorError.mustBeNormalized([1, 0, 0], 'unit vector');
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for normalized vector');
    end
end

function testMustBePositive(testCase)
    %TESTMUSTBEPOSITIVE Test positive value validation
    
    % Test with negative value
    try
        STLExtractorError.mustBePositive(-1, 'negative value');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NotPositive');
        testCase.verifyTrue(contains(ME.message, 'negative value'));
    end
    
    % Test with zero
    try
        STLExtractorError.mustBePositive(0, 'zero value');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NotPositive');
    end
    
    % Test with positive value (should pass)
    try
        STLExtractorError.mustBePositive(1, 'positive value');
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for positive value');
    end
end

function testMustBeFinite(testCase)
    %TESTMUSTBEFINITE Test finite value validation
    
    % Test with NaN
    try
        STLExtractorError.mustBeFinite(NaN, 'NaN value');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NotFinite');
        testCase.verifyTrue(contains(ME.message, 'NaN value'));
    end
    
    % Test with Inf
    try
        STLExtractorError.mustBeFinite(Inf, 'infinite value');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:NotFinite');
    end
    
    % Test with finite value (should pass)
    try
        STLExtractorError.mustBeFinite([1, 2, 3], 'finite values');
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for finite values');
    end
end

function testMustBeValidDirection(testCase)
    %TESTMUSTBEVALIDDIRECTION Test direction validation
    
    % Test with invalid direction
    try
        STLExtractorError.mustBeValidDirection('invalid');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:InvalidDirection');
        testCase.verifyTrue(contains(ME.message, 'invalid'));
    end
    
    % Test with valid directions (should pass)
    validDirections = ["x", "y", "z"];
    for dir = validDirections
        try
            STLExtractorError.mustBeValidDirection(dir);
            % Should not throw error
        catch ME
            testCase.verifyFail(sprintf('Unexpected error thrown for valid direction %s', dir));
        end
    end
end

function testMustBeValidTriangulation(testCase)
    %TESTMUSTBEVALIDTRIANGULATION Test triangulation validation
    
    % Test with invalid triangulation
    try
        STLExtractorError.mustBeValidTriangulation('not a triangulation');
        testCase.verifyFail('Expected error was not thrown');
    catch ME
        testCase.verifyEqual(ME.identifier, 'STLExtractor:Validation:InvalidTriangulation');
    end
    
    % Test with valid triangulation (should pass)
    % Create a simple triangulation
    points = [0 0; 1 0; 0 1];
    connectivity = [1 2 3];
    tri = triangulation(connectivity, points);
    
    try
        STLExtractorError.mustBeValidTriangulation(tri);
        % Should not throw error
    catch ME
        testCase.verifyFail('Unexpected error thrown for valid triangulation');
    end
end
