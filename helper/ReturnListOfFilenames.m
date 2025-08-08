% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Return a list of filenames
% -------------------------------------------------------------------------
% You can choose between 3 options:
% 1) Select one single file (isMultipleFiles = false)
% 2) Select multiple files (isMultipleFiles = true)
% 3) Select a folder (isMultipleFiles = true)

function [pathToFiles, listOfFilenames, numberOfFiles] = ReturnListOfFilenames( ...
    isMultipleFiles, ...
    pathToFiles, ...
    LIST_OF_FILE_TYPES_TO_FILTER, ...
    nameOfFileType ...
    )
    if isMultipleFiles
        answerIsMultiselection = 'Multiple files';
        answerIsFolder = 'Folder';
        answerIsCancel = 'Cancel';
        answerOfQuestdlg = questdlg( ...
            'Do you want to select multiple files or a folder?', ...
            'Select type of batch mode', ...
            answerIsMultiselection, ...
            answerIsFolder, ...
            answerIsCancel, ...
            answerIsCancel ...
            );

        switch answerOfQuestdlg
            case answerIsMultiselection
                disp(['   Select multiple ' nameOfFileType ' files...'])
                [filenamesOfMultipleFiles,pathToFiles,isCanceled] = uigetfile( ...
                    LIST_OF_FILE_TYPES_TO_FILTER, ['Select ' nameOfFileType ' files'], pathToFiles,'MultiSelect','on');
                
                if isCanceled == 0
                    [listOfFilenames, numberOfFiles] = ShowStopMessage(1);
                    return
                end
                
                pathToFiles = CheckIfPathEndsWithFilesep(pathToFiles);
                
                if class(filenamesOfMultipleFiles) == 'char'
                    listOfFilenames(1).name = filenamesOfMultipleFiles;
                    listOfFilenames(1).isdir = false;
                    numberOfFiles = 1;
                else
                    numberOfFiles = length(filenamesOfMultipleFiles);
                    listOfFilenames(numberOfFiles) = struct;
                    for i = 1:numberOfFiles
                        listOfFilenames(i).name = char(filenamesOfMultipleFiles(i));
                        listOfFilenames(i).isdir = false;
                    end
                end
            case answerIsFolder
                disp(['   Select folder with ' nameOfFileType ' files...'])
                pathToFiles = uigetdir(pathToFiles, ['Select folder with ' nameOfFileType ' files']);
                if pathToFiles == 0
                    [listOfFilenames, numberOfFiles] = ShowStopMessage(1);
                    return
                end
                numberOfFileTypes = size(LIST_OF_FILE_TYPES_TO_FILTER,1);
                for index = 1:numberOfFileTypes
                    fileType = char(split(LIST_OF_FILE_TYPES_TO_FILTER{index},';'));
                    numberOfSubFileTypes = size(fileType,1);
                    for subindex = 1:numberOfSubFileTypes
                        if ~exist('listOfFilenames','var')
                            listOfFilenames = dir(fullfile(pathToFiles,fileType(subindex,:)));
                        else
                            listOfFilenames = [listOfFilenames;dir(fullfile(pathToFiles,fileType(subindex,:)))];
                        end
                    end
                end
                numberOfFiles = length(find([listOfFilenames.isdir] == false));
            case answerIsCancel
                [listOfFilenames, numberOfFiles] = ShowStopMessage(1);
                return
        end
    else
        disp(['   Select ' nameOfFileType ' file...'])
        [listOfFilenames(1).name,pathToFiles,isCanceled] = uigetfile( ...
            LIST_OF_FILE_TYPES_TO_FILTER, ['Select ' nameOfFileType ' file'], pathToFiles);
        
        if isCanceled == 0
            [listOfFilenames, numberOfFiles] = ShowStopMessage(1);
            return
        end
        
        pathToFiles = CheckIfPathEndsWithFilesep(pathToFiles);
        listOfFilenames(1).isdir = false;
        numberOfFiles = 1;
    end
end



%% Helper functions

function [listOfFilenames, numberOfFiles] = ShowStopMessage(msg)
    switch msg
        case 1
            warning('Stop script: Cancel or window close button was clicked in file open dialog.')
        case 2
            warning('Stop script: Cancel button was clicked in question dialog box.')
    end
    
    listOfFilenames = 0;
    numberOfFiles = 0;
end

function pathToFiles = CheckIfPathEndsWithFilesep(pathToFiles)
    if pathToFiles(end) == filesep
        pathToFiles = pathToFiles(1:end-1);
    end
end