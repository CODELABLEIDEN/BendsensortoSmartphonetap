function [BS,model_predictions] = main_lstm_MA(EEG, model_file_path, weights_file_path)
%% Generates model predictions  
%
% **Usage:** [BS,model_predictions] = main_lstm_MA(EEG, model_file_path, weights_file_path)
%
% Input(s):
%   - EEG = EEG struct m 
%   - model_file_path = keras model (h5 or JSON)
%   - weights_file_path = keras model weights (h5)
% Output(s):
%   - BS = preprocessed bendsensor data
%   - model_predictions =  output from lstm 
% Requires:
%   - getcleanedbsdata.m
%   - predict_MA.m
% Example:
%   main_lstm_MA(EEG, 'model_version2_2_4A.json', 'model_version2_2_4A_weights.h5');

%% load in keras model
net = importKerasNetwork(model_file_path, 'WeightFile', weights_file_path, 'OutputLayerType', 'regression');
%%
% Predict model outcomes
BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
BS = BS.'; 

model_predictions = predict_MA(BS,net);