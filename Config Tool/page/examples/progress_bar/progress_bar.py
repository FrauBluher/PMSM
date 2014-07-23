#! /usr/bin/env python
# -*- python -*-

import sys

py2 = py30 = py31 = False
version = sys.hexversion
if version >= 0x020600F0 and version < 0x03000000 :
    py2 = True    # Python 2.6 or 2.7
    from Tkinter import *
    import ttk
elif version >= 0x03000000 and version < 0x03010000 :
    py30 = True
    from tkinter import *
    import ttk
elif version >= 0x03010000:
    py31 = True
    from tkinter import *
    import tkinter.ttk as ttk
else:
    print ("""
    You do not have a version of python supporting ttk widgets..
    You need a version >= 2.6 to execute PAGE modules.
    """)
    sys.exit()



def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = Tk()
    root.title('Progress_Bar')
    root.geometry('301x129+472+154')
    w = Progress_Bar (root)
    init()
    root.mainloop()

w = None
def create_Progress_Bar (root):
    '''Starting point when module is imported by another program.'''
    global w, w_win
    if w: # So we have only one instance of window.
        return
    w = Toplevel (root)
    w.title('Progress_Bar')
    w.geometry('301x129+472+154')
    w_win = Progress_Bar (w)
    init()
    return w_win

def destroy_Progress_Bar ():
    global w
    w.destroy()
    w = None




def init():
    pass




class Progress_Bar:
    def __init__(self, master=None):
        # Set background of toplevel window to match
        # current style
        style = ttk.Style()
        theme = style.theme_use()
        default = style.lookup(theme, 'background')
        master.configure(background=default)

        self.TProgressbar1 = ttk.Progressbar (master)
        self.TProgressbar1.place(relx=0.17,rely=0.47,relheight=0.15
                ,relwidth=0.66)
        self.prog_var = IntVar()
        self.TProgressbar1.configure(variable=self.prog_var)

        self.update(0.4)

    def update (self, v):
        print 'Progress_Bar: update: v =', v    # rozen pyp
        self.prog_var.set(int(v*100))

    def close(self):
        destroy_Progress_Bar()





if __name__ == '__main__':
    vp_start_gui()



