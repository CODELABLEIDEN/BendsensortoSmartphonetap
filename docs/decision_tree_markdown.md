# Decision tree
This decision tree helps decide which alignment to use. It decides when to ignore a participant's data and when to perform a model based alignment. These decisions are based on a few heuristics that can be seen in the following image:
*insert image*

## Usage
```
decision_tree_alignment(EEG, BS, create_diagnostic_plot)
```
The function takes three arguments:
- The loaded EEG data with the model predictions. An example on how to load the file follows: The set files containing the EEG data can be loaded with the pop_loadset function from EEGLAB [1](https://github.com/sccn/eeglab/blob/develop/functions/popfunc/pop_loadset.m).
```
    path_to_EEG_data = '/media/Storage/Common_Data_Storage/EEG/Feb_2018_2020_RUSHMA_PreprocessedEEG/';
    participant_file = 'DS31/08_13_01_04_19.set';
    EEG = pop_loadset(strcat(path_to_EEG_data,participant_file));
```
- The preprocessed BS data. This preprocessing is done with the function getcleanedbsdata *link*, which performs outlier detection and removal. This is followed by bandpass filtering. The upper range of the bandpass filter should be chosen.
```
    bandpass_upper_range = 10;
    BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1), EEG.srate, [1 bandpass_upper_range]);
```
- Boolean, 1 displays the aligned data and 0 does not create the plot.

## Output
It returns two arguments:
- EEG struct with a new cell: EEG.Aligned.Phone.Model contains the aligned phone data. If the participant's file is ignored it is empty.
- Simple, if simple is 1 then the model based alignment was performed, if simple is 3 then the participant file was ignored
