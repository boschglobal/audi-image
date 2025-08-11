% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Plot and save complete Pitchogram
% -------------------------------------------------------------------------
% Open complete Pitchogram, plot it to a figure and save it as PNG file.

function PlotAndSavePictureOfCompletePitchogram( ...
    filenameOfAudioFile, ...
    filenameOfCompletePitchogramMatFile, ...
    options ...
    )
    SCALE_FACTOR_TO_STRETCH_TO_COLORMAP = 256 / 1.5;    % 256 = steps of colormap, 1.5 = expected max value of data to plot

    load(filenameOfCompletePitchogramMatFile, ...
        'completePitchogram', ...
        'timeAxisOfCompletePitchogram', ...
        'lagAxisInHzOfCompletePitchogram', ...
        'frameRateOfSaiMovie' ...
        )

    colormapMatrix = ReturnColormapMatrix(options.NAME_OF_COLORMAP);
    
    % Lag axis: set ticks and ticklabels
    ticksForLagAxisInHz = [ 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 ];
    [~, indicesOfTicksForLagAxis] = min(abs((lagAxisInHzOfCompletePitchogram - ticksForLagAxisInHz')'));
    ticklabelsForLagAxisInHz = num2cell(ticksForLagAxisInHz);
    
    % Time axis: set ticks and ticklabels
    indicesOfTicksForTimeAxis = ReturnIndicesOfTicksForTimeAxis(timeAxisOfCompletePitchogram, frameRateOfSaiMovie);
    ticklabelsForTimeAxisInSeconds = num2cell(timeAxisOfCompletePitchogram(indicesOfTicksForTimeAxis));
    ticklabelsForTimeAxisInSeconds(end) = num2cell(round(ticklabelsForTimeAxisInSeconds{end},1));
    
    % Set name of file to save figure as PNG
    [pathToCompletePitchogramMatFile,nameOfCompletePitchogramMatFile,~] = fileparts(filenameOfCompletePitchogramMatFile);
    fullFilenameOfCompletePitchogramPngFileWithLagOnXAxis = fullfile(pathToCompletePitchogramMatFile,[nameOfCompletePitchogramMatFile,'_',options.NAME_OF_COLORMAP,'_LagOnXAxis.png']);
    fullFilenameOfCompletePitchogramPngFileWithLagOnYAxis = fullfile(pathToCompletePitchogramMatFile,[nameOfCompletePitchogramMatFile,'_',options.NAME_OF_COLORMAP,'_LagOnYAxis.png']);
    
    
    % Plot Pitchogram as in the SAI movie: x-axis = lag, y-axis = time
    figure
    image(SCALE_FACTOR_TO_STRETCH_TO_COLORMAP * completePitchogram)
    colormap(colormapMatrix)
    
    set(gca,'TickDir','out')
    
    set(gca,'XAxisLocation','top');
    xticks(indicesOfTicksForLagAxis)
    xticklabels(ticklabelsForLagAxisInHz)
    xlabel('log-compressed lag in Hz')

    set(gca,'YAxisLocation','right')
    yticks(indicesOfTicksForTimeAxis)
    yticklabels(ticklabelsForTimeAxisInSeconds)
    ylabel('Time in s')

    title(['Pitchogram' newline filenameOfAudioFile],'Interpreter','none')
    colorbar
    c = colorbar;
    c.Ticks = [1 64:64:256];
    c.TickLabels = round(c.Ticks / SCALE_FACTOR_TO_STRETCH_TO_COLORMAP,1);
    c.Label.String = 'Magnitude';
    grid on
    
    exportgraphics(gcf,fullFilenameOfCompletePitchogramPngFileWithLagOnXAxis)
    CloseFigureInBatchMode(options.isBatchMode)

   
    % Plot Pitchogram "as expected": x-axis = time, y-axis = lag
    figure
    image(SCALE_FACTOR_TO_STRETCH_TO_COLORMAP * rot90(completePitchogram))
    colormap(colormapMatrix);
    
    set(gca,'TickDir','out')
    
    set(gca,'XAxisLocation','top');
    xticks(indicesOfTicksForTimeAxis)
    xticklabels(ticklabelsForTimeAxisInSeconds)
    xlabel('Time in s')

    yticks(flip(length(lagAxisInHzOfCompletePitchogram) - indicesOfTicksForLagAxis))
    yticklabels(flip(ticklabelsForLagAxisInHz))
    ylabel('log-compressed lag in Hz')

    title(['Pitchogram' newline filenameOfAudioFile],'Interpreter','none')
    colorbar
    c = colorbar;
    c.Ticks = [1 64:64:256];
    c.TickLabels = round(c.Ticks / SCALE_FACTOR_TO_STRETCH_TO_COLORMAP,1);
    c.Label.String = 'Magnitude';
    grid on
    
    exportgraphics(gcf,fullFilenameOfCompletePitchogramPngFileWithLagOnYAxis)
    CloseFigureInBatchMode(options.isBatchMode)
end