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
% Make movie file from images and audio data
% -------------------------------------------------------------------------
% This function converts images and audio data via FFmpeg converter to a
% movie.
%
% Modifications done here don't change the functionality at all, they're
% done to keep this function working and add some independence of machine
% type.
% Below our modifications are summarized in one big list. Down in the code 
% then some of the "core" modifications and/or additional comments are 
% marked with "AudiImage" to somehow distinguish between original comments 
% and comments by us.
%
% - code indentation optimized
% - path to FFmpeg executable adjusted
% - path to FFmpeg executable is chosen by machine type (Linux/Windows)
% - "system(['rm "'...);" removed since it doesn't work on Windows machines
% - therefore FFmpeg parameter '-y' introduced which overwrites output file
% - movie file is converted addionally from mpeg to mp4. Direct conversion 
%   to mp4 I was not able to realize (video stream was always corrupted). 
%   Background to have mp4 is the seemless import to PowerPoint.
% - "png_name_pattern" in "ffmpeg_command" is enclosed with quotation marks
%   (this is necessary, if filename contains blank character(s))

function MakeMovieFromPngsAndWav( ...
    frame_rate, ...
    png_name_pattern, ...
    wav_filename, ...
    out_filename ...
    )

    if ~exist(wav_filename, 'file')
        error(['Audio file is missing ', wav_filename])
    end

    % AudiImage: Choose path to FFmpeg executable depending on machine type
    switch computer
        case 'GLNXA64'
            PATH_TO_FFmpeg = '/usr/bin/ffmpeg';
        case 'PCWIN64'
            PATH_TO_FFmpeg = 'C:\Path\To\ffmpeg.exe';
        otherwise
            error('Computer type could not be determined. Path to FFmpeg could not be set.')
    end
    
    % AudiImage: Original implementation: mpeg = Video: mpeg1video & Audio: mp2
    ffmpeg_command = [PATH_TO_FFmpeg ...
        ' -r ' num2str(frame_rate) ...
        ' -i "' png_name_pattern '"' ...
        ' -i "' wav_filename '"' ...
        ' -b:v 1024k' ...
        ' -y "' out_filename '"'];
    system(ffmpeg_command);
    
    % AudiImage: Convert mpeg to mp4 = Video: h264 & Audio: aac
    ffmpeg_command = [PATH_TO_FFmpeg ...
        ' -i "' out_filename '"' ...
        ' -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2"' ...
        ' -y "' replace(out_filename,'.mpg','.mp4') '"'];
    system(ffmpeg_command);
end