##############################################################################
# $Id: tops.tcl,v 1.22 2006/01/28 21:02:26 kenparkerjr Exp $
#
# tops.tcl - procedures for managing toplevel windows
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

proc vTcl:wm_take_focus {target} {
    global vTcl
    if {$vTcl(w,class) == "Toplevel"} {
        set vTcl(w,insert) $target
    }

    after idle "vTcl:place_handles \"$vTcl(w,widget)\""
}

proc vTcl:destroy_top {target} {
    global vTcl

    vTcl:active_widget $target
    vTcl:delete "" $target

    return [expr ![winfo exists $target]]
}

proc vTcl:show_top {target} {
    global vTcl
    if {[vTcl:streq $target "."]} { return }
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm deiconify $target
            vTcl:raise $target
        }
    } else {
        Window show $target
        wm deiconify $target
        vTcl:raise $target
        vTcl:widget:register_all_widgets $target
        vTcl:setup_bind_widget $target
        vTcl:update_top_list
        vTcl:init_wtree
    }
    vTcl:select_widget $target
    vTcl:destroy_handles
}

proc vTcl:hide_top {target} {
    global vTcl
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm withdraw $target
            vTcl:select_widget .
        }
    }
}

proc vTcl:update_top_list {} {
    global vTcl
    set base .vTcl.toplist
    if {[winfo exists $base]} {
        $base.f2.list delete 0 end
        set index 0
        foreach i $vTcl(tops) {
            if [catch {set n [wm title $i]}] {
                set n $i
            }
            $base.f2.list insert end $n
            set vTcl(tops,$index) $i
            incr index
        }
    }
}

# convert hidden toplevels from a 1.22 project to a 1.51 project
proc vTcl:convert_tops {} {
    global vTcl

    foreach i $vTcl(tops) {
        if {![winfo exists $i]} {
            # this is to convert 1.22 projects to 1.51
            # 1.51 hidden toplevels exist but are hidden
            # 1.2x hidden toplevels don't exist at all except
            # their proc
            vTcl:show_top $i
            vTcl:hide_top $i
        }
    }
}

# adds the _TopLevel binding tag if it is missing, so that
# the project automatically exits when all toplevels have been closed
proc vTcl:bind_tops {} {
    global vTcl

    ## do this anyway so that the latest version of the bindings
    ## will be saved into the file
    vTcl::widgets::core::toplevel::setBindings

    foreach i $vTcl(tops) {
    # convert from 1.51 to 1.6
    if {[lsearch $::vTcl(bindtags,$i) _TopLevel] == -1} {
        lappend ::vTcl(bindtags,$i) _TopLevel
    }
    }
}

proc vTcl:toplist:show {{on ""}} {
    global vTcl
    if {$on == "flip"} { set on [expr - $vTcl(pr,show_top)] }
    if {$on == ""}     { set on $vTcl(pr,show_top) }
    if {$on == 1} {
        Window show $vTcl(gui,toplist)
        vTcl:update_top_list
    } else {
        Window hide $vTcl(gui,toplist)
    }
    set vTcl(pr,show_top) $on
}

proc vTcl:toplist:show_selection {base {show show}} {
    global vTcl
    if { $vTcl(mode) == "TEST" } {
        ::vTcl::MessageBox -message "Removing Top Level is not allowed in test mode!"
        return
    }
        set vTcl(x) [$base.f2.list curselection]
        if {$vTcl(x) != ""} {
        vTcl:${show}_top $vTcl(tops,$vTcl(x))
    }
}

proc vTclWindow.vTcl.toplist {args} {
    global vTcl
    set base .vTcl.toplist
    if {[winfo exists $base]} { wm deiconify $base; return }

    toplevel $base -class vTcl
    wm withdraw $base
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 200x200+714+382
    wm maxsize $base 1137 870
    wm minsize $base 200 100
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Window List"
    wm protocol $base WM_DELETE_WINDOW {vTcl:toplist:show 0}
    bind $base <Double-Button-1> "vTcl:toplist:show_selection $base"

    frame $base.frame7 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.frame7 \
        -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    vTcl:toolbar_button $base.frame7.button8 \
        -command "vTcl:toplist:show_selection $base" \
        -padx 9 -pady 3 -image [vTcl:image:get_image show.gif]
    pack $base.frame7.button8 \
        -in $base.frame7 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    vTcl:set_balloon $base.frame7.button8 "Show toplevel window"
    vTcl:toolbar_button $base.frame7.button9 \
        -command "vTcl:toplist:show_selection $base hide" \
        -padx 9 -pady 3 -image [vTcl:image:get_image hide.gif]
    pack $base.frame7.button9 \
        -in $base.frame7 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    vTcl:set_balloon $base.frame7.button9 "Hide toplevel window"
    ::vTcl::CancelButton $base.frame7.button10 \
        -command "vTcl:toplist:show_selection $base destroy"
    pack $base.frame7.button10 \
        -in $base.frame7 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    vTcl:set_balloon $base.frame7.button10 "Delete toplevel window"
    ::vTcl::OkButton $base.frame7.button11 -command "vTcl:toplist:show 0"
    pack $base.frame7.button11 \
        -expand 0 -side right
    vTcl:set_balloon $base.frame7.button11 "Close"

    ScrolledWindow $base.f2
    pack $base.f2 \
        -in $base -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side top
    listbox $base.f2.list -exportselection 0
    $base.f2 setwidget $base.f2.list
    #pack $base.f2.list     Rozen    7/19 pm

    vTcl:setup_vTcl:bind $base
    catch {wm geometry $base $vTcl(geometry,$base)}
    update idletasks
    wm deiconify $base

    # ok, let's add a special tag to override the <KeyPress-Delete> mechanism

    # first, make sure the list gets the focus when it's clicked on
    bind $base.f2.list <ButtonPress-1> {
        focus %W
    }

    # bind all controls in the window
    foreach child [vTcl:list_widget_tree $base] {
        bindtags $child "_vTclTopDelete [bindtags $child]"
    }

    bind _vTclTopDelete <KeyPress-Delete> {
        vTcl:toplist:show_selection [winfo toplevel %W] destroy

        # stop event processing here
        break
    }

    # when the title option changes in the attributes editor, we want
    # to know about it
    ::vTcl::notify::subscribe geom_config_cmd tops ::vTcl::tops::geom_config_event
}

namespace eval ::vTcl::tops {

    proc geom_config_event {id target cmd option} {
        if {$cmd == "vTcl:wm:conf_title" && $option == "title"} {
            vTcl:update_top_list
    }
    }

    proc handleRunvisible {cmd} {
        foreach i $::vTcl(tops) {
            set var ::widgets::${i}::runvisible
            if {[info exists $var] &&
                [set $var] == 0} {
                wm $cmd $i
            }
        }
    }
    proc editMode {id args} {
        handleRunvisible deiconify
    }

    proc testMode {id args} {
        handleRunvisible withdraw
    }

    ## manages the "run visible" feature
    ::vTcl::notify::subscribe edit_mode "vtcltops" ::vTcl::tops::editMode
    ::vTcl::notify::subscribe test_mode "vtcltops" ::vTcl::tops::testMode
}


