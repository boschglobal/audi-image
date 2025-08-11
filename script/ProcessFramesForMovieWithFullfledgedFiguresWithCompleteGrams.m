% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Process frames for movie with full-fledged figures
% -------------------------------------------------------------------------
% Open SAI results file and generate frames for a movie with full-fledged
% figures with complete Cochleagram and Pitchogram.

function ProcessFramesForMovieWithFullfledgedFiguresWithCompleteGrams( ...
    filenameOfAudioFile, ...
    fullFilenameOfSaiMatFile, ...
    fullFilenameOfCompleteCochleagramMatFile, ...
    fullFilenameOfCompletePitchogramMatFile, ...
    fullFolderForSaiSegmentsOfAudioFile, ...
    namePatternForSaiSegments, ...
    options ...
    )
    load(fullFilenameOfSaiMatFile, ...
        'totalNumberOfSegments', ...
        'frequencyAxisOfSaiAndCochleagram', ...
        'lagAxisInHzOfSaiAndPitchogram', ...
        'frameRateOfSaiMovie', ...
        'stabilizedAuditoryImage' ...
        )
    load(fullFilenameOfCompleteCochleagramMatFile, ...
        'timeAxisOfCompleteCochleagram', ...
        'frequencyAxisOfCompleteCochleagram', ...
        'completeCochleagram' ...
        )
    load(fullFilenameOfCompletePitchogramMatFile, ...
        'lagAxisInHzOfCompletePitchogram', ...
        'completePitchogram' ...
        )

    colormapMatrix = ReturnColormapMatrix(options.NAME_OF_COLORMAP);
    
    ticksForFrequencyAxisInHz = [ 50 100 200 500 1000 2000 5000 10000 ];
    ticksForLagAxisInHz = [ 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 ];
    numberOfActualSegment = 1;
    
    % Frequency axis: SAI & Cochleagram
    [~, indicesOfTicksForFrequencyAxis] = min(abs((frequencyAxisOfSaiAndCochleagram' - ticksForFrequencyAxisInHz')'));
    ticklabelsForFrequencyAxisInHz = num2cell(ticksForFrequencyAxisInHz);
    
    % Lag axis: SAI & Pitchogram
    [~, indicesOfTicksForLagAxis] = min(abs((lagAxisInHzOfSaiAndPitchogram - ticksForLagAxisInHz')'));
    ticklabelsForLagAxisInHz = num2cell(ticksForLagAxisInHz);
    
    % Time axis: Complete Cochleagram & Pitchogram
    indicesOfTicksForTimeAxisOfCompleteGrams = ReturnIndicesOfTicksForTimeAxis(timeAxisOfCompleteCochleagram, frameRateOfSaiMovie);
    ticklabelsForTimeAxisOfCompleteGrams = num2cell(timeAxisOfCompleteCochleagram(indicesOfTicksForTimeAxisOfCompleteGrams));
    ticklabelsForTimeAxisOfCompleteGrams(end) = num2cell(round(ticklabelsForTimeAxisOfCompleteGrams{end},1));
    
    figure(97)
    colormap(colormapMatrix)
    set(gcf,'Position',[100 100 1280 800])
    
    
    % SAI
    subplot(2,2,1)
    currentSai = image(32 * stabilizedAuditoryImage(:,:,numberOfActualSegment));

    set(gca,'TickDir','out')

    set(gca,'YAxisLocation','right')
    yticks(flip(indicesOfTicksForFrequencyAxis))
    yticklabels(flip(ticklabelsForFrequencyAxisInHz))
    ylabel('Frequency in Hz')

    xticks(indicesOfTicksForLagAxis)
    xticklabels(ticklabelsForLagAxisInHz)
    xlabel('log-compressed lag in Hz')

    title('SAI','Interpreter','none')
    grid on

    
    % complete Cochleagram
    subplot(2,2,2)
    image(32*8 * completeCochleagram)

    set(gca,'TickDir','out')

    set(gca,'YAxisLocation','right')
    yticks(flip(indicesOfTicksForFrequencyAxis))
    yticklabels(flip(ticklabelsForFrequencyAxisInHz))
    ylabel('Frequency in Hz')

    xticks(indicesOfTicksForTimeAxisOfCompleteGrams)
    xticklabels(ticklabelsForTimeAxisOfCompleteGrams)
    xlabel('Time in s')

    title('Cochleagram','Interpreter','none')
    grid on

    lineToShowPositionInCompleteCochleagram = line;
    lineToShowPositionInCompleteCochleagram.XData = [numberOfActualSegment numberOfActualSegment];
    lineToShowPositionInCompleteCochleagram.YData = [1 length(frequencyAxisOfCompleteCochleagram)];
    lineToShowPositionInCompleteCochleagram.Color = 'r';
    lineToShowPositionInCompleteCochleagram.Marker = 'o';
    lineToShowPositionInCompleteCochleagram.MarkerFaceColor = 'r';

    
    % complete Pitchogram
    subplot(2,2,3)
    image(32*10 * completePitchogram)

    set(gca,'TickDir','out')

    xticks(indicesOfTicksForLagAxis)
    xticklabels(ticklabelsForLagAxisInHz)
    xlabel('log-compressed lag in Hz')

    set(gca,'YAxisLocation','right')
    yticks(indicesOfTicksForTimeAxisOfCompleteGrams)
    yticklabels(ticklabelsForTimeAxisOfCompleteGrams)
    ylabel('Time in s')

    title('Pitchogram','Interpreter','none')
    grid on

    lineToShowPositionInCompletePitchogram = line;
    lineToShowPositionInCompletePitchogram.XData = [1 length(lagAxisInHzOfCompletePitchogram)];
    lineToShowPositionInCompletePitchogram.YData = [numberOfActualSegment numberOfActualSegment];
    lineToShowPositionInCompletePitchogram.Color = 'r';
    lineToShowPositionInCompletePitchogram.Marker = 'o';
    lineToShowPositionInCompletePitchogram.MarkerFaceColor = 'r';

    
    % Set figure title and running segment number & time position
    figureTitle = text(0,0,filenameOfAudioFile);
    figureTitle.Interpreter = 'None';
    figureTitle.Units = 'normalized';
    figureTitle.Position = [0 2.5];
    
    actualSegmentNumber = text(0,0,['Segment #' num2str(numberOfActualSegment)]);
    actualSegmentNumber.Interpreter = 'None';
    actualSegmentNumber.FontSize = 16;
    actualSegmentNumber.FontWeight = 'bold';
    actualSegmentNumber.Units = 'normalized';
    actualSegmentNumber.Position = [1.25 1];

    timeDerivedFromActualSegmentNumber = text(0,0,['Time = ' num2str(round(numberOfActualSegment/frameRateOfSaiMovie,6)) ' s']);
    timeDerivedFromActualSegmentNumber.Interpreter = 'None';
    timeDerivedFromActualSegmentNumber.FontSize = 16;
    timeDerivedFromActualSegmentNumber.Units = 'normalized';
    timeDerivedFromActualSegmentNumber.Position = [1.25 0.9];
    
    
    h = waitbar(0,['1 / ' num2str(totalNumberOfSegments)],'Name','Segment processing in progress...');
    for numberOfActualSegment = 1:totalNumberOfSegments
        waitbar(numberOfActualSegment/totalNumberOfSegments,h,[num2str(numberOfActualSegment) ' / ' num2str(totalNumberOfSegments)])

        currentSai.CData = 32 * stabilizedAuditoryImage(:,:,numberOfActualSegment);
        lineToShowPositionInCompleteCochleagram.XData = [numberOfActualSegment numberOfActualSegment];
        lineToShowPositionInCompletePitchogram.YData = [numberOfActualSegment numberOfActualSegment];
        actualSegmentNumber.String = ['Segment #' num2str(numberOfActualSegment)];
        timeDerivedFromActualSegmentNumber.String = ['Time = ' num2str(round(numberOfActualSegment/frameRateOfSaiMovie,6)) ' s'];

        exportgraphics( ...
            gcf, ...
            fullfile(fullFolderForSaiSegmentsOfAudioFile,sprintf(namePatternForSaiSegments, numberOfActualSegment)), ...
            'Resolution', 96 ...
            )
    end
    close(h)
    CloseFigureInBatchMode(options.isBatchMode)
end