##############################################################################
# $Id: proc.tcl,v 1.36 2005/11/11 07:42:44 kenparkerjr Exp $
#
# proc.tcl - procedures for manipulating proctions and the proction browser
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

proc vTcl:delete_proc {name} {
    global vTcl
    set result [::vTcl::MessageBox -type yesno \
        -title "PAGE" \
        -message "Are you sure you want to delete procedure $name ?"]

    if {$result == "no"} {
        return
    }

    if {$name != ""} {
        rename $name ""
        vTcl:list delete "{$name}" vTcl(procs)
        vTcl:update_proc_list
    }
}

proc vTcl:find_new_procs {} {
    global vTcl
    return [vTcl:diff_list $vTcl(start,procs) [info procs]]
}

proc vTcl:proc:get_args { name } {
    set args {}
    if {$name != ""} {
        foreach j [info args $name] {
            if {[info default $name $j def]} {
                lappend args [list $j $def]
            } else {
                lappend args $j
            }
        }
    }
    return $args
}

proc vTcl:show_proc {name} {

    # Rozen. Since my user will want to define function for use in his
    # python program there may be name clashes with Tcl/Tk procs and
    # commands that will screw up vtcl. For instance, the user may
    # want to define a function "open" using this mechanism and, by
    # George, that will redifine the Tcl builtin open and boy vtcl is
    # at that instance blown out of the water. So I am seeding the
    # function definition window with a name py:xxx and a minimal body
    # for the function.  All the user has to do is replace the xxx
    # which occurs in the header and within the body with the name he
    # wants and he is golden.

    global vTcl
    if {$name != ""} {
        set args [vTcl:proc:get_args $name]
        set body [string trim [info body $name] "\n"]
        set win .vTcl.proc_[vTcl:rename $name]
        Window show .vTcl.proc $win $name $args $body
    } else {
        # Rozen. I want to put in the window a python template.
        #Window show .vTcl.proc .vTcl.proc_new "" "" "global widget\n\n"
        Window show .vTcl.proc .vTcl.proc_new "py:xxx" "" \
            "def xxx() :\n    pass"
    }
}

proc vTcl:proclist:show {{on ""}} {
    global vTcl
    if {$on == "flip"} { set on [expr - $vTcl(pr,show_func)] }
    if {$on == ""}     { set on $vTcl(pr,show_func) }
    if {$on == 1} {
        Window show $vTcl(gui,proclist)
        vTcl:update_proc_list
    } else {
        Window hide $vTcl(gui,proclist)
    }
    # set vTcl(pr,show_func) $on ;# Rozen. Once on stays on. Don't like.
}

proc vTcl:update_proc {base {close 1}} {
    global vTcl
    set vTcl(pr,geom_proc) [wm geometry $base]
    set name [$base.f2.f8.procname get]
    set args [$base.f2.f9.args get]
    set body [string trim [$base.f4.text get 0.0 end] "\n"]

#Don't submit if there is any syntax errors
    if { [info complete $body] == 0 } {

          ::vTcl::MessageBox -type ok -icon error \
           -message "Syntax Error: Please check you're code and try again." \
           -title "Syntax Error"
          return
    }


    if {[lempty $name]} { return }
    if {[regexp (.*):: $name matchAll context]} {

    # create new namespace if necessary
    namespace eval ${context} {}
    }

    ## verify that proc really changed before marking project as changed
    set old_args ""
    set old_body ""
    if {[info proc $name] != ""} {
        ## proc existed before
        set old_args [info args $name]
        set old_body [string trim [info body $name] "\n"]
    }
    proc $name $args \n$body\n

    vTcl:list add "{$name}" vTcl(procs)
    if {$close} {
        destroy $base
    } else {
        ::vTcl::proc::edit_reset $base
    }
    vTcl:update_proc_list $name

    ## body or argument have changed?
    if {$old_args != $args || $old_body != $body} {
        ::vTcl::change
    }
}

proc vTcl:update_proc_list {{name {}}} {
    global vTcl
    if {![winfo exists $vTcl(gui,proclist)]} { return }
    $vTcl(gui,proclist).f2.list delete 0 end
    foreach i [lsort $vTcl(procs)] {
    if {![vTcl:valid_procname $i]} { continue }
    if {[info body $i] != "" || $i == "main" || $i == "init"} {
        $vTcl(gui,proclist).f2.list insert end $i
    }
    }
    if {$name != ""} {
        set plist [$vTcl(gui,proclist).f2.list get 0 end]
        set pindx [lsearch $plist $name]
        if {$pindx >= 0} {
            $vTcl(gui,proclist).f2.list selection set $pindx
            $vTcl(gui,proclist).f2.list see $pindx
        }
    }
}

# kc: during File->Open or File->Source, determine if we should keep
# record of proc $name.  Used to exclude tix procs that get defined as a
# byproduct of creating tix widgets.
#
# returns:
#   1 if should be ignored, 0 if should be kept
#
proc vTcl:ignore_procname_when_sourcing {name} {
    global vTcl
    foreach ignore $vTcl(proc,ignore) {
        if {[string match $ignore $name]} {
            return 1
        }
    }
    return 0
}

