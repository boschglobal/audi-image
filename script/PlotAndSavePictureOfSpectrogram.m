% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Compute, plot and save Spectrogram
% -------------------------------------------------------------------------
% Compute spectrogram, plot it to a figure and save it as PNG file.

function PlotAndSavePictureOfSpectrogram( ...
    filenameOfAudioFile, ...
    audioSignalForSaiComputation, ...
    samplingFrequencyOfAudioSignal, ...
    filenameOfSpectrogramPngFileWithLinYAxis, ...
    filenameOfSpectrogramPngFileWithLogYAxis, ...
    options ...
    )
    TYPE_OF_WINDOW = options.SPECTROGRAM_TYPE_OF_WINDOW;
    NUMBER_OF_DFT_POINTS = options.SPECTROGRAM_NUMBER_OF_DFT_POINTS;
    WINDOW_OVERLAP_IN_PERCENT = options.SPECTROGRAM_WINDOW_OVERLAP_IN_PERCENT;
    WINDOW_OVERLAP_IN_SAMPLES = round(NUMBER_OF_DFT_POINTS * WINDOW_OVERLAP_IN_PERCENT/100);
    
    colormapMatrix = ReturnColormapMatrix(options.NAME_OF_COLORMAP);
    windowAsVector = eval([TYPE_OF_WINDOW '(' num2str(NUMBER_OF_DFT_POINTS) ')']);
    titleOfSpectrogramFigure = ['Spectrogram (' TYPE_OF_WINDOW ', ' num2str(NUMBER_OF_DFT_POINTS) ', ' num2str(WINDOW_OVERLAP_IN_PERCENT) ' %)' newline filenameOfAudioFile];
    
    spectrogram(audioSignalForSaiComputation, windowAsVector, WINDOW_OVERLAP_IN_SAMPLES, NUMBER_OF_DFT_POINTS, samplingFrequencyOfAudioSignal, 'yaxis')
    
    
    % Plot Spectrogram with linear y-axis (default output of spectrogram)
    colormap(colormapMatrix)
    
    title(titleOfSpectrogramFigure,'Interpreter','none')
    grid on
    
    exportgraphics(gcf,filenameOfSpectrogramPngFileWithLinYAxis)

    
    % Plot Spectrogram with logarithmic y-axis
    set(gca,'YScale','log')
    
    title(titleOfSpectrogramFigure,'Interpreter','none')
    grid on
    
    exportgraphics(gcf,filenameOfSpectrogramPngFileWithLogYAxis)
    
    CloseFigureInBatchMode(options.isBatchMode)
end