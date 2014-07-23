##############################################################################
# $Id: tree.tcl,v 1.28 2005/12/02 21:28:45 kenparkerjr Exp $
#
# tree.tcl - widget tree browser and associated procedures
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

set vTcl(tree,last_selected) ""
set vTcl(tree,last_yview) 0.0

proc vTcl:show_selection_in_tree {widget_path} {

    vTcl:show_selection .vTcl.tree.cpd21.03.[vTcl:rename $widget_path] \
        $widget_path
}

proc vTcl:show_selection {button_path target} {
    global vTcl
    # do not refresh the widget tree if it does not exist
    if {![winfo exists .vTcl.tree]} return

    if {[vTcl:streq $target "."]} { return }

    vTcl:log "widget tree select: $button_path"
    set b .vTcl.tree.cpd21.03

    if {$vTcl(tree,last_selected)!=""} {
        #$b itemconfigure "TEXT$vTcl(tree,last_selected)" -fill #000000
        $b itemconfigure "TEXT$vTcl(tree,last_selected)" -fill $vTcl(pr,fgcolor)
    }

    #set fill #0000ff
    set fill $vTcl(pr,fgcolor)

    if {![lempty $vTcl(pr,treehighlight)]} { set fill $vTcl(pr,treehighlight) }
    $b itemconfigure "TEXT$button_path" -fill $fill


    set vTcl(tree,last_selected) $button_path

    # let's see if we can bring the thing into view
    lassign [$b cget -scrollregion] foo foo cx cy
    lassign [$b bbox $button_path] x1 y1 x2 y2

    if {$cy <= 0} {return}

    set yf0 [expr $y1.0 / $cy]
    set yf1 [expr $y2.0 / $cy]
    lassign [$b yview] yv0 yv1

    if {$yf0 < $yv0 || $yf1 > $yv1} {
        set ynew [expr $yf0 - ($yf1 - $yf0) / 2.0]
        if {$ynew < 0.0} {
            set ynew $yf0
        }
        $b yview moveto $ynew
    }
}

proc vTcl:show_wtree {} {
    global vTcl
    Window show .vTcl.tree
    vTcl:init_wtree
}

proc vTcl:clear_wtree {} {
    # Do not refresh the widget tree if it does not exist.
    if {![winfo exists .vTcl.tree]} { return }
    set b .vTcl.tree.cpd21.03
    foreach i [winfo children $b] {
        destroy $i
    }
    $b delete TEXT LINE
    $b configure -scrollregion "0 0 0 0"
}

proc vTcl:left_click_tree {cmd i b j} {
    global vTcl
    if {$::classes([vTcl:get_class $i],ignoreLeftClk)} return
    if {$vTcl(mode) == "TEST"} return

    #IF THE WIDGET DOES NOT EXIST REGISTER IT
    if {![catch {namespace children ::widgets} namespaces]} {
        if { [lsearch $namespaces ::widgets::${i}] <= -1 } {

        vTcl:widget:register_widget $i
    }
    }
    $cmd $i
    vTcl:active_widget $i
    vTcl:show_selection $b.$j $i
}

proc vTcl:right_click_tree {i X Y x y} {

    global vTcl

    if {$::classes([vTcl:get_class $i],ignoreRightClk)} return
    if {$vTcl(mode) == "TEST"} return

    vTcl:active_widget $i
    vTcl:set_mouse_coords $X $Y $x $y
    $vTcl(gui,rc_menu) post $X $Y
    grab $vTcl(gui,rc_menu)
    bind $vTcl(gui,rc_menu) <ButtonRelease> {
        grab release $vTcl(gui,rc_menu)
        $vTcl(gui,rc_menu) unpost
    }
}

# returns the number of levels to offset for a megawidget
#
# the parameter is prearranged as a list whose first
# parameter is the widget and the remainder is a list
# of offsets
#
# (for example "{.top35 .tab36} -4" will return -4
#  but         "{.top35 .tab36 ... .tab35} -4 -4" returns -8

