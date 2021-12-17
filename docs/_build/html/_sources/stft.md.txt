# Data alignment: Bendsensor to Forcesensor
**Deprecated : None of these models were used in the final version. To see the final model code click [here](../src/alignment/moving_averages). For the final model documentation click [here](moving_averages.md).**

To achieve alignment of Bendsensor(BS) and Forcesensor(FS) data, a Bidirectional Long short-term memory (BiLSTM) is trained. This documentation explains the alignment process.

During the measurements of the data, the participants alternated between using their smartphone to collect taps, and using a 'box' which measured FS data. The BS measurements were collected throughout the whole measurement process. Thus, for each participant, the data had to be separated, because only the sections which contained BS and FS data were used during training.

Four models were trained with different features. The first model contained moving averages of the BS data (to see this model go to the moving_averages folder). This is refered to as the MA model. The stft model contains frequencies. The MA_stft_40 model contains frequencies and moving averages. The data for this model went through a bandpassfilter of range 0 to 40 hz. The MA_stft_10 model contains frequencies and moving averages. The data for this model went through a bandpassfilter of range 0 to 10 hz. The model results are explained under the section 'Model results'. The data preparation steps for each model are explained below. Not all steps were included in each model this is reported between parenthesis next to the step.

[Click here for the stft code](../src/alignment/stft)

# Data preparation
The data preparation is performed in Matlab R2019b.
## Bendsensor
The model input is BS data. The features that are used, are frequencies extracted with short time fourier transform (stft). To retain time information, moving averages are also used as features to the model.

The data preparation consisted of the following steps:

**Pre-processing**
1. Raw BS data: EEG.Aligned.BS.Data(:,1). *(all models)*
2. To remove movement irrelevant information from the BS data a bandpass filter is used with a range of 1 to 40 Hz. *(all models)*
3. Performs outlier detection and removal *(all models)*
4. Segments where BS data may have been absent are removed. This is defined as any window of 1000 milliseconds or higher where the sum of the difference between the signals is 0 *(all models except MA)*
5. To remove sign information from the data and make it more stable, the root mean square (RMS) is calculated, using a rolling window technique. This ensures no data is lost. The rolling window size for the RMS is 10. Towards the end a shrinking window size is used. *(all models except MA)*

**STFT** *(all models except MA)*

4. Zero padding is added to the data, as to not lose information during the stft.
5. Frequencies are extracted with stft. A hanning window size of 1024 and frame size of 1024 is used. Hopsize of 512 (50%). The sampling frequency is 1000 Hz.
6. Frequencies above 40 Hz are removed as these were filtered out already with the bandpass filter. Remove frequencies below 0 Hz. *(for stft_ma_10 frequencies above 10 Hz were removed)*
7. Complex numbers are transformed by taking the absolute(x)^2 where x is the STFT output.
8. STFT output is normalized across the time domain.

The output shape of the stft is now:

- number of frames by filtered frequency bins.
- number of frames by 42

**Moving averages** *(Only applicable for MA, STFT_MA_10 and STFT_MA_40)*
1. BS data is reshaped into number of frames x hopsize. This is done in order to take the same time windows used during the stft and calculate the moving averages on each of these time windows. The number of frames is calculated as:
```((Number of BS samples - frame size) / hopsize)+ 1. ```*(STFT_MA_10 and STFT_MA_40)*
2. Calculate the moving average over each time window, where each mean is calculated over a sliding window of length k. For the first calculation k is 10. Shrink endpoints of moving averages (STFT_MA_10 and STFT_MA_40, for MA the time window was the whole BS data set)
3. The moving averages are added as features. *(MA, STFT_MA_10 and STFT_MA_40)*
4. Repeat step 2 and 3, i times. k grows in steps of 10. *(For MA i is 99. For STFT_MA_10 and STFT_MA_40 i is 10, this means each frame contains 42 frequencies and 10 moving averages windows of size 512.)*

The final STFT_MA_10 and STFT_MA_40 output will have a shape of:

- frames by 42 + 512 x 10

- frames by 5162)



# Forcesensor
The model output is FS data.

**Pre-processing**
1. Raw FS data: EEG.Aligned.BS.Data(:,2)  *(all models)*
1. No movement pressure in the FS data is shown as values ranging from -0.8 to -1. As no pressure is always the same, all these values were transformed to one common value which is -1. *(all models)*
2. The FS contained noise. These are seen as fast spikes smaller than 5 ms. These spikes are too fast to be real movements and were thus set as no movement (-1). *(all models)*
3. Sampling rate of the FS is 1000 Hz. *(all models)*
4. The FS is reshaped into number of frames x hopsize. This is done in order to map the same time windows used during the stft. *(all models, except MA)*

The data is exported as a h5 file. The structure is :
/participant_fileNumber/participant_windowNumber/filename_filetype_windowNumber
As an example for participant DS01 file 1 window 2 the file looks like:
/DS01_1/DS01_1_win_2/DS01_BS_2

# Model
The model is a simple bidirectional lstm. It was trained in Keras version 2.2.4. This is necessary to be able to import the Keras model into matlab.
### MA model
```
model = keras.Sequential()

model.add(keras.layers.Bidirectional(keras.layers.LSTM(100, return_sequences=True), input_shape=(timesteps,num_features)))
model.add(keras.layers.Bidirectional(keras.layers.LSTM(64)))
model.add(keras.layers.Dense(1000))

model.summary()
model.compile(loss='mse', optimizer='adam')
```
The model was trained in batches of shape (B,T,F), where B is 10, T is 1000 and F is 100.
The loss function was mean squared error and the optimizer Adam. Models are trained for 5 epochs.

