##############################################################################
# $Id: edit.tcl,v 1.28 2002/10/29 05:59:48 cgavin Exp $
#
# edit.tcl - procedures used in cut, copy, and paste
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

proc vTcl:entry_or_text {w} {
    if {[lempty $w] || ![string match .vTcl* $w]} { return 0 }
    set c [vTcl:get_class $w]
    if {[vTcl:streq $c "Text"] || [vTcl:streq $c "Entry"]} { return 1 }
    return 0
}

proc vTcl:copy {{w ""}} {
    # Cut/copy/paste handled by text widget only
    global vTcl
    if {[vTcl:entry_or_text $w]} { return }
    # # Want to be sure that the set_sash list we use will be a fresh one.
    # if {[info exists vTcl(set_sash)]} { unset vTcl(set_sash)}
    set vTcl(copy) 1
    eval [vTcl::compounds::createCompound $::vTcl(w,widget) clipboard scrap]
    set vTcl(copy) 0
}

proc vTcl:cut {{w ""}} {
    # Cut/copy/paste handled by text widget only
    if {[vTcl:entry_or_text $w]} { return }

    global vTcl
    if { $vTcl(w,widget) == "." } { return }

    vTcl:copy
    vTcl:delete $w
}

proc vTcl:delete {recipient {w ""}} {
    # Cut/copy/paste handled by text widget only
    if {[vTcl:entry_or_text $recipient]} { return }

    global vTcl classes

    if {$w == ""} {
        set w $vTcl(w,widget)
    }

    if {[lempty $w]} { return }
    if {[vTcl:streq $w "."]} { return }

    set class [winfo class $w]

    if {[vTcl:streq $class "Toplevel"] && ![lempty [vTcl:get_children $w]]} {
        set result [::vTcl::MessageBox -type yesno \
            -title "Visual Tcl" \
            -message "Are you sure you want to delete top-level window $w ?"]

        if {$result == "no"} { return 0 }
    }

    vTcl:destroy_handles

    set top [winfo toplevel $w]
    # list widget tree, without widget itself (which comes first in the list)
    set children [lrange [vTcl:complete_widget_tree $w 0] 1 end]
    set parent [winfo parent $w]

    set buffer [vTcl::compounds::createCompound $w temp scrap]
    set do ""
    set destroy_cmd "destroy"
    foreach child $children {
        append do "vTcl:unset_alias $child; "
        append do "::vTcl::notify::publish delete_widget $child; "
    }
    if {$classes($class,deleteCmd) != ""} {
        set destroy_cmd $classes($class,deleteCmd)
    }
    append do "vTcl:unset_alias $w; "
    append do "::vTcl::notify::publish delete_widget $w; "
    append do "vTcl:setup_unbind_widget $w; "
    append do "$destroy_cmd $w; "
    append do "set _cmds \[info commands $w.*\]; "
    append do {foreach _cmd $_cmds {catch {rename $_cmd ""}}}
    set opts ""
    set mgr [winfo manager $w]
    if {$mgr != "wm" && $mgr != "canvas"} {
        set opts [[winfo manager $w] info $w]
    }
    set undo "$buffer; ::vTcl::compounds::insertCompoundDirect $w temp scrap $vTcl(w,def_mgr) [list $opts]; "
    append undo "::vTcl::compounds::deleteCompound temp scrap; "
    append undo "vTcl:init_wtree; vTcl:select_widget $w; vTcl:active_widget $w"
    vTcl:push_action $do $undo

    ## Destroy the widget namespace, as well as the namespaces of
    ## all it's subwidgets
    set namespaces [vTcl:namespace_tree ::widgets]
    foreach namespace $namespaces {
        if {[string match ::widgets::$w* $namespace]} {
            catch {namespace delete $namespace} error
        }
    }

    ## If it's a toplevel window, remove it from the tops list.
    if {$class == "Toplevel"} {
        if {[info procs vTclWindow$w] != ""} {
            rename vTclWindow$w {}
        }
        set vTcl(newtops) 1   ;# Rozen 12/14/12
    }

    if {![info exists vTcl(widgets,$top)]} { set vTcl(widgets,$top) {} }
    ## Activate the widget created before this one in the widget order.
    set s [lsearch $vTcl(widgets,$top) $w]

    ## Remove the window and all its children from the widget order.
    eval lremove vTcl(widgets,$top) $w $children

    if {$s > 0} {
        set n [lindex $vTcl(widgets,$top) [expr $s - 1]]
    } else {
        set n [lindex $vTcl(widgets,$top) end]
    }

    if {[lempty $vTcl(widgets,$top)] || ![winfo exists $n]} { set n $parent }

    # automatically refresh widget tree after delete operation

    after idle {vTcl:init_wtree}

    if {[vTcl:streq $n "."]} {
        vTcl:prop:clear
        ::widgets_bindings::init_ui
        return
    }

    if {[winfo exists $n]} { vTcl:active_widget $n }
}

