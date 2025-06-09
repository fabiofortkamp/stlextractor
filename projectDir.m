function p = projectDir
    %PROJECTDIR Return the path to this project's root folder
    [p,~,~] = fileparts(mfilename("fullpath"));
end