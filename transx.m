function y = transx(x,tcode)

%% transx.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function transforms the input variable x according to the supplied transformation code. There are a total of 
%   six possible transformation to choose from. They are as follows. 
%
%       1. Level
%       2. First difference
%       3. Second difference
%       4. Logarithmic transformation
%       5. Logarithmic difference
%       6. Second logarithmic difference
%
%   ---------------------------------
%   Last modified: December, 2015
%   ---------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Error checking on input parameters
if (nargin < 2)
  error('transx.m: Not enough input arguments');
end

if (nargin > 2)
  error('transx.m: Too many input arguments');
end

if (~ismember(tcode,1:6))
    error('transx.m: Transformation code outside supported range');
end

%-----------------------------------------------------------------------------------------------------------------------
%% PRELIMINARIES
%-----------------------------------------------------------------------------------------------------------------------

% Setting preliminaries
nObs    = size(x,1);
small   = 1e-6;

%-----------------------------------------------------------------------------------------------------------------------
%% TRANSFORMATIONS ACCORDING TO CODES
%-----------------------------------------------------------------------------------------------------------------------

% Transformation according to transformation codes (tcodes)
switch(tcode)
    
    case 1 % Level case
        
        y = x;
    
    case 2 % First difference
        
        y(1)        = 0;
        y(2:nObs)   = x(2:nObs) - x(1:nObs-1);
        
    case 3 % Second difference
        
        y(1)        = 0;
        y(2)        = 0;
        y(3:nObs)   = x(3:nObs) - 2*x(2:nObs-1) + x(1:nObs-2);
        
    case 4 % Log transformation
        
        if min(x) < small
            
            y = NaN; 
            
        else
            
            y = log(x);
            
        end
        
    case 5 % First log difference
        
        if min(x) < small
            
            y = NaN; 
            
        else
            
            x           = log(x);
            y(1)        = 0;
            y(2:nObs)   = x(2:nObs) - x(1:nObs-1);
            
        end
        
    case 6 % Second log difference
        
        if min(x) < small
            
            y = NaN; 
            
        else
            
            y(1)        = 0;
            y(2)        = 0;
            x           = log(x);
            y(3:nObs)   = x(3:nObs) - 2*x(2:nObs-1) + x(1:nObs-2);
            
        end    
end
end

%-----------------------------------------------------------------------------------------------------------------------
% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------