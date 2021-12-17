# Pre-processing files for data alignment
Files for pre-processing the data for data alignment.
Read more of the pre-processing rules in [moving_averages.md](moving_averages.md#Data-preparation). 

For the pre-processing code click [here](../src/alignment/pre-process).
# Directory structure
```
+-- pre-process
|   +-- remove_inactive_bs.m --> removes inactive BS signals
|   +-- preprocess.m --> preprocess FS and BS data
|   +-- seperate_FS_sets.m --> seperates data into windows where there is FS data present
|   +-- inverted_bs.m --> identify inverted BS data, if its inverted return the corrected flipped data
```
