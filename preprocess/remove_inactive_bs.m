function [data1, data2, inactive] = remove_inactive_bs(data1, data2, window_of_inactivity) 
%% Removes segments where BS data may have been absent. 
% Inactive  BS data is defined as any sequence of x milliseconds or higher where the sum of the difference between the signals is 0.
%
% **Usage:** [BS, filtered] = remove_inactive_bs(BS, filtered)
%
% Input(s):
%   - data1 = Data set that contains inactive sequences. 
%   - data2 = Data set of equal length to data1, whose inactive sequences are also to be removed 
%   - window_of_inactivity = integer of size x representing the size of inactive sequences
%
% Output(s):
%   - data1 = dataset 1 without inactive sections
%   - data2 = dataset 2 without inactive sections 
%   - inactive = boolean array with the points that are inactive as 0 and
%   active as 1

inactive = [];
counter = 0;
diff_bs = diff(data1);
for i=1:size(diff_bs,2)
   if diff_bs(i) == 0 && i ~= size(diff_bs,1)
      counter = counter + 1;
   else 
      if counter >= window_of_inactivity 
         inactive = [inactive [i-counter:i]];
      end
      counter = 0;
   end
end
% remove inactive signals from raw data
data1(inactive) = [];
data2(inactive) = [];