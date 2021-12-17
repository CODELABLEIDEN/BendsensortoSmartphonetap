function [model_predictions] = predict_MA(BS,net)
% Prepare data for prediction and predict in batches
%
% **Usage:** [model_predictions] = predict_MA(BS,net)
%
% Input(s):
%   - BS = preprocessed bendsensor data
%   - net = keras imported network
% Output(s):
%   - model_predictions = model output 

%% prepare data for prediction
% set sequence length in matlab/ timesteps in python
timesteps = 1000;
num_features = 100;
% normalize data
BS_norm = normalize(BS);
% add padding
padding_length = mod(timesteps-size(BS_norm,1),timesteps);
bs_data = [BS_norm; zeros(padding_length,1)];
%% predict
% input to predict is num_features x timesteps
% for this model input is 100 x 1000
% output from predict is 1 x 1000
% loop over the whole BS data length and call predict for each batch to get the full
% data (a batch has size 1 in matlab sequence2sequence)
MA_matrix = [];
for j=1:num_features-1
    new_MA = movmean(bs_data, j*10);
    MA_matrix = [MA_matrix new_MA];
end
MA_matrix = [bs_data MA_matrix];
%% perform prediction for each batch
BS_size = size(bs_data,1);
model_predictions = zeros(1,BS_size);
batch_index = 1;
for chunk_num=1:BS_size/timesteps
    data_chunk = MA_matrix(batch_index:batch_index+timesteps-1,:);
    YPred = predict(net,data_chunk.');
    model_predictions(batch_index:batch_index+timesteps-1) = YPred;
    batch_index = batch_index+timesteps-1;
end

% remove the padding
model_predictions = model_predictions(1:BS_size-padding_length).';