### STFT, STFT_MA_10, STFT_MA_40
```
model = keras.Sequential()

model.add(keras.layers.Bidirectional(keras.layers.LSTM(256, return_sequences=True), input_shape=(timesteps,num_features_bs)))
model.add(keras.layers.Bidirectional(keras.layers.LSTM(128, return_sequences=True)))
model.add(keras.layers.Dense(number_of_fs_features))

model.summary()
model.compile(loss='mse', optimizer='adam')
```

These models were trained in batches of shape (B,T,F), where B is 10, T is 1 and F is 5162.
The loss function was mean squared error and the optimizer Adam. Models are trained for 5 epochs.

# Prediction
The model was imported into matlab for prediction, using the Deep Learning Toolbox.

The data is prepared for prediction in the same way as it was prepared for training. The prediction is performed in batches.
The normalization is performed on a smaller window chunk.

# Model results
### MA model:

model file:
- model_version2_2_4A.json

weights file:
- model_version2_2_4A_weights.h5

Training loss 0.1097 -- Val loss 0.0877 -- Test loss 0.1387

## STFT:
Stft model 40 Hz bandpass filter

model file:
- stft.json

weights file:
- stft_weights.h5


Training loss : 0.1128 -- Val loss: 0.0931 -- Test loss

## STFT_MA_40
Stft moving averages model 10 Hz bandpass filter

model file:
- stft_MA_40.json

weights file:
- stft_MA_40_weights.h5

Training loss : 0.1112 -- Val loss 0.0881 -- Test loss

## STFT_MA_10
Stft moving averages model 10 Hz bandpass filter

model file:
- stft_MA_10.json

weights file:
- stft_MA_40_weights.h5

Training loss : 0.1104 -- Val loss : 0.0940 -- Test loss


# Directory structure
```
+-- README.md
+-- moving_averages
|   +-- features -> Scripts to generate the features for training
|   |   +-- create_hdf.m --> creates the h5 data file for training the STFT, STFT_MA models
|   |   +-- gen_freq_data.m --> generates data for prediction or training
|   +-- predict  -> Scripts to predict the results
|   |   +-- predict_stft.m --> performs model predictions for the stft models
|   |   +-- main_lstm.m --> calls all functions for prediction
|   +-- training -> Scripts to train the model(s)
|   |   +-- lstm_1024.py --> trains the model and saves weights and model structure
```

The stft files are explained further below.

## matlab
### main_lstm(participant_type, EEG)
Main data alignment function. The function calls all other relevant functions to perform prediction.

**Input(s):**
- participant_type = Binary, 0 is not a DS participant and 1 is a DS participant
- EEG = EEG data
- model_file_path = keras model (h5 or JSON)
- weights_file_path = keras model weights (h5)
- bandpass_upper_range = max frequency range used in the bandpass filter

**Output(s):**

- filtered = preprocessed force sensor data
- BS = preprocessed bendsensor data
- model_predictions =  output from lstm

**Requires:**
- getcleanedbsdata.m
- preprocess.m
- predict_stft.m

---


### getcleanedbsdata(bsvals,fs,range)
Function to preprocess BS data. Performs, outlier detection, removal and bandpass filtering

**Input(s):**
- bsvals: Raw BS data
- fs: the sampling rate as in 1000 samples per second
- range: is the frequency range in Hz

**Output:**
- Filtered BS data

---


### preprocess(EEG1)
Pre-process force sensor data and prepare bendsensor data.

**Input(s):**
- EEG1 = EEG data from one participant
- bandpass_upper_range = max frequency range used in the bandpass filter

**Output(s):**
- filtered = filtered force sensor data
- BS = filtered BS dataset
- base = value when there is no force on the sensor

**Requires:**
- getcleanedbsdata.m

---


### seperate_FS_sets(filtered, BS, base)
Extracts bendsensor values when force sensor data is present.

**Input(s):**
- filtered = filtered force sensor data
- BS = filtered BS dataset
- base = value when there is no force on the sensor

**Output(s):**
- dataset = cell array containing the seperate FS and BS windows
- base_indices = index where the FS data starts and ends

---


### gen_freq_data(EEG,BS_window, FS_window, bandpass_upper_range, ma, model_data_generation)
Generates the data for training. Performs rolling window rms, stft, moving averages calculation and normalization.

**Input(s):**
- EEG = EEG data from one participant
- BS_window = Bendsensor data
- FS_window = Forcesensor data
- bandpass_upper_range = max frequency range used in the bandpass filter
- ma = binary 1 if moving averages should be generated and 0 if not
- model_data_generation = binary 1 if used for prediction and 0 if used for model data generation

**Ouput(s):**
- reshaped_FS_window: Forcesensor data processed and reshaped into model ready format
- BS_window_freq_MA: Bensensor data with stft and moving averages features

---


### function create_hdf(path)
Finds every participatant and generate for each, the data for training. Save the training data in h5 file format.

**Input(s):**
- path: path where the generated h5 file is to be saved

---

### predict_stft(EEG,BS_window,FS_window,bandpass_upper_range,model_file_path,weights_file_path)

Import keras model, prepares data for prediction, predict model outputs
**Input(s):**
- BS_window = filtered bendsensor data
- FS_window = filtered forcesensor data
- bandpass_upper_range = max frequency range used in the bandpass filter
- model_file_path = keras model (h5 or JSON)
- weights_file_path = keras model weights (h5)
- ma = binary 1 if moving averages should be generated and 0 if not

**Output(s):**
- YPred_reshaped = model output

## python
Model code is in lstm_stft.py.
