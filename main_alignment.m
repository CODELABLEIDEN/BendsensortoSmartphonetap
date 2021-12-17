% run starting from 'non_attribute_movement_and_EEG'!!!!!!!!!!!
% add all subfolders to path
% addpath(genpath('/home/ruchella/non_attribute_movement_and_EEG'))
% addpath(genpath('/home/ruchella/imports'))
% % Raw training data path
% path = '/media/Storage/User_Specific_Data_Storage/ruchella/July_2021_BS_to_tap_classification_EEG';
% addpath(genpath(path), '-end')
function [EEG] = main_alignment(options)
%% Performs any alignment step
%
% **Usage:** 
%   - Do nothing: main_alignment();
%   - Train model: main_alignment('train_model', 1,'train_model_raw_data_path', path_to_train_data);
%   - Predict with EEG struct of 1 participant: [EEG] =  main_alignment('predict_one_participant', 1, 'EEG_struct', EEG);
%   - Predict with EEG struct of 1 participant and generate aligned taps: main_alignment('predict_one_participant', 1, 'EEG_struct', EEG, 'align', 1);
%   - Predict for multiple participants = main_alignment('predict_all_participants', 1, 'predict_all_participants_path', path, 'predict_all_participants_save_path', save_path)
%   - Predict for multiple participants and generate aligned taps:  = main_alignment('predict_all_participants', 1, 'predict_all_participants_path', path, 'predict_all_participants_save_path', save_path, 'align', 1)
%
%  Input(s):
%  Name - value pairs (All inputs are optional. However there are some expectations based on selected options, see notes.)
%   - train_model logical (default 0) = 1 to perform the training step
%       Note1: If set to 1, train_model_raw_data_path must be provided
%   - train_model_raw_data_path char = path to traning data
%   - predict_one_participant logical (default 0) = 1
%       use pretrained model to predict data for 1 participant, 0 otherwise.
%       Note1: If set to 1, EEG_struct must be provided 
%       Note2: If set to 1, predict_all_participants should be set to 0 it will otherwise be ignored 
%   - EEG_struct = struct with BS data (see below for more details of required format)
%   - predict_all_participants logical = 1 to perform the prediction for
%   multiple participants, 0 otherwise. 
%       Note1: If set to 1, predict_all_participants_path must be provided
%       Note2: If set to 1, predict_one_participant must be set to 1 
%   - predict_all_participants_path char = path to folder contains subfolders with set files for all participants 
%   Example:
%   predict_all_participants_path/
%       ... participant1/
%           ... participant1.set
%           ... participant1.fdt
%       ... participant2/
%           ... participant2_set1.set
%           ... participant2_set1.fdt
%           ... participant2_set2.set
%           ... participant2_set2.fdt
%   - predict_all_participants_save_path char = path to save predictions
%   - align logical = 1 to perform the alignment and generate aligned taps
%   - create_alignment_plot logical = 1 to create diagnostic plot of alignment
%   - participant_selection = 1 to perform participant selection 
%
%  Output(s):
%   - EEG = struct with model predictions and aligned taps if applicable 
%
% Author: R.M.D. Kock

arguments
    options.train_model logical = 0
    options.train_model_raw_data_path char = ''
    options.predict_one_participant logical = 0
    options.EEG_struct = []
    options.predict_all_participants logical = 0
    options.predict_all_participants_path char = ''
    options.predict_all_participants_save_path char = ''
    options.align logical = 0
    options.create_alignment_plot logical = 0
    options.participant_selection logical = 0
end
EEG = [];

%% train_model
if options.train_model && ~isempty(options.train_model_raw_data_path) && ~(options.predict_all_participants && options.predict_one_participant)
    % prepare data for training
    save_path_top = 'data/alignment_train_data/MA';
    % formatout = 'dd_mm_yy_HH_MM';
    % unique_date = datestr(now, formatout);
    % save_path = sprintf('%s_%s.h5',save_path_top,unique_date);
    save_path = sprintf('%s.h5',save_path_top);
    f = @create_hdf_MA;
    call_func_for_all_participants(options.train_model_raw_data_path,save_path,f,'start_idx',25,'end_idx',28);
    %%
    system('python src/alignment/training/lstm_MA.py')
elseif options.train_model && isempty(options.train_model_raw_data_path)
    error('Provide path to raw data for training')
end
%% Predict
% predict for one participant
if options.predict_one_participant && ~isempty(options.EEG_struct)
    % Load model
    model_file_path = 'models/alignment_models/MA_inverted_full.json';
    weights_file_path = 'models/alignment_models/MA_inverted_full_weights.h5';
    net = importKerasNetwork(model_file_path, 'WeightFile', weights_file_path, 'OutputLayerType', 'regression');
    [EEG, BS] = getNonEEGdataalignedtoEEGdpv3(options.EEG_struct,'net', net);
    %% Align
    if options.align && ~isempty(EEG.Aligned.BSnet)
        [EEG, simple] = decision_tree_alignment(EEG, BS,options.create_alignment_plot, options.participant_selection);
        if simple
            disp('Alignment successfull, data in EEG.Aligned.Phone.Model')
        else
            warning('Data was not aligned')
        end
    elseif  options.align && isempty(EEG.Aligned.BSnet)
        warning('Data was not aligned')
    end
elseif options.predict_one_participant && isempty(options.EEG_struct)
   warning('Provide struct with data to align') 
% predict for multiple participants
elseif options.predict_all_participants && ~isempty(options.predict_all_participants_path)
    f = @getNonEEGdataalignedtoEEGdpv3;
    % if not save folder, save in current directory
    if isempty(options.predict_all_participants_save_path)
        mkdir model_predictions
        options.predict_all_participants_save_path = pwd;
    end
    call_func_for_all_participants(options.predict_all_participants_path,options.predict_all_participants_save_path,f, 'predict_MA', 1, 'align', options.align)
elseif options.predict_all_participants && isempty(options.predict_all_participants_path)
    warning('Provide path to data with EEG set files') 
end

end