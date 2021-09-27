function [EEG simple]= getbsnetcorrecttapsinEEG(EEG)
% usage [EEG simple] = getbsnetcorrecttapsinEEG (EEG)
% Goes through all possible options to land an alignment between phone and
% EEG data. Note, BS data must be present
% If the correction was simple == 1, if based on clearer signal, == 2, if
% no correction == 3.

if isfield(EEG.Aligned.BS, 'Data') && isfield(EEG.Aligned.BS, 'Model')
    display ('BS and BSNET model are present')
    BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
    
    % examine blind alignment
    Phone_d = []; Marker_d = [];
    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Blind{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Blind{1,ff}(:,2)')];
    end
    
    Phone = double(ismember(1:EEG.pnts, Phone_d));
    Transitions = double(ismember(1:EEG.pnts, Marker_d));
    Transitions(Transitions<1) = deal(NaN) ;
    
    idx = find(Phone>0.1); 
    idx(diff(idx)<200) = [];
    ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-30000 30000]); %ep_blind_bs(ep_blind_bs==0) = deal(NaN);
    ep_blind_model = getepocheddata(nanzscore(EEG.Aligned.BS.Model),idx,[-30000 30000]); %ep_blind_model(ep_blind_model==0) = deal(NaN);
    
    [max_val_model max_model_loc]= max((mean(ep_blind_model, 'omitnan')))
    [max_val_bs max_bs_loc]= max((abs(mean(ep_blind_bs, 'omitnan'))))
    
    %Phone data is ahead by the following number of samples according to model
    subtractthisfrommarker_model = max_model_loc-30000;
    subtractthisfrommarker_bs = max_bs_loc-30000;
    
    % Now, choose the correction and perform it
    if abs(diff([max_model_loc max_bs_loc]))<300 % if the difference in correction is really small its simple choose Model
        for ff = 1:size(EEG.Aligned.Phone.Blind,2)
            EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
            EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)+subtractthisfrommarker_model;
        end
        display('simple correction')
        simple = 1;
    else
        if max_val_bs<max_val_model
            for ff = 1:size(EEG.Aligned.Phone.Blind,2)
                EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
                EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)+subtractthisfrommarker_model;
            end
            simple = 2;
        elseif max_val_bs>0.25
            for ff = 1:size(EEG.Aligned.Phone.Blind,2)
                EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
                EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)+subtractthisfrommarker_bs;
            end
            simple = 2;
        else
            for ff = 1:size(EEG.Aligned.Phone.Blind,2)
                EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
            end
            simple =3;
        end
    end
else
    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
        EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
    end
    simple =3;
    
end


if or(simple ==2, simple == 1)
    %diagnostic plot
    h = figure; 
    Phone_d = []; Marker_d = [];
    for ff = 1:size(EEG.Aligned.Phone.Model,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Model{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Model{1,ff}(:,2)')];
    end
    
    
    Phone = double(ismember(1:EEG.pnts, Phone_d));
    Transitions = double(ismember(1:EEG.pnts, Marker_d));
    Transitions(Transitions<1) = deal(NaN) ;
    
    idx = find(Phone>0.1); idx(diff(idx)<200) = [];
    ep_blind_bs = getepocheddata(zscore(BS),idx,[-3000 3000]); %ep_blind_bs(ep_blind_bs==0) = deal(NaN);
    ep_blind_model = getepocheddata(zscore(EEG.Aligned.BS.Model),idx,[-3000 3000]); %ep_blind_model(ep_blind_model==0) = deal(NaN);
    plot([-3000:3000],nanmean(ep_blind_model)); 
yyaxis right; plot([-3000:3000],nanmean(ep_blind_bs))
shg
shg
end
end


% First, gather an assesment based on 
