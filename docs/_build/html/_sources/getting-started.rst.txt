Startup guide
=============
Installation
------------

This project uses python for model training and Matlab for the rest of
the analysis. If you want to use the pre-trained models skip all python
related installations.

.. note:: The paths used in this project are all relative to the position in which this repository is cloned. It assumes you are inside the cloned repository. Change the paths when necessary.

.. note:: Throughout this documentation you will see the word tap or smartphone interaction (SI) used interchangeably they refer to the same things. Furthermore the abbreviation of bendsensor (BS) and forcesensor (FS) are also used.

Matlab startup
^^^^^^^^^^^^^^

Install Matlab `R2019b <https://nl.mathworks.com/products/new_products/release2019b.html>`__

Install the following toolboxes:

**Matlab external toolboxes**

- `EEGLAB 2020 <https://sccn.ucsd.edu/eeglab/ressources.php>`__
- `icablinkmetrics <https://github.com/mattpontifex/icablinkmetrics>`__
- `LIMO EEG <https://github.com/LIMO-EEG-Toolbox/limo_tools>`__

**Additional Matlab toolboxes**

- `Deep Learning Toolbox <https://nl.mathworks.com/products/deep-learning.html>`__
- `Statistics Toolbox <https://nl.mathworks.com/products/statistics.html>`__
- `Curve Fitting Toolbox <https://nl.mathworks.com/products/curvefitting.html>`__
- `Signal Processing Toolbox <https://www.mathworks.com/products/signal.html>`__

Python startup
^^^^^^^^^^^^^^

The project uses
`python3.6 <https://www.python.org/downloads/release/python-360/>`__.

Make sure you have `Anaconda or Miniconda installed <https://www.anaconda.com/products/individual>`__
A basic understanding of Anaconda is assumed.

Startup via Linux
~~~~~~~~~~~~~~~~~
Run this bash script to create an environment and install the required packages.

::

    chmod u+x get_started.sh
    ./get_started.sh

After running the script make sure you activate the environment see :ref:`activate_environment`.

Startup via Windows
~~~~~~~~~~~~~~~~~~~

Run the following commands to download the necessary requirements

::

    conda create -n non_attribute_movement_and_EEG python=3.6
    conda activate non_attribute_movement_and_EEG
    conda install pandas
    conda install -c anaconda keras-gpu
    conda install matplotlib
    conda install -c conda-forge scikit-learn

Alternative Startup
~~~~~~~~~~~~~~~~~~~
Create and activate an environment and run:

::

    pip install -r requirements.txt

Although this may end up with dependency errors to be fixed.

.. _activate_environment:

Activate environment
~~~~~~~~~~~~~~~~~~~~
Finally, after the required packages are installed make sure the (conda) environment is activated if you have created one.
If you follow the steps below this can be done with:

::

    conda activate non_attribute_movement_and_EEG

Alignment Overview
------------------

This is a quick overview of the alignment model. For the details
on the alignment problem see: :doc:`Data alignment: Moving Averages (MA) <moving_averages>`

Model training
^^^^^^^^^^^^^^

The data preparation for training is done in Matlab. The alignment model is trained in python.

1. Prepare the raw data for training and save as h5 file.

  An existing h5 file can be downloaded at: **TODO**

2. Run the lstm\_MA.py script

   ::

       python src/alignment/training/lstm_MA.py

3. You will be prompted to input the path to the h5 file prepared in step 1. Type the path and press enter.
4. The trained model is saved in the
   *'models/alignment'* folder. Three files are generated:

   -  Checkpoint file named:
      *MA\_{day\_month\_year\_hour\_minute\_second}.hd5*
   -  JSON file with saved model architrecture:
      *MA\_{day\_month\_year\_hour\_minute\_second}.json*
   -  Trained model weights:
      *MA\_weights\_{day\_month\_year\_hour\_minute\_second}.h5*


Using pre-trained alignment model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The pre-trained model weight files can be downloaded at: **TODO**

The model can be imported into matlab or python for prediction. In this project, it has been implemented via Matlab. However, the weights file can be imported via python and the prediction performed there since it is a Keras model.

Predicting via Matlab
~~~~~~~~~~~~~~~~~~~~~

**TODO**

Accessing model predictions
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The prediction has already been performed for all the participants and saved in the EEG struct in the following location:

- EEG.Aligned.BS.model

Using the aligned BS data
^^^^^^^^^^^^^^^^^^^^^^^^^

The actual alignment is performed through the decision tree function.
See more details at: :doc:`Decision tree <decision_tree>`

Bendsensor(BS) to tap model overview
------------------------------------
The bendsensor(BS) to tap model is used to identify the (non) attributable movements. This is a quick overview of the model. For more details see :doc:`Bendsensor to Tap <bs_to_tap>`

Model training
^^^^^^^^^^^^^^

The data preparation for training is done in Matlab. The BS to tap model is trained in python.

.. _step_1_bs_to_tap:

1. Prepare the raw data for training and save it as an h5 file.
   An existing h5 file can be downloaded at. **TODO**
2. Run the lstm\_MA.py script

  ::

      python src/bs_to_tap/training/bs_to_tap.py

