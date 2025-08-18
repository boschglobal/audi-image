% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Process the SAI
% -------------------------------------------------------------------------
% This script can (re)process existing SAI data (this means you need to run 
% the compute SAI script first and have a summary file available).
% Processing a SAI means:
% - get movie of the SAI (movie file and image files of every frame)
% - get figure/image of complete cochleagram
% - get figure/image of complete pitchogram
% - get figure/image of spectrogram.

function ProcessSai( ...
    filenameOfAudioFileSaiComputationSummary, ...
    pathToResults, ...
    processOptions ...
    )
    SCRIPTNAME_FOR_DISPCOMMANDS = 'Process SAI: ';
    
    cd(pathToResults)


    
    %% Set up variables/constants
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Set up variables/constants...'])


    namePatternForSaiFrames = 'frame%05d.png';

    subfolderForSaiFrames = 'Movie';
    subfolderForSpectrogram = 'Spectrogram';



    %% Load summary file and set base name for files and folders

    
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Load summary file...'])
    load(fullfile(pwd,filenameOfAudioFileSaiComputationSummary), ...
        'audioSignalForSaiComputation', ...
        'samplingFrequencyOfAudioSignal', ...
        'filenameOfAudioFile', ...
        'subfolderForAudioFile', ...
        'nameSuffixDependingOnWavType', ...
        'fullFilenameOfSaiMatFile', ...
        'fullFilenameOfCompleteCochleagramMatFile', ...
        'fullFilenameOfCompletePitchogramMatFile', ...
        'fullFilenameOfMovieCochleagramMatFile', ...
        'fullFilenameOfMoviePitchogramMatFile', ...
        'frameRateOfSaiMovie' ...
        );
    disp(['   Summary file:        ',filenameOfAudioFileSaiComputationSummary])
    disp(['   from path:           ',pathToResults])
    
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Set base name for files and folders...'])
    [~,nameOfAudioFile,~] = fileparts(filenameOfAudioFile);
    nameSuffixDependingOnColormap = ['_',processOptions.NAME_OF_COLORMAP];



    %% Movie with composed image
    %  The "original" variant from ../matlab/CARFAC_SAI_hacking.m script
    
 
    if processOptions.isProcessMovieWithComposedImage
        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Make movie with composed image...'])

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Set file and folder names...'])
        filenameOfSaiMovieFile = [nameOfAudioFile,nameSuffixDependingOnWavType,nameSuffixDependingOnColormap,'_ComposedImage.mpg'];
        [~,folderForSaiFramesWithComposedImage,~] = fileparts(filenameOfSaiMovieFile);
        fullFolderForSaiFramesWithComposedImage = fullfile(subfolderForSaiFrames,folderForSaiFramesWithComposedImage);
        MkdirIfFolderNotExists(subfolderForSaiFrames)
        mkdir(subfolderForSaiFrames,folderForSaiFramesWithComposedImage);

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Process frames for movie...'])
        ProcessFramesForMovieWithComposedImage( ...
            fullFilenameOfSaiMatFile, ...
            fullFilenameOfMovieCochleagramMatFile, ...
            fullFilenameOfMoviePitchogramMatFile, ...
            fullFolderForSaiFramesWithComposedImage, ...
            namePatternForSaiFrames, ...
            processOptions ...
            )

        dispWithTrailingNewline([SCRIPTNAME_FOR_DISPCOMMANDS,'      Convert frames to a movie...'])
        MakeMovieFromPngsAndWav( ...
            round(frameRateOfSaiMovie), ...
            fullfile(fullFolderForSaiFramesWithComposedImage,namePatternForSaiFrames), ...
            fullfile(subfolderForAudioFile,filenameOfAudioFile), ...
            fullfile(subfolderForSaiFrames,filenameOfSaiMovieFile) ...
            )

        dispWithPrecedingNewline([SCRIPTNAME_FOR_DISPCOMMANDS,'      ZIP frames of movie...'])
        ZipAndRemoveFrames(subfolderForSaiFrames,folderForSaiFramesWithComposedImage)

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Movie creation finished.'])
    end
    
    
    
    %% Movie with full-fledged figures
    %  with cochleagram and pitchogram like in the movie
    
    
    if processOptions.isProcessMovieWithMovieGrams
        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Make movie with full-fledged figures with cochleagram and pitchogram like in the movie...'])

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Set file and folder names...'])
        filenameOfSaiMovieFileWithMovieGrams = [nameOfAudioFile,nameSuffixDependingOnWavType,nameSuffixDependingOnColormap,'_MovieGrams.mpg'];
        [~,folderForSaiFramesWithMovieGrams,~] = fileparts(filenameOfSaiMovieFileWithMovieGrams);
        fullFolderForSaiFramesWithMovieGrams = fullfile(subfolderForSaiFrames,folderForSaiFramesWithMovieGrams);
        MkdirIfFolderNotExists(subfolderForSaiFrames)
        mkdir(subfolderForSaiFrames,folderForSaiFramesWithMovieGrams);

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Process frames for movie...'])
        ProcessFramesForMovieWithFullfledgedFiguresWithMovieGrams( ...
            filenameOfAudioFile, ...
            fullFilenameOfSaiMatFile, ...
            fullFilenameOfMovieCochleagramMatFile, ...
            fullFilenameOfMoviePitchogramMatFile, ...
            fullFolderForSaiFramesWithMovieGrams, ...
            namePatternForSaiFrames, ...
            processOptions ...
            )

        dispWithTrailingNewline([SCRIPTNAME_FOR_DISPCOMMANDS,'      Convert frames to a movie...'])
        MakeMovieFromPngsAndWav( ...
            round(frameRateOfSaiMovie), ...
            fullfile(fullFolderForSaiFramesWithMovieGrams,namePatternForSaiFrames), ...
            fullfile(subfolderForAudioFile,filenameOfAudioFile), ...
            fullfile(subfolderForSaiFrames,filenameOfSaiMovieFileWithMovieGrams) ...
            )

        dispWithPrecedingNewline([SCRIPTNAME_FOR_DISPCOMMANDS,'      ZIP frames of movie...'])
        ZipAndRemoveFrames(subfolderForSaiFrames,folderForSaiFramesWithMovieGrams)

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Movie creation finished.'])
    end
    


    %% Movie with full-fledged figures
    %  with complete cochleagram and pitchogram
    
    
    if processOptions.isProcessMovieWithCompleteGrams
        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Make movie with full-fledged figures with complete cochleagram and pitchogram...'])

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Set file and folder names...'])
        filenameOfSaiMovieFileWithCompleteGrams = [nameOfAudioFile,nameSuffixDependingOnWavType,nameSuffixDependingOnColormap,'_CompleteGrams.mpg'];
        [~,folderForSaiFramesWithCompleteGrams,~] = fileparts(filenameOfSaiMovieFileWithCompleteGrams);
        fullFolderForSaiFramesWithCompleteGrams = fullfile(subfolderForSaiFrames,folderForSaiFramesWithCompleteGrams);
        MkdirIfFolderNotExists(subfolderForSaiFrames)
        mkdir(subfolderForSaiFrames,folderForSaiFramesWithCompleteGrams);

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Process frames for movie...'])
        ProcessFramesForMovieWithFullfledgedFiguresWithCompleteGrams( ...
            filenameOfAudioFile, ...
            fullFilenameOfSaiMatFile, ...
            fullFilenameOfCompleteCochleagramMatFile, ...
            fullFilenameOfCompletePitchogramMatFile, ...
            fullFolderForSaiFramesWithCompleteGrams, ...
            namePatternForSaiFrames, ...
            processOptions ...
            )

        dispWithTrailingNewline([SCRIPTNAME_FOR_DISPCOMMANDS,'      Convert frames to a movie...'])
        MakeMovieFromPngsAndWav( ...
            round(frameRateOfSaiMovie), ...
            fullfile(fullFolderForSaiFramesWithCompleteGrams,namePatternForSaiFrames), ...
            fullfile(subfolderForAudioFile,filenameOfAudioFile), ...
            fullfile(subfolderForSaiFrames,filenameOfSaiMovieFileWithCompleteGrams) ...
            )

        dispWithPrecedingNewline([SCRIPTNAME_FOR_DISPCOMMANDS,'      ZIP frames of movie...'])
        ZipAndRemoveFrames(subfolderForSaiFrames,folderForSaiFramesWithCompleteGrams)

        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'      Movie creation finished.'])
    end
    
    

    %% Plot and write PNG for cochleagram, pitchogram and spectrogram
    %  depending on options what to process

    
    if processOptions.isProcessCochleagram
        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Plot and write cochleagram...'])
        PlotAndSavePictureOfCompleteCochleagram( ...
            filenameOfAudioFile, ...
            fullFilenameOfCompleteCochleagramMatFile, ...
            processOptions ...
            )
    end
    
    if processOptions.isProcessPitchogram
        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Plot and write pitchogram...'])
        PlotAndSavePictureOfCompletePitchogram( ...
            filenameOfAudioFile, ...
            fullFilenameOfCompletePitchogramMatFile, ...
            processOptions ...
            )
    end
    
    if processOptions.isProcessSpectrogram
        disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Plot and write spectrogram...'])
        filenameOfSpectrogramPngFileWithLinYAxis = [nameOfAudioFile,'_Spectrogram',nameSuffixDependingOnWavType,nameSuffixDependingOnColormap,'_LinYAxis.png'];
        filenameOfSpectrogramPngFileWithLogYAxis = [nameOfAudioFile,'_Spectrogram',nameSuffixDependingOnWavType,nameSuffixDependingOnColormap,'_LogYAxis.png'];
        fullFilenameOfSpectrogramPngFileWithLinYAxis = fullfile(subfolderForSpectrogram,filenameOfSpectrogramPngFileWithLinYAxis);
        fullFilenameOfSpectrogramPngFileWithLogYAxis = fullfile(subfolderForSpectrogram,filenameOfSpectrogramPngFileWithLogYAxis);
        MkdirIfFolderNotExists(subfolderForSpectrogram)

        PlotAndSavePictureOfSpectrogram( ...
            filenameOfAudioFile, ...
            audioSignalForSaiComputation, ...
            samplingFrequencyOfAudioSignal, ...
            fullFilenameOfSpectrogramPngFileWithLinYAxis, ...
            fullFilenameOfSpectrogramPngFileWithLogYAxis, ...
            processOptions ...
            )
    end

    

    %% Finished
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Finished.'])
end



%% Helper functions

function ZipAndRemoveFrames(subfolderForFrames,folderForFramesOfAudioFile)
    zip( ...
        fullfile(subfolderForFrames,folderForFramesOfAudioFile), ...
        '*.png', ...
        fullfile(subfolderForFrames,folderForFramesOfAudioFile) ...
        )

    rmdir(fullfile(subfolderForFrames,folderForFramesOfAudioFile),'s')
end

function dispWithTrailingNewline(messageToDisp)
    disp([messageToDisp,newline])
end

function dispWithPrecedingNewline(messageToDisp)
    disp([newline,messageToDisp])
end