import threading
import time
import zmq
import shlex
import sqlite3
import sys
import os
import random
import portio
from subprocess import Popen

sampling_frq = 9600
num_scans = 128
sampling_step = 1.0 / sampling_frq

# make sure you have root permission
if os.getuid():
    print('You need to be root! Exiting...')
    sys.exit()

status = portio.ioperm(0xe010, 1, 1)
if status:
    print('ioperm:', os.strerror(status))
    sys.exit()

portio.outb(0x0, 0xe010)

#########################
## Left Ear
#########################

class PlaySound(threading.Thread):
	def __init__(self, s):
		self.s = s
		threading.Thread.__init__(self)
	def GetBusy(self):
		return s.get_busy()
	def run(self):
		s.play()

### brain
def ss_vep(frequency):
    global continue_ss_vep
    interval = 1.0 / frequency
    if continue_ss_vep:
        threading.Timer(interval, ss_vep, [frequency]).start()
    portio.outb(0xff, 0xe010)
    time.sleep(interval * 1.5 / 5.0)
    portio.outb(0x0, 0xe010)


context = zmq.Context()
socket = context.socket(zmq.REQ)
socket.connect("ipc:///tmp/record.pipe")
#socket.setsockopt(zmq.SUBSCRIBE, '')

### Simple VEP

#print "simple vep"

#folder_name = '/media/ssd/left_eye_vep_simple_10ms_' + str(int(time.time() * 1000000.0))
#os.makedirs(folder_name)

#accel_db = folder_name + "/eeg.db"
#connection = sqlite3.connect(accel_db)
#cursor = connection.cursor()

#create_str = "CREATE TABLE eeg (time INTEGER PRIMARY KEY"
#for i in range(1, num_channels + 1):
#        create_str += ", c" + str(i) + " REAL"
#create_str += ");"
#cursor.execute(create_str)

#continue_simple_vep = True
#simple_vep()

'''counter = 0
sample_num = 0
prev_time = 0
prev_tuple = 0
stop_time = time.time() + 61
while time.time() < stop_time:
        string = socket.recv()
        #print string
        sample_num += 1
        eegs = shlex.split(string)
        time_str = eegs[0]
        cur_time = round(sample_num * num_scans * sampling_step * 100000.0)
        print "time: ", cur_time
        if cur_time == prev_time:
                continue
        prev_time = cur_time
        for scan in range(0, num_scans):
                EEG = []
                for i in range(0, num_channels):
                        EEG.append(float(eegs[scan * num_channels + i + 1]))
                holders = ','.join('?' * (num_channels + 1))
                sql = 'INSERT INTO eeg VALUES({0})'.format(holders)
                tuple_row = (round(cur_time + scan * sampling_step * 100000),)
                tuple_row += tuple(EEG)
                try:
                        cursor.execute(sql, tuple_row)
                        prev_tuple = tuple_row
                except:
                        print "Warning, ", sys.exc_info()[1]
                        print tuple_row
                        print prev_tuple
                        continue
        counter += 1
        if counter == 256:
                print 'commit'
                connection.commit()
                counter = 0

continue_simple_vep = False
connection.commit()
connection.close()

time.sleep(5)'''

### SSVEP 10hz

print "brainstem aep"

'''folder_name = '/media/ssd/left_eye_ss_vep_30hz_' + str(int(time.time() * 1000000.0))
os.makedirs(folder_name)

accel_db = folder_name + "/eeg.db"
connection = sqlite3.connect(accel_db)
cursor = connection.cursor()

create_str = "CREATE TABLE eeg (time INTEGER PRIMARY KEY"
for i in range(1, num_channels + 1):
        create_str += ", c" + str(i) + " REAL"
create_str += ");"
cursor.execute(create_str)
'''

#mixer.init()
#s = mixer.Sound('/home/user/code/easter/aep/pip_train_brainstem.wav')
#s.set_volume(1.0)
#sth = PlaySound(s)

control = True

#p = Popen(['python', '/home/user/code/easter/aep/play_pip_train.py'])

time.sleep(3.0)

#continue_ss_vep = True
#ss_vep(30.0)
if control:
    socket.send("human_speaker_control_right_ssaep_ear")
else:
    socket.send("human_speaker_right_ssaep_ear")
socket.recv()


stop_time = time.time() + (1 * 60) 
#stop_time = time.time() + (10)
while time.time() < stop_time:
    print "recording ", (stop_time - time.time())

continue_ss_vep = False
socket.send("stop")
socket.recv()

'''counter = 0
sample_num = 0
prev_time = 0
prev_tuple = 0
stop_time = time.time() + 121
while time.time() < stop_time:
        string = socket.recv()
        #print string
        sample_num += 1
        eegs = shlex.split(string)
        time_str = eegs[0]
        cur_time = round(sample_num * num_scans * sampling_step * 100000.0)
        print "time: ", cur_time
        if cur_time == prev_time:
                continue
        prev_time = cur_time
        for scan in range(0, num_scans):
                EEG = []
                for i in range(0, num_channels):
                        EEG.append(float(eegs[scan * num_channels + i + 1]))
                holders = ','.join('?' * (num_channels + 1))
                sql = 'INSERT INTO eeg VALUES({0})'.format(holders)
                tuple_row = (round(cur_time + scan * sampling_step * 100000),)
                tuple_row += tuple(EEG)
                try:
                        cursor.execute(sql, tuple_row)
                        prev_tuple = tuple_row
                except:
                        print "Warning, ", sys.exc_info()[1]
                        print tuple_row
                        print prev_tuple
                        continue
        counter += 1
        if counter == 256:
                print 'commit'
                connection.commit()
                counter = 0

continue_ss_vep_30hz = False
connection.commit()
connection.close()

time.sleep(5)

### SSVEP random

print "ssvep random"

folder_name = '/media/ssd/left_eye_ss_vep_random10hzto40hz_' + str(int(time.time() * 1000000.0))
os.makedirs(folder_name)

accel_db = folder_name + "/eeg.db"
connection = sqlite3.connect(accel_db)
cursor = connection.cursor()

create_str = "CREATE TABLE eeg (time INTEGER PRIMARY KEY"
for i in range(1, num_channels + 1):
        create_str += ", c" + str(i) + " REAL"
create_str += ");"
cursor.execute(create_str)

continue_ss_vep_random = True
ss_vep_random()

counter = 0
sample_num = 0
prev_time = 0
prev_tuple = 0
stop_time = time.time() + 121
while time.time() < stop_time:
        string = socket.recv()
        #print string
        sample_num += 1
        eegs = shlex.split(string)
        time_str = eegs[0]
        cur_time = round(sample_num * num_scans * sampling_step * 100000.0)
        print "time: ", cur_time
        if cur_time == prev_time:
                continue
        prev_time = cur_time
        for scan in range(0, num_scans):
                EEG = []
                for i in range(0, num_channels):
                        EEG.append(float(eegs[scan * num_channels + i + 1]))
                holders = ','.join('?' * (num_channels + 1))
                sql = 'INSERT INTO eeg VALUES({0})'.format(holders)
                tuple_row = (round(cur_time + scan * sampling_step * 100000),)
                tuple_row += tuple(EEG)
                try:
                        cursor.execute(sql, tuple_row)
                        prev_tuple = tuple_row
                except:
                        print "Warning, ", sys.exc_info()[1]
                        print tuple_row
                        print prev_tuple
                        continue
        counter += 1
        if counter == 256:
                print 'commit'
                connection.commit()
                counter = 0

continue_ss_vep_random = False
connection.commit()
connection.close()
'''

