#!/usr/bin/env python
# -*- python -*-
# Time-stamp: <2014-06-18 14:45:31 rozen>

##############################################################################
#
# WCPE - A program for displaying the current piece playing on WCPE.
#
# Copyright (C) 2013 - Donald Rozenberg
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

##############################################################################

# This program is pure Python but does require the user to install the
# latest version of pytz to handle the time zone aspects of the
# program. See https://pypi.python.org/pypi/pytz/ for the latest
# version and installation instructions.  Unfortunately, this package
# is necessary to handle to provide the current time in Raleigh, North
# Carolina where WCPE is located.


import sys

try:
    from Tkinter import *
except ImportError:
    from tkinter import *
try:
    import ttk
    py3 = 0
except ImportError:
    import tkinter.ttk as ttk
    py3 = 1


def set_Tk_var():
    # These are Tk variables used passed to Tkinter and must be
    # defined before the widgets using them are created.
    global composer
    composer = StringVar()

    global performers
    performers = StringVar()

    global start_time
    start_time = StringVar()

    global time_current
    time_current = StringVar()

    global title
    title = StringVar()

import time
import threading

def init(top, gui):
    ''' Function to create the thread for periodically updating the GUI.'''
    global t
    global w, top_level
    global busyWidgets
    w = gui
    top_level = top
    t = threading.Thread(target=fill_window,) # This starts the process.
    t.start()
    busyWidgets = (top, w.Scrolledtext1)



def fill_window():
    global w
    '''This is the timer thread. It runs every second and calls the
    update program every minute. It runs every second so that
    selecting the 'quit' button only appears to take 1 second to
    respond.'''
    sec_cnt = 90
    while True:
        if die:
            return
        if sec_cnt >= 60:
            # Run once a minute,
            display_data(w)
            sec_cnt = 1
        sec_cnt += 1
        time.sleep(1)

import urllib2
import datetime
import time
from pytz import timezone
import pytz
import unicodedata
import os
import copy
import re

dayofweek = {0:'monday',1:'tuesday',2:'wednesday', 3:'thursday', 4:'friday',
             5:'saturday', 6:'sunday'}

eastern = timezone('US/Eastern')
pacific = timezone('US/Pacific')

debuging_mode = True
debuging_mode = False

def display_data(obj):
    ''' Function to get the program date to process. '''
    global gui
    global html
    global eastern_time
    global now_output
    gui = obj

    # Get time and day-of-the week in Raleigh-Durhan
    now = datetime.datetime.now()      # Pacific zone time for testing.
    now_utc = datetime.datetime.utcnow()
    now_output = now.strftime("%A,  %H:%M %Z")

    ea_time = datetime.datetime.now(eastern)
    eastern_time = datetime.datetime.now(eastern)
    ea_date_str = eastern_time.strftime("%A, %B %d, %Y")
    w_day = eastern_time.weekday()
    d = dayofweek[w_day]
    # See if we have the data already by looking in wcperc.
    rcpath = os.path.expanduser('~/wcperc')
    rc_date = ''
    data_path = os.path.expanduser('~/playlist_data')

    if os.path.exists(rcpath):
        rc = open(rcpath)
        rc_date = rc.read().strip()
        rc.close()
        #sys.exit()
    if debuging_mode == False: 
        # Test to see if the current Raleigh date is the same as the last
        # time we wrote the wcperc file. If so skip the part that read the
        # daily program page from the WWW.
        if (ea_date_str != rc_date):
            # read data from web
            gui.Scrolledtext1.delete(1.0, END)
            gui.Scrolledtext1.insert(END, "      Reading data from the net")
            busyStart()                  	 # Turn on busy cursor.
            url = 'http://theclassicalstation.org/music/%s.shtml' % d
            response = urllib2.urlopen(url)
            html = response.readlines()     # html is the date we are to process.
            data_file = open(data_path, 'w')
            # Since we read the data anew we will update the wcperc file.
            for line in html:
                data_file.write(line)
            rc = open(rcpath, 'w')
            rc.write(ea_date_str)
            rc.close()
            busyEnd()                         # Turn off busy cursor.
        else:
            # Read from saved file.  Much faster than rereading the WWW.
            data_file = open(data_path, 'r')
            html = data_file.readlines()
    else:
        # We are in debugging mode:
        data_path = os.path.expanduser('~/playlist_data.look')

        data_file = open(data_path, 'r')
        html = data_file.readlines()

        month = 7
        day = 6
        hr = 11
        min = 30
        eastern_time = eastern_time.replace(month = 7, day = day,
                                            hour=hr, minute=min)

    get_playlist()

