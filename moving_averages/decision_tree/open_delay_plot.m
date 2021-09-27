function open_delay_plot(path, participant_folder_name, delay_model)
%% Opens one plot created by create_model_results.m
%
% **Usage:** open_delay_plot(path, participant_folder_name, delay_model)
%
% Input(s):
%   - path = folder that contains the plots
%   - participant_folder_name = participant folder name
%   - delay_model = delay of model data based on max average signal around tap

%%
% look for all the figures with delay in the name
figures_files = dir(fullfile(path, '*fig'));
fig_names = {figures_files.name};
% look for the figure for the given participant_folder_name and delay model
figures = contains(fig_names, participant_folder_name) & contains(fig_names, num2str(delay_model)); 
figures = contains(fig_names, participant_folder_name); 
fig_name = fig_names(figures);
% check if that figure exists
if find(figures == 1)
    openfig(fig_name{1,1}, 'visible');
end
