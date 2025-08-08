% Copyright (c) 2025 - for information on the respective copyright owner 
% see the NOTICE file or the repository <https://github.com/boschglobal/audi-image>
%
% SPDX-License-Identifier: Apache-2.0

% -------------------------------------------------------------------------
% Return colormap matrix
% -------------------------------------------------------------------------
% Mainly wrapper, to return a colormap

function colormapMatrix = ReturnColormapMatrix(nameOfColormapAsCharArray)
    switch nameOfColormapAsCharArray
        case 'parula'
            colormapMatrix = parula;
        case 'turbo'
            colormapMatrix = turbo;
        case 'hsv'
            colormapMatrix = hsv;
        case 'hot'
            colormapMatrix = hot;
        case 'cool'
            colormapMatrix = cool;
        case 'spring'
            colormapMatrix = spring;
        case 'summer'
            colormapMatrix = summer;
        case 'autumn'
            colormapMatrix = autumn;
        case 'winter'
            colormapMatrix = winter;
        case 'gray'
            colormapMatrix = gray;
        case 'bone'
            colormapMatrix = bone;
        case 'copper'
            colormapMatrix = copper;
        case 'pink'
            colormapMatrix = pink;
        case 'jet'
            colormapMatrix = jet;
        case 'grayInverted'
            colormapMatrix = flip(gray);
        case 'artemis'
            load('ArtemisColormap.mat', 'colormapAsUsedInArtemis')
            colormapMatrix = colormapAsUsedInArtemis;
        otherwise
            disp('No valid colormap was passed! Choosing turbo.')
            colormapMatrix = turbo;
    end
end