% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Plot and save complete Cochleagram
% -------------------------------------------------------------------------
% Open complete Cochleagram, plot it to a figure and save it as PNG file.

function PlotAndSavePictureOfCompleteCochleagram( ...
    filenameOfAudioFile, ...
    filenameOfCompleteCochleagramMatFile, ...
    options ...
    )
    SCALE_FACTOR_TO_STRETCH_TO_COLORMAP = 256 / 1;  % 256 = steps of colormap, 1 = expected max value of data to plot

    load(filenameOfCompleteCochleagramMatFile, ...
        'completeCochleagram', ...
        'timeAxisOfCompleteCochleagram', ...
        'frequencyAxisOfCompleteCochleagram', ...
        'frameRateOfSaiMovie' ...
        )

    colormapMatrix = ReturnColormapMatrix(options.NAME_OF_COLORMAP);
    
    % Frequency axis: set ticks and ticklabels
    ticksForFrequencyAxisInHz = [ 50 100 200 500 1000 2000 5000 10000 ];
    [~, indicesOfTicksForFrequencyAxis] = min(abs((frequencyAxisOfCompleteCochleagram' - ticksForFrequencyAxisInHz')'));
    ticklabelsForFrequencyAxisInHz = num2cell(ticksForFrequencyAxisInHz);

    % Time axis: set ticks and ticklabels
    indicesOfTicksForTimeAxis = ReturnIndicesOfTicksForTimeAxis(timeAxisOfCompleteCochleagram, frameRateOfSaiMovie);
    ticklabelsForTimeAxisInSeconds = num2cell(timeAxisOfCompleteCochleagram(indicesOfTicksForTimeAxis));
    ticklabelsForTimeAxisInSeconds(end) = num2cell(round(ticklabelsForTimeAxisInSeconds{end},1));
    
    % Set name of file to save figure as PNG
    [pathToCompleteCochleagramMatFile,nameOfCompleteCochleagramMatFile,~] = fileparts(filenameOfCompleteCochleagramMatFile);
    fullFilenameOfCompleteCochleagramPngFile = fullfile(pathToCompleteCochleagramMatFile,[nameOfCompleteCochleagramMatFile,'_',options.NAME_OF_COLORMAP,'.png']);
    
    
    figure
    image(SCALE_FACTOR_TO_STRETCH_TO_COLORMAP * completeCochleagram)
    colormap(colormapMatrix)
    
    set(gca,'TickDir','out')
    
    yticks(flip(indicesOfTicksForFrequencyAxis))
    yticklabels(flip(ticklabelsForFrequencyAxisInHz))
    ylabel('Frequency in Hz')

    xticks(indicesOfTicksForTimeAxis)    
    xticklabels(ticklabelsForTimeAxisInSeconds)
    xlabel('Time in s')
    
    title(['Cochleagram' newline filenameOfAudioFile],'Interpreter','none')
    colorbar
    c = colorbar;
    c.Ticks = [1 64:64:256];
    c.TickLabels = round(c.Ticks / SCALE_FACTOR_TO_STRETCH_TO_COLORMAP,2);
    c.Label.String = 'Magnitude';
    grid on
    
    exportgraphics(gcf,fullFilenameOfCompleteCochleagramPngFile)
    CloseFigureInBatchMode(options.isBatchMode)
end