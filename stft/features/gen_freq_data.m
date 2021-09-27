function [reshaped_FS_window, BS_window_freq] = gen_freq_data(EEG,BS_window, FS_window,bandpass_upper_range, ma,model_data_generation)
%% Generates the data for training. Performs rolling window rms, stft, moving averages calculation and normalization. 
%
% **Usage:** [reshaped_FS_window, BS_window_freq] = gen_freq_data(EEG,BS_window, FS_window,bandpass_upper_range, ma,model_data_generation)
%
% Input(s):
%   - EEG = EEG data from one participant
%   - BS_window = Bendsensor data 
%   - FS_window = Forcesensor data
%   - bandpass_upper_range = max frequency range used in the bandpass filter
%   - ma = binary 1 if moving averages should be generated and 0 if not
%   - model_data_generation = binary 1 if used for prediction and 0 if used for model data generation
% Ouput(s):
%   - reshaped_FS_window: Forcesensor data processed and reshaped into model ready format
%   - BS_window_freq_MA: Bensensor data with stft and moving averages features 
%
%% rms
win_size = 10;
rms_arr = zeros(size(BS_window));
for i=1:length(BS_window)
    if i+win_size < length(BS_window)-win_size
        x = BS_window(i:win_size+i);
        rms_arr(i) = sqrt(1/length(x).*(sum(x.^2)));
    else
        % shrinking window
        x = BS_window(i:end);
        rms_arr(i) = sqrt(1/length(x).*(sum(x.^2)));
    end
end
%% stft 
window_size = 1024;
frame_size = 1024;
hopsize = frame_size/2;
fs = EEG.srate; %sampling rate

padding_stft = (frame_size - mod(size(rms_arr,1),frame_size)) + hopsize;
BS_rms = [rms_arr ; zeros(padding_stft, 1)];

[bs_f, F] = stft(BS_rms,fs,'Window',hann(window_size),'OverlapLength',hopsize,'FFTLength',frame_size);
% remove frequencies above 40 hz and below 0
bs_f = bs_f(find(F>=0,1, 'first'):find(F>bandpass_upper_range,1, 'first'),:);

% remove complex numbers and normalize BS frequencies
BS_window_freq = abs(bs_f).^2; 
%% normalize
% For model prediction normalize over a chunks of the data
if model_data_generation
    index = 1;
    chunk_size = 2000;
    normalizations = ceil(size(BS_window_freq,2)/2000);
    BS_window_freq_norm = [];
    for i=1:normalizations
        if  index <= size(BS_window_freq,2)-chunk_size
            BS_window_freq_chunk = normalize(BS_window_freq(:,index:index+chunk_size-1),2);
        else
            BS_window_freq_chunk = normalize(BS_window_freq(:,index:end),2);
        end
        index = index + chunk_size;
        BS_window_freq_norm = horzcat(BS_window_freq_norm,BS_window_freq_chunk);
    end
    BS_window_freq = BS_window_freq_norm.';
else
    % For model data generation
    BS_window_freq = BS_window_freq.';
end 
%% Moving averages
if ma
    num_features = 10;
    pad_bs = size(bs_f,2) * hopsize - size(BS_window,1);
    BS_padded = [BS_window ; zeros(pad_bs, 1)];
    reshaped_BS_window = reshape(BS_padded, [hopsize,size(bs_f,2)]).';

    MA_matrix = [];
    for j=1:num_features
       new_MA = movmean(reshaped_BS_window, j*10,1);
       MA_matrix = horzcat(MA_matrix,new_MA);
    end

% combine moving averages and stft
BS_window_freq = horzcat(BS_window_freq,MA_matrix);
end 
%% resample fs
reshaped_FS_window = [];
if FS_window
    %FS_window = normalize(FS_window);
    pad_fs = size(bs_f,2) * hopsize - size(FS_window,1);
    FS_padded = [FS_window ; zeros(pad_fs, 1)];
    reshaped_FS_window = reshape(FS_padded, [hopsize,size(bs_f,2)]).';
end
