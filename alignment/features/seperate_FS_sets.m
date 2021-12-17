function [dataset,base_indices] = seperate_FS_sets(filtered, BS, base)
%% Extracts bendsensor values when force sensor data is present
%
% **Usage:** [dataset,base_indices] = seperate_FS_sets(filtered, BS, base)
%
% Input(s):
%   - filtered = preprocessed force sensor data
%   - BS = preprocessed BS dataset
%   - base = value when there is no force on the sensor
%
% Output(s):
%   - dataset = cell array containing the seperate FS and BS windows
%   - base_indices = indexes where the FS data starts and ends
%
% Author: R.M.D. Kock

%% find start and end indices FS data
key_inds = find(filtered==base);
start_index = key_inds(1);
end_index = key_inds(end);
start_indices = [start_index; key_inds(find(diff(key_inds)>1)+1)];
end_indices = [key_inds(find(diff(key_inds)>1)); end_index];

% get the start and end index of the sequences that are more than size
intersec = (end_indices - start_indices > 300000);
ends = end_indices(intersec);
starts = start_indices(intersec);
base_indices = [];
for i=1:length(ends)
    base_indices = [base_indices ; starts(i); ends(i)];
end

% sometimes there is FS data at the beginning of the recording
% If this is the case then there are not enough consecutive -1 values
% check if there are enough signals at the start, if yes add it to base
% indices
if sum(filtered(start_indices(1):end_indices(10)) > 0.5) > 100 && base_indices(1) ~= start_indices(1)
    base_indices = [start_indices(1); end_indices(1); base_indices];
end
%% select values based on base indices
index = 0;
for FS_set_num=1:length(base_indices)/2
    index = index + 2;
    if index ~= length(base_indices)
         FS_window = filtered(base_indices(index):base_indices(index+1));
         BS_window = BS(base_indices(index):base_indices(index+1));
         dataset{FS_set_num} = [BS_window FS_window];
    else
        FS_window = filtered(base_indices(index):end);
        BS_window = BS(base_indices(index):end);
        % check if there really are values until end of filtered
        if sum(FS_window > 0.5) > 100
            dataset{FS_set_num} = [BS_window FS_window];
        end
    end
end
