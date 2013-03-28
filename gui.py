#!/usr/bin/python
from Tkinter import *
import os

master = Tk()

def left_eye():
	print "left eye"
	os.system('python ./vep/left_eye_vep.py')
def right_eye():
	print "right eye"
	os.system('python ./vep/right_eye_vep.py')
def baseline_5m():
	print "right eye"
	os.system('python ./baseline_5m.py')
def left_ear_pip_brainstem():
	print "left ear pip brainstem"
	os.system('python ./aep/left_ear_pip_train_brainstem.py')
def left_ear_click_brainstem():
	print "left ear click brainstem"
	os.system('python ./aep/left_ear_click_train_brainstem.py')
def left_ear_click_slow():
	print "left ear click slow"
	os.system('python ./aep/left_ear_click_train_slow.py')
def right_ear_pip_brainstem():
	print "right ear pip brainstem"
	os.system('python ./aep/right_ear_pip_train_brainstem.py')
def right_ear_click_brainstem():
	print "right ear click brainstem"
	os.system('python ./aep/right_ear_click_train_brainstem.py')
def right_ear_click_slow():
	print "right ear click slow"
	os.system('python ./aep/right_ear_click_train_slow.py')
def speaker_ear_pip_brainstem():
	print "speaker pip brainstem"
	os.system('python ./aep/speaker_ear_pip_train_brainstem.py')
def speaker_ear_click_brainstem():
	print "speaker click brainstem"
	os.system('python ./aep/speaker_ear_click_train_brainstem.py')
def speaker_ear_click_slow():
	print "speaker click slow"
	os.system('python ./aep/speaker_ear_click_train_slow.py')
def speaker_ear_ssaep_20hz():
	print "speaker SSAEP 20hz"
	os.system('python ./aep/speaker_ear_click_train_20hz.py')
def speaker_ear_ssaep_30hz():
	print "speaker SSAEP 30hz"
	os.system('python ./aep/speaker_ear_click_train_30hz.py')
def speaker_ear_ssaep_40hz():
	print "speaker SSAEP 40hz"
	os.system('python ./aep/speaker_ear_click_train_40hz.py')
def speaker_ear_ssaep_50hz():
	print "speaker SSAEP 50hz"
	os.system('python ./aep/speaker_ear_click_train_50hz.py')
def speaker_ear_ssaep_60hz():
	print "speaker SSAEP 60hz"
	os.system('python ./aep/speaker_ear_click_train_60hz.py')

f = Frame(master, height=600, width=320)
f.pack_propagate(0)
f.pack()
b1 = Button(f, text="Baseline 5 min", command=baseline_5m)
b1.pack(fill=X, expand=1)
b2 = Button(f, text="Left Eye", command=left_eye)
b2.pack(fill=X, expand=1)
b3 = Button(f, text="Right Eye", command=right_eye)
b3.pack(fill=X, expand=1)
b4 = Button(f, text="Left Ear Pip train Brainstem", command=left_ear_pip_brainstem)
b4.pack(fill=X, expand=1)
b5 = Button(f, text="Left Ear Click train Brainstem", command=left_ear_click_brainstem)
b5.pack(fill=X, expand=1)
b6 = Button(f, text="Left Ear Click train SlowAEP", command=left_ear_click_slow)
b6.pack(fill=X, expand=1)
b7 = Button(f, text="Right Ear Pip train Brainstem", command=right_ear_pip_brainstem)
b7.pack(fill=X, expand=1)
b8 = Button(f, text="Right Ear Click train Brainstem", command=right_ear_click_brainstem)
b8.pack(fill=X, expand=1)
b9 = Button(f, text="Right Ear Click train SlowAEP", command=right_ear_click_slow)
b9.pack(fill=X, expand=1)
b10 = Button(f, text="Speaker Pip train Brainstem", command=right_ear_pip_brainstem)
b10.pack(fill=X, expand=1)
b11 = Button(f, text="Speaker Click train Brainstem", command=right_ear_click_brainstem)
b11.pack(fill=X, expand=1)
b12 = Button(f, text="Speaker Click train SlowAEP", command=right_ear_click_slow)
b12.pack(fill=X, expand=1)
b13 = Button(f, text="Speaker SS AEP 20 Hz", command=speaker_ear_ssaep_20hz)
b13.pack(fill=X, expand=1)
b14 = Button(f, text="Speaker SS AEP 30 Hz", command=speaker_ear_ssaep_30hz)
b14.pack(fill=X, expand=1)
b15 = Button(f, text="Speaker SS AEP 40 Hz", command=speaker_ear_ssaep_40hz)
b15.pack(fill=X, expand=1)
b16 = Button(f, text="Speaker SS AEP 50 Hz", command=speaker_ear_ssaep_50hz)
b16.pack(fill=X, expand=1)
b17 = Button(f, text="Speaker SS AEP 60 Hz", command=speaker_ear_ssaep_60hz)
b17.pack(fill=X, expand=1)


mainloop()
