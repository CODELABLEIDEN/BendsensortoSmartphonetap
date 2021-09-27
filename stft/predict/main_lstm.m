function [filtered,BS,model_predictions] = main_lstm(participant_type, EEG, model_file_path, weights_file_path,bandpass_upper_range,ma)
%% Main data alignment function. 
% The function calls all other relevant functions to perform prediction. 
%
% **Usage:** [filtered,BS,model_predictions] = main_lstm(participant_type, EEG, model_file_path, weights_file_path,bandpass_upper_range,ma)
%
% Input(s):
%   - participant_type = Binary, 0 is not a DS participant and 1 is a DS participant
%   - EEG = EEG data 
%   - model_file_path = keras model (h5 or JSON)
%   - weights_file_path = keras model weights (h5)
%   - bandpass_upper_range = max frequency range used in the bandpass filter
%   - ma = binary 1 if moving averages should be generated and 0 if not
% Output(s):
%   - filtered = preprocessed force sensor data
%   - BS = preprocessed bendsensor data
%   - model_predictions =  output from lstm 
% Requires:
%   getcleanedbsdata.m
%   preprocess.m
%   predict_stft.m
% Example(s):
%   - For stft model: [filtered,BS,model_predictions] = main_lstm(1, EEG, 'stft.json', 'stft_weights.h5',40,0);
%   - For stft_MA_10 model: [filtered,BS,model_predictions] = main_lstm(1, EEG, 'stft_MA_10.json', 'stft_MA_10_weights.h5',10,1);
%   - For stft_MA_40 model(best): [filtered,BS,model_predictions] = main_lstm(1, EEG, 'stft_MA_40.json', 'stft_MA_40_weights.h5',40,1);
%%
% Predict model outcomes and plot all data
if participant_type
    [filtered, BS, base] = preprocess(EEG,bandpass_upper_range);
else
    BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 bandpass_upper_range]);
    BS = BS.';
    filtered = [];
end
model_predictions = predict_stft(EEG,BS,filtered,bandpass_upper_range,model_file_path,weights_file_path,ma); 
end