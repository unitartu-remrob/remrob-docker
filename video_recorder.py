#!/usr/bin/python3

import argparse
import os
import signal
import subprocess

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Notify', '0.7')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk as gtk
from gi.repository import AppIndicator3 as appindicator
from gi.repository import Notify as notify
from gi.repository import Gdk

screen = Gdk.Screen.get_default()
geo = screen.get_monitor_geometry(screen.get_primary_monitor())

FILE_NAME ='recording'

def name_file(path):
    global FILE_NAME
    max_num = 1
    while True:
        FILE_NAME = os.path.join(path,f'recording-{max_num}.mp4')
        if os.path.exists(FILE_NAME): max_num+=1
        else: break


APPINDICATOR_ID = 'myappindicator'

def main():
    indicator = appindicator.Indicator.new(APPINDICATOR_ID, os.path.abspath('sample_icon.svg'), appindicator.IndicatorCategory.SYSTEM_SERVICES)
    indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
    indicator.set_menu(build_menu())
    notify.init(APPINDICATOR_ID)
    gtk.main()

def build_menu():
    menu = gtk.Menu()

    item_myapp = gtk.MenuItem(label='Start recording 1 minute')
    item_myapp.connect('activate', myapp)
    menu.append(item_myapp)
    
    item_myapp_stop = gtk.MenuItem(label='Stop recording')
    item_myapp_stop.connect('activate', myapp_stop)
    menu.append(item_myapp_stop)

    item_quit1 = gtk.MenuItem(label='Quit')
    item_quit1.connect('activate', quit1)
    menu.append(item_quit1)

    menu.show_all()
    return menu


def myapp(_):
    subprocess.call(["pkill", "ffmpeg"], shell=False) # make sure no recorder is running
    os.system(f'ffmpeg \
                -video_size {geo.width}x{geo.height} \
                -framerate 25 \
                -f x11grab \
                -i :2.0 \
                -t 60 \
                -y \
                {FILE_NAME} &')
    return myapp
    
def myapp_stop(_):
    subprocess.call(["pkill", "ffmpeg"], shell=False)
    name_file(opt.saving_path)
    return myapp_stop

def quit1(_):
    notify.uninit()
    gtk.main_quit()

def parse_args():
    global opt
    parser = argparse.ArgumentParser()
    parser.add_argument('--saving_path', default='/home/kasutaja/', help='Video saving folder')
    opt = parser.parse_args()
    return opt

if __name__ == "__main__":
    opt = parse_args()
    name_file(opt.saving_path)
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main()