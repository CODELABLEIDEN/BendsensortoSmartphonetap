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