proc vTcl:paste {{fromMouse ""} {w ""}} {
    # Cut/copy/paste handled by text widget only
    if {[vTcl:entry_or_text $w]} { return }

    global vTcl

    if {[lempty [vTcl::compounds::enumerateCompounds clipboard]]} {
        return
    }

    # I created the two variables below to retain the x and y of the
    # spot where I want to paste the stuff.
    set vTcl(paste,x) 0
    set vTcl(paste,y) 0
    set script [bind vTcl(b) <Button-1>]

    # I want to wait until the user selects a paste point.
    bind vTcl(b) <Button-1> \
        "set vTcl(paste,x) %x
         set vTcl(paste,y) %y"
    vwait vTcl(paste,x)
    bind vTcl(b) <Button-1> $script


    set mgr $vTcl(w,def_mgr)
    set opts {}
    # The if block below is bad because vTcl(mouse,x) and
    # vTcl(mouse,y) don't seem to be set anywhere, hense my use if the
    # two x and y variables from above.

    if {$fromMouse == "-mouse" && $mgr == "place"} {
         set opts "-x $vTcl(paste,x) -y $vTcl(paste,y)"
    } elseif {$mgr == "place"} {
         set opts "-x 0 -y 0"
    }

    if {[vTcl::compounds::getClass clipboard scrap] == "Toplevel"} {
        set mgr "wm"
        set opts ""
    }

    vTcl::compounds::autoPlaceCompound clipboard scrap $mgr $opts
}

namespace eval ::vTcl::findReplace {
    variable base   .vTcl.find
    variable txtbox ""
    variable count  0
    variable changeCmd  ""

    variable case   1
    variable wild   0
    variable regexp 0
    variable dir    down

    variable index  0.0
    variable selFirst   0.0
    variable selLast    0.0
    variable origInd    0.0
}

