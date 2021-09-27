% Analyze model predictions. Generates plots the epoched standardized model and BS data. 
% 
% **Usage:** create_model_results.m
%
% Generates a cell with the following fields.
%   - results = 
%       - delay_bs = delay of BS data based on max epoched signal around tap
%       - delay_model = delay of model data based on max average signal around tap
%       - p_file = participant folder name & file name(E.G. AG02/12_02_30_02_02.set)
%       - max_val_bs = max value of the epoched BS signal around tap
%       - max_val_model =  max value of the epoched model signal around tap
%       - [pks_bs, locs_bs, w_bs, p_bs] = results of findpeaks on epoched BS signal
%       - [pks_mod, locs_mod, w_mod, p_mod]= results of findpeaks on epoched model signal
%
% Requires: 
%   - getepocheddata.m
%   - nanzscore.m

%%
path = '/media/Storage/Common_Data_Storage/EEG/Feb_2018_2020_RUSHMA_ProcessedEEG';
figures_save_path = '/home/ruchella/Matlab/results_plots/distribution_plots';
results_save_path = '/home/ruchella/Matlab/results_plots/decision_tree_results.mat'

index = 1;
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
            % get the phone data from the participant based on blind
            % alignment
            Phone_d = []; Marker_d = []; delay_model = []; delay_bs = [];
            for ff = 1:size(EEG.Aligned.Phone.Blind,2)
                Phone_d = [Phone_d EEG.Aligned.Phone.Blind{1,ff}(:,2)'];
                Marker_d = [Marker_d min(EEG.Aligned.Phone.Blind{1,ff}(:,2)')];
            end
            Phone = double(ismember(1:EEG.pnts, Phone_d));
            idx = find(Phone>0.1); 
            idx(diff(idx)<200) = [];
            
            aligned_bs_data = EEG.Aligned.BS.Data(:,1);
            % Check if there is any phone data 
            % Check if there is any BS data 
            % Check if the BS data is not only NANs
            if ~isempty(idx) && ~isempty(aligned_bs_data) && ~(sum(isnan(aligned_bs_data)==1) == length(aligned_bs_data))  
                % get cleaned BS data
                BS = getcleanedbsdata(aligned_bs_data,EEG.srate,[1 10]);
                % epoched data around the taps 
                % range 30000 because a delay shouldn't be larger than that
                ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-30000 30000]); 
                ep_blind_model = getepocheddata(nanzscore(EEG.Aligned.BS.Model),idx,[-30000 30000]); 
                [max_val_model max_model_loc]= max(mean(ep_blind_model, 'omitnan'))
                [max_val_bs max_bs_loc]= max(abs(mean(ep_blind_bs, 'omitnan')))
                delay_model = max_model_loc-30000;
                delay_bs = max_bs_loc-30000;
                
                % find peaks in the average BS or model signal 
                % this is done to check whether there are many large peaks
                % in the signal 
                [pks_bs, locs_bs, w_bs, p_bs] = findpeaks(mean(ep_blind_bs, 'omitnan'), 'MinPeakWidth', 100);   
                [pks_mod, locs_mod, w_mod, p_mod] = findpeaks(mean(ep_blind_model, 'omitnan'), 'MinPeakWidth', 100);
                % participant folder name & file name(E.G. AG02/12_02_30_02_02.set)
                p_file = sprintf('%s/%s',participants{1,i},data_files{1,j});
                
                % store all values in a cell
                results(index,:) = {delay_bs, delay_model,p_file , max_val_bs, max_val_model, [pks_bs, locs_bs, w_bs, p_bs], [pks_mod, locs_mod, w_mod, p_mod]}
                
                % plot epoched BS and model signal around taps
                h = figure()
                plot(mean(ep_blind_bs, 'omitnan'))
                yyaxis right
                plot(mean(ep_blind_model, 'omitnan'))
                legend('BS', 'Model')
                title(sprintf('%s delayBs %d delayMod %d', participant, delay_bs, delay_model))
                savefig(h, sprintf('%s/%s_delay_%d.fig', figures_save_path, participant, delay_model))
                close(h)
                index = index + 1;
            end
        
        end
    end
end 
save(results_save_path, 'results')