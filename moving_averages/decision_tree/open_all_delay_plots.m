function open_all_delay_plots(data, threshold, results)
%% Loops over all the participants whose data are below a certain threshold. Open all the diagnostic plots created from decision_tree_analysis.m
%
% **Usage:** open_all_delay_plots(results, data, threshold)
%
% Input(s):
%   - results = cell with following fields:
%       - delay_bs = delay of BS data based on max epoched signal around tap
%       - delay_model = delay of model data based on max average signal around tap
%       - p_file = participant folder name & file name(E.G. AG02/12_02_30_02_02.set)
%       - max_val_bs = max value of the epoched BS signal around tap
%       - max_val_model =  max value of the epoched model signal around tap
%       - [pks_bs, locs_bs, w_bs, p_bs] = results of findpeaks on epoched BS signal
%       - [pks_mod, locs_mod, w_mod, p_mod]= results of findpeaks on epoched model signal
%   - data = cell field to analyze
%   - threshold = Decision tree threshold
% Requires:
%   open_delay_plot.m

%%
path = '/home/ruchella/master_thesis_IS-DS/src/alignment/moving_averages/results/average_delay_plots_titles';
participants = results(data < threshold, 3);
delays = results(data < threshold, 2);
for participant=1:size(participants)
    participant_file_name = participants{participant,1};
    % Select only the folder name since the plots only have the folder
    % names and not the file names too
    % The participant can have multiple files, use delay to ensure its
    % selecting the right plot
    participant_name = split(participant_file_name, '/');
    open_delay_plot(path,participant_name(1), delays{participant,1});
end
