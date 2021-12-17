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