# kc: during File->Save, determine if proc $name should be saved.  Used
# to prevent global tk and tix functions from being saved.
#
# returns:
#   1 if should be ignored, 0 if saved
#
proc vTcl:ignore_procname_when_saving {name} {
    global vTcl
    set len [expr [string length $vTcl(winname)] - 1]
    if {[vTcl:ignore_procname_when_sourcing $name] \
            || ([string range $name 0 $len] == "$vTcl(winname)")} {
        return 1
    } else {
        return 0
    }
}

# kc: for backward compatibility
proc vTcl:valid_procname {name} {

    # include namespace procedures
    if {[string match *::* $name]} {
    return 1
    }

    return [expr ![vTcl:ignore_procname_when_saving $name]]
}

proc vTclWindow.vTcl.proclist {args} {
    global vTcl
    set base .vTcl.proclist
    if { [winfo exists $base] } { wm deiconify $base; return }
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm withdraw $vTcl(gui,proclist)
    wm focusmodel $base passive
    wm geometry $base 300x500+48+237
    wm maxsize $base 1137 870
    wm minsize $base 200 100
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Function List"
    wm protocol $base WM_DELETE_WINDOW {vTcl:proclist:show 0}
    frame $base.frame7 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.frame7 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    vTcl:toolbar_button $base.frame7.button8 \
        -command {vTcl:show_proc ""} \
        -image [vTcl:image:get_image add.gif]
    pack $base.frame7.button8 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:set_balloon $base.frame7.button8 "Add a new procedure"
    vTcl:toolbar_button $base.frame7.button9 \
        -command {
            set vTcl(x) [.vTcl.proclist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:show_proc [.vTcl.proclist.f2.list get $vTcl(x)]
            }
        } \
        -image [vTcl:image:get_image open.gif]
    pack $base.frame7.button9 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:set_balloon $base.frame7.button9 "Edit selected procedure"
    ::vTcl::CancelButton $base.frame7.button10 -command {
    set vTcl(x) [.vTcl.proclist.f2.list curselection]
    if {$vTcl(x) != ""} {
        vTcl:delete_proc [.vTcl.proclist.f2.list get $vTcl(x)]
    }
    }
    pack $base.frame7.button10 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:set_balloon $base.frame7.button10 "Remove selected procedure"
    ::vTcl::OkButton $base.frame7.button11 -command "Window hide $base"
    pack $base.frame7.button11 \
        -expand 0 -side right
    vTcl:set_balloon $base.frame7.button11 "Close"

    ScrolledWindow $base.f2
    pack $base.f2 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    listbox $base.f2.list \
        -yscrollcommand {.vTcl.proclist.f2.sb4  set}
    bind $base.f2.list <Double-Button-1> {
        set vTcl(x) [.vTcl.proclist.f2.list curselection]
        if {$vTcl(x) != ""} {
            vTcl:show_proc [.vTcl.proclist.f2.list get $vTcl(x)]
        }
    }
    #pack $base.f2.list \
    #    -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
    #    -side left    Rozen 7/19  pm
#pack [ttk::sizegrip $base.f2.sz -style "PyConsole.TSizegrip"] -side right -anchor se
#grid [ttk::sizegrip $base.f2.sz] -column 999 -row 999 -sticky se
    $base.f2 setwidget $base.f2.list

    vTcl:setup_vTcl:bind $vTcl(gui,proclist)
    catch {wm geometry $vTcl(gui,proclist) $vTcl(geometry,$vTcl(gui,proclist))}
    update idletasks
    wm deiconify $vTcl(gui,proclist)

    vTcl:BindHelp $vTcl(gui,proclist) FunctionList
}