3. You will be prompted to input the path to the h5 file prepared in step 1. Type the path and press enter.
4. The trained models are saved in
   *'models/bs\_to\_tap'*. A folder is generated for every participant. The folder contains many different files.

   Most importantly:

   -  The trained model weights for the delta model : *{participant
      name}\_deltas.h5*
   -  JSON file with saved architrecture for delta model : *{participant
      name}\_deltas.json*
   -  The trained model weights for the integral model : *{participant
      name}\_integrals.h5*
   -  JSON file with saved architrecture for integral model :
      *{participant name}\_integrals.json*

   Additional model results:

   -  Checkpoint files for both delta and integral models
   -  Delta and integral model history: *{participant name}\_{deltas or
      integrals}\_history.csv*
   -  PNG Image with 3 subplots: *{participant name}\_{deltas or
      integrals}\_loss\_&\_positives.png*

      i.   model loss and validation loss
      ii.  model true and false positive
      iii. validation true and false positives.

   -  PNG Image with 4 subplots: *{participant name}\_{deltas or
      integrals}\_negatives.png*

      i.   model true negatives
      ii.  model false negatives
      iii. validation true negatives
      iv.  validation false negatives

   For each test file 3 images:

   -  Precision recall curve: *{participant name}\_{deltas or
      integrals}\_{test number}\_pr\_test.png*
   -  ROC curve: *{participant name}\_{deltas or integrals}\_{test
      number}\_roc\_test.png*
   -  Model predictions and true taps *{participant name}\_{deltas or
      integrals}\_{test number}\_test\_predictions.png*

Model prediction
^^^^^^^^^^^^^^^^

To use the trained model weights, generate predictions with your data.

1. Prepare the raw data for training and save as h5 file.
   An existing h5 file can be downloaded at. **TODO**.
   Note this file is the same file as generated at step 1 from model training (see :ref:`step_1_bs_to_tap`). However, if you want to predict on another data set the data has to be prepared in the same way as it was for training.
2. Run the python script to generate an h5 file with the predictions saved.

  ::

      python src/bs_to_tap/training/bs_to_tap.py


 This file contains the following items for each participant and for each feature

  - Model predictions: *{participant name}\\{window number}\\{deltas or integrals}\\predictions*
  - Thresholds: *{participant name}\\{window number}\\{deltas or integrals}\\thresholds*
  - F2 scores: *{participant name}\\{window number}\\{deltas or integrals}\\f2\_scores*
  - Highest F2 score: *{participant name}\\{window number}\\{deltas or integrals}\\best_f2\_scores*
  - Optimal threshold for the highest F2 score: *{participant name}\\{window number}\\{deltas or integrals}\\optimal\_threshold*
  - Bendsensor data: *{participant name}\\{window number}\\{deltas or integrals}\\BS*
  - Phone taps: *{participant name}\\{window number}\\{deltas or integrals}\\FS*

3. (Optional) Save model predictions inside `EEGlab struct <https://eeglab.org/tutorials/ConceptsGuide/Data_Structures.html>`__

  .. code:: matlab

         % Matlab
         % Path to raw data
         raw_data_path = <Insert path>;
         % Path to location to save the EEG structs
         save_path_upper = <Insert path>;
         % Path to generated h5 file from step 2
         path_saved_predictions = <Insert path>;

         paths{1,1} = raw_data_path; paths{1,2} = save_path_upper; paths{1,3} = path_saved_predictions;
         f = @save_predictions;
         [EEG] = call_func_for_all_participants(raw_data_path,paths,f,'load_eeg', 0);

Attributable and Non attributable movements analysis (Figure 1)
---------------------------------------------------------------
This section gives a quick overview on how Figure 1 of the paper is created.

For more details see :doc:`Attributable and Non attributable movements identification <ams_nams>`

1. Prepare the necessary data sets:

  .. code:: matlab

          % matlab
          %% Gather all saved bs_to_tap predictions in a cell
          % path to data with bs_to_tap model predictions
          path = <Insert path>;
          % path to save the generated results
          save_path = <Insert path>;
          [bs_to_tap_predictions] = generate_bs_to_tap_model_preds(path,1,save_path);

          %% Gather all ams and nams in a cell
          % path to data with bs_to_tap model predictions
          path = <Insert path>;
          % path to save the cell
          save_path = <Insert path>;
          f = @generate_all_epochs;
          [all_epochs] = call_func_for_all_participants_eeg(path,save_path,f);

2. (Optional) Alternatively the data can be downloaded at: **TODO**.
   If downloaded, load the files.

   .. code:: matlab

       load('data/bs_to_tap_predictions.mat')
       load('data/all_epochs.mat')

3. Find the AMs and NAMs

   .. code:: matlab

       [s_i,s_d,taps] = get_ams_nam(bs_to_tap_predictions);

4. Create the figures

  .. code:: matlab

       % Figure 1 - B
       plot_bs_shape_tl_ams_nams(bs_to_tap_predictions, 0, 's_i',s_i, 's_d',s_d, 'taps', taps)

       % Figure 1 - C figure_name = 'BS_freq_ams_nams';
       plot_freq_ams_nams(bs_to_tap_predictions, 0, 's_i', s_i,'s_d',s_d, 'taps', taps,'plot_deltas', 0)

       % Figure 1 - D
       plot_density_am_nams(all_epochs, 0)

       % Figure 1 - E
       plot_inter_event_intervals(all_epochs, 0)

       % Supplementary Figure 1
       plot_pred_tl_ams_nams(bs_to_tap_predictions, 0, 's_i', s_i,'s_d',s_d, 'taps', taps)

EEG analysis (Figure 2)
-----------------------
