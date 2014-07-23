#! /usr/bin/env python
# -*- python -*-
# Time-stamp: <2013-03-04 23:22:55 rozen>


"""
This is a rework of Guilherme Polo's example to include
folder icons which open and close.  Polo's example is Based
on bitwalk's directory browser
<http://bitwalk.blogspot.com/2008/01/ttktreeview.html>..
"""

import os
import os.path

import sys

py26 = py30 = py31 = False
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
    global val, w
    root = Tk()
    root.title('Directory Tree')
    root.geometry('609x422+377+239')
    w = New_Toplevel_1(root)
    init()
    root.mainloop()


def init():
    pass


def quit():
    sys.exit()

class New_Toplevel_1:
    def __init__(self, master=None):

        # Set background of toplevel window to match current style
        style = ttk.Style()
        theme = style.theme_use()
        default = style.lookup(theme, 'background')
        master.configure(background=default)

        self.folder = PhotoImage(file='folder.gif')
        self.openfold = PhotoImage(file='openfold.gif')
        self.stop = PhotoImage(file='stop.gif')

        self.tSc38 = ScrolledTreeView (master)
        self.tSc38.place(relx=0.26,rely=0.17,relheight=0.68,relwidth=0.47)
        self.tSc38.bind('<<TreeviewSelect>>',
                        lambda e :self.update_tree(self.tSc38))
        self.tSc38.bind('<<TreeviewOpen>>',
                        lambda e :self.tree_open(self.tSc38))
        self.tSc38.bind('<<TreeviewClose>>',
                        lambda e :self.tree_close(self.tSc38))
        self.init_tree(self.tSc38)


        self.tBu40 = ttk.Button(master)
        self.tBu40.place(x=0, y=0)
        self.tBu40.configure(text="Press to quit")
        self.tBu40.configure(compound="top")
        self.tBu40.configure(image=self.stop)
        self.tBu40.configure(command=quit)

    def init_tree(self, tree):
        tree.column('#0')
        tree.heading('#0',text='File System')
        node = tree.insert('', 'end', text='/', image=self.folder,
                           values = [ '/', 'directory'])
        self.populate_tree(tree, node)

    def populate_tree(self, tree, node):
        nd = tree.item(node)
        n_type = nd['values'][1]
        if (n_type != 'directory'): return
        n_path = nd['values'][0]
        children = tree.get_children(node)
        try:
            tree.delete(children)
        except:
            pass
        flist = os.listdir(n_path)
        flist.sort()
        for f in flist:
            path = os.path.join(n_path, f)
            if (os.path.isdir(os.path.join(n_path, f))):
                id = tree.insert(node, 'end', text=f, image=self.folder,
                                 values=(path, 'directory'))
                tree.insert(id, 'end', text='dummy')
            else:
                id = tree.insert(node, 'end', text=f, values=(path,'file'))
        tree.item(node, values=(n_path,'processed'))


    def update_tree(self, tree):
        sel = tree.selection()
        self.populate_tree(tree, sel)

    def tree_open(self, tree):
        sel = tree.selection()
        tree.item(sel,image=self.openfold)

    def tree_close(self, tree):
        sel = tree.selection()
        tree.item(sel,image=self.folder)

class AutoScroll(object):
    '''Configure the scrollbars for a widget.'''

    def __init__(self, master):
        vsb = ttk.Scrollbar(master, orient='vertical', command=self.yview)
        hsb = ttk.Scrollbar(master, orient='horizontal', command=self.xview)

        self.configure(yscrollcommand=self._autoscroll(vsb),
            xscrollcommand=self._autoscroll(hsb))
        self.grid(column=0, row=0, sticky='nsew')
        vsb.grid(column=1, row=0, sticky='ns')
        hsb.grid(column=0, row=1, sticky='ew')

        master.grid_columnconfigure(0, weight=1)
        master.grid_rowconfigure(0, weight=1)

        # Copy geometry methods of master  (took from ScrolledText.py)
        if py31:
            methods = Pack.__dict__.keys() | Grid.__dict__.keys() \
                  | Place.__dict__.keys()
        else:
            methods = Pack.__dict__.keys() + Grid.__dict__.keys() \
                  + Place.__dict__.keys()


        for meth in methods:
            if meth[0] != '_' and meth not in ('config', 'configure'):
                setattr(self, meth, getattr(master, meth))

    @staticmethod
    def _autoscroll(sbar):
        '''Hide and show scrollbar as needed.'''
        def wrapped(first, last):
            first, last = float(first), float(last)

            if first <= 0 and last >= 1:
                sbar.grid_remove()
            else:
                sbar.grid()

            sbar.set(first, last)

        return wrapped

    def __str__(self):
        return str(self.master)

def _create_container(func):
    '''Creates a ttk Frame with a given master, and use this new frame to
    place the scrollbars and the widget.'''
    def wrapped(cls, master, **kw):
        container = ttk.Frame(master)
        return func(cls, container, **kw)

    return wrapped

class ScrolledTreeView(AutoScroll, ttk.Treeview):
    '''A standard ttk Treeview widget with scrollbars that will
    automatically show/hide as needed.'''
    @_create_container
    def __init__(self, master, **kw):
        ttk.Treeview.__init__(self, master, **kw)
        AutoScroll.__init__(self, master)


if __name__ == '__main__':
    vp_start_gui()



