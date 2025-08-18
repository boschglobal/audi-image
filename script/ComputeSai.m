% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Compute the SAI
% -------------------------------------------------------------------------
% This script computes a SAI from an audio file.
% Computing a SAI means:
% - get MAT file of the SAI
% - get MAT file of cochleagram
% - get MAT file of pitchogram

function filenameOfAudioFileSaiComputationSummary = ComputeSai( ...
    filenameOfAudioFile, ...
    pathToAudioFile, ...
    pathToResults, ...
    computeOptions ...
    )
    SCRIPTNAME_FOR_DISPCOMMANDS = 'Compute SAI: ';

    MkdirIfFolderNotExists(pathToResults)
    cd(pathToResults)



    %% Set up variables/constants
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Set up variables/constants...'])


    subfolderForAudioFile = 'Audio';
    subfolderForCochleagram = 'Cochleagram';
    subfolderForPitchogram = 'Pitchogram';
    subfolderForSai = 'SAI';



    %% Load audio file, pre-process it for CARFAC & SAI, set file and folder names for results


    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Load audio file...'])
    [audioSignal, samplingFrequencyOfAudioSignal] = audioread(fullfile(pathToAudioFile,filenameOfAudioFile));
    disp(['   Audio file:          ',filenameOfAudioFile])
    disp(['   from path:           ',pathToAudioFile])
    disp(['   Sampling frequency = ',num2str(samplingFrequencyOfAudioSignal),' Hz'])
    disp(['   # of samples =       ',num2str(length(audioSignal))])
    disp(['   Duration =           ',num2str(length(audioSignal)/samplingFrequencyOfAudioSignal),' s'])
    if computeOptions.DURATION_IN_SECONDS_TO_PAD_AUDIO_SIGNAL > 0
        disp(['   Time to pad =        ',num2str(computeOptions.DURATION_IN_SECONDS_TO_PAD_AUDIO_SIGNAL),' s'])
        disp(['   (   = # of samples = ',num2str(computeOptions.DURATION_IN_SECONDS_TO_PAD_AUDIO_SIGNAL*samplingFrequencyOfAudioSignal),' )'])
    end


    % Pre-processing of audio signal
    if computeOptions.isConvertStereoToMono
        audioSignal = ConvertStereoChannelsToMonoChannel( ...
            audioSignal ...
            );
    else
        audioSignal = ExtractChannelFromAudioSignal( ...
            audioSignal, ...
            computeOptions.CHANNEL_FROM_AUDIO_SIGNAL_TO_EXTRACT ...
            );
    end
    if computeOptions.DURATION_IN_SECONDS_TO_PAD_AUDIO_SIGNAL > 0
        audioSignal = PadAudioSignalWithSilence( ...
            audioSignal, ...
            samplingFrequencyOfAudioSignal, ...
            computeOptions.DURATION_IN_SECONDS_TO_PAD_AUDIO_SIGNAL ...
            );
    end

    if computeOptions.isWavFile32bitIEEEFloatFormat
        % See hint in parameter file for SAI computation
        audioSignalForSaiComputation = audioSignal / computeOptions.SCALE_FACTOR_TO_CONVERT_REAL_SOUND_PRESSURE;
        nameSuffixDependingOnWavType = '';
    else
        % Orignal procedure from ../matlab/CARFAC_SAI_hacking.m script
        audioSignalForSaiComputation = audioSignal * 10^(computeOptions.REDUCTION_OF_FULL_SCALE_AMPLITUDE_IN_dB/20);
        nameSuffixDependingOnWavType = ['_',num2str(computeOptions.REDUCTION_OF_FULL_SCALE_AMPLITUDE_IN_dB),'dB'];
    end

    % Set file and folder names for results
    [~,nameOfAudioFile,~] = fileparts(filenameOfAudioFile);

    MkdirIfFolderNotExists(subfolderForAudioFile)
    copyfile(fullfile(pathToAudioFile,filenameOfAudioFile), subfolderForAudioFile)

    filenameOfAudioFileSaiComputationSummary = [nameOfAudioFile,'_Summary',nameSuffixDependingOnWavType,'.mat'];

    filenameOfCompleteCochleagramMatFile = [nameOfAudioFile,'_Cochleagram',nameSuffixDependingOnWavType,'.mat'];
    filenameOfMovieCochleagramMatFile = [nameOfAudioFile,'_MovieCochleagram',nameSuffixDependingOnWavType,'.mat'];
    fullFilenameOfCompleteCochleagramMatFile = fullfile(subfolderForCochleagram,filenameOfCompleteCochleagramMatFile);
    fullFilenameOfMovieCochleagramMatFile = fullfile(subfolderForCochleagram,filenameOfMovieCochleagramMatFile);
    MkdirIfFolderNotExists(subfolderForCochleagram)

    filenameOfCompletePitchogramMatFile = [nameOfAudioFile,'_Pitchogram',nameSuffixDependingOnWavType,'.mat'];
    filenameOfMoviePitchogramMatFile = [nameOfAudioFile,'_MoviePitchogram',nameSuffixDependingOnWavType,'.mat'];
    fullFilenameOfCompletePitchogramMatFile = fullfile(subfolderForPitchogram,filenameOfCompletePitchogramMatFile);
    fullFilenameOfMoviePitchogramMatFile = fullfile(subfolderForPitchogram,filenameOfMoviePitchogramMatFile);
    MkdirIfFolderNotExists(subfolderForPitchogram)

    filenameOfSaiMatFile = [nameOfAudioFile,'_SAI',nameSuffixDependingOnWavType,'.mat'];
    fullFilenameOfSaiMatFile = fullfile(subfolderForSai,filenameOfSaiMatFile);
    MkdirIfFolderNotExists(subfolderForSai)

    fullFilenamesForSaiResults = struct( ...
        'OfSaiMatFile', fullFilenameOfSaiMatFile, ...
        'OfCompleteCochleagramMatFile', fullFilenameOfCompleteCochleagramMatFile, ...
        'OfMovieCochleagramMatFile', fullFilenameOfMovieCochleagramMatFile, ...
        'OfCompletePitchogramMatFile', fullFilenameOfCompletePitchogramMatFile, ...
        'OfMoviePitchogramMatFile', fullFilenameOfMoviePitchogramMatFile ...
        );


    %% Computation of CARFAC model and SAI
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Compute CARFAC model and SAI...'])


    disp('   Call CARFAC_Design...')
    CF_struct = CARFAC_Design(1, samplingFrequencyOfAudioSignal);

    disp('   Call CARFAC_Init...')
    CF_struct = CARFAC_Init(CF_struct);

    disp('   Call SAI_RunLayered...')
    [frameRateOfSaiMovie, numberOfFramesOfSaiMovie] = SAI_RunLayered( ...
        CF_struct, ...
        audioSignalForSaiComputation, ...
        fullFilenamesForSaiResults, ...
        computeOptions ...
        );



    %% Save summary
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Save summary...'])


    save(fullfile(pwd,filenameOfAudioFileSaiComputationSummary), ...
        'audioSignalForSaiComputation', ...
        'samplingFrequencyOfAudioSignal', ...
        'filenameOfAudioFile', ...
        'pathToAudioFile', ...
        'pathToResults', ...
        'subfolderForAudioFile', ...
        'subfolderForSai', ...
        'subfolderForCochleagram', ...
        'subfolderForPitchogram', ...
        'filenameOfSaiMatFile', ...
        'fullFilenameOfSaiMatFile', ...
        'filenameOfCompleteCochleagramMatFile', ...
        'fullFilenameOfCompleteCochleagramMatFile', ...
        'filenameOfMovieCochleagramMatFile', ...
        'fullFilenameOfMovieCochleagramMatFile', ...
        'filenameOfCompletePitchogramMatFile', ...
        'fullFilenameOfCompletePitchogramMatFile', ...
        'filenameOfMoviePitchogramMatFile', ...
        'fullFilenameOfMoviePitchogramMatFile', ...
        'frameRateOfSaiMovie', ...
        'numberOfFramesOfSaiMovie', ...
        'nameSuffixDependingOnWavType', ...
        'computeOptions', ...
        '-v7.3' ...
        )

    disp(['   Summary file:        ',filenameOfAudioFileSaiComputationSummary])
    disp(['   to path:             ',pathToResults])

    
    
    %% Finished
    disp([SCRIPTNAME_FOR_DISPCOMMANDS,'Finished.'])
end



%% Helper functions

function outputSignal = ConvertStereoChannelsToMonoChannel(inputSignal)
    outputSignal = mean(inputSignal,2);
end

function outputSignal = ExtractChannelFromAudioSignal(inputSignal, channelToExtract)
    outputSignal = inputSignal(:, channelToExtract);
end

function outputSignal = PadAudioSignalWithSilence(inputSignal, samplingFrequency, durationToPad)
    outputSignal = [inputSignal; zeros(samplingFrequency * durationToPad, size(inputSignal,2))];
end