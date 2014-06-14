#!/usr/bin/python
import threading
import time
import zmq
import shlex
import sqlite3
import sys
import os
import random
import portio

from Tkinter import *

# length of recording in seconds
recordLength = 5 * 60 + 20
filename = "_vep_";


context = zmq.Context()
socket = context.socket(zmq.REQ)
socket.connect("ipc:///tmp/record.pipe")
#socket.setsockopt(zmq.SUBSCRIBE, '')

top = Tk()

Label(top, text="Filename").grid(row=0)
#L1.pack( side = LEFT)


var = StringVar()
var.set(filename)

E1 = Entry(top, textvariable=var)
#E1.pack(side = RIGHT)
E1.grid(row=0, column=1, sticky=(E, W), columnspan=2)

Grid.columnconfigure(top,1,weight=1)

E1.focus_set()


def callback(argument=None):
    top.quit()

b = Button(top, text="OK", width=10, command=callback)
E1.bind('<Return>', callback)
b.grid(row=1)
#b.pack()

top.mainloop()
filename = var.get()

print filename

socket.send(filename)

socket.recv()

stop_time = time.time() + recordLength
while time.time() < stop_time:
    print "recording ", (stop_time - time.time())

socket.send("stop")
socket.recv()

