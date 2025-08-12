%% Path settings
basePathToResults = 'C:\Base\Path\To\Results';
pathToResults = fullfile(basePathToResults, 'Relative\Path\To\Results');

%% SAI process options
isBatchMode = false;

processOptions.isProcessCochleagram = true;
processOptions.isProcessPitchogram = true;
processOptions.isProcessSpectrogram = true;
processOptions.isProcessMovieWithComposedImage = true;
processOptions.isProcessMovieWithMovieGrams = false;     % if 'true', it then requires a long time!
processOptions.isProcessMovieWithCompleteGrams = false;  % if 'true', it then requires a long time!

processOptions.NAME_OF_COLORMAP = 'turbo';  % 'turbo' 'grayInverted' 'analyzer' 'jet'
processOptions.SPECTROGRAM_TYPE_OF_WINDOW = 'hann';
processOptions.SPECTROGRAM_NUMBER_OF_DFT_POINTS = 2048;
processOptions.SPECTROGRAM_WINDOW_OVERLAP_IN_PERCENT = 50;