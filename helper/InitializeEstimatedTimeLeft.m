% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Initialize estimated time left
% -------------------------------------------------------------------------
% This is function initializes ReturnEstimatedTimeLeft function.

function [estimatedTimeLeft, estimatedTimeLeftAsString] = InitializeEstimatedTimeLeft
    estimatedTimeLeft.mean = 0;
    estimatedTimeLeft.total = 0;
    estimatedTimeLeftAsString = 'unknown';
end