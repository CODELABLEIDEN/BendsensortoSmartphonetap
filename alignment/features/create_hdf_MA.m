function [] = create_hdf_MA(EEG, inner_loop_idx, participant, save_path)
%% Create hdf file with data for model training
%
% **Usage:** create_hdf_MA(EEG, inner_loop_idx, participant, save_path)
%
% Input(s):
%   - EEG = EEG struct
%   - inner_loop_idx = index in which to add the data in the h5 file
%   - participant = participant folder name and file number (E.g. AGO3_2)
%   - save_path = path to save the file with .h5 extention.
%     Example: 'data/alignment_train_data/MA.h5'
%
% Output(s):
%   - None - generates a h5 file at the save_path location with the training data
%
% Requires:
%   - seperate_FS_sets.m
%   - preprocess.m
%   - create_matrix_MA.m
%
% Author: R.M.D. Kock

%%
if strcmp(participant(1:2), 'DS')
    % preprocess the BS and FS data
    [filtered, BS] = preprocess(EEG, 10);

    % correct participants with inverted BS
    if (strcmp(participant,'DS02_1') || strcmp(participant,'DS02_2') || strcmp(participant,'DS07_1') || strcmp(participant,'DS22_1') || strcmp(participant,'DS22_2'))
        BS = -BS;
        disp('inverted')
    end

    [dataset,base_indices] = seperate_FS_sets(filtered, BS, -1);
    for win=1:length(dataset)
        BS_window = dataset{1,win}(:,1);
        FS_window = dataset{1,win}(:,2);
        [MA_matrix] = create_matrix_MA(BS_window);
        h5create(save_path,sprintf('/%s/win_%g/%s_BS_%g',participant,win,participant,inner_loop_idx),(size(MA_matrix)));
        h5write(save_path,sprintf('/%s/win_%g/%s_BS_%g',participant,win,participant,inner_loop_idx),MA_matrix);
        h5create(save_path,sprintf('/%s/win_%g/%s_FS_%g',participant,win,participant,inner_loop_idx),size(FS_window));
        h5write(save_path,sprintf('/%s/win_%g/%s_FS_%g',participant,win,participant,inner_loop_idx),FS_window);
    end
end
end
