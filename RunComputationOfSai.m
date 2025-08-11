% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Compute the SAI
% -------------------------------------------------------------------------
% This script initializes and computes SAI from audio file(s). This is the 
% main script to run the computation of SAI with some conveniant stuff like
% file or folder picking and parameter file reading.
% Optionally you can process the obtained SAI data directly afterwards.
% Computing a SAI means:
% - get MAT file of the SAI
% - get MAT file of cochleagram
% - get MAT file of pitchogram
% - optional: process the SAI (see process SAI script for details)



%% Clear workspace
disp('Clear workspace...')


clearvars -except ...
    isAudiImageAddedToSearchPath
close all
SCRIPTNAME_FOR_DISPCOMMANDS = 'Run computation of SAI: ';



%% Initialization


if ~exist('isAudiImageAddedToSearchPath','var') || ~isAudiImageAddedToSearchPath
    isAudiImageAddedToSearchPath = AddSearchPathForAudiImage;
end



%% Set up variables/constants
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Set up variables/constants...'])


ParametersToComputeSai;

computeOptions.isBatchMode = isBatchMode;
processOptions.isBatchMode = isBatchMode;

LIST_OF_AUDIO_FILE_TYPES_TO_FILTER = { ...
    '*.wav', 'WAVE (*.wav)'; ...
    '*.ogg', 'OGG (*.ogg)'; ...
    '*.flac', 'FLAC (*.flac)'; ...
    '*.au', 'AU (*.au)'; ...
    '*.aiff;*.aif', 'AIFF (*.aiff, *.aif)'; ...
    '*.aifc', 'AIFC (*.aifc)'; ...
    '*.mp3', 'MP3 (*.mp3)'; ...
    '*.m4a;*.mp4', 'MPEG-4 AAC (*.m4a, *.mp4)' ...
    };

durationOfScriptRuntime = 0;



%% Select audio file(s) and start runtime counter


% Select audio file(s)
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Select audio file(s)...'])
[pathToAudioFile, listOfAudioFilenames, numberOfAudioFiles] = ReturnListOfFilenames( ...
    isBatchMode, ...
    pathToAudioFile, ...
    LIST_OF_AUDIO_FILE_TYPES_TO_FILTER, ...
    'audio' ...
    );
if numberOfAudioFiles == 0
    return
end

% Start runtime counter
startOfScriptRuntime = tic;



%% Compute SAI
disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Compute SAI...'])


numberOfActualAudioFile = 1;
statisticsOverSingleRun(numberOfAudioFiles) = struct;
[estimatedTimeLeft, estimatedTimeLeftAsString] = InitializeEstimatedTimeLeft;

h = waitbar(0,['0 / ',num2str(numberOfAudioFiles),newline],'Name','Computation of SAI in progress...');
h = ConfigureRunWaitbar(h);
for i = 1:length(listOfAudioFilenames)
    durationOfProcessRun = 0;
    if ~listOfAudioFilenames(i).isdir
        filenameOfAudioFile = listOfAudioFilenames(i).name;
        waitbar(numberOfActualAudioFile/numberOfAudioFiles,h, ...
            [num2str(numberOfActualAudioFile),' / ',num2str(numberOfAudioFiles),newline, ...
            filenameOfAudioFile,newline, ...
            'Estimated time left: ',estimatedTimeLeftAsString ...
            ])
        
        startOfWholeRun = tic;
        
        filenameOfAudioFileSaiComputationSummary = ComputeSai( ...
            filenameOfAudioFile, ...
            pathToAudioFile, ...
            pathToResults, ...
            computeOptions ...
            );

        if isProcessSaiAfterComputation
            disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Process SAI...'])
            tic
            ProcessSai( ...
                filenameOfAudioFileSaiComputationSummary, ...
                pathToResults, ...
                processOptions ...
                )
            durationOfProcessRun = toc;
        end

        durationOfWholeRun = toc(startOfWholeRun);
        durationOfComputeRun = durationOfWholeRun - durationOfProcessRun;

        statisticsOverSingleRun(numberOfActualAudioFile).serialNumber = numberOfActualAudioFile;
        statisticsOverSingleRun(numberOfActualAudioFile).filenameOfAudioFile = filenameOfAudioFile;
        statisticsOverSingleRun(numberOfActualAudioFile).pathToAudioFile = pathToAudioFile;
        statisticsOverSingleRun(numberOfActualAudioFile).filenameOfAudioFileSaiComputationSummary = filenameOfAudioFileSaiComputationSummary;
        statisticsOverSingleRun(numberOfActualAudioFile).pathToResults = pathToResults;
        statisticsOverSingleRun(numberOfActualAudioFile).durationOfWholeRun = durationOfWholeRun;
        statisticsOverSingleRun(numberOfActualAudioFile).durationOfComputeRun = durationOfComputeRun;
        statisticsOverSingleRun(numberOfActualAudioFile).durationOfProcessRun = durationOfProcessRun;
        statisticsOverSingleRun(numberOfActualAudioFile).isProcessSaiAfterComputation = isProcessSaiAfterComputation;
        statisticsOverSingleRun(numberOfActualAudioFile).dateAndTimeOfRun = char(datetime('now','Format','uuuu-MM-dd''T''HH:mm:ss'));

        disp([ ...
            '   Runtime = ',num2str(round(durationOfWholeRun,1)),' s  |  ', ...
            'Time to compute SAI = ',num2str(round(durationOfComputeRun,1)),' s  |  ', ...
            'Time to process SAI = ',num2str(round(durationOfProcessRun,1)),' s' ...
            ])

        [estimatedTimeLeft, estimatedTimeLeftAsString] = ReturnEstimatedTimeLeft( ...
            numberOfAudioFiles, numberOfActualAudioFile, ...
            durationOfWholeRun, estimatedTimeLeft ...
            );
        numberOfActualAudioFile = numberOfActualAudioFile + 1;
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