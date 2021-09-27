function [EEG, simple, idx, Phone, ep_blind_bs, ep_blind_model] = decision_tree_alignment(EEG, BS,create_diagnostic_plot)
%% Decides when to choose the model based alignment, BS based alignment, or old alignment
%
% **Usage:** [EEG simple] = decision_tree_alignment(EEG)
% 
%
% Input(s):
%   - EEG = EEG data from one participant
%   - BS = preprocessed BS dataset
%   - create_diagnostic_plot =  bool 1= yes create diagnostic plot, 0 = do
%   not create plot
% Output(s):
%   - EEG = EEG data from one participant where EEG.Aligned.Phone.Blind
%   contains corrected alignment rules
%   - simple = 1: model based alignment ,2: BS based alignment, 3 old alignment
% 
% Derived from getbsnetcorrecttapsinEEG (EEG) but different splits
%
%%
if isfield(EEG.Aligned.BS, 'Data') && isfield(EEG.Aligned.BS, 'Model')
    display ('BS and BSNET model are present')
    
    % examine blind alignment
    [Phone, Transitions, idx] = get_phone_data(EEG, 0);
    
    ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-30000 30000]); %ep_blind_bs(ep_blind_bs==0) = deal(NaN);
    ep_blind_model = getepocheddata(nanzscore(EEG.Aligned.BS.Model),idx,[-30000 30000]); %ep_blind_model(ep_blind_model==0) = deal(NaN);
    
    [max_val_model, max_model_loc]= max((mean(ep_blind_model, 'omitnan')));
    [max_val_bs, max_bs_loc]= max((abs(mean(ep_blind_bs, 'omitnan'))));
    
    %Phone data is ahead by the following number of samples according to model
    delay_model = max_model_loc-30000;
    delay_bs = max_bs_loc-30000;
  

    if (max_val_bs<0.15 || abs(diff([delay_model delay_bs]))>EEG.srate)
        for ff = 1:size(EEG.Aligned.Phone.Blind,2)
            %EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
            EEG.Aligned.Phone.Model{1,ff} = [];
        end
        simple = 3;
    %elseif (abs(diff([delay_model delay_bs]))<500)
    else
        for ff = 1:size(EEG.Aligned.Phone.Blind,2)
            EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
            EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)+delay_model;
        end
        simple = 1;
    %else 
    %    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
    %        EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
    %       EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)+delay_bs;
    %   end
    %    simple = 2;
    end 
else
    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
        EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
    end
    simple =3;
    

    if create_diagnostic_plot
        if or(simple ==2, simple == 1)
            %diagnostic plot
            [Phone, Transitions, idx] = get_phone_data(EEG, 2);
            h = figure;       
            ep_blind_bs = getepocheddata(zscore(BS),idx,[-3000 3000]);
            ep_blind_model = getepocheddata(zscore(EEG.Aligned.BS.Model),idx,[-3000 3000]); 
            plot([-3000:3000],mean(ep_blind_model, 'omitnan')); 
            yyaxis right; 
            plot([-3000:3000],mean(ep_blind_bs, 'omitnan'))
            title(participant)
            legend('model', 'bs')
        end
    end
end
%%
%f = fit([-30000:30000].', mean(ep_blind_model, 'omitnan').', 'smoothingspline', 'SmoothingParam', 0.01);
%mean_model = f([-30000:30000].');
%[pks_mod, locs_mod, w_mod, prominance] = findpeaks(mean_model, 'MinPeakWidth', 100);
%sorted_p = sort(prominance);
%difference = sorted_p(end) - sorted_p(end-1);
%if (max_val_bs<0.15 || abs(diff([delay_model delay_bs]))>EEG.srate || difference<0.15)