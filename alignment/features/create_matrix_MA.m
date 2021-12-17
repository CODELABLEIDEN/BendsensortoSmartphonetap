function [MA_matrix] = create_matrix_MA(BS_window)
%% Create moving averages matrix from BS data
%
% **Usage:** [MA_matrix] = create_matrix_MA(BS_window)
%
% Input(s):
%   - BS_window = preprocessed BS dataset.
%
% Output(s):
%   - MA_matrix = Moving averages matrix, these are the features for training
%       Size: (length BS_window x 100)
%
% Author: R.M.D. Kock

%% features
    num_features = 100;
    MA_matrix = [];
%% root mean square
%    win_size = 10;
%    rms_arr = zeros(size(BS_window));
%    for k=1:length(BS_window)
%        if k+win_size < length(BS_window)-win_size
%            x = BS_window(k:win_size+k);
%            rms_arr(k) = sqrt(1/length(x).*(sum(x.^2)));
%        else
%            % shrinking window
%            x = BS_window(k:end);
%            rms_arr(k) = sqrt(1/length(x).*(sum(x.^2)));
%        end
%    end
%    rms_arr_norm = normalize(rms_arr);
%    plot(rms_arr_norm);
%%
    BS_window = abs(BS_window);
    for j=1:num_features-1
        new_MA = movmean(BS_window, j*10);
        MA_matrix = [MA_matrix new_MA];
    end
    MA_matrix = [BS_window MA_matrix];
