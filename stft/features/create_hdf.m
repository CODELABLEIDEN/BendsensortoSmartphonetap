function create_hdf(path, save_path)
%% Finds every participatant data and generate for each, the data for training. Save the training data in h5 file format.
%
% **Usage:** create_hdf(path, save_path)
%
% Input(s):
%   - path: path to data 
%   - save_path: name of the hd5 file. Example: 'stft_1024_with_rms.h5'
% Output(s):
%   - The data is exported as a h5 file. The structure is /participant_fileNumber/participant_windowNumber/filename_filetype_windowNumber. As an example for participant DS01 file 1 window 2 the file looks like /DS01_1/DS01_1_win_2/DS01_BS_2
%
data_folder = dir(path);
participants = {data_folder([data_folder.isdir]).name};
participants = participants(~ismember(participants,{'.','..'}));
for i=1:size(participants,2)
    files = dir(sprintf('%s\\%s', path, participants{1,i}));
    data_files = {files.name};
    data_files = data_files(~ismember(data_files,{'.','..'}));
    for j=1:size(data_files,2)
        if data_files{1,j} ~= "Status.mat"
            load(data_files{1,j})
            participant = sprintf('%s_%d', participants{1,i}, j)
            [filtered, BS, base, bandpass_upper_range] = preprocess(EEG);
            [dataset] = seperate_FS_sets(filtered, BS, base);
            for win=1:length(dataset)
                BS_window = dataset{1,win}(:,1);
                FS_window = dataset{1,win}(:,2);
                [reshaped_FS_window, BS_window_freq] = gen_freq_data(EEG,BS_window, FS_window,bandpass_upper_range,1,0);
                h5create(save_path,sprintf('/%s/win_%g/%s_BS_%g',participant,win,participant,j),(size(BS_window_freq)));
                h5write(save_path,sprintf('/%s/win_%g/%s_BS_%g',participant,win,participant,j),BS_window_freq);
                h5create(save_path,sprintf('/%s/win_%g/%s_FS_%g',participant,win,participant,j),size(reshaped_FS_window));
                h5write(save_path',sprintf('/%s/win_%g/%s_FS_%g',participant,win,participant,j),reshaped_FS_window);
            end
        end
    end
end 