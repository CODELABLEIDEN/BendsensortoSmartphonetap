function [EEG, BS]= getNonEEGdataalignedtoEEGdpv3(EEG,inner_loop_idx, participant, save_path, options)
% Usage [EEG]= getNonEEGdataalignedtoEEGdp(EEG,ClockModel,SecStep, ClockGen);
% Input, CODELAB EEG.set file with BS (EEG.BS) and Phone data (EEG.PhoneData) inserted (by using the
% organization script Run_Orginzation_withoutICA)
% Input, ClockModel the cfit object used to adjust clock drifts. [] if
% needed to determine this.
% Input, SecStep. [] if no secondary clock correction is needed
% Input, ClockGen. The general correction as a cfit object to correct the
% phone indices. Leave [] if not correcting
% Input, net. Trained neuronal net
% Input, type, Subject type for BSnet *ie, DS(1) or not DS (0)
% Output, t_phone the phone touch indices in EEG dpnts.
%
% Output, EEG
% Output, EEG.Aligned
%
% Output, EEG.Aligned.Params.BS_adjustment --> The alignment stats based on
% sensor trigger vs. EEG trigger detection (matched to EEG sample rate, and
% based on [BS_adjustment,EEGinfo, Triggerlatency] = getBSdatainEEGidx(EEG)
%
% Output, EEG.Aligned.Params.EEGinfo --> The EEG trigger information based
% on getBSdatainEEGidx, also contains onset and offset of EEG segments
% Output, EEG.Aligned.Params.Alignmentmethod --> True if aligned triggers
%
% Output, EEG.Aligned.BS.Triggers --> The BS triggers aligned to EEG pnts
% Output, EEG.Aligned.BS.Data(:,1)--> The BS values
% Output, EEG.Aligned.BS.Data(:,2)--> The BS values as in force sensor
%
% Output, EEG.Aligned.Phone.Blind{1,EEGsegment}, The phone timestamp and
% the corresponding EEG dpnts idx.
%
% Output, EEG.Aligned.Phone.Corrected{1,EEGsegment}, The phone timestamp and
% the corresponding EEG dpnts idx. corrected for delay according to aligned
% BS output
%
% Output, EEG.Aligned.Phone.RNNCorrected{1,EEGsegment}, The phone timestamp
% and the corresponding EEG dpnts idx. corrected for delay according to
% aligned RNN model BS output
%
% EEG.Aligned.Params.PhoneBSCoeff ---> Correlation coefficent of the delay
% EEG.Aligned.Params.Phone_delay ----> The delay according to finddelay
% [Segment level correction is preferred] If that is performed then the
% following outputs matter
% EEG.Aligned.Params.Phone_timeser{1,segment}----> The delay according to finddelay
% EEG.Aligned.Params.Phone_timeserCoeff{1,segment}---> Correlation coefficent of the delay
%
% -------------------------------------------------------------------------
% Other relevant outputs
% EEG.PhoneData{1, 1}.SUBJECT.tap  ----> Phone data QA format (obtained using gettapdata)
%
% Arko Ghosh, Leiden University
arguments
    EEG struct
    inner_loop_idx = []
    participant = []
    save_path = []
    options.net = []
end
if isempty(options.net)
    try
        model_file_path = 'models/alignment_models/MA_inverted_full.json';
        weights_file_path = 'models/alignment_models/MA_inverted_full_weights.h5';
        options.net = importKerasNetwork(model_file_path, 'WeightFile', weights_file_path, 'OutputLayerType', 'regression');
    catch
        error('Please provide a trained series network as name value pair argument to this function. Example: "net", seriesnetworkobject')
    end
end
BS = [];
EEG.Aligned.BSnet =[];
%% Step 1 Alignment is only worth while if there is BS data
%% If BS RNN model exists, re-estimate the correction needed for the blind alignment
if isfield(EEG.Aligned, 'BS')
    % House keeping
    % Use BS RNN net for predictions
    tic
    display('starting RNN model prediction....');
    
    % Predict model outcomes
    BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
    BS = BS.';
    
    %         C = 'C:\Users\aghos\OneDrive - fsw.leidenuniv.nl\Leiden_CODELAB\Clean_Codes';
    %         rmpath(genpath(C));
    
    % Find users who were sampled below 100 Hz and interpolate
    if EEG.srate< 1000 % find experiments which were performed at 500 Hz
        BS(isnan(BS)) = deal(nanmedian(BS));
        BS = interp(BS,round(1000/EEG.srate));
    end
    
    % Actual predictions;
    [model_predictions] = predict_MA(BS,options.net);
    
    
    % Decimate data for non 1000 Hz users
    if EEG.srate< 1000
        model_predictions(isnan(model_predictions)) = deal(nanmedian(model_predictions));
        [EEG.Aligned.BS.Model] = decimate(model_predictions,round(1000/EEG.srate));
    else
        [EEG.Aligned.BS.Model] = model_predictions;
    end
    display('End RNN model prediction....')
    toc
end
end