% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0
%
% This source code is derived from CARFAC (forked 2025-08-08)
%     https://github.com/google/carfac
%
% Copyright 2013 The CARFAC Authors. All Rights Reserved.
% Author: Richard F. Lyon
%
% This file is part of an implementation of Lyon's cochlear model:
% "Cascade of Asymmetric Resonators with Fast-Acting Compression"
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

% -------------------------------------------------------------------------
% Run the CARFAC and generate SAI movie frames
% -------------------------------------------------------------------------
% This function runs the CARFAC and generates SAI movie frames.
% The original implementation added to the SAI movie its derived components
% (cochleagram and pitchogram). The duration of "movie" cochleagram is 
% somewhat long (~20 s), the pitchogram in contrast shows only few seconds 
% into the past. Since SAI, "movie" cochleagram and "movie" pitchogram are 
% stored as MAT files, cochleagram and pitchogram are also available as so
% called "complete" versions. "complete" means, that the entire cochleagram
% and pitchogram over the whole time span of the inputed audio is stored 
% and is available for post-analysis.
%
% SAI_RunLayered() is the core function to run the CARFAC segment-wise and
% to generate the SAI movie frames. The original implementation composed
% single images (frames) of the SAI (central part), the cochleagram (in the
% upper part) and the pitchogram (at the bottom) and "dumped" them as PNG
% files.
% Our intention for modification of SAI_RunLayered() was to harness the SAI
% for analysis tasks and other post-processing steps. Therefore the SAI and
% its derived components, the cochleagram and the pitchogram, are stored as
% MAT files for further processing.
% Below our modifications are summarized in one big list. Down in the code 
% then some of the "core" modifications and/or additional comments are 
% marked with "AudiImage" to somehow distinguish between original comments 
% and comments by us.
%
% - introduce a waitbar for segment computation
% - code indentation optimized
% - increase verbosity by adding disp() commands with meaningful messages
% - code "coc_gram" deleted
% - code "piano black keys" deleted; instead a simple border is introduced 
%   to separate cochleagram and pitchogram from SAI in the "movie"
% - structs with filenames and options added as input parameters
% - SAI, cochleagram and pitchogram stored now in separate MAT files
% - "complete" cochleagram and pitchogram introduced
% - no frames export as PNG here anymore (now done in SAI processing)
% - variable "future_lags" deleted
% - variable "average_composite" deleted
% - magic numbers removed and replaced by variables and/or constants
% - refactoring of code and some of the variables
% - "live" figure during SAI computation could be switch on/off 
% - "movie" pitchogram is no longer smoothed out, it behaves now similar to
%   cochleagram
% - NUMBER_OF_ROWS_OF_PITCHOGRAM rewritten as formula
% - NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM changed to 5 (old: 10)
% - FRAMES_PER_SECOND is stored in all result files as frameRateOfSaiMovie
% - DURATION_OF_PITCHOGRAM_IN_SECONDS introduced
% - duration, number of rows and rows to stretch pitchogram are stored in
%   "movie" pitchogram results file.
% - First paragraph of inductory comment moved up and rewritten

