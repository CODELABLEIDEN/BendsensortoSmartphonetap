function [BS,bs_name,attysflag] = getBSdata(BSfolder)
%usage [BS,bs_name,attysflag] = getBSdata(BSfolder)
% BS folder -> insert the path of the folder up to the subject code as in 'C:\Users\Post_Box\AG06\'
% Output the BSData in struct and the corresponding starttimes 
% BS.triggers contains the voltage values corresponding to synchronization
% TTL pulses
% BS.vals contains the voltage values corresponding to the bendsensor
% recordings with each recording session in a seperate cell. Additional
% coloumns are added to this if there are more connections like forcesensor
% attysflag = true , if atays flag is found 
%
% Arko Ghosh, Leiden University, 15/06/2020


% Identify BS folders

%% make a list of directories 
dirs = regexp(genpath(BSfolder),['[^;]*'],'match');
attysflag = false;
%% filter out BS folders in the subject data 

for d = 1:length(dirs)
    s = ([dirs{1,d}]);
    Find_BS{1,1} = strfind(s, 'BS');
    Find_BS{2,1} = strfind(s, 'bs');
    Find_BS{3,1} = strfind(s, 'Bs');
    Find_BS{4,1} = strfind(s, 'Bend');
    Find_BS{5,1} = strfind(s, 'bend');  
    
    if [Find_BS{:,1}] > 5 
    Idx_BS(d) = true;  
    else
    Idx_BS(d) = false;  
    end
    
    
end

    
    
% Check if TSV files are present and if yes stop 


folders_BS = dirs(Idx_BS); 

for d = 1:length(folders_BS)
    cd(folders_BS{1,d})
CheckTSV = dir('*.tsv');
if length(CheckTSV)>0
    BS = [];
    bs_name = [];
    display('Attys files detected use getBSaudioattysdata Instead')
    attysflag = true;
    return
end
end

k = 0; 
for f = 1:length(folders_BS);
cd(folders_BS{1,f});
BSfiles = dir; 
BSfiles([BSfiles.isdir] == 1) = [];
BSfiles([BSfiles.bytes] < 200) = [];

for e = 1:length(BSfiles)
    k = k+1; 
bs_name(k).name = BSfiles(e).name; 
bs_name(k).path = folders_BS(1,f); 
a = GetFileTime(strcat(bs_name(k).path{1,1},'\',bs_name(k).name), 'UTC', 'Struct');
bs_name(k).stop = posixtime(datetime(a.Write(1),a.Write(2),a.Write(3),a.Write(4),a.Write(5),a.Write(6),'Format','dd-MM-yyyy HH:mm:ss.SSSSSS','TimeZone', 'UTC'));

end
end
clear tmp k e dt* f fid n tline dur BS_date ans

%% get BS data 

for b = 1:length(bs_name)

f_nameBS = char(strcat(bs_name(1,b).path,'/',bs_name(1,b).name));
fid = fopen(f_nameBS);
tmp = textscan(fid,'','delimiter',',','headerlines',5,'emptyvalue',nan,'collectoutput',1);
col = 0; 
for i = 1:2:size(tmp{1,1},2)
    if i == 1;
        BS{b}.triggers = [tmp{1,1}(:,i)+(tmp{1,1}(:,i+1)./1000)];
    else i > 2;
        col = col+1; 
        BS{b}.vals(:,col) = [tmp{1,1}(:,i)+(tmp{1,1}(:,i+1)./1000)]';
    end
end
% remove any unrealist values 
try
fs = getBSfs(f_nameBS);
BS{b}.BS_Date = importfile_dateBS(f_nameBS, 2, 2); % Get the date the file was created from header
BS{b}.BS_Datetime = datetime(BS{b}.BS_Date,'InputFormat','dd-MM-yyyy HH:mm', 'TimeZone', 'Europe/Amsterdam');
bs_name(b).start =bs_name(b).stop -(length(tmp{1,1})./fs); 
BS{b}.samplerate = fs; 
end

end