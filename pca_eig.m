function [princomp,loadings,var_explained] = pca_eig(X,num_component,stdize)

%% pca_eig.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function estimates the principal components of the input matrix X using the eigenvalue decomposition to obtain
%   the eigenvectors. The input parameters are as follows:
%
%   Input variables:
%   ---------------------------------------------------------
%   X               = Matrix of variables
%   num_component   = Number of principal components to extract
%   stdize          = Scaler indicating whether to standardize the panel or not
%
%   Output variables:
%   ---------------------------------------------------------
%   princomp        = Matrix of estimated principal components
%   loadings        = Matrix of loadings from the PCA routine
%   var_explained   = Proportion of variance explained by the principal components
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Error checking
if (nargin < 2)
	error('pca_eig.m: Not enough input parameters');
end

if (nargin > 3)
	error('pca_eig.m: Too many input parameters');
end

if (size(X,2) <= 1)
    error('pca_eig.m: Input X should be a matrix');
end

% Internal standardization standard or chosen or not
if (nargin == 3)
    
    if ~isempty(stdize) && strcmp(stdize,'Yes');

        Z = standard(X);

    elseif ~isempty(stdize) && strcmp(stdize,'No');

    	Z = X;

    else 

    	error('pca_eig: Wrong argument provided for standardization');

    end
    
elseif (nargin < 3)
    
    Z = standard(X);
    
end

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING PRINCIPAL COMPONENTS
%-----------------------------------------------------------------------------------------------------------------------

% Estimating the principal components
[loadings,eigenvalues]  = eig(cov(Z));                          % Eigenvalue decomposition
[eigenvalues,indx]      = sort(diag(eigenvalues),'descend');    % Sorting eigenvalues in descending order
loadings                = loadings(:,indx);                     % Sorting the eigenvectors after size of eigenvalues
princomp                = Z*loadings;                           % Estimating the full set of principal components
princomp                = princomp(:,1:num_component);               % Selecting the number needed
loadings                = loadings(:,1:num_component);          % Selecting the loadings for the estimated factors
var_explained           = eigenvalues/sum(eigenvalues);         % Computing proportion of variance explained

end

%-----------------------------------------------------------------------------------------------------------------------
% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------