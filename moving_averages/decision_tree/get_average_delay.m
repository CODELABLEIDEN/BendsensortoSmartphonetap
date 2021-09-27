function [delay_model, delay_bs] = get_average_delay(EEG, participant, save_path)
% Calculates the average delay for one participant given BS data or model predictions
%
% **Usage:** [delay_model, delay_bs] = get_average_delay(EEG, participant, save_path)
%
% Input(s):
%   - EEG = EEG data
%   - participant = participant number 
%   - save_path = path to save the plots
% Output(s):
%   - delay_model = delay for one participant according to model predictions 
%   - delay_bs = delay for one participant according to BS data 
% Requires :
%   - getepocheddata.m
%   - nanzscore.m
%%
if isfield(EEG.Aligned.BS, 'Data') && isfield(EEG.Aligned.BS, 'Model')
    % Get the smartphone data based on the blind alignment
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
        BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
        % epoched data around the taps
        ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-30000 30000]); 
        ep_blind_model = getepocheddata(nanzscore(EEG.Aligned.BS.Model),idx,[-30000 30000]); 
        [max_val_model max_model_loc]= max(mean(ep_blind_model, 'omitnan'))
        [max_val_bs max_bs_loc]= max(abs(mean(ep_blind_bs, 'omitnan')))
        
        % check if the bs data is regular or model made consistent predictions
        % 0.15 is manually chosen
        % If yes calculate the delay
        if max_val_bs>0.15 && max_val_model>0.15
            delay_model = max_model_loc-30000;
            delay_bs = max_bs_loc-30000;
            h = figure('name', 'regular BS and mod', 'visible', 'off')
        else
            h = figure('name', 'irregular BS or mod', 'visible', 'off')
        end 
        
        % plot data
        ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-3000 3000]); 
        ep_blind_model = getepocheddata(nanzscore(EEG.Aligned.BS.Model),idx,[-3000 3000]); 
        plot([-3000:3000], mean(ep_blind_bs, 'omitnan'))
        yyaxis right
        plot([-3000:3000], mean(ep_blind_model, 'omitnan'))
        legend('BS', 'model')
        savefig(h, sprintf('%s/%_delay_%d.fig', save_path, participant, delay_model))
        close(h)
    end
end