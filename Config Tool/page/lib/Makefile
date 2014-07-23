all: TAGS

tags: TAGS

TAGS: *.tcl ../*.tcl
	#ctags -e --exclude debug.tcl --exclude RCS --exclude kpwidgets --exclude bwidget *.tcl ../page.tcl Widgets/ttk/* Widgets/core/*
	ctags -e --exclude=debug.tcl --exclude=compound.tcl --exclude=tkcon.tcl --exclude=kpwidgets --exclude=bWidgets  ../page.tcl *.tcl Widgets/ttk/* Widgets/core/*

clean::
	rm -f TAGS

stuff:
	#etags --regex='/proc[ \t]+\([^ \t]+\)/\1/' *.tcl ../*.tcl
	#ctags -e --exclude=debug.tcl  --exclude=kpwidgets --exclude=bWidgets  ../page.tcl *.tcl Widgets/ttk/* Widgets/core/*

