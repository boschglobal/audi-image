% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Return indices of ticks for time axis for complete Cochleagram/Pitchogram
% -------------------------------------------------------------------------
% The title says it all.

function indicesOfTicksForTimeAxis = ReturnIndicesOfTicksForTimeAxis(timeAxis, FPS)
    NUMBER_OF_DIVISIONS_ON_TIME_AXIS = 10;
    % GET_SHORT_TIME_NUMBER: By the given FPS you need FPS/10 steps to get 
    % a time, without long number colons after the decimal point
    STEP_OF_INDICES_TO_GET_SHORT_TIME_NUMBER = FPS / 10;

    lastIndexOfTimeAxis = length(timeAxis);
    indexStepOnTimeAxis = round((lastIndexOfTimeAxis / NUMBER_OF_DIVISIONS_ON_TIME_AXIS) / STEP_OF_INDICES_TO_GET_SHORT_TIME_NUMBER) * STEP_OF_INDICES_TO_GET_SHORT_TIME_NUMBER;
    lastButOneIndexOnTimeAxis = round(lastIndexOfTimeAxis - lastIndexOfTimeAxis / NUMBER_OF_DIVISIONS_ON_TIME_AXIS);
    indicesOfTicksForTimeAxis = [ 1:indexStepOnTimeAxis:(lastButOneIndexOnTimeAxis+1) lastIndexOfTimeAxis ];
end