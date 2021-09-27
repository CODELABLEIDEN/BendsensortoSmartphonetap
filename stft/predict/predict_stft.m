function [YPred_reshaped, BS_window_freq_norm] = predict_stft(EEG,BS_window,FS_window,bandpass_upper_range,model_file_path,weights_file_path, ma)
% Import keras model, prepares data for prediction, predict model outputs
%
% **Usage:** [YPred_reshaped, BS_window_freq_norm] = predict_stft(EEG,BS_window,FS_window,bandpass_upper_range,model_file_path,weights_file_path, ma)
%
% Input(s):
%   - EEG = EEG data from one participant
%   - BS_window = filtered bendsensor data
%   - FS_window = filtered forcesensor data
%   - bandpass_upper_range = max frequency range used in the bandpass filter
%   - model_file_path = keras model (h5 or JSON)
%   - weights_file_path = keras model weights (h5)
%   - ma = binary 1 if moving averages should be generated and 0 if not
% Output(s):
%   - YPred_reshaped = model output 
tic
%% load in keras model
net = importKerasNetwork(model_file_path, 'WeightFile', weights_file_path, 'OutputLayerType', 'regression');
%% prepare data for prediction
[reshaped_FS_window, BS_window_freq] = gen_freq_data(EEG,BS_window,FS_window,bandpass_upper_range,ma,1);
BS_window_freq = BS_window_freq.';
%% predict
YPred_chunk = zeros(size(reshaped_FS_window.'));
for chunk_num=1:size(BS_window_freq,2)
    YPred_batch = predict(net,BS_window_freq(:,chunk_num));
    YPred_chunk(:,chunk_num) = YPred_batch;
end
YPred_reshaped = reshape(YPred_chunk, [numel(YPred_chunk),1]);

%% plot results
figure
plot(YPred_reshaped)
yyaxis right
hold on
plot(FS_window)
toc 