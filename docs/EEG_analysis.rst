EEG analysis
============

Includes analysis of event related potentials (ERP) and event-related spectral perturbations (ERSP)

ERP analysis
------------

Pre-processing steps:

1. Read EEG struct and include participants that meet the following criteria:

 - Has EEG data
 - Has been aligned and also selected based on the participant selection
 - Has predictions from the BS to tap model
 - If the participant is a curfew participant include only the first measurement file
 - Attys is false

2. Clean EEG data by running gettechnicallcleanEEG

 - Remove blinks according to ICA
 - Interpolate missing channels
 - Re-reference data to the average channel
 - Highpass filter up to 45 Hz
 - Lowpass filter from 0.5 Hz

3. Run pred_events for attributable and non attributable movements separately (See :doc:`Attributable and Non Attributable Movements identification <ams_nams>` for more info)

 - Identify attributable and non attributable movements
 - Epoch data [-2000 2000]
 - Calculate parameters for each trials

4. Merge EEG structs

5. Remove baseline [-2000 -1500]

6. Threshold trials in range -80 to 80 mV

7. Check if there are sufficient trails left (number of trials > 50)

8. Save:

 - Participant folder name
 - Trimmedmean ERP removing edge 20% for attributable movements
 - Mean ERP for attributable movements
 - Number of trials of attributable movements
 - Trimmedmean ERP removing edge 20% for non attributable movements
 - Mean ERP for non attributable movements
 - Number of trials of non attributable movements

ERSP analysis
-------------
Repeat step 1 to 7 of ERP analysis, skipping step 5.

8. Time frequency analysis for all channels with wavelet transform (baseline = [-2000 -1500], cycles = 1 0.3)

9. Save the:

 - Participant folder  name
 - Power attributable movements
 - Power non attributable movements
 - Number of trials of attributable movements
 - Number of trials of non attributable movements
 - Timesout - array of times used
 - Frequencies - array of frequencies used
 - Channel number


Directory structure
-------------------
**TODO** update


::

   +-- EEG_analysis
   |   +-- channeighbstructmat.mat -->
   |   +-- expected_chanlocs.mat -->
   |   +-- ERP --> Scripts to perform ERP analysis
   |   +-- preprocess_EEG --> Scripts to pre-process the EEG data
   |   |   +-- getdataorganised.m --> Saves the data as eeglab struct
   |   |   +-- gettechnicallycleanEEG.m --> performs the preprocessing of the EEG data

Code
----

Pre-Processing
^^^^^^^^^^^^^^

.. mat:automodule:: EEG_analysis.preprocess_EEG
   :members:


ERP analysis
^^^^^^^^^^^^

.. mat:automodule:: EEG_analysis.ERP
   :members:

ERSP analysis
^^^^^^^^^^^^^

.. mat:automodule:: EEG_analysis.time_freq_analysis
   :members:

Result plotting
^^^^^^^^^^^^^^^

.. mat:automodule:: EEG_analysis.result_plotting
   :members:
