% Script loops over all participant files and calculate the average delays with get_average_delay.m. Save delays in a file. 
%
% **Usage:** get_average_delays
%
% Output(s):
%   - delays_model = delay for all participants according to model predictions 
%   - delays_bs = delay for all participants according to BS data 
% Requires :
%   - get_average_delay.m  
%%
path = '/media/Storage/Common_Data_Storage/EEG/Feb_2018_2020_RUSHMA_ProcessedEEG';
save_path = '/home/ruchella/Matlab/results_plots/average_delay_plots/delays.mat'

delays_model = [];
delays_bs = [];

% loop over all the participant folders
data_folder = dir(path);
participants = {data_folder([data_folder.isdir]).name};
participants = participants(~ismember(participants,{'.','..'}));

for i=1:size(participants,2)
    files = dir(sprintf('%s/%s', path, participants{1,i}));
    data_files = {files.name};
    data_files = data_files(~ismember(data_files,{'.','..'}));
    % loop over all the files inside the folders
    for j=1:size(data_files,2)
        % only load the set files
        if contains(data_files{1,j}, 'set')
            EEG = pop_loadset(data_files{1,j});
            % participant number
            participant = sprintf('%s_%d', participants{1,i}, j)
            [delay_model, delay_bs] = get_average_delay(EEG, participant, save_path);
            delays_model = [delays_model delay_model];
            delays_bs = [delays_bs delay_bs];
        end
    end
end 
% save model and bs delays 
save(save_path, 'delays_bs', 'delays_model')