time_patt = r'([0-2][0-9]):([0-9][0-9])'
time_re = re.compile(time_patt)

def get_playlist():
    # This processes the data to determine which line of data contians
    # the current selection.
    global html
    global first_text
    global end_cnt
    #global composer
    global selection
    global eastern_time

    comp_time = copy.copy(eastern_time)
    cnt = -1
    in_guide = 0
    listing_count = 0
    playlist_cnt = 0

    for line in html:
        cnt += 1
        match_obj = time_re.search(line)
        if match_obj == None:
            # Skips lines which are not playlist items.
            continue
        else:
            hr = int(match_obj.group(1))
            min = int(match_obj.group(2))
        if (in_guide == 0):
            # First time
            start_cnt = cnt
            first_text = cnt
            in_guide = 1

        playlist_cnt += 1
        start_time = comp_time.replace(hour = hr, minute = min)
        if (start_time >= eastern_time):
            if listing_count == 0:
                listing_count = playlist_cnt
                if playlist_cnt == 1:
                    curr_line = html[cnt]
                    curr_index = cnt
                else:
                    curr_line = previous_playlist_line
        previous_playlist_line = html[cnt]
        last_cnt = cnt
        end_cnt = cnt

    if (listing_count == 0):
        # At the bottom
        curr_line = previous_playlist_line
        curr_index = last_cnt
    curr_index = listing_count
    curr_line = clean_line(curr_line)
    curr_pieces = curr_line.split("|")
    if len(curr_pieces) == 1:
        match_obj = time_re.search(curr_line)
        if match_obj != None:
            time = match_obj.group(1) + ':' + match_obj.group(2)
        composer = ''
        title = 'Special Programming'
        artist = ''
        label = ''
    else:
        time = curr_pieces[1]
        composer = curr_pieces[3]
        title = curr_pieces[4]
        artist = curr_pieces[5]
        label = curr_pieces[6]
    time = convert_starttime_to_localtime(time)
    current_time = copy.copy(time)
    write_gui_variables(composer, artist, time, title, now_output)
    load_textbox(curr_index)

def write_gui_variables(creator, artist, st_time, piece, cur_time):
    ''' This routine copies the results into the GUI. '''
    global composer
    global performers
    global start_time
    global title
    global time_current
    composer.set(creator)
    performers.set(artist)
    start_time.set(st_time)
    title.set(piece)
    time_current.set(cur_time)


def load_textbox(curr_index):
    ''' Function to actually put stuff in the GUI and highlight the
    current selection.'''
    gui.Scrolledtext1.delete(1.0, END) # Clear the GUI textbox.
    skip_count = 0
    out_cnt = 0
    i = 0
    for line in html:
        match_obj = time_re.search(line)
        if match_obj == None:
            # Skips lines which are not playlist items.
            continue
        else:
            hr = match_obj.group(1)
            min = match_obj.group(2)
        i += 1
        line = clean_line(line)

        line = gen_line(line, hr, min)
        gui.Scrolledtext1.insert(END, line) # Insert a line of data.
        out_cnt += 1
        if curr_index == 0:
            index_value = out_cnt
            color_line(out_cnt, line)
        if curr_index   == out_cnt + 1:
            # If the line is the current selection invole the coloring
            # routine.
            color_line(out_cnt, line)
            index_value = out_cnt
        if curr_index == 1:
            index_value = 1
            color_line(1, line)

    index = "%d.0" % (index_value)
    gui.Scrolledtext1.see(index) # Make sure the current selection is
                                  # visible in the text window.

def color_line(curr_index, line):
    ''' Function to color current line red.'''
    gui.Scrolledtext1.tag_remove('current', 1.0, END) # Remove any old coloring.
    gui.Scrolledtext1.tag_configure('current', foreground='red')
    start, end = (0, len(line))
    min_c = '%d.0+%dchars' % (curr_index, start)
    max_c = '%d.0+%dchars' % (curr_index, end)
    gui.Scrolledtext1.tag_add('current', min_c, max_c) # Color desired line.