function [frameRateOfSaiMovie, numberOfFramesOfSaiMovie] = SAI_RunLayered( ...
    CF, ...
    input_waves, ...
    fullFilename, ...
    options ...
    )
    % Computes a "layered" SAI composed of images computed at several
    % time scales.
    %
    % Layer 1 is not decimated from the 22050 rate; subsequent layers have
    % smoothing and 2X decimation each.  All layers get composited together
    % into movie frames.
    %% AudiImage: Initialization and set up variables/constants
    disp('      SAI_RunLayered: started')

    FRAMES_PER_SECOND = 30;
    TOTAL_NUMBER_OF_LAYERS = 15;
    WIDTH_PER_LAYER = 36;
    DURATION_OF_PITCHOGRAM_IN_SECONDS = 5;
    NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM = 5;
    NUMBER_OF_ROWS_OF_PITCHOGRAM = DURATION_OF_PITCHOGRAM_IN_SECONDS * FRAMES_PER_SECOND + NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM;

    totalNumberOfChannels = CF.n_ch;
    [totalNumberOfSamples, totalNumberOfEars] = size(input_waves);
    if totalNumberOfEars ~= CF.n_ears
        error('Bad number of input_waves channels passed to CARFAC_Run.')
    end
    fs = CF.fs;

    lengthOfOneSegment = round(fs / FRAMES_PER_SECOND);  % Pick about 30 fps
    totalNumberOfSegments = ceil(totalNumberOfSamples / lengthOfOneSegment);

    % Design the composite log-lag SAI using these parameters and defaults.
    [layer_array, totalWidthOfAllLayers, lags] = SAI_DesignLayers(TOTAL_NUMBER_OF_LAYERS, WIDTH_PER_LAYER, lengthOfOneSegment);

    % AudiImage:
    % "pitches" contains the frequencies/lags for "x-axis" of SAI/pitchogram
    pitches = fs ./ lags;
    
    % Make the history buffers in the layers_array
    for layer = 1:TOTAL_NUMBER_OF_LAYERS
        layer_array(layer).nap_buffer = zeros(layer_array(layer).buffer_width, totalNumberOfChannels);
        layer_array(layer).nap_fraction = 0;  % leftover fraction to shift in.
        % The SAI frame is transposed to be image-like.
        layer_array(layer).frame = zeros(totalNumberOfChannels, layer_array(layer).frame_width);
    end

    % AudiImage:
    % - allocate memory for        SAI frame (= composite_frame),
    %                      cochleagram frame (= marginals_frame) and
    %                       pitchogram frame (= marginals)
    % - instead of "piano black keys" a simple border is used
    % - allocate memory for all   SAI frames (= stabilizedAuditoryImage),
    %                     cochleagram frames (= cochleagramFromSaiMovie),
    %                      pitchogram frames (= pitchogramFromSaiMovie) and 
    %           for the complete cochleagram (= completeCochleagram) and 
    %                    complete pitchogram (= completePitchogram)
    composite_frame = zeros(totalNumberOfChannels, totalWidthOfAllLayers);  % SAI
    marginals_frame = zeros(totalNumberOfChannels, totalWidthOfAllLayers);  % Cochleagram
    marginals = zeros(NUMBER_OF_ROWS_OF_PITCHOGRAM, totalWidthOfAllLayers); % Pitchogram

    borderForComposedImage = ones(2, totalWidthOfAllLayers);
    
    stabilizedAuditoryImage = zeros(totalNumberOfChannels, totalWidthOfAllLayers, totalNumberOfSegments);
    
    cochleagramFromSaiMovie = zeros(totalNumberOfChannels, totalWidthOfAllLayers, totalNumberOfSegments);
    pitchogramFromSaiMovie = zeros(NUMBER_OF_ROWS_OF_PITCHOGRAM, totalWidthOfAllLayers, totalNumberOfSegments);

    completeCochleagram = zeros(totalNumberOfChannels, totalNumberOfSegments);
    completePitchogram = zeros(totalNumberOfSegments, totalWidthOfAllLayers);

    %% AudiImage: Run segment-wise computation of SAI
    disp('      SAI_RunLayered | Segment computation: started')

    h = waitbar(0,['1 / ' num2str(totalNumberOfSegments)],'Name','Segment computation in progress...');
    for numberOfActualSegment = 1:totalNumberOfSegments
        waitbar(numberOfActualSegment/totalNumberOfSegments,h,[num2str(numberOfActualSegment) ' / ' num2str(totalNumberOfSegments)])
        
        % SAI -------------------------------------------------------------
        % seg_range is the range of input sample indices for this segment
        if numberOfActualSegment == totalNumberOfSegments
            % The last segment may be short of seglen, but do it anyway:
            seg_range = (lengthOfOneSegment*(numberOfActualSegment - 1) + 1):totalNumberOfSamples;
        else
            seg_range = lengthOfOneSegment*(numberOfActualSegment - 1) + (1:lengthOfOneSegment);
        end
        [seg_naps, CF] = CARFAC_Run_Segment(CF, input_waves(seg_range, :));

        seg_naps = max(0, seg_naps);  % Rectify

        if numberOfActualSegment == totalNumberOfSegments  % pad out the last result
            seg_naps = [seg_naps; zeros(lengthOfOneSegment - size(seg_naps,1), size(seg_naps, 2))];
        end

        % Shift new data into some or all of the layer buffers:
        layer_array = SAI_UpdateBuffers(layer_array, seg_naps, numberOfActualSegment);

        for layer = TOTAL_NUMBER_OF_LAYERS:-1:1  % Stabilize and blend from coarse to fine
            update_interval = layer_array(layer).update_interval;
            if 0 == mod(numberOfActualSegment, update_interval)
                layer_array(layer) = SAI_StabilizeLayer(layer_array(layer));
                composite_frame = SAI_BlendFrameIntoComposite(layer_array(layer), composite_frame);
            end
        end
        
        % AudiImage:
        % Store current SAI frame into 3-D matrix
        stabilizedAuditoryImage(:,:,numberOfActualSegment) = composite_frame;
        % ------------------------------------------------------------- SAI

        % Pitchogram ------------------------------------------------------
        for row = NUMBER_OF_ROWS_OF_PITCHOGRAM:-1:(NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM+1)
            % AudiImage: no longer smoothing of pitchogram
            marginals(row, :) = marginals(row - 1, :);
        end
        lag_marginal = mean(composite_frame, 1);  % means max out near 1 or 2
        lag_marginal = lag_marginal - 0.75*smooth1d(lag_marginal, 30)';

        for row = NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM:-1:1
            marginals(row, :) = lag_marginal - (NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM - row) / 40;
        end

        % AudiImage:
        % - store current time step (= segment) to build complete pitchogram
        % - store current frame of pitchogram for the "movie"
        completePitchogram(numberOfActualSegment,:) = lag_marginal;
        pitchogramFromSaiMovie(:,:,numberOfActualSegment) = max(0,marginals);
        % ------------------------------------------------------ Pitchogram

        % Cochleagram -----------------------------------------------------
        freq_marginal = mean(layer_array(1).nap_buffer);
        % emphasize local peaks:
        freq_marginal = freq_marginal - 0.5*smooth1d(freq_marginal, 5)';

        marginals_frame = [marginals_frame(:, 2:end), freq_marginal(1:end)'];

        % AudiImage: 
        % - store current time step (= segment) to build complete cochleagram
        % - store current frame of cochleagram for the "movie"
        completeCochleagram(:,numberOfActualSegment) = freq_marginal(1:end)';
        cochleagramFromSaiMovie(:,:,numberOfActualSegment) = marginals_frame;
        %------------------------------------------------------ Cochleagram

        % AudiImage:
        % "display_frame" contains the current frame of the SAI movie and
        % is shown in a figure. This "live" output is switchable so that
        % whole compute time is saved (~1 s faster for 60 segments).
        %       marginals_frame = Cochleagram
        %       composite_frame = Stabilized Auditory Image
        %       marginals       = Pitchogram
        % In the original implementation the "dump" to PNG files was done 
        % here, which is not anymore done, since storing everything now 
        % in MAT files.
        if options.isDisplaySaiDuringComputation
            display_frame = [ ...
                8 * marginals_frame; ...    % default 4 * 
                borderForComposedImage; ...
                composite_frame(ceil((1:(2*end))/2), :); ...
                borderForComposedImage; ...
                10*max(0,marginals) ...
                ];

            figure(99)
            image(32*display_frame)
            colormap(flip(gray))
            drawnow
        end
    end
    
    close(h)
    disp('      SAI_RunLayered | Segment computation: finished')

    %% AudiImage: Store everything to MAT files

    % AudiImage:
    % - Save final SAI as 3-D matrix in MAT file
    % - In addition "movie" cochleagram and pitchogram are saved each in 
    %   separate MAT files
    % - Same is done for "complete" cochleagram and pitchogram
    
    % Stabilized Auditory Image
    numberOfFramesOfSaiMovie = numberOfActualSegment;
    frameRateOfSaiMovie = FRAMES_PER_SECOND;
    timeResolutionOfSaiMovie = 1 / FRAMES_PER_SECOND;
    
    timeAxisOfSaiMovie = 0:timeResolutionOfSaiMovie:(totalNumberOfSegments-1)*timeResolutionOfSaiMovie;
    frequencyAxisOfSaiAndCochleagram = CF.pole_freqs;
    lagAxisInHzOfSaiAndPitchogram = pitches;
    
    disp('      SAI_RunLayered | Save SAI: started')
    save(fullFilename.OfSaiMatFile, ...
        'stabilizedAuditoryImage', ...
        'timeAxisOfSaiMovie', ...
        'frequencyAxisOfSaiAndCochleagram', ...
        'lagAxisInHzOfSaiAndPitchogram', ...
        'totalNumberOfSegments', ...
        'totalNumberOfChannels', ...
        'totalWidthOfAllLayers', ...
        'frameRateOfSaiMovie', ...
        'timeResolutionOfSaiMovie', ...
        'numberOfFramesOfSaiMovie', ...
        '-v7.3' ...
        )
    disp('      SAI_RunLayered | Save SAI: finished')

    % Cochleagramm
    timeAxisOfCompleteCochleagram = timeAxisOfSaiMovie;
    frequencyAxisOfCompleteCochleagram = frequencyAxisOfSaiAndCochleagram;
    
    disp('      SAI_RunLayered | Save Cochleagram: started')
    disp('      SAI_RunLayered |    "Movie" Cochleagram...')
    save(fullFilename.OfMovieCochleagramMatFile, ...
        'cochleagramFromSaiMovie', ...
        'frequencyAxisOfSaiAndCochleagram', ...
        'totalWidthOfAllLayers', ...
        'frameRateOfSaiMovie', ...
        '-v7.3' ...
        )
    disp('      SAI_RunLayered |    Complete Cochleagram...')
    save(fullFilename.OfCompleteCochleagramMatFile, ...
        'completeCochleagram', ...
        'timeAxisOfCompleteCochleagram', ...
        'frequencyAxisOfCompleteCochleagram', ...
        'frameRateOfSaiMovie', ...
        '-v7.3' ...
        )
    disp('      SAI_RunLayered | Save Cochleagram: finished')
    
    % Pitchogramm
    timeAxisOfCompletePitchogram = timeAxisOfSaiMovie';
    lagAxisInHzOfCompletePitchogram = lagAxisInHzOfSaiAndPitchogram;
    
    disp('      SAI_RunLayered | Save Pitchogram: started')
    disp('      SAI_RunLayered |    "Movie" Pitchogram...')
    save(fullFilename.OfMoviePitchogramMatFile, ...
        'pitchogramFromSaiMovie', ...
        'lagAxisInHzOfSaiAndPitchogram', ...
        'DURATION_OF_PITCHOGRAM_IN_SECONDS', ...
        'NUMBER_OF_ROWS_OF_PITCHOGRAM', ...
        'NUMBER_OF_ROWS_TO_STRETCH_PITCHOGRAM', ...
        'frameRateOfSaiMovie', ...
        '-v7.3' ...
        )
    disp('      SAI_RunLayered |    Complete Pitchogram...')
    save(fullFilename.OfCompletePitchogramMatFile, ...
        'completePitchogram', ...
        'timeAxisOfCompletePitchogram', ...
        'lagAxisInHzOfCompletePitchogram', ...
        'frameRateOfSaiMovie', ...
        '-v7.3' ...
        )
    disp('      SAI_RunLayered | Save Pitchogram: finished')

    disp('      SAI_RunLayered: finished')
end