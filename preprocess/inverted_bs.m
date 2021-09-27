function [inverted, BS] = inverted_bs(EEG, BS)
%% Find inverted bendsensor data and flip
%
% **Usage:** [inverted, BS] = inverted_bs(EEG, BS)
%
% Input(s):
%   - EEG = EEG struct
%   - BS = preprocessed bendsensor data
% Output(s):
%   - inverted = 1 data was inverted 0 data was not inverted
%   - BS = BS data flipped if inverted = 1

%% All signals
[pks_neg, locs_neg] = findpeaks(-BS, 'MinPeakWidth', 100, 'MinPeakProminence', 0.2);
[pks_pos, locs_pos] = findpeaks(BS, 'MinPeakWidth', 100, 'MinPeakProminence', 0.2);
%figure()
%x = 1:length(data); 
%x_peaks_neg = x(locs_neg);
%x_peaks_pos = x(locs_pos);
%plot(x,data,x_peaks_neg,-pks_neg,'*r')
%hold on
%plot(x,data,x_peaks_pos,pks_pos,'*r')

inverted_all = 0;
if mean(pks_neg) < mean(pks_pos)
    inverted_all = 1;
end
%% Average signal
Phone_d = []; Marker_d = [];
for ff = 1:size(EEG.Aligned.Phone.Blind,2)
    Phone_d = [Phone_d EEG.Aligned.Phone.Blind{1,ff}(:,2)'];
end
Phone = double(ismember(1:EEG.pnts, Phone_d));
idx = find(Phone>0.1); 
idx(diff(idx)<200) = [];
ep_blind_bs = getepocheddata(nanzscore(BS),idx,[-10000 10000]);   
ep_blind_bs_avg = nanmean(ep_blind_bs);

[pks_neg_avg, locs_neg_avg] = findpeaks(-ep_blind_bs_avg, 'MinPeakWidth', 100, 'MinPeakProminence', 0.1);
[pks_pos_avg, locs_pos_avg] = findpeaks(ep_blind_bs_avg, 'MinPeakWidth', 100, 'MinPeakProminence', 0.1); 

inverted_avg = 0;
if  max(pks_neg_avg) < max(pks_pos_avg)
    inverted_avg = 1;
end
%figure
%plot(ep_blind_bs_avg)
%x = 1:length(ep_blind_bs_avg); 
%x_peaks_neg = x(locs_neg_avg);
%x_peaks_pos = x(locs_pos_avg);
%plot(x, ep_blind_bs_avg, x_peaks_neg, -pks_neg_avg,'*r')
%hold on
%plot(x, ep_blind_bs_avg, x_peaks_pos, pks_pos_avg,'*r')
%% Final decision
inverted = 0;
if inverted_all == inverted_avg && inverted_all
   inverted = inverted_all;
   BS = -BS;
   disp('Inverted')
end