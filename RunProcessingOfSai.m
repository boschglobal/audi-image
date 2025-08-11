% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Process the SAI
% -------------------------------------------------------------------------
% This script initializes and processes existing SAI data (reprocessing is
% possible, too!). Prerequisite is to run the compute SAI script beforehand
% and have a summary file available! This is the main script to run the 
% processing of SAI data with some conveniant stuff like file or folder 
% picking and parameter file reading.
% Processing a SAI means: 
% - get movie of the SAI (movie file and image files of every frame)
% - get figure/image of complete cochleagram
% - get figure/image of complete pitochogram
% - get figure/image of spectrogram.



%% Clear workspace
disp('Clear workspace...')


clearvars -except ...
    isAudiImageAddedToSearchPath
close all
SCRIPTNAME_FOR_DISPCOMMANDS = 'Run processing of SAI: ';



%% Initialization


if ~exist('isAudiImageAddedToSearchPath','var') || ~isAudiImageAddedToSearchPath
    isAudiImageAddedToSearchPath = AddSearchPathForAudiImage;
end



%% Set up variables/constants
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Set up variables/constants...'])


ParametersToProcessSai;

processOptions.isBatchMode = isBatchMode;

LIST_OF_MATLAB_FILE_TYPES_TO_FILTER = { ...
    '*.mat', 'MAT-files (*.mat)' ...
    };

durationOfScriptRuntime = 0;



%% Select summary file(s) and start runtime counter


% Select summary file(s)
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Select summary file(s)...'])
[pathToResults, listOfSummaryFilenames, numberOfSummaryFiles] = ReturnListOfFilenames( ...
    isBatchMode, ...
    pathToResults, ...
    LIST_OF_MATLAB_FILE_TYPES_TO_FILTER, ...
    'summary' ...
    );
if numberOfSummaryFiles == 0
    return
end

% Start runtime counter
startOfScriptRuntime = tic;



%% Process SAI
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Process SAI...'])


numberOfActualSummaryFile = 1;
statisticsOverSingleRun(numberOfSummaryFiles) = struct;
[estimatedTimeLeft, estimatedTimeLeftAsString] = InitializeEstimatedTimeLeft;

h = waitbar(0,['0 / ',num2str(numberOfSummaryFiles),newline],'Name','Processing of SAI in progress...');
h = ConfigureRunWaitbar(h);
for i = 1:length(listOfSummaryFilenames)
    durationOfProcessRun = 0;
    if ~listOfSummaryFilenames(i).isdir
        filenameOfAudioFileSaiComputationSummary = listOfSummaryFilenames(i).name;
        waitbar(numberOfActualSummaryFile/numberOfSummaryFiles,h, ...
            [num2str(numberOfActualSummaryFile),' / ',num2str(numberOfSummaryFiles),newline, ...
            filenameOfAudioFileSaiComputationSummary,newline, ...
            'Estimated time left: ',estimatedTimeLeftAsString ...
            ])
        
        tic
        ProcessSai( ...
            filenameOfAudioFileSaiComputationSummary, ...
            pathToResults, ...
            processOptions ...
            )
        durationOfProcessRun = toc;

        statisticsOverSingleRun(numberOfActualSummaryFile).serialNumber = numberOfActualSummaryFile;
        statisticsOverSingleRun(numberOfActualSummaryFile).filenameOfAudioFileSaiComputationSummary = filenameOfAudioFileSaiComputationSummary;
        statisticsOverSingleRun(numberOfActualSummaryFile).pathToResults = pathToResults;
        statisticsOverSingleRun(numberOfActualSummaryFile).durationOfProcessRun = durationOfProcessRun;
        statisticsOverSingleRun(numberOfActualSummaryFile).dateAndTimeOfRun = char(datetime('now','Format','uuuu-MM-dd''T''HH:mm:ss'));

        disp([ ...
            '   Runtime = ',num2str(round(durationOfProcessRun,1)),' s' ...
            ])

        [estimatedTimeLeft, estimatedTimeLeftAsString] = ReturnEstimatedTimeLeft( ...
            numberOfSummaryFiles, numberOfActualSummaryFile, ...
            durationOfProcessRun, estimatedTimeLeft ...
            );
        numberOfActualSummaryFile = numberOfActualSummaryFile + 1;
    end
end
close(h)


%% Script finished


% Save runtime statistics
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Save runtime statistics...'])
filenameOfStatistics = ['RuntimeStatistics_',char(datetime('now','Format','yyyyMMdd_HHmmss')),'.xlsx'];
writetable(struct2table(statisticsOverSingleRun),filenameOfStatistics)
disp(['   Runtime statistics:  ',filenameOfStatistics])
disp(['   to path:             ',pathToResults])

% Stop runtime counter
durationOfScriptRuntime = toc(startOfScriptRuntime);
h = msgbox(['Runtime = ' char(duration(0, 0, durationOfScriptRuntime, 'Format', 'hh:mm:ss'))],'Finished','help');



%% Helper functions

function isAdded = AddSearchPathForAudiImage
    disp('   Add search paths for AudiImage...')
    
    ROOT_PATH_OF_AUDIIMAGE = fileparts(mfilename('fullpath'));
    addpath(ROOT_PATH_OF_AUDIIMAGE);
    addpath(fullfile(ROOT_PATH_OF_AUDIIMAGE,'script'));
    addpath(fullfile(ROOT_PATH_OF_AUDIIMAGE,'matlab'));
    addpath(fullfile(ROOT_PATH_OF_AUDIIMAGE,'helper'));
    isAdded = true;
end