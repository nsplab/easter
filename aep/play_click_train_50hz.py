from pygame import mixer
import time,os

mixer.init()
s = mixer.Sound('aep/click_train_ss_50hz.wav')
s.set_volume(0.30682)

os.system('echo "0;" > /dev/ttyACM0')
s.play()

while mixer.get_busy():
        os.system('echo "1;" > /dev/ttyACM0')

os.system('echo "0;" > /dev/ttyACM0')


