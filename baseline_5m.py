import threading
import time, os
import zmq
import shlex
import sqlite3
import select, sys
import random

sampling_frq = 2400.0
num_scans    = 16
num_channels = 26
sampling_step = 1.0/sampling_frq

#########################
## Baseline 5 min
#########################


context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect("tcp://192.168.56.101:5556")
socket.setsockopt(zmq.SUBSCRIBE, '')

folder_name = '/media/ssd/baseline_5m_'+str(int(time.time()*1000000.0))
os.makedirs(folder_name)

accel_db= folder_name+"/eeg.db"
connection=sqlite3.connect(accel_db)
cursor=connection.cursor()

create_str = "CREATE TABLE eeg (time INTEGER PRIMARY KEY"
for i in range(1, num_channels+1):
        create_str += ", c"+str(i)+" REAL"
create_str += ");"
cursor.execute(create_str)

counter = 0
sample_num = 0
prev_time = 0
prev_tuple = 0
stop_time = time.time()+301
while time.time() < stop_time:
        string = socket.recv()
        #print string
        sample_num += 1
        eegs = shlex.split(string)
        time_str = eegs[0]
        cur_time = round(sample_num*num_scans*sampling_step*100000.0)
        print "time: ", cur_time
        if cur_time == prev_time:
                continue
        prev_time = cur_time
        for scan in range(0, num_scans):
                EEG = []
                for i in range(0, num_channels):
                        EEG.append(float(eegs[scan*num_channels+i+1]))
                holders = ','.join('?' * (num_channels+1))
                sql = 'INSERT INTO eeg VALUES({0})'.format(holders)
                tuple_row = (round(cur_time+scan*sampling_step*100000),)
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

connection.commit()
connection.close()

