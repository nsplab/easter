import time, os

while True:
	os.system('echo "a" > /dev/ttyACM0')
	time.sleep(0.095)
	os.system('echo "d" > /dev/ttyACM0')
	time.sleep(0.095)

