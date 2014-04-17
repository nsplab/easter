from pygame import mixer
import time,os

mixer.init()
s = mixer.Sound('aep/brainstem_click_train.wav')
s.set_volume(1.0)

#os.system('echo "0;" > /dev/ttyACM0')
s.play()

while mixer.get_busy():
    pass
    #print '-'
    #os.system('echo "1;" > /dev/ttyACM0')

#os.system('echo "0;" > /dev/ttyACM0')
#os.system('echo "0;" > /dev/ttyACM0')
#os.system('echo "0;" > /dev/ttyACM0')


