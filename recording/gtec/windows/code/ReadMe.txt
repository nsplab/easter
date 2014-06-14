========================================================================
    CONSOLE APPLICATION : gHIampDemo Project Overview
========================================================================

AppWizard has created this gHIampDemo application for you.  

This file contains a summary of what you will find in each of the files that
make up your gHIampDemo application.


gHIampDemo.vcproj
    This is the main project file for VC++ projects generated using an Application Wizard. 
    It contains information about the version of Visual C++ that generated the file, and 
    information about the platforms, configurations, and project features selected with the
    Application Wizard.

gHIampDemo.cpp
     This application reads data from exactly one g.HIamp device and writes received data to a binary output file ("receivedData.bin" in the working directory).
	 This binary output file can be read by using MATLAB for example. The file consists of consecutive float values (4 bytes each) that are the measured values in microvolts from the devices.
	 A single scan consists of one measured value (sample) for each channel, one following the other. The file contains a number of those scans, one complete scan following the other.


/////////////////////////////////////////////////////////////////////////////
Other standard files:

StdAfx.h, StdAfx.cpp
    These files are used to build a precompiled header (PCH) file
    named gHIampDemo.pch and a precompiled types file named StdAfx.obj.

/////////////////////////////////////////////////////////////////////////////
Other notes:

AppWizard uses "TODO:" comments to indicate parts of the source code you
should add to or customize.

/////////////////////////////////////////////////////////////////////////////
