function create_hdf_MA(path, save_path)
%% Create hdf file with data for model training 
% 
% **Usage:** create_hdf_MA(path, save_path)
%
% Input(s):
%   - path = path BS dataset. 
%   - save_path = path to save the file .h5 extensension.
%     Example: 'D:/MA_abs_full.h5'
% Output(s):
%   - generates a h5 file at the save_path location with the training data
% Requires:
%   - seperate_FS_sets.m
%   - preprocess.m
%   - create_matrix_MA.m

data_folder = dir(path);
participants = {data_folder([data_folder.isdir]).name};
participants = participants(~ismember(participants,{'.','..'}));
for i=1:size(participants,2)
    files = dir(sprintf('%s/%s', path, participants{1,i}));
    data_files = {files.name};
    data_files = data_files(~ismember(data_files,{'.','..'}));
    for j=1:size(data_files,2)
        if data_files{1,j} ~= "Status.mat"
            load(data_files{1,j})
            participant = sprintf('%s_%d', participants{1,i}, j);
            [filtered, BS] = preprocess(EEG, 10);
            if (strcmp(participant,'DS02_1') || strcmp(participant,'DS02_2') || strcmp(participant,'DS07_1') || strcmp(participant,'DS22_1') || strcmp(participant,'DS22_2'))
                BS = -BS;
               disp('inverted')
            end

            [dataset,base_indices] = seperate_FS_sets(filtered, BS, -1);
            for win=1:length(dataset)
                BS_window = dataset{1,win}(:,1);
                FS_window = dataset{1,win}(:,2);
                [MA_matrix] = create_matrix_MA(BS_window);
                h5create(save_path,sprintf('/%s/win_%g/%s_BS_%g',participant,win,participant,j),(size(MA_matrix)));
                h5write(save_path,sprintf('/%s/win_%g/%s_BS_%g',participant,win,participant,j),MA_matrix);
                h5create(save_path',sprintf('/%s/win_%g/%s_FS_%g',participant,win,participant,j),size(FS_window));
                h5write(save_path,sprintf('/%s/win_%g/%s_FS_%g',participant,win,participant,j),FS_window);
            end
        end
    end
end
