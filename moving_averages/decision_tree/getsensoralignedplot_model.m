function [Phone, Marker_d, BS, idx] = getsensoralignedplot_model(EEG,indices);
% Plot phone data in onjunction with BS movement data 
% Also plots the IBM Alignment pulses 
% Usage : [Phone, Transitions, BS, idx] = getsensoralignedplot(EEG1,indices)
% Continous Phone Data
% Marker_d Breaks in EEG recorder
% BS data (filtered)
% Indices of phone data idx.
%
% Use of indices 
%   - If 0 use uncorrected phone indices vs. EEG aligned BS data
%   - If 1 use corrected phone indices vs. EEG aligned BS data 
%   - If 2 use RNN corrected phone indices vs. EEG aligned BS data 
%
% CODELAB EEG FORMAT (partial data is sufficient) 
% Arko Ghosh, Leiden University
if indices == 0 
    Phone_d = []; Marker_d = []; 
    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Blind{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Blind{1,ff}(:,2)')];
    end
elseif indices == 1
    Phone_d = []; Marker_d = []; 
    for ff = 1:size(EEG.Aligned.Phone.Corrected,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Corrected{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Corrected{1,ff}(:,2)')];
    end
elseif indices == 2
    Phone_d = []; Marker_d = []; 
    for ff = 1:size(EEG.Aligned.BSnet.Phone.Corrected,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Model{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Model{1,ff}(:,2)')];

    end
end 

    Phone = double(ismember(1:EEG.pnts, Phone_d));
    Transitions = double(ismember(1:EEG.pnts, Marker_d));
    Transitions(Transitions<1) = deal(NaN) ;

    if or(indices == 1, indices == 0)
BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
    else
BS = getcleanedbsdata(EEG.Aligned.BS.Model,EEG.srate,[1 20]); 
    end
BS_model = (EEG.Aligned.BS.Model); 

figure('name','Aligned Data')
plot(Phone); hold on; 
plot(Transitions,'.r','MarkerSize',20)
yyaxis right; 
plot(BS, 'k'); 
grid on
grid minor


figure('name','Aligned Data Model')
plot(Phone); hold on; 
plot(Transitions,'.r','MarkerSize',20)
yyaxis right; 
plot(BS_model, 'k'); 
grid on
grid minor

figure('name','Aligned Epoched Data')
idx = find(Phone>0.1); idx(diff(idx)<200) = []; 
ep = getepocheddata(BS,idx,[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'k'); hold on
 lim = min([length(idx) 200]); 
 ep = getepocheddata(BS,idx(1:lim),[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'g','LineWidth',1.5); hold on
 try
 lim = (length(idx)-200); 
 ep = getepocheddata(BS,idx(lim:end),[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'b','LineWidth',1.5); hold on
 end
 legend({'Overall if more than 200','First 200 or less', 'Last 200 or less'}); 

xlabel('Distance from smartphone touch (data points)')
ylabel('Mean displacement (a.u)')
grid on
grid minor



figure('name','Aligned Epoched Data Model')
idx = find(Phone>0.1); idx(diff(idx)<200) = []; 
ep = getepocheddata(BS_model,idx,[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'k'); hold on
 lim = min([length(idx) 200]); 
 ep = getepocheddata(BS_model,idx(1:lim),[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'g','LineWidth',1.5); hold on
 try
 lim = (length(idx)-200); 
 ep = getepocheddata(BS_model,idx(lim:end),[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'b','LineWidth',1.5); hold on
 end
 legend({'Overall if more than 200','First 200 or less', 'Last 200 or less'}); 

xlabel('Distance from smartphone touch (data points)')
ylabel('Mean displacement (a.u)')
grid on
grid minor

figure('name','Trigger Alignment')
pre_trig = and(or(contains({EEG.urevent.type}, 'T'),contains({EEG.urevent.type}, 'S')),~contains({EEG.urevent.type}, 'T  1_o'));
tmp_trig = (double(ismember([1:EEG.urevent(end).latency],[EEG.urevent(pre_trig).latency])));

plot((EEG.Aligned.BS.Triggers))
hold on; 
plot((tmp_trig), '--')

legend({'BS/FS Recorded pulses','EEG Recorded pulses'}); 
xlabel('Sample (data points)')
ylabel('Trigger Locations or Voltages (a.u)')
grid on
grid minor
end