def clean_line(line):
    line = line.replace('</td><td>','|')
    line = line.replace('</tr>',' ')
    line = line.replace('<tr>',' ')
    line = line.replace('<td>',' ')
    line = line.replace('</td>','')
    return line

def gen_line(line, hr, min):
    ''' Function to create individual lines for the GUI.'''
    line = remove_accents(line)
    time = hr + ':' + min
    if line.find('|') == -1:
        composer = ''
        title = 'Special Programming'
        artist = ''
        label = ''
    else:
        pieces = line.split("|")
        time = convert_starttime_to_localtime(time)
        composer = pieces[3]
        title = pieces[4]
        artist = pieces[5]
        label = pieces[6]
    ret_line = "{:6} {:20} {:40} {:40}\n".format(time, composer,
                                                 title[0:39], artist)
    return ret_line


def remove_accents(string):
    ''' The tk text box cannot handle the accents which asppear in the
    htlm data so I have to ignore them.  This was the trickest part of
    building the whole program.'''
    for c in string:
        if ord(c) > 0x7f:
            x = unicodedata.normalize('NFKD', unichr(ord(c))).encode('ascii',
                                                                     'ignore')
            string = string.replace(c, x)
    return string

def convert_starttime_to_localtime(time):
    t = time.split(':')
    copy_eastern = copy.copy(eastern_time)
    eastern_replace = copy_eastern.replace(hour = int(t[0]), minute = int(t[1]))
    eastern_start_to_local = eastern_replace.astimezone(pacific)
    t_str = eastern_start_to_local.strftime("%H:%M")
    return t_str

# Code added to allow one to change default cursor to a busy cursor.
# Variables added manually to indicate long processes based on code by
# Greg Walters in his python programming examples.  These routines
# also can be seen in the Greyson book pg. 158.
busyCursor = 'watch'
preBusyCursors = None

def busyStart(newcursor=None):
    '''We first check to see if a value was passed to "newcursor". If
       not, we default to the busyCursor. Then we walk through the
       busyWidgets tuple and set the cursor to whatever we want.'''
    global preBusyCursors
    if not newcursor:
        newcursor = busyCursor
    newPreBusyCursors = {}
    for component in busyWidgets:
        newPreBusyCursors[component] = component['cursor']
        component.configure(cursor=newcursor)
        component.update_idletasks()
    preBusyCursors = (newPreBusyCursors, preBusyCursors)

def busyEnd():
    '''In this routine, we basically reset the cursor for the widgets
       in our busyWidget tuple back to our default cursor.'''
    global preBusyCursors
    if not preBusyCursors:
        return
    oldPreBusyCursors = preBusyCursors[0]
    preBusyCursors = preBusyCursors[1]
    for component in busyWidgets:
        try:
            component.configure(cursor=oldPreBusyCursors[component])
        except KeyError:
            pass
        component.update_idletasks()
# End of busy cursor code.

die = False
def quit():
    ''' Function to terminate the program. '''
    global die
    die = True
    sys.exit()

def main():
    ''' Function for debugging this module; it is not used when whole
    program is run.'''
## def convert_time_to_utc(time):
##     print 'convert_time_to_utc: time =', time    # rozen   pyp
##     print 'convert_time_to_utc: ea_time =', ea_time    # rozen   pyp
##     print 'convert_time_to_utc: ea_date_str =', ea_date_str    # rozen   pyp
##     print 'convert_time_to_utc: ea_date =', ea_date    # rozen   pyp
##     date = ea_date.strftime('%Y-%m-%d')
##     print 'convert_time_to_utc: date =', date    # rozen   pyp
##     date_p = date.split('-')
##     print 'convert_time_to_utc: date_p =', date_p    # rozen   pyp
##     date_p = date_p + time.split(':')
##     print 'convert_time_to_utc: date_p =', date_p    # rozen   pyp
##     time_obj = datetime.datetime(*([int(date_p[i]) for i in range(5)]),
##                                  tzinfo=eastern)
##     print 'convert_time_to_utc: time_obj =', time_obj    # rozen   pyp
##     time_utc = time_obj.astimezone(pytz.utc)
##     print 'convert_time_to_utc: time_utc =', time_utc    # rozen   pyp
##     return time_utc

##     #quit()
    get_playlist()
if __name__ == '__main__':
    main()


