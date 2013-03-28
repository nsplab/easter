import time, os
from pygame import mixer


#os.system('echo "0;" > /dev/ttyACM0')

mixer.init()

s = mixer.Sound('tone.wav')
#s = mixer.Sound('click10ms.wav')

s.set_volume(0.30682)
#s.set_volume(1.50682)

s.play()
time.sleep(9999)

for i in range(1,121):
	print i
	os.system('echo "1;" > /dev/ttyACM0')
	s.play()
	time.sleep(0.009)
	os.system('echo "0;" > /dev/ttyACM0')
	time.sleep(0.988)
	