proc ::vTcl::findReplace::window {{newBase ""}} {
    variable base

    if {[llength $newBase] > 0} { set base $newBase }
    if {[winfo exists $base]} {
    wm deiconify $base
    $base.fra22.findEnt select range 0 end
    focus $base.fra22.findEnt
    return
    }

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel -cursor {}
    wm focusmodel $base passive
    wm maxsize $base 1028 753
    wm minsize $base 104 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Find and Replace"

    frame $base.fra22
    label $base.fra22.labelFindWhat \
        -pady 1 -text {Find what:} -underline 2
    label $base.fra22.labelReplaceWith \
        -pady 1 -text {Replace with:} -underline 1
    entry $base.fra22.findEnt -width 40 -background white
    entry $base.fra22.replaceEnt -width 40 -background white
    button $base.findBut \
        -padx 3m -pady 1 -text {Find Next} \
        -underline 0 -command ::vTcl::findReplace::find
    button $base.cancelBut \
        -padx 3m -pady 1 -text Cancel -underline 0 \
        -command ::vTcl::findReplace::cancel
    button $base.replaceBut \
        -padx 3m -pady 1 -text Replace -underline 0 \
        -command ::vTcl::findReplace::replace
    button $base.replaceAllBut \
        -padx 3m -pady 1 -text {Replace All} -underline 8 \
        -command ::vTcl::findReplace::replaceAll
    frame $base.bottomFrame
    frame $base.bottomFrame.frameDirection \
        -borderwidth 2
    frame $base.bottomFrame.frameDirection.frameUpDown \
        -relief groove -borderwidth 2
    radiobutton $base.bottomFrame.frameDirection.frameUpDown.upRadio \
        -pady 0 -text Up -underline 0 -value up \
        -variable ::vTcl::findReplace::dir
    radiobutton $base.bottomFrame.frameDirection.frameUpDown.downRadio \
        -pady 0 -text Down -underline 0 -value down \
        -variable ::vTcl::findReplace::dir
    frame $base.bottomFrame.frameDirection.frameUpDown.frameSpacing \
        -height 10
    label $base.bottomFrame.frameDirection.labelDirection \
        -text Direction
    frame $base.bottomFrame.frameOptions
    checkbutton $base.bottomFrame.frameOptions.caseCheck \
        -anchor w -pady 0 -text {Match case} -underline 0  \
        -variable ::vTcl::findReplace::case
    checkbutton $base.bottomFrame.frameOptions.wildCheck \
        -anchor w -pady 0 -text {Use wildcards} -underline 4 \
        -variable ::vTcl::findReplace::wild
    checkbutton $base.bottomFrame.frameOptions.regexpCheck \
        -anchor w -pady 0 -text {Regular expression} -underline 2 \
        -variable ::vTcl::findReplace::regexp

    focus $base.fra22.findEnt

    bind $base <Key-Escape> "::vTcl::findReplace::cancel"

    bind $base.fra22.findEnt <Key-Return> "::vTcl::findReplace::find"
    bind $base.fra22.replaceEnt <Key-Return> "::vTcl::findReplace::replace"

    bind $base <Alt-f> "focus $base.fra22.findEnt"
    bind $base <Alt-e> "focus $base.fra22.replaceEnt"
    bind $base <Alt-n> "$base.findBut invoke"
    bind $base <Alt-c> "$base.cancelBut invoke"
    bind $base <Alt-r> "$base.replaceBut invoke"
    bind $base <Alt-a> "$base.replaceAllBut invoke"
    bind $base <Alt-m> "$base.caseCheck invoke"
    bind $base <Alt-w> "$base.wildCheck invoke"
    bind $base <Alt-g> "$base.regexpCheck invoke"
    bind $base <Alt-u> "$base.fra22.upRadio invoke"
    bind $base <Alt-d> "$base.fra22.downRadio invoke"

    ###################
    # SETTING GEOMETRY
    ###################
    grid columnconf $base 0 -weight 1
    grid rowconf $base 4 -weight 1
    grid $base.fra22 \
        -in $base -column 0 -row 0 -columnspan 1 -rowspan 4 -pady 5 \
        -sticky nesw
    grid columnconf $base.fra22 1 -weight 1
    grid rowconf $base.fra22 0 -weight 1
    grid rowconf $base.fra22 1 -weight 1
    grid $base.fra22.labelFindWhat \
        -in $base.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nw
    grid $base.fra22.labelReplaceWith \
        -in $base.fra22 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky nw
    grid $base.fra22.findEnt \
        -in $base.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 3 \
        -sticky new
    grid $base.fra22.replaceEnt \
        -in $base.fra22 -column 1 -row 1 -columnspan 1 -rowspan 1 -padx 3 \
        -sticky new
    grid $base.findBut \
        -in $base -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 3 -pady 2 \
        -sticky new
    grid $base.cancelBut \
        -in $base -column 1 -row 1 -columnspan 1 -rowspan 1 -padx 3 -pady 2 \
        -sticky new
    grid $base.replaceBut \
        -in $base -column 1 -row 2 -columnspan 1 -rowspan 1 -padx 3 -pady 2 \
        -sticky new
    grid $base.replaceAllBut \
        -in $base -column 1 -row 3 -columnspan 1 -rowspan 1 -padx 3 -pady 2 \
        -sticky new
    grid $base.bottomFrame \
        -in $base -column 0 -row 4 -columnspan 1 -rowspan 1 -sticky nesw
    grid columnconf $base.bottomFrame 0 -weight 1
    grid columnconf $base.bottomFrame 1 -weight 1
    grid rowconf $base.bottomFrame 0 -weight 1
    grid $base.bottomFrame.frameDirection \
        -in $base.bottomFrame -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky new
    grid columnconf $base.bottomFrame.frameDirection 0 -weight 1
    grid rowconf $base.bottomFrame.frameDirection 0 -weight 1
    grid $base.bottomFrame.frameDirection.frameUpDown \
        -in $base.bottomFrame.frameDirection -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -pady 5 -sticky nesw
    grid columnconf $base.bottomFrame.frameDirection.frameUpDown 0 -weight 1
    grid $base.bottomFrame.frameDirection.frameUpDown.upRadio \
        -in $base.bottomFrame.frameDirection.frameUpDown -column 0 -row 1 \
        -columnspan 1 -rowspan 1 -sticky w
    grid $base.bottomFrame.frameDirection.frameUpDown.downRadio \
        -in $base.bottomFrame.frameDirection.frameUpDown -column 0 -row 2 \
        -columnspan 1 -rowspan 1 -sticky w
    grid $base.bottomFrame.frameDirection.frameUpDown.frameSpacing \
        -in $base.bottomFrame.frameDirection.frameUpDown -column 0 -row 0 \
        -columnspan 1 -rowspan 1
    place $base.bottomFrame.frameDirection.labelDirection \
        -x 10 -y 0 -anchor nw -bordermode ignore
    grid $base.bottomFrame.frameOptions \
        -in $base.bottomFrame -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky new
    grid columnconf $base.bottomFrame.frameOptions 0 -weight 1
    grid $base.bottomFrame.frameOptions.caseCheck \
        -in $base.bottomFrame.frameOptions -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $base.bottomFrame.frameOptions.wildCheck \
        -in $base.bottomFrame.frameOptions -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $base.bottomFrame.frameOptions.regexpCheck \
        -in $base.bottomFrame.frameOptions -column 0 -row 2 -columnspan 1 \
        -rowspan 1 -sticky ew
}

