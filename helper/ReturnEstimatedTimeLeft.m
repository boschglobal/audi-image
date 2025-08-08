% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Return estimated time left
% -------------------------------------------------------------------------
% This is function returns the estimated time left depending on total
% number of files, processed files so far and time needed for last run.

function [estimatedTimeLeft, estimatedTimeLeftAsString] = ReturnEstimatedTimeLeft( ...
    totalNumberOfFiles, ...
    numberOfActualFile, ...
    durationOfLastRun, ...
    estimatedTimeLeft ...
    )
    estimatedTimeLeft.mean = (estimatedTimeLeft.mean * (numberOfActualFile-1) + durationOfLastRun) / numberOfActualFile;
    estimatedTimeLeft.total = estimatedTimeLeft.mean * (totalNumberOfFiles - numberOfActualFile);
    estimatedTimeLeftAsString = datestr(seconds(estimatedTimeLeft.total),'HH:MM:SS');
end