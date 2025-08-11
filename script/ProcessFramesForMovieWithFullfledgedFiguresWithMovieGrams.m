% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Process frames for movie with full-fledged figures
% -------------------------------------------------------------------------
% Open SAI results file and generate frames for a movie with full-fledged
% figures with "movie"-like Cochleagram and Pitchogram.

function ProcessFramesForMovieWithFullfledgedFiguresWithMovieGrams( ...
    filenameOfAudioFile, ...
    fullFilenameOfSaiMatFile, ...
    fullFilenameOfMovieCochleagramMatFile, ...
    fullFilenameOfMoviePitchogramMatFile, ...
    fullFolderForSaiSegmentsOfAudioFile, ...
    namePatternForSaiSegments, ...
    options ...
    )
    load(fullFilenameOfSaiMatFile, ...
        'totalNumberOfSegments', ...
        'frequencyAxisOfSaiAndCochleagram', ...
        'lagAxisInHzOfSaiAndPitchogram', ...
        'frameRateOfSaiMovie', ...
        'totalWidthOfAllLayers', ...
        'stabilizedAuditoryImage' ...
        )
    load(fullFilenameOfMovieCochleagramMatFile, ...
        'cochleagramFromSaiMovie' ...
        )
    load(fullFilenameOfMoviePitchogramMatFile, ...
        'pitchogramFromSaiMovie', ...
        'NUMBER_OF_ROWS_OF_PITCHOGRAM', ...
        'NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM' ...
        )

    colormapMatrix = ReturnColormapMatrix(options.NAME_OF_COLORMAP);
    
    ticksForFrequencyAxisInHz = [ 50 100 200 500 1000 2000 5000 10000 ];
    ticksForLagAxisInHz = [ 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 ];
    numberOfRowsOfPitchogram = NUMBER_OF_ROWS_OF_PITCHOGRAM;
    numberOfRowsToStretchPitchogram = NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM;
    numberOfActualSegment = 1;
    
    % Frequency axis: SAI & Cochleagram
    [~, indicesOfTicksForFrequencyAxis] = min(abs((frequencyAxisOfSaiAndCochleagram' - ticksForFrequencyAxisInHz')'));
    ticklabelsForFrequencyAxisInHz = num2cell(ticksForFrequencyAxisInHz);
    
    % Lag axis: SAI & Pitchogram
    [~, indicesOfTicksForLagAxis] = min(abs((lagAxisInHzOfSaiAndPitchogram - ticksForLagAxisInHz')'));
    ticklabelsForLagAxisInHz = num2cell(ticksForLagAxisInHz);
    
    % Time axis: Cochleagram
    indicesOfTicksForTimeAxisOfCochleagram = frameRateOfSaiMovie:frameRateOfSaiMovie:totalWidthOfAllLayers;
    ticklabelsForTimeAxisOfCochleagram = num2cell(indicesOfTicksForTimeAxisOfCochleagram/frameRateOfSaiMovie);
    
    % Time axis: Pitchogram            
    indicesOfTicksForTimeAxisOfPitchogram = numberOfRowsToStretchPitchogram:frameRateOfSaiMovie:numberOfRowsOfPitchogram;
    ticklabelsForTimeAxisOfPitchogram = num2cell((indicesOfTicksForTimeAxisOfPitchogram-numberOfRowsToStretchPitchogram)/frameRateOfSaiMovie);

    figure(98)
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


    % Cochleagram
    subplot(2,2,2)
    currentCochleagram = image(32*8 * flip(cochleagramFromSaiMovie(:,:,numberOfActualSegment),2));

    set(gca,'TickDir','out')

    set(gca,'YAxisLocation','right')
    yticks(flip(indicesOfTicksForFrequencyAxis))
    yticklabels(flip(ticklabelsForFrequencyAxisInHz))
    ylabel('Frequency in Hz')

    xticks(indicesOfTicksForTimeAxisOfCochleagram)
    xticklabels(ticklabelsForTimeAxisOfCochleagram)
    xlabel('Delta Time in s')

    title('Cochleagram','Interpreter','none')
    grid on


    % Pitchogram
    subplot(2,2,3)
    currentPitchogram = image(32*10 * max(0,pitchogramFromSaiMovie(:,:,numberOfActualSegment)));

    set(gca,'TickDir','out')

    xticks(indicesOfTicksForLagAxis)
    xticklabels(ticklabelsForLagAxisInHz)
    xlabel('log-compressed lag in Hz')

    set(gca,'YAxisLocation','right')
    yticks(indicesOfTicksForTimeAxisOfPitchogram)
    yticklabels(ticklabelsForTimeAxisOfPitchogram)
    ylabel('Delta Time in s')

    title('Pitchogram','Interpreter','none')
    grid on

    
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
        currentCochleagram.CData = 32*8 * flip(cochleagramFromSaiMovie(:,:,numberOfActualSegment),2);
        currentPitchogram.CData = 32*10 * max(0,pitchogramFromSaiMovie(:,:,numberOfActualSegment));
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