%% Script to analyze the model results created from create_model_results based on a few pre defined decision tree questions 
% This helps determine when to trust the model results
%
% **Usage:** analyze_model_results.m
%
threshold = 0.15;
%% Max BS peaks < 0.15
max_peak_size_bs = sum([results{:,4}] < threshold);
%open_all_delay_plots([results{:,4}], threshold, results)
% 18
%% Max model peaks < 0.15
sum([results{:,5}] < threshold)
%open_all_delay_plots([results{:,5}], threshold, results)
% 14
%% Max model peaks AND max BS peaks <0.15
sum([results{:,4}]' < threshold & [results{:,5}]' < threshold);
% 10
%% Irregular BS pattern
%peak prominence 
differences_bs = zeros(1, size(results,1));
for i=1:length(results)
    prominance = results{i,6}(length(results{i,6})- (length(results{i,6})/4)+1:length(results{i,6}));
    if prominance
       differences_bs(i) = (max(prominance)-mean(prominance));
    end
end
sum(differences_bs < threshold)
%open_all_delay_plots(differences_bs, threshold, results)
% 20 
% Makes 3 mistakes but corrects 1 possible mistake of the Q BS <0.15
%% Irregular model pattern
%peak prominence 
differences_mod = zeros(1, size(results,1));
for i=1:length(results)
    prominance = results{i,7}(length(results{i,7})- (length(results{i,7})/4)+1:length(results{i,7}));
    if prominance
       differences_mod(i) = (max(prominance)-mean(prominance));
    end
end
sum(differences_mod < threshold)
%open_all_delay_plots(differences_mod, threshold, results)
% 28 
% if BS < 0.15 the mod prediction is always irregular = 18 
% In 3 cases did it catch a mistake 
% In 5 cases it made a mistake 
%% irregular mod and bs pattern 
sum(differences_mod < threshold & differences_bs < threshold)
%% irregular bs and non prominent bs
sum(differences_bs < threshold & [results{:,4}] < threshold)
%% irregular mod and non prominent mod
sum(differences_mod < threshold & [results{:,5}] < threshold)
%% Delays 
delay_threshold = 1000;
abs_diff_delays = abs([results{:,1}] - [results{:,2}]);
sum(abs_diff_delays > delay_threshold)
%open_all_delay_plots(-abs_diff_delays, -delay_threshold, results)
%% All 
sum(differences_mod < threshold & differences_bs < threshold & [results{:,4}] < threshold & [results{:,5}] < threshold);
sum(differences_mod < threshold & differences_bs < threshold & [results{:,4}] < threshold & [results{:,5}] < threshold & abs_diff_delays > delay_threshold);

%% avg signal prominance
differences_bs = ones(1, size(aligned_ma,1));
for i=1:size(aligned_ma,1)
    if ~isempty(aligned_ma{i,3})
        f = fit([-3000:3000].', aligned_ma{i,3}.', 'smoothingspline', 'SmoothingParam', 0.01);
        mean_model = f([-3000:3000].');
        %mean_model_normalized = (mean_model -  min(mean_model)) / (max(mean_model) - min(mean_model));
        [pks_mod, locs_mod, w_mod, prominance] = findpeaks(mean_model, 'MinPeakWidth', 100);
        differences_bs(i) = (max(prominance)-mean(prominance));
        sorted_p = sort(prominance);
        differences_bs(i) = sorted_p(end) - sorted_p(end-1);
        if differences_bs(i) < 0.15
            disp('got_here')
            figure;
            findpeaks(mean_model, 'MinPeakWidth', 100, 'Annotate', 'extents')
            yyaxis right
            plot(aligned_ma{i,2}, 'g' )
            title(sprintf('%.2f -- %s', differences_bs(i), aligned_ma{i,1}))
        end 
    end
end
%% avg signal prominance

[rt,ll,ul] = risetime(data{1,3});
risetime(data{1,3});
var_rise(floor(ul)) = deal(1);
[delay_model] = finddelay(smoothdata(var_rise, 'gaussian', 20), data{1,2})
%[a b] = xcorr(smoothdata(var_rise, 'gaussian', 20), (data{1,2})); 
%figure; plot(b,a)

idx = find(var_rise>0.1);
epoched = getepocheddata(smoothdata(var_rise, 'gaussian', 20), idx, [-3000 3000]);
epoched_mod = getepocheddata(data{1,3}, idx, [-3000 3000]);
epoched_bs = getepocheddata(data{1,1}, idx, [-3000 3000]);
figure; 
plot(mean(epoched_mod, 'omitnan'), 'k')
yyaxis right 
plot(mean(epoched_bs, 'omitnan'), 'g')
hold on
plot(mean(epoched, 'omitnan'))
%% 
[Phone, Transitions, idx] = get_phone_data(EEG, 0);
BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
model_predictions = EEG.Aligned.BS.Model;

[rt,ll,ul] = risetime(model_predictions);
var_rise(floor(ul)) = deal(1);
[delay_model] = finddelay(smoothdata(var_rise, 'gaussian', 20), Phone)
for ff = 1:size(EEG.Aligned.Phone.Blind,2)
    EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
    EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)-delay_model;
end

[Phone, Transitions, idx] = get_phone_data(EEG, 2);
%epoched_mod =  getepocheddata(nanzscore(model_predictions), idx, [-3000: 3000]);
ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-3000 3000]); 
ep_blind_model = getepocheddata(nanzscore(EEG.Aligned.BS.Model),idx,[-3000 3000]); 
figure; 
plot([-3000:3000], mean(ep_blind_model, 'omitnan'))
hold on 
plot([-3000:3000], mean(ep_blind_bs, 'omitnan'))

%% 
z = aligned_ma_new(:,1);
participants = string(z(~cellfun(@isempty, aligned_ma_new(:,1)))).';
no_files = dir('/home/ruchella/master_thesis_IS-DS/src/alignment/moving_averages/results/aligned_model_plots/no');
data_files = {no_files.name};
data_files = data_files(~ismember(data_files,{'.','..'}));
no_split = split(data_files, '.');
no = string(no_split(:,:,1));
unfiltered_no = intersect(no, participants);
size(unfiltered_no, 2)
percentage = size(unfiltered_no, 2)/length(no) * 100


maybe_files = dir('/home/ruchella/master_thesis_IS-DS/src/alignment/moving_averages/results/aligned_model_plots/maybe');
data_files = {maybe_files.name};
data_files = data_files(~ismember(data_files,{'.','..'}));
maybe_split = split(data_files, '.');
maybe = string(maybe_split(:,:,1));
unfiltered_maybe = intersect(maybe, participants);
size(unfiltered_maybe, 2)
percentage = size(unfiltered_maybe, 2)/length(maybe) * 100

prob_files = dir('/home/ruchella/master_thesis_IS-DS/src/alignment/moving_averages/results/aligned_model_plots/probably');
data_files = {prob_files.name};
data_files = data_files(~ismember(data_files,{'.','..'}));
prob_split = split(data_files, '.');
prob = string(prob_split(:,:,1));
unfiltered_prob = intersect(prob, participants);
size(unfiltered_prob, 2)
percentage = size(unfiltered_prob, 2)/length(prob) * 100

yes_files = dir('/home/ruchella/master_thesis_IS-DS/src/alignment/moving_averages/results/aligned_model_plots/yes');
data_files = {yes_files.name};
data_files = data_files(~ismember(data_files,{'.','..'}));
yes_split = split(data_files, '.');
yes = string(yes_split(:,:,1));
unfiltered_yes = intersect(yes, participants);
size(unfiltered_yes, 2)
percentage = size(unfiltered_prob, 2)/length(prob) * 100