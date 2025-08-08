% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Configure the "run" waitbar
% -------------------------------------------------------------------------
% The "run" waitbar is the overall waitbar in the "Run..." scripts which
% shows the number of total files and other stuff. To avoid overlay by
% other "default" waitbars, it is configured with this central function.

function h = ConfigureRunWaitbar(h)
    h.Children.Title.Interpreter = 'none';
    h.Children.Title.FontSize = 7;
    h.Position(2) = 600;
end