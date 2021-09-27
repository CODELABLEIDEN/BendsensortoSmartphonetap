function [results] = call_func_for_all_participants(f, path)
% loop over all the participant folders
data_folder = dir(path);
participants = {data_folder([data_folder.isdir]).name};
participants = participants(~ismember(participants,{'.','..'}));

for i=1:size(participants,2)
    files = dir(sprintf('%s/%s', path, participants{1,i}));
    data_files = {files.name};
    data_files = data_files(~ismember(data_files,{'.','..'}));
    % loop over all the files inside the folders
    for j=1:size(data_files,2)
        % only load the set files
        if contains(data_files{1,j}, 'set')
            EEG = pop_loadset(data_files{1,j});
            % participant number
            participant = sprintf('%s_%d', participants{1,i}, j)
            f(EEG, participant)
        end
    end
end 
