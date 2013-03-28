import zmq
import shlex
import sqlite3
import select, sys
import time, os

sampling_frq = 1200.0
num_scans    = 8
num_channels = 10
sampling_step = 1.0/sampling_frq

print str(sys.argv[1])

folder_name = str(sys.argv[1])+'_'+str(int(time.time()*1000000.0))
os.makedirs(folder_name)

context = zmq.Context()
socket = context.socket(zmq.SUB)
#socket.connect("ipc:///home/nsplab3/pelops/build/eeg_signals.ipc")
socket.connect("tcp://192.168.56.101:5556")
socket.setsockopt(zmq.SUBSCRIBE, '')

accel_db= folder_name+"/eeg.db"
connection=sqlite3.connect(accel_db)
cursor=connection.cursor()

create_str = "CREATE TABLE eeg (time INTEGER PRIMARY KEY"
for i in range(1, num_channels+1):
	create_str += ", c"+str(i)+" REAL"
create_str += ");"
cursor.execute(create_str)
print create_str

def heardEnter():
    i,o,e = select.select([sys.stdin],[],[],0.00001)
    for s in i:
        return False
#        if s == sys.stdin:
#            input = sys.stdin.readline()
    return True

counter = 0
conti = True
def mainloop():
	global counter
	global conti
	sample_num = 0
	prev_time = 0
	prev_tuple = 0
	while conti:
		string = socket.recv()
		sample_num += 1
#		print 'got ', string
		eegs = shlex.split(string)
#		print 'p ', len(eegs), eegs
		time_str = eegs[0]
		#time = (round(float(time_str)*100000.0))
		#print (round(float(time_str)*100000.0))
		time = round(sample_num*num_scans*sampling_step*100000.0)
		print "time: ", time
		if time == prev_time:
			continue
		prev_time = time
		for scan in range(0, num_scans):
			EEG = []
			for i in range(0, num_channels):
	#			print eegs[i+1]
				EEG.append(float(eegs[scan*num_channels+i+1]))
			holders = ','.join('?' * (num_channels+1))
			sql = 'INSERT INTO eeg VALUES({0})'.format(holders)
	#		print 'eeg ', EEG
			#print int(scan*sampling_step*100000.0)
			tuple_row = (round(time+scan*sampling_step*100000),)
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
		conti = heardEnter()
	#print "x: ",r[0], "  y: ",r[1], "  z: ",r[2]


mainloop()

