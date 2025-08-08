% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Close current figure if batch mode is activated
% -------------------------------------------------------------------------
% In batch mode all generated figures have to be closed after use to
% prevent messing up screen with dozens of figures.

function CloseFigureInBatchMode(isBatchMode)
    if isBatchMode
        close
    end
end