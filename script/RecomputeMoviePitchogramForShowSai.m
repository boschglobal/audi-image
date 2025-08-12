% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Recompute the "movie" pitchogram for displaying in ShowSai.mlapp
% -------------------------------------------------------------------------
% This function recomputes the "movie" pitchogram from ready-available SAI 
% data for ShowSai.mlapp.
%
% The code below is derived from the modified version of 
% ../matlab/SAI_RunLayered.m 

function pitchogramFromSaiMovie = RecomputeMoviePitchogramForShowSai( ...
    numberOfRowsOfPitchogram, ...
    numberOfRowsToStretchPitchogram, ...
    sai ...
    )
    pitchogramFrame = zeros(numberOfRowsOfPitchogram, sai.totalWidthOfAllLayers);
    pitchogramFromSaiMovie = zeros(numberOfRowsOfPitchogram, sai.totalWidthOfAllLayers, sai.totalNumberOfSegments);

    h = waitbar(0,['1 / ' num2str(sai.totalNumberOfSegments)],'Name','Segment computation in progress...');
    for numberOfActualSegment = 1:sai.totalNumberOfSegments
        waitbar(numberOfActualSegment/sai.totalNumberOfSegments,h,[num2str(numberOfActualSegment) ' / ' num2str(sai.totalNumberOfSegments)])

        % SAI -------------------------------------------------------------
        stabilizedAuditoryImageFrame = sai.stabilizedAuditoryImage(:,:,numberOfActualSegment);
        % ------------------------------------------------------------- SAI

        % Pitchogram ------------------------------------------------------
        for row = numberOfRowsOfPitchogram:-1:(numberOfRowsToStretchPitchogram+1)
            pitchogramFrame(row, :) = pitchogramFrame(row - 1, :);
        end
        pitchogram = mean(stabilizedAuditoryImageFrame, 1);
        pitchogram = pitchogram - 0.75*smooth1d(pitchogram, 30)';

        for row = numberOfRowsToStretchPitchogram:-1:1
            pitchogramFrame(row, :) = pitchogram - (numberOfRowsToStretchPitchogram - row) / 40;
        end

        pitchogramFromSaiMovie(:,:,numberOfActualSegment) = max(0,pitchogramFrame);
        % ------------------------------------------------------ Pitchogram
    end

    close(h)
end