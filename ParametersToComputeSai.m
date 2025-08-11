%% Path settings
basePathToData = 'C:\Base\Path\To\Data';
pathToAudioFile = fullfile(basePathToData, 'Relative\Path\To\AudioFile');
pathToResults = fullfile(basePathToData, 'Relative\Path\To\Results');

%% SAI compute and process options
isBatchMode = false;
isProcessSaiAfterComputation = true;

computeOptions.isWavFile32bitIEEEFloatFormat = false;
computeOptions.isDisplaySaiDuringComputation = false;
computeOptions.isConvertStereoToMono = false;

computeOptions.CHANNEL_FROM_AUDIO_SIGNAL_TO_EXTRACT = 1;
computeOptions.DURATION_IN_SECONDS_TO_PAD_AUDIO_SIGNAL = 0;
computeOptions.REDUCTION_OF_FULL_SCALE_AMPLITUDE_IN_dB = -30;
computeOptions.SCALE_FACTOR_TO_CONVERT_REAL_SOUND_PRESSURE = 40; %2; %20;

processOptions.isProcessCochleagram = false;
processOptions.isProcessPitchogram = false;
processOptions.isProcessSpectrogram = false;
processOptions.isProcessMovieWithComposedImage = true;
processOptions.isProcessMovieWithMovieGrams = false;     % if 'true', it then requires a long time!
processOptions.isProcessMovieWithCompleteGrams = false;  % if 'true', it then requires a long time!
    
processOptions.NAME_OF_COLORMAP = 'turbo';  % 'turbo' 'grayInverted' 'artemis' 'jet'
processOptions.SPECTROGRAM_TYPE_OF_WINDOW = 'hann';
processOptions.SPECTROGRAM_NUMBER_OF_DFT_POINTS = 2048;
processOptions.SPECTROGRAM_WINDOW_OVERLAP_IN_PERCENT = 50;



%% Hints:

% computeOptions.isWavFile32bitIEEEFloatFormat
%   false: WAV 16 bit Integer (= values show no meaning of sound pressure)
%   true:  WAV 32 bit IEEE Float (= real sound pressure values)
%   If WAV file is 32 bit IEEE Float format the values represent then the 
%   original sound pressure values. Here is the reply from Dick to the 
%   question how to scale:
%   "I usually say the scaling is that 1.0 in corresponds to about
%    100 dB SPL (2 Pa), but it's not really calibrated. I just looked up
%    what I did for Figure 17.3, and found 1e-5 corresponds to 0 dB SPL
%    there, so that would be right."

% computeOptions.REDUCTION_OF_FULL_SCALE_AMPLITUDE_IN_dB
%   If WAV file is 16 bit, choose here downscaling from full scale
%   -30 dB is most reasonable, default from ../matlab/CARFAC_SAI_hacking.m
%   is -40 dB.

% computeOptions.isConvertStereoToMono
% You can choose either Stero2Mono conversion or extract a channel from
% audio signal. Both is not possible. If isConvertStereoToMono = true then
% CHANNEL_FROM_AUDIO_SIGNAL_TO_EXTRACT is ignored.