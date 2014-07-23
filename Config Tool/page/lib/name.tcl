##############################################################################
# $Id: name.tcl,v 1.6 2001/07/06 21:41:51 damonc Exp $
#
# name.tcl - procedures for prompting widget names
#
# Copyright (C) 1996-1998 Stewart Allen
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
#

proc vTcl:get_name {type} {
    global vTcl
    set vTcl(x) ""
    Window show .vTcl.name
    focus .vTcl.name.ent18
    catch {grab .vTcl.name}
    wm title .vTcl.name "Naming new $type"
    tkwait window .vTcl.name
    if {[string first . $vTcl(x)] != -1} {
        vTcl:error "Invalid widget name"
        return ""
    } else {
        return $vTcl(x)
    }
}

proc vTcl:ok_new_widget {} {
    global vTcl
    set vTcl(x) [.vTcl.name.ent18 get]
    grab release .vTcl.name
    destroy .vTcl.name
}

proc vTclWindow.vTcl.name {args} {
    set base .vTcl.name
    if {[winfo exists .vTcl.name]} {
        wm deiconify .vTcl.name; return
    }
    toplevel .vTcl.name
    wm focusmodel .vTcl.name passive
    wm geometry .vTcl.name 225x49+288+216
    wm maxsize .vTcl.name 500 870
    wm minsize .vTcl.name 225 1
    wm overrideredirect .vTcl.name 0
    wm resizable .vTcl.name 1 0
    wm deiconify .vTcl.name
    wm title .vTcl.name "Name Widget"
    bind .vTcl.name <Key-Return> {
        vTcl:ok_new_widget
    }
    vTcl:entry .vTcl.name.ent18 \
        -cursor {}
    pack .vTcl.name.ent18 \
        -in .vTcl.name -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    frame .vTcl.name.fra19 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack .vTcl.name.fra19 \
        -in .vTcl.name -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    button .vTcl.name.fra19.but20 \
        -command {
            vTcl:ok_new_widget
        } \
         -padx 9 \
        -pady 3 -text OK -width 5
    pack .vTcl.name.fra19.but20 \
        -in .vTcl.name.fra19 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    button .vTcl.name.fra19.but21 \
        -command {
            grab release .vTcl.name
            destroy .vTcl.name
        } \
         -padx 9 \
        -pady 3 -text Cancel -width 5
    pack .vTcl.name.fra19.but21 \
        -in .vTcl.name.fra19 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
}