proc ::vTcl::findReplace::show {textWidget changeCmdParam} {
    variable base
    variable txtbox  $textWidget
    variable index   0.0
    variable origInd [$txtbox index current]
    variable changeCmd

    set changeCmd $changeCmdParam

    ## Bind the F3 key so the user can continue to find the next entry.
    bind $txtbox <Key-F3> "::vTcl::findReplace::find"

    window
}

proc ::vTcl::findReplace::find {{replace 0}} {
    variable base
    variable txtbox
    variable dir
    variable count
    variable index
    variable case
    variable wild
    variable regexp
    variable selFirst
    variable selLast

    if {!$case}  { lappend switches -nocase }
    if {!$wild}  { lappend switches -exact  }
    if {$regexp} { lappend switches -regexp }

    set up 0
    set stop end
    set start top
    if {[string compare $dir "up"] == 0 } {
    set up 1
    lappend switches -backward
    set stop 0.0
    set start bottom
    }

    lappend switches -count ::vTcl::findReplace::count --

    set text [$base.fra22.findEnt get]
    if {[llength $text] == 0} { return }

    set i [eval $txtbox search $switches [list $text] $index $stop]
    if {[llength $i] == 0} {
    if {!$replace} {
        set x [::vTcl::MessageBox -title "No match" -parent $base \
        -type yesno \
        -message "   Cannot find \"$text\"\nSearch again from the $start?"]
        if {[string compare $x "yes"] == 0} {
        set index 0.0
        if {$up} { set index end }
        ::vTcl::findReplace::find
        }
    }
    return -1
    }


    set selFirst $i
    set selLast [$txtbox index "$i + $count chars"]
    set index $selLast
    if {$up} { set index $selFirst }

    $txtbox tag remove sel 0.0 end
    $txtbox tag add sel $i "$i + $count chars"
    $txtbox see $i
    focus $txtbox

    return $i
}

proc ::vTcl::findReplace::notifyChange {} {
    variable changeCmd

    ## the buffer has changed, notify
    if {$changeCmd != ""} {
        uplevel #0 $changeCmd
    }
}

proc ::vTcl::findReplace::replace {} {
    variable base
    variable txtbox
    variable index
    variable dir
    variable selFirst
    variable selLast
    variable origInd
    variable changeCmd

    set text [$base.fra22.replaceEnt get]

    while {[::vTcl::findReplace::find 1] > -1} {
    set ln [lindex [split $selFirst .] 0]
    $txtbox see $selFirst
    set x [::vTcl::MessageBox -title "Match found" -parent $base \
        -type yesnocancel \
           -message "Match found on line $ln\nReplace this instance?" \
               -icon question]

    if {$x != "yes"} { continue }

    $txtbox delete $selFirst $selLast
    $txtbox insert $selFirst $text

      ## buffer has changed
      notifyChange

      ## advances the current index to avoid recursively replacing the
      ## same pattern
      set index [$txtbox index "$index + [llength $text] chars"]
    }

    set index 0.0
    set start top
    if {[string compare $dir "up"]} {
    set index end
    set start bottom
    }

    set text [$base.fra22.findEnt get]
    set x [::vTcl::MessageBox -title "No match found" -parent $base \
    -type yesno \
    -message "   Cannot find \"$text\"\nSearch again from the $start?"]

    if {[vTcl:streq $x "yes"]} { ::vTcl::findReplace::replace }

    $txtbox tag remove sel 0.0 end
    $txtbox see $origInd
    focus $txtbox
}

proc ::vTcl::findReplace::replaceAll {} {
    variable base
    variable txtbox
    variable dir
    variable index
    variable selFirst
    variable selLast
    variable origInd

    set text [$base.fra22.replaceEnt get]

    while {[::vTcl::findReplace::find 1] > -1} {
    $txtbox delete $selFirst $selLast
    $txtbox insert $selFirst $text

      ## buffer has changed
      notifyChange

      ## advances the current index to avoid recursively replacing the
      ## same pattern
      set index [$txtbox index "$index + [llength $text] chars"]
    }

    set index 0.0
    if {[string compare $dir "up"] == 0 } { set index end }

    $txtbox tag remove sel 0.0 end
    $txtbox see $origInd
    focus $txtbox
}

proc ::vTcl::findReplace::cancel {} {
    variable base
    variable txtbox

    wm withdraw $base
    focus $txtbox
}





