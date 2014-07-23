##############################################################################
# $Id: balloon.tcl,v 1.7 2001/08/09 04:36:42 cgavin Exp $
#
# balloon.tcl - procedures used by balloon help
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

bind _vTclBalloon <Enter> {
    namespace eval ::vTcl::balloon {
        ## self defining balloon?
        if {![info exists %W]} {
            vTcl:FireEvent %W <<SetBalloon>>
        }
        set set 0
        set first 1
        set id [after 500 {vTcl:FireEvent %W <<vTclBalloon>>}]
    }
}

bind _vTclBalloon <Motion> {
    namespace eval ::vTcl::balloon {
        if {!$set} {
            after cancel $id
            set id [after 500 {vTcl:FireEvent %W <<vTclBalloon>>}]
        }
    }
}

bind _vTclBalloon <Button> {
    namespace eval ::vTcl::balloon {
        set first 0
    }
    vTcl:FireEvent %W <<KillBalloon>>
}

bind _vTclBalloon <Leave> {
    namespace eval ::vTcl::balloon {
        set first 0
    }
    vTcl:FireEvent %W <<KillBalloon>>
}

bind _vTclBalloon <<KillBalloon>> {
    namespace eval ::vTcl::balloon {
        after cancel $id
        if {[winfo exists .vTcl.balloon]} {
            destroy .vTcl.balloon
        }
        set set 0
    }
}

bind _vTclBalloon <<vTclBalloon>> {
    if {$::vTcl::balloon::first != 1} {break}
    namespace eval ::vTcl::balloon {
        set first 2
        if {![winfo exists .vTcl]} {
            toplevel .vTcl; wm withdraw .vTcl
        }
        if {![winfo exists .vTcl.balloon]} {
            toplevel .vTcl.balloon -bg black
        }
        wm overrideredirect .vTcl.balloon 1
        label .vTcl.balloon.l \
            -text ${%W} -relief flat \
            -bg #ffffaa -fg black -padx 2 -pady 0 -anchor w
        pack .vTcl.balloon.l -side left -padx 1 -pady 1
        wm geometry \
            .vTcl.balloon \
            +[expr {[winfo rootx %W]+[winfo width %W]/2}]+[expr {[winfo rooty %W]+[winfo height %W]+4}]
        set set 1
    }
}

proc vTcl:set_balloon {target message} {
    ## Balloons disabled?
    if {!$::vTcl(pr,balloon)} {return}

    namespace eval ::vTcl::balloon "variable $target"
    set ::vTcl::balloon::$target $message

    ## Add tag to the widget
    bindtags $target "[bindtags $target] _vTclBalloon"
}
