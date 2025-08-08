% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Make directory if it does not exists
% -------------------------------------------------------------------------
% This is a wrapper function for mkdir with checking if folder exists

function MkdirIfFolderNotExists(folder)
    if ~isfolder(folder)
        mkdir(folder)
    end
end