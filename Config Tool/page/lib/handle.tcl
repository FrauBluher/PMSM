##############################################################################
# $Id: handle.tcl,v 1.8 2001/07/10 17:37:19 damonc Exp $
#
# handle.tcl - procedures to manipulate widget handles
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

proc vTcl:destroy_handles {} {
    global vTcl
    if {$vTcl(h,exist) && [winfo exists $vTcl(h,n)]} {
        destroy $vTcl(h,n)  $vTcl(h,e)
        destroy $vTcl(h,s)  $vTcl(h,w)
        destroy $vTcl(h,nw) $vTcl(h,ne)
        destroy $vTcl(h,se) $vTcl(h,sw)
    }
    set vTcl(h,exist) 0
}

proc vTcl:create_handles {target} {
    global vTcl
    if {$vTcl(h,exist)} { vTcl:destroy_handles }
    if { $vTcl(w,manager) == "wm" || $target == "." } { return }
    set vTcl(h,exist) 1
    set s [expr $vTcl(h,size) * 2]
    if {![winfo exists $target]} { return }
    set parent [winfo parent $target]
    if { $parent == "." } { set parent "" }

    set handles {
        {n  top_side}
        {s  bottom_side}
        {e  right_side}
        {w  left_side}
        {nw top_left_corner}
        {ne top_right_corner}
        {sw bottom_left_corner}
        {se bottom_right_corner}
    }
    foreach i $handles {
        set a [lindex $i 0]
        set b [lindex $i 1]
        set vTcl(h,$a) "$parent.vTH_${a}"
        frame $vTcl(h,$a) \
            -width $s -height $s -bd 0 -relief flat \
            -highlightthickness 0 -cursor $b -bg $vTcl(actual_gui_fg) ;# Rozen
        bind $vTcl(h,$a) <B1-Motion>       "vTcl:grab_resize %X %Y $a"
        bind $vTcl(h,$a) <Control-B1-Motion> "vTcl:grab_resize_ctrl %X %Y $a"
                                                # Rozen
        bind $vTcl(h,$a) <Button-1>        "vTcl:grab %W %X %Y"
        bind $vTcl(h,$a) <ButtonRelease-1> "vTcl:grab_release %W"
    }
    vTcl:place_handles $target
}

proc vTcl:place_handles {target} {
    global vTcl
    if {$target == ""} { return }

    ## Don't place handles on a toplevel window.
    if {[vTcl:get_class $target] == "Toplevel"} {
        vTcl:destroy_handles
        return
    }

    if {$vTcl(h,exist) && [winfo exists $vTcl(h,n)]} {
        update idletasks
        set s $vTcl(h,size)
        set x [winfo x $target]
        set y [winfo y $target]
        set w1 [winfo width $target]
        set w2 [expr $w1 / 2]
        set h1 [winfo height $target]
        set h2 [expr $h1 / 2]
        place $vTcl(h,n)  \
            -x [expr $x + $w2 - $s] -y [expr $y - $s]       -bordermode ignore
        place $vTcl(h,e)  \
            -x [expr $x + $w1 - $s] -y [expr $y + $h2 - $s] -bordermode ignore
        place $vTcl(h,s)  \
            -x [expr $x + $w2 - $s] -y [expr $y + $h1 - $s] -bordermode ignore
        place $vTcl(h,w)  \
            -x [expr $x - $s]       -y [expr $y + $h2 - $s] -bordermode ignore
        place $vTcl(h,nw) \
            -x [expr $x - $s]       -y [expr $y - $s]       -bordermode ignore
        place $vTcl(h,ne) \
            -x [expr $x + $w1 - $s] -y [expr $y - $s]       -bordermode ignore
        place $vTcl(h,se) \
            -x [expr $x + $w1 - $s] -y [expr $y + $h1 - $s] -bordermode ignore
        place $vTcl(h,sw) \
            -x [expr $x - $s]       -y [expr $y + $h1 - $s] -bordermode ignore
    } else {
        vTcl:create_handles $target
    }
}
