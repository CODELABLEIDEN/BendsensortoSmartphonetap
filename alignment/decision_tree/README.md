# Data alignment: Bendsensor to Forcesensor
To achieve alignment of Bendsensor(BS) and Forcesensor(FS) data, a Bidirectional Long short-term memory (BiLSTM) is trained. This documentation explains the alignment process. 

During the measurements of the data, the participants alternated between using their smartphone to collect taps, and using a 'box' which measured FS data. The BS measurements were collected throughout the whole measurement process. Thus, for each participant, the data had to be separated, because only the sections which contained BS and FS data were used during training. 

Four models were trained with different features. The first model contained moving averages of the BS data. This is refered to as the MA model. The stft model contains frequencies. The MA_stft_40 model contains frequencies and moving averages. The data for this model went through a bandpassfilter of range 0 to 40 hz. The MA_stft_10 model contains frequencies and moving averages. The data for this model went through a bandpassfilter of range 0 to 10 hz. The model results are explained under the section 'Model results'. The data preparation steps for each model are explained below. Not all steps were included in each model this is reported between parenthesis next to the step.

# Data preparation
The data preparation is performed in Matlab R2019b. 
## Bendsensor
The model input is BS data. Moving averages are used as features to the model. 

The data preparation consisted of the following steps:

**Pre-processing**
1. Raw BS data: EEG.Aligned.BS.Data(:,1). 
2. To remove movement irrelevant information from the BS data a bandpass filter is used with a range of 1 to 10 Hz. 
3. Performs outlier detection and removal 


**Moving averages** 
1. Calculate the moving average over each time window, where each mean is calculated over a sliding window of length k. For the first calculation k is 10. Shrink endpoints of moving averages 
3. Repeat step 2 and 3, i times. k grows in steps of 10. 

# Forcesensor 
The model output is FS data. 

**Pre-processing**
1. Raw FS data: EEG.Aligned.BS.Data(:,2)  
1. No movement pressure in the FS data is shown as values ranging from -0.8 to -1. As no pressure is always the same, all these values were transformed to one common value which is -1. 
2. The FS contained noise. These are seen as fast spikes smaller than 5 ms. These spikes are too fast to be real movements and were thus set as no movement (-1). 
3. Sampling rate of the FS is 1000 Hz.

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


# Prediction 
The model was imported into matlab for prediction, using the Deep Learning Toolbox. 

The data is prepared for prediction in the same way as it was prepared for training. The prediction is performed in batches. 

# Model results
### MA model:

model file: 
- model_version2_2_4A.json

weights file: 
- model_version2_2_4A_weights.h5

Training loss 0.1097 -- Val loss 0.0877 -- Test loss 0.1387

# Code
```
+-- README.md 
+-- MA
|   +-- main_lstm_MA.m --> calls all functions for prediction or data generation
|   +-- create_hdf_MA.m --> creates the h5 data file for training the MA model
|   +-- create_matrix_MA.m --> creates the moving averages matrix
|   +-- plot_predictions_MA.m --> plots model results
|   +-- predict_MA.m --> **rename** performs model predictions
|   +-- preprocess_MA.m --> preprocess FS and BS data
|   +-- seperate_FS_sets_MA.m --> seperates data into windows where there is FS data present
```

The stft files are explained further below. 

## matlab
### main_lstm_MA(EEG)
Main data alignment function. The function calls all other relevant functions to perform prediction. 

**Input(s):**
- EEG = EEG data 
- model_file_path = keras model (h5 or JSON)
- weights_file_path = keras model weights (h5)

**Output(s):**
- BS = preprocessed bendsensor data
- model_predictions =  output from lstm 

**Requires:**
- getcleanedbsdata.m
- predict_MA.m

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

### preprocess_MA(EEG)
Pre-process force sensor data and prepare bendsensor data.

**Input(s):**
- EEG = EEG data from one participant
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


### create_hdf(path)
Finds every participatant and generate for each, the data for training. Save the training data in h5 file format.

**Input(s):**
- path: path where the generated h5 file is to be saved

---

### predict_MA(BS,net)

Import keras model, prepares data for prediction, predict model outputs
**Input(s):**
- BS = filtered bendsensor data
       shape length x 1
- net = keras imported network

**Output(s):**
- model_predictions = model output 

## python
Model code is in lstm_stft.py.
