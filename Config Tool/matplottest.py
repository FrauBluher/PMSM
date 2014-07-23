#!/usr/bin/env python
# Plot a graph of Data which is comming in on the fly
# uses pylab
# Author: Norbert Feurle
# Date: 12.1.2012
# License: if you get any profit from this then please share it with me  and only use it for good
import pylab
from pylab import *
import Tkinter
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg

root = Tkinter.Tk()
root.wm_title("Extended Realtime Plotter")

xAchse=pylab.arange(0,100,1)
yAchse=pylab.array([0]*100)

fig = pylab.figure(1)
ax = fig.add_subplot(111)
ax.grid(True)
ax.set_title("Realtime Waveform Plot")
ax.set_xlabel("Time")
ax.set_ylabel("Amplitude")
ax.axis([0,100,-1.5,1.5])
line1=ax.plot(xAchse,yAchse,'-')

canvas = FigureCanvasTkAgg(fig, master=root)
canvas.show()
canvas.get_tk_widget().pack(side=Tkinter.TOP, fill=Tkinter.BOTH, expand=1)

toolbar = NavigationToolbar2TkAgg( canvas, root )
toolbar.update()
canvas._tkcanvas.pack(side=Tkinter.TOP, fill=Tkinter.BOTH, expand=1)

values=[]
values = [0 for x in range(100)]

Ta=0.01
fa=1.0/Ta
fcos=3.5

Konstant=cos(2*pi*fcos*Ta)
T0=1.0
T1=Konstant

def SinwaveformGenerator():
  global values,T1,Konstant,T0,wScale2
  #ohmegaCos=arccos(T1)/Ta
  #print "fcos=", ohmegaCos/(2*pi), "Hz"

  Tnext=((Konstant*T1)*2)-T0 
  if len(values)%100>70:
    values.append(random()*2-1)
  else:
    values.append(Tnext)
  T0=T1
  T1=Tnext
  root.after(int(wScale2['to'])-wScale2.get(),SinwaveformGenerator)

def RealtimePloter():
  global values,wScale,wScale2
  NumberSamples=min(len(values),wScale.get())
  CurrentXAxis=pylab.arange(len(values)-NumberSamples,len(values),1)
  line1[0].set_data(CurrentXAxis,pylab.array(values[-NumberSamples:]))
  ax.axis([CurrentXAxis.min(),CurrentXAxis.max(),-1.5,1.5])
  canvas.draw()
  root.after(25,RealtimePloter)
  #canvas.draw()

  #manager.show()

def _quit():
    root.quit()     # stops mainloop
    root.destroy()  # this is necessary on Windows to prevent
                    # Fatal Python Error: PyEval_RestoreThread: NULL tstate

button = Tkinter.Button(master=root, text='Quit', command=_quit)
button.pack(side=Tkinter.BOTTOM)

wScale = Tkinter.Scale(master=root,label="View Width:", from_=3, to=1000,sliderlength=30,length=ax.get_frame().get_window_extent().width, orient=Tkinter.HORIZONTAL)
wScale2 = Tkinter.Scale(master=root,label="Generation Speed:", from_=1, to=200,sliderlength=30,length=ax.get_frame().get_window_extent().width, orient=Tkinter.HORIZONTAL)
wScale2.pack(side=Tkinter.BOTTOM)
wScale.pack(side=Tkinter.BOTTOM)

wScale.set(100)
wScale2.set(wScale2['to']-10)

root.protocol("WM_DELETE_WINDOW", _quit)  #thanks aurelienvlg
root.after(100,SinwaveformGenerator)
root.after(100,RealtimePloter)
Tkinter.mainloop()
#pylab.show()
