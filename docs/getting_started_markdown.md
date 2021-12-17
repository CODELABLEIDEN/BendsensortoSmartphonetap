# Startup guide
# Installation
This project uses python for model training and matlab for the rest of the analysis.
If you want to use the pre-trained models skip all python related installations.

## Matlab startup
Install matlab [R2019b](https://nl.mathworks.com/products/new_products/release2019b.html)
Install the following toolboxes:
### Matlab external toolboxes
[EEGLAB 2020](https://sccn.ucsd.edu/eeglab/ressources.php)
[icablinkmetrics](https://github.com/mattpontifex/icablinkmetrics)
[LIMO EEG](https://github.com/LIMO-EEG-Toolbox/limo_tools)

**Additional Matlab toolboxes:**  
- [Deep Learning Toolbox](https://nl.mathworks.com/products/deep^learning.html)
- [Statistics Toolbox](https://nl.mathworks.com/products/statistics.html)
- [Curve Fitting Toolbox](https://nl.mathworks.com/products/curvefitting.html)
- [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html)

## Python startup
The project uses [python3.6](https://www.python.org/downloads/release/python-360/).
### Startup via linux
Install anaconda or miniconda
```
chmod u+x ~/Non_attribute_movements_and_EEG/get_started.sh
./get_started.sh
```
### Startup via Windows
Install anaconda or miniconda and run the following commands to download the necessary requirements
```
conda create -n non_attribute_movement_and_EEG python=3.6
conda activate non_attribute_movement_and_EEG
conda install pandas
conda install -c anaconda keras-gpu
conda install matplotlib
conda install -c conda-forge scikit-learn
```

### Alternative Startup
```
pip install -r requirements.txt
```
Although this may end up with dependency errors to be fixed.

# Alignment Overview
This is a quick overview of the alignment model. For the actual details on the model see: [moving_averages_documentation]()**TODO**
## Model training
The data preparation for training is done in Matlab. The alignment model is trained in python.
1. Prepare the raw data for training and save as h5 file.
	An existing h5 file can be downloaded at. **TODO**
2. Activate the conda environment 'non_attribute_movement_and_EEG' (See installation for more details).
```
conda activate non_attribute_movement_and_EEG
```
3. Run the lstm_MA.py script
```
python ~/Non_attribute_movement_and_EEG/src/alignment/training/lstm_MA.py
```
4. You will be prompted to input the path to the h5 file prepared in step 1. Type the path and press enter.
5. The trained model is saved in **'~/Non_attribute_movement_and_EEG/models'.** Three files are generated:
	- Checkpoint file named: **MA_{day_month_year_hour_minute_second}.hd5**
	- JSON file with saved model architrecture: **MA_{day_month_year_hour_minute_second}.json**
	- Trained model weights: **MA_weights_{day_month_year_hour_minute_second}.h5**
## Using pre-trained alignment model
The pretrained model weight files can be downloaded at: **TODO**
The model can be imported into matlab or python for prediction. In this project it has been implemented via matlab. However, the weights file can be imported via python and the prediction performed there since it is a keras model.
### Predicting via Matlab
**TODO**

## Accessing model predictions
The prediction has already been performed for all the participants and saved in the EEG struct in the following location:
- EEG.Aligned.BS.model

## Using the aligned BS data
The actual alignment is performed through the decision tree function.
See more details at:

# Bendsensor to tap model overview
First step is to activate the environment.
Activate the conda environment 'non_attribute_movement_and_EEG' (See installation for more details).
```
conda activate non_attribute_movement_and_EEG
```
## Model training
The data preparation for training is done in Matlab. The bendsensor to tap model is trained in python.
1. Prepare the raw data for training and save as h5 file.
	An existing h5 file can be downloaded at. **TODO**
3. Run the lstm_MA.py script
```
python ~/Non_attribute_movement_and_EEG/src/bs_to_tap/training/bs_to_tap.py
```
4. You will be prompted to input the path to the h5 file prepared in step 1. Type the path and press enter.
5. The trained models are saved in _'~/Non\_attribute\_movement\_and\_EEG/models/bs\_to\_tap'._. A folder is generated for every participant. The folder contains many different files:
Most importantly:
	- The trained model weights for the delta model : _{participant name}\_deltas.h5_
	- JSON file with saved architrecture for delta model : _{participant name}\_deltas.h5_
	- The trained model weights for the integral model : _{participant name}\_integrals.h5_
	- JSON file with saved architrecture for integral model : _{participant name}\_integrals.h5_

	Additional model results:
	- Checkpoint files for both delta and integral models
	- Delta and integral model history: {participant name}\_{deltas or integrals}\_history.csv_
	- PNG Image with 3 subplots: _{participant name}\_{deltas or integrals}\_loss\_&\_positives.png_
		i. model loss and validation loss
		ii. model true and false positive
		iii. validation true and false positives.
	- PNG Image with 4 subplots: _{participant name}\_{deltas or integrals}\_negatives.png_
		i. model true negatives
		ii. model false negatives
		iii. validation true negatives
		iiii. validation false negatives

	For each test file 3 images:
	- Precision recall curve: {participant name}\_{deltas or integrals}\_{test number}\_pr_test.png
	- ROC curve: {participant name}\_{deltas or integrals}\_{test number}\_roc_test.png
	- Model predictions and true taps {participant name}\_{deltas or integrals}\_{test number}\_test_predictions.png

## Model prediction
To use the trained model weights, generate predictions with your data.
1. Prepare the raw data for training and save as h5 file.
	An existing h5 file can be downloaded at. **TODO**.
	Note this file is the same file as generated at step 1 from model training. However, if you want to predict on another data set the data has to be prepared in the same way as it was for training.
2. Run the python script to generate an h5 file with the predictions saved
```
python ~/Non_attribute_movement_and_EEG/src/bs_to_tap/training/bs_to_tap.py
```
This file contains the following items for each participant and for each feature
- Model predictions: {participant name}\ {deltas or integrals}\yhat\_reshaped
- Thresholds: {participant name}\ {deltas or integrals}\thresholds
- F2 scores: {participant name}\ {deltas or integrals}\f2\_scores
- Highest F2 score: {participant name}\ {deltas or integrals}\best\_f2\_scores
- Optimal threshold for the highest F2 score: {participant name}\ {deltas or integrals}\optimal\_threshold
- Bendsensor data: {participant name}\ {deltas or integrals}\bs\_array\_std
- Phone taps: {participant name}\ {deltas or integrals}\fs\_array\_std

**TODO** Insert example image

3. (Optional) Save model predictions inside EEG struct
```matlab
% matlab
% Path to raw data
raw_data_path = '/media/Storage/Common_Data_Storage/EEG/Feb_2018_2020_RUSHMA_ProcessedEEG';
% Path to location to save the EEG structs
save_path_upper = '/media/Storage/User_Specific_Data_Storage/ruchella/Oct_2021_BS_to_tap_classification_EEG';
% Path to generated h5 file from step 2
path_saved_predictions = '~/non_attribute_movement_and_EEG/data/bs_to_tap/predicted_file.h5';

paths{1,1} = raw_data_path; paths{1,2} = save_path_upper; paths{1,3} = path_saved_predictions;
f = @save_predictions;
[EEG] = call_func_for_all_participants(raw_data_path,paths,f,'load_eeg', 0);
```
## Bendsensor to tap results analysis (Generating Figure 1)
1. Prepare the necessary data sets:
```matlab
%% Gather all saved bs_to_tap predictions in a cell
% path to data with bs_to_tap model predictions
path = '/media/Storage/User_Specific_Data_Storage/ruchella/July_2021_BS_to_tap_classification_EEG';
% path to save the cell
save_path = '/home/ruchella/non_attribute_movement_and_EEG/data/bs_to_tap_predictions.mat';
[bs_to_tap_predictions] = generate_bs_to_tap_model_preds(path,1, save_path);

%% Gather all ams and nams in a cell
% path to data with bs_to_tap model predictions
path = '/media/Storage/User_Specific_Data_Storage/ruchella/July_2021_BS_to_tap_classification_EEG';
% path to save the cell
save_path = '/home/ruchella/non_attribute_movement_and_EEG/data/all_epochs.mat';
f = @generate_all_epochs;
[all_data] = call_func_for_all_participants_eeg(path,save_path,f);
```

2. (Optional) Alternatively the data can be downloaded at: **TODO**. If downloaded, load the files.
```matlab
load('~/Non_attribute_movement_and_EEG/data/bs_to_tap_predictions.mat')
load('~/Non_attribute_movement_and_EEG/data/all_epochs.mat')
```
3. Find the AMs and NAMs
```matlab
[s_i,s_d,taps] = get_ams_nam(bs_to_tap_predictions);
```
5. Create the figures
```matlab
% Figure 1 - B
plot_bs_shape_tl_ams_nams(bs_to_tap_predictions, 0, 's_i', s_i, 's_d',s_d, 'taps', taps)

% Figure 1 - C
figure_name = 'BS_freq_ams_nams';
plot_freq_ams_nams(bs_to_tap_predictions, 0, 's_i', s_i, 's_d',s_d, 'taps', taps,'plot_integrals', 0)

% Figure 1 - D
plot_density_am_nams(all_epochs, 0)
% Figure 1 - E
plot_inter_event_intervals(all_epochs, 0)

% Supplementary Figure 1
figure_name = 'BS_pred_ams_nams';
plot_pred_tl_ams_nams(bs_to_tap_predictions, 0, 's_i', s_i, 's_d',s_d, 'taps', taps)
```
# EEG analysis
