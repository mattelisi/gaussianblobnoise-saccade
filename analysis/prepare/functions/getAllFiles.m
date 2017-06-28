function fileList = getAllFiles(dirName, fullPath)
%
% List of files one directory (including all the subdirectories)
% 'fullPath' flag determine whether the whole path will be written in the 
% filename or not.
%
% Load files using: load(char(filelist(1)))
% 
% Matteo Lisi, 2013
%

if nargin < 2
    fullPath = 0;
end

dirData = dir(dirName);                   % Get the data for the current directory
dirIndex = [dirData.isdir];               % Find the index for directories
fileList = {dirData(~dirIndex).name}';    % Get a list of the files

if fullPath
    if ~isempty(fileList)
        fileList = cellfun(@(x) fullfile(dirName,x),...  % Prepend path to files
            fileList,'UniformOutput',false);
    end
end

subDirs = {dirData(dirIndex).name};             % Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});     % Find index of subdirectories that are not '.' or '..'

for iDir = find(validIndex)                       % Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    % Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  % Recursively call getAllFiles
end
