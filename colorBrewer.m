function colors = color_brewer(number_of_colors)

%% color_brewer.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function simply outputs RGB values for a particular color palette that looks good for plotting multiple lines
%   in Matlab plots. 
%
%   --------------------------------
%   Last modified: January, 2016
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

if (nargin > 2)
    error('line_colors.m: Too many input arguments');
end

if (number_of_colors > 7)
    error('line_colors.m: A most five colors are currently supported');
end

if (number_of_colors < 0)
    error('line_colors.m: Negative number of colors not a valid input');
end

%-----------------------------------------------------------------------------------------------------------------------
%% SETTING RGB VALUES FOR COLOR PALETTE
%-----------------------------------------------------------------------------------------------------------------------

% Setting RGB values
color_rgb_values = [
    55 126 184
    228 26 28
    77 175 74
    255 127 0
    152 78 163
    255 255 51
    166 86 40
];

% Setting output
if ismember(number_of_colors,1:7)

    colors  = color_rgb_values(number_of_colors,:)./255;

else

    colors  = color_rgb_values./255;

end

end

%-----------------------------------------------------------------------------------------------------------------------
% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------