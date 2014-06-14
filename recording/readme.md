How to install this code:

How to run this code:

This code runs from the command line. You will first open the windows virtual environment and launch the g.tech driver there. Second, you will run our Linux C code that implements the gtech signal acquisition module. Third, you will launch the python code in each directory. This final step starts the process of recording ~1.5 minutes worth of data to file. About 10 seconds into this recording, you should launch either the Arduino code (VEP, SSVEP) or the Arduino code followed by the Audacity sound file (SSAEP, BAEP). For the auditory testing, the Arduino detects output from the headphones and triggers digital inputs to the g.hiamp accordingly.

More detailed installation and usage instructions will be added to the github wiki.


Directories:

- baep: code for recording eeg and generating Brainstem Auditory Evoked Potential time-marked stimuli

- ssaep: code for recording eeg and generating Steady State Auditory Evoked Potential time-marked stimuli

- ssvep: code for recording eeg and generating Steady State Visual Evoked Potential time-marked stimuli

- vep: code for recording eeg and generating Visual Evoked Potential time-marked stimuli
