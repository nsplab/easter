Introduction
============

This directory contains code to generate the figures for [TODO: paper name/citation].
The code generates plots showing the Visual Evoked Potential (VEP) response,
the Steady-State Visual Evoked Potential (SSVEP) response, and the Steady-State
Auditory Evoked Potential (SSAEP). for endovascular/scalp electrode in the two rabbits in the manuscript

Visual Evoked Potential (VEP)
-----------------------------

The VEP response plots align the data from the electrodes based on the stimulus
and display the mean.

Steady-State Evoked Potential (SSVEP and SSAEP)
-----------------------------------------------
The SSVEP and SSAEP responses are shown by computing the power spectral density
and taking the ratio of the power in each band in during the experimental
period and the resting state period.


Generating Figures
==================

Step:
1. Download data
check for "rabbit" and "animal" (change to subject)
send data and code to mosalam, have him test run and edit tutorial if necessary

Obtaining Data
--------------

The data is available at [TODO: link], and should be placed in the data
directory (the data should already be available if this was downloaded from
[TODO: link].

Running Code
------------

To generate the figures, run the command

>> generate_all()

in MATLAB, in this directory.

The figures will be placed in the figures directory. Next, to convert some SVG
files into PDFs, and to crop the PDF files, run

$ ./convert_to_pdf.sh

in the layout directory from a terminal. Finally, compile layout/figures.tex to
generate the paper format figures.


Directory Structure
===================

cardiac
-------
This directory contains code for removing cardiac artifacts and generating
figures demonstrating the removal of cardiac artifacts.

  cardiac_removal.m: removes cardiac artifacts from a channel
  cardiac_figure.m: generates the figures demonstrating removal of cardiac
                    artifacts

config
------
This directory contains functions to get information about the recordings,
file locations, and formatting the plots.

  plot_settings.m: selects channels to plot and the colors to use
  subject_information.m: information about the electrode positions during
                         experiments
  get_pathname.m: returns paths to the data files and experiment log

data
----
This directory contains the data used to generate the plots.

figures
-------
Generated figures are placed into this directory.

layout
------
This directory contains files needed to layout the figures in the paper format.

  figures.tex: LaTeX document with the same structure as the paper
  convert_to_pdf.sh: script for converting SVG files to PDF files, and crops
                     the PDF files (Note: this depends on inkscape and pdfcrop)

ssavep
------
This directory contains the code that analyzes SSAEP and SSVEP experiments.

  plot_ssavep.m: generates the figure for one experiment, after loading the data
  plot_all_ssavep.m: generates all figures for one subject

util
----
This directory contains miscellaneous functions to do small tasks.

  get_frequency.m: returns the frequency used for a SSAEP/SSVEP experiment
                   based on the experiment log
  get_filters.m: return a list of desired filters for cleaning up data
  reduce_all_data.m: recursively shrinks the data by removing unnecessary
                     channels
  save2pdf.m: external library to save figures as PDFs with correct window
  load_data.m: load binary data files
  plot2svg.m: exernal library to save figures as SVG files
  make_legend.m: generates a figure with the legend
  assert_match.m: verifies that the data files and experiment log match
  run_filters.m: cleans a channel with the requested filters
  reduce_data.m: shrinks a data file by removing unneeded channels
  get_information.m: returns list of files and comments from experiment log

vep
---
This directory contains the code that analyzes VEP experiments.

  plot_vep.m: generates the figure for one experiment, after loading the data
  plot_all_vep.m: generates all figures for one subject


Data Format
===========
The binary data files are stored in the directory data.

Naming
------
The filenames of the experiment logs are of the form

  data/SUBJECT_ID/neuro_experiment_log.txt

The filenames of the data files are of the form

  data/SUBJECT_ID/EXPERIMENT/DAY_DD_MM_YYYY_HH_MM_SS

SUBJECT_ID can be 'subject1' or 'subject2'.
EXPERIMENT can be 'vep', 'ssvep', or 'ssaep'.
DAY_DD_MM_YYYY is either 'Thu_15_05_2014' (subject1) or
                         'Tue_06_05_2014_11_17_10' (subject2).
HH_MM_SS is the hours, minutes, and seconds of the time when the experiment
began (HH is in 24-hour format).

Contents
--------

The experiment log contains a single line for each experiment. Each line has
the format

  HH:MM:SS - EXPERIMENT - ADDITIONAL INFORMATION

The data files are binary files which consist of a sequence of single (MATLAB)
or float (C++) values. The number of channels (N) in each data file is specified
in config/subject_information.m, and each block of N values represents the
samples from each channel at the timestep.

The data files can be read with util/load_data.m.


Tutorial
========

A tutorial is available at https://www.writelatex.com/read/cxgjsstnwrxy.
[TODO: Will the tutorial just be copied to this directory?]