proc vTcl:get_tree_diff {path} {
    if {[llength $path] == 1} {return ""}

    set size [llength $path]
    set diff 0
    for {set i 1} {$i < $size} {incr i} {
        set diff [incr diff [lindex $path $i]]
    }

    return $diff
}

# counts the number of children without menu items
proc vTcl:count_children {w} {
    set children [vTcl:get_children $w]

    # special menu items have .# in their path
    if {[string first .\# $children] == -1} {
        return [llength $children]
    }

    # so let's count 'em
    set count 0
    foreach child $children {
        if {![string match *.\#* $child]} {incr count}
    }

    return $count
}

proc vTcl:init_wtree {{wants_destroy_handles 1}} {
    global vTcl widgets classes
    # do not refresh the widget tree if it does not exist
    if {![winfo exists .vTcl.tree]} return
    if {![info exists vTcl(tree,width)]} { set vTcl(tree,width) 0 }

    set b .vTcl.tree.cpd21.03

    # save scrolling position first
    set vTcl(tree,last_yview) [lindex [$b yview] 0]

    vTcl:destroy_handles

    vTcl:clear_wtree
    set y 10
    set tree [vTcl:complete_widget_tree]
    foreach ii $tree {
        set ii   [split $ii \#]
        set i    [lindex $ii 0]
        set diff [vTcl:get_tree_diff $ii]
        if {$i == "."} {
            set depth 1
        } else {
            set depth [llength [split $i "."]]
        }
        if {$diff!=""} {set depth [expr $depth + $diff]}
        set depth_minus_one [expr $depth - 1]
        set x [expr $depth * 30 - 15]
        set x2 [expr $x + 40]
        set y2 [expr $y + 15]
        set j [vTcl:rename $i]
        if {$i == "."} {
            set c vTclRoot
            set t "PAGE"  ;# Rozen
        } else {
            set c [vTcl:get_class $i]
            set t {}
        }
        if {[winfo exists $b.$j]} {
            $b coords $b.$j $x $y
            incr y 30
            continue
        }

        if {$i != "." && $classes(${c},megaWidget)} {
            set childSites [lindex $classes($c,treeChildrenCmd) 1]
            if {$childSites != ""} {
                set l($depth) [llength [$childSites $i]]
            } else {
                set l($depth) 0
            }
        } else {
            set l($depth) [vTcl:count_children $i]
        }
        if {$i == "."} {
            incr l($depth) -1
        }
        if {$depth > 1} {
            if {[info exists l($depth_minus_one)]} {
                incr l($depth_minus_one) -1
            } else {
                set l($depth_minus_one) 1
            }
        }
        set cmd vTcl:show
        if {$c == "Toplevel" || $c == "vTclRoot"} { set cmd vTcl:show_top }
        set left_click_cmd  "vTcl:left_click_tree $cmd $i $b $j"
        set right_click_cmd "vTcl:right_click_tree $i %X %Y %x %y"
        button $b.$j -image [vTcl:widget:get_image $i] -command $left_click_cmd
        bind $b.$j <ButtonRelease-3> $right_click_cmd
        vTcl:set_balloon $b.$j $i
        $b create window $x $y -window $b.$j -anchor nw -tags $b.$j
        if {[lempty $t]} { set t [vTcl:widget:get_tree_label $i] }
        set t [$b create text $x2 $y2 -text $t -anchor w -font $vTcl(pr,font_dft) \
            -tags "TEXT TEXT$b.$j" \
            -fill $vTcl(pr,fgcolor)]
        $b bind TEXT$b.$j <ButtonPress-1> $left_click_cmd
        $b bind TEXT$b.$j <ButtonRelease-3> $right_click_cmd
        set size [lindex [$b bbox $t] 2]
        if {$size > $vTcl(tree,width)} { set vTcl(tree,width) $size }

        set d2 $depth_minus_one
set fill $vTcl(pr,fgcolor)
        for {set k 1} {$k <= $d2} {incr k} {
            if {![info exists l($k)]} {set l($k) 1}
            if {$depth > 1} {
                set xx2 [expr $k * 30 + 15]
                set xx1 [expr $k * 30]
                set yy1 [expr $y + 30]
                set yy2 [expr $y + 30 - 15]
                if {$k == $d2} {
                    if {$l($k) > 0} {
                        $b create line $xx1 $y $xx1 $yy1 -tags LINE \
                            -fill $fill
                        $b create line $xx1 $yy2 $xx2 $yy2  -tags LINE \
                            -fill $fill
                    } else {
                        $b create line $xx1 $y $xx1 $yy2 -tags LINE \
                            -fill $fill
                        $b create line $xx1 $yy2 $xx2 $yy2 -tags LINE \
                            -fill $fill
                    }
                } elseif {$l($k) > 0} {
                    $b create line $xx1 $y $xx1 $yy1 -tags LINE \
                        -fill $fill
                }
            }
        }

        incr y 30
    }
    $b configure -scrollregion "0 0 [expr $vTcl(tree,width) + 30] $y"

    if {!$wants_destroy_handles} {
        vTcl:create_handles $vTcl(w,widget)
        vTcl:place_handles $vTcl(w,widget)
        vTcl:show_selection_in_tree $vTcl(w,widget)
    }

    # Restore scrolling position
    $b yview moveto $vTcl(tree,last_yview)
}

proc vTclWindow.vTcl.tree {args} {
    global vTcl
    set base .vTcl.tree
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm withdraw $base
    wm focusmodel $base passive
    wm geometry $base 296x243+75+142
    wm maxsize $base 1137 870
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Widget Tree"

    frame $base.frameTop
    vTcl:toolbar_button $base.frameTop.buttonRefresh \
        -image [vTcl:image:get_image "refresh.gif"] \
        -command vTcl:init_wtree
    ::vTcl::OkButton $base.frameTop.buttonClose -command "Window hide $base"
    # One needs lib_bwidget to get the scrolled window below. Rozen
    ScrolledWindow $base.cpd21
    canvas $base.cpd21.03 -highlightthickness 0 \
       -background $vTcl(pr,bgcolor) \
       -borderwidth 0 \
         -closeenough 1.0 -relief flat
      #-background #ffffff -borderwidth 0 -closeenough 1.0 -relief flat
    $base.cpd21 setwidget $base.cpd21.03

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.frameTop \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.frameTop.buttonRefresh \
        -in $base.frameTop -anchor center -expand 0 -fill none -side left
    pack $base.frameTop.buttonClose \
        -in $base.frameTop -anchor center -expand 0 -fill none -side right
    pack $base.cpd21 \
        -in $base -anchor center -expand 1 -fill both -side top
    #pack $base.cpd21.03  ;# Rozen  BWidget

    ttk::style configure PyConsole.TSizegrip \
        -background $vTcl(pr,bgcolor) ;# 11/22/12
    #grid [ttk::sizegrip $base.cpd21.sz -style "PyConsole.TSizegrip"] \
        -column 999 -row 999 -sticky se
    #pack [ttk::sizegrip $base.cpd21.sz -style "PyConsole.TSizegrip"] \
        -side right -anchor se
    #place [ttk::sizegrip $base.sz -style PyConsole.TSizegrip] \
        -in $base -relx 1.0 -rely 1.0 -anchor se

    vTcl:set_balloon $base.frameTop.buttonRefresh "Refresh the widget tree"
    vTcl:set_balloon $base.frameTop.buttonClose   "Close"

    catch {wm geometry .vTcl.tree $vTcl(geometry,.vTcl.tree)}
    vTcl:init_wtree
    vTcl:setup_vTcl:bind $base
    vTcl:BindHelp $base WidgetTree

    wm deiconify $base
}