proc vTclWindow.vTcl.proc {args} {
    global vTcl
    set base  [lindex $args 0]
    set title [lindex $args 1]
    set iproc [lindex $args 1]
    set iargs [lindex $args 2]
    set ibody [lindex $args 3]
    if { [winfo exists $base] } { wm deiconify $base; return }
    set vTcl(proc,[lindex $args 0],chg) 0
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base $vTcl(pr,geom_proc)
    wm maxsize $base 1137 870
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "$title"
    bind $base <Key-Escape> "vTcl:update_proc $base"
    frame $base.f2 -height 30 -width 30
    pack $base.f2 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 3 -pady 3 \
        -side top
    frame $base.f2.f8 -height 30 -width 30 -relief flat
    pack $base.f2.f8 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    label $base.f2.f8.label10 -anchor w  \
        -relief flat -text Function -width 9
    pack $base.f2.f8.label10 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 0 \
        -side left
    vTcl:entry $base.f2.f8.procname \
        -cursor {}  \
        -highlightthickness 0
    pack $base.f2.f8.procname \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    frame $base.f2.f9 \
        -height 30 -width 30 -relief flat
    pack $base.f2.f9 \
        -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    label $base.f2.f9.label12 \
        -anchor w  \
        -relief flat -text Arguments -width 9
    pack $base.f2.f9.label12 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 0 \
        -side left
    vTcl:entry $base.f2.f9.args \
        -cursor {}  \
        -highlightthickness 0
    pack $base.f2.f9.args \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    frame $base.f3 \
        -borderwidth 2 -relief flat
    pack $base.f3 \
        -anchor center -expand 0 -fill x -side top

    # toolbar
    frame $base.f3.toolbar
    pack $base.f3.toolbar -side top -anchor nw -fill x

    set butInsert [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit inswidg.gif] ] \
        -command "vTcl:insert_widget_in_text $base.f4.text" ]
    pack configure $butInsert -side left
    vTcl:set_balloon $butInsert "Insert selected widget command"

    set last [vTcl:formCompound:add $base.f3.toolbar frame -width 5]
    pack configure $last -side left

    set last [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit copy.gif] ] \
        -command "tk_textCopy $base.f4.text"]
    pack configure $last -side left
    vTcl:set_balloon $last "Copy selected text to clipboard"

    set last [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit cut.gif] ]  \
        -command "tk_textCut $base.f4.text"]
    pack configure $last -side left
    vTcl:set_balloon $last "Cut selected text"

    set last [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit paste.gif] ]  \
        -command "tk_textPaste $base.f4.text"]
    pack configure $last -side left
    vTcl:set_balloon $last "Paste text from clipboard"

    set last [vTcl:formCompound:add $base.f3.toolbar frame -width 5]
    pack configure $last -side left

    set butFind [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit search.gif] ] \
    -command "::vTcl::findReplace::show $base.f4.text \"vTcl::proc::edit_change $base Space\""]
    pack configure $butFind -side left
    vTcl:set_balloon $butFind "Find/Replace"

    set butOK [vTcl:formCompound:add $base.f3.toolbar ::vTcl::OkButton \
        -command "vTcl:update_proc $base"]
    pack configure $butOK -side right
    vTcl:set_balloon $butOK "Save changes"

    ScrolledWindow $base.f4 -auto vertical
    text $base.f4.text \
        -background white -borderwidth 0 -height 3 -wrap none -relief flat

    $base.f4 setwidget $base.f4.text

    pack $base.f4 -in $base -anchor center -expand 1 -fill both -side top
    pack $base.f4.text

    bind $base.f4.text <KeyPress> "+::vTcl::proc::edit_change $base %K"
    bind $base.f4.text <Control-Key-i> "$butInsert invoke"
    bind $base.f4.text <Control-Key-f> "$butFind invoke"
    bind $base <Destroy> {
    if {[winfo exists .vTcl.find]} { destroy .vTcl.find }
    }
    wm protocol $base WM_DELETE_WINDOW "vTcl:update_proc $base"

    set pname $base.f2.f8.procname
    set pargs $base.f2.f9.args
    set pbody $base.f4.text
    $pname delete 0 end
    $pargs delete 0 end
    $pbody delete 0.0 end
    $pname insert end $iproc
    $pargs insert end $iargs
    $pbody insert end $ibody
    $pbody mark set insert 0.0
    if {$iproc == ""} {
        focus $pname
        $butOK configure -state disabled
    } else {
        focus $pbody
    }

    # don't allow empty procedure name
    bind $pname <KeyRelease> "\
        if \{\[$pname get\] == \"\"\} \{ \
              $butOK configure -state disabled \
        \} else \{ \
              $butOK configure -state normal \
        \}"

    vTcl:syntax_color $base.f4.text

    ## be notified when we switch between edit and test mode
    ::vTcl::notify::subscribe edit_mode $base ::vTcl::proc::edit_mode
    ::vTcl::notify::subscribe test_mode $base ::vTcl::proc::test_mode

    ## be notified when the project has been closed... proc window will be destroyed
    ::vTcl::notify::subscribe closed_project $base ::vTcl::proc::closed_project

    bind $base <Destroy> "
        grab release $base
        ::vTcl::notify::unsubscribe edit_mode $base
        ::vTcl::notify::unsubscribe test_mode $base
        ::vTcl::notify::unsubscribe closed_project $base
    "
}

namespace eval ::vTcl::proc {

    proc closed_project {base} {
        destroy $base
    }

    proc edit_mode {base args} {
    }

    proc test_mode {base args} {
        vTcl:update_proc $base 0;   # do not close the window
    }

    proc edit_reset {base} {
        global vTcl
        set vTcl(proc,$base,chg) 0
        set name [$base.f2.f8.procname get]
        wm title $base $name
    }

    proc edit_change {w k} {

        ## We don't want to mark the text as changed when we're just
        ## moving around.
        switch -- $k {
       "Up"        -
       "Down"      -
       "Right"     -
       "Left"      -
       "Prior"     -
       "Next"      -
       "Home"      -
       "End"       -
       "Insert"    -
       "Shift_L"   -
       "Shift_R"   -
       "Control_L"    -
       "Control_R"
           { return }
        }

        global vTcl
        if {!$vTcl(proc,$w,chg)} {
            wm title $w "[wm title $w]*"
        }

        set vTcl(proc,$w,chg) 1
    }

    proc add_procs {procs} {
        foreach name $procs {
            vTcl:list add "{$name}" ::vTcl(procs)
        }
        vTcl:update_proc_list
    }
}

