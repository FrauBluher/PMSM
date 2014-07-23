##############################################################################
# $Id: misc.tcl,v 1.74 2005/12/05 06:51:02 kenparkerjr Exp $
#
# misc.tcl - leftover uncategorized procedures
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

proc vTcl:toolbar_button {args} {
    eval button $args
    set path [lindex $args 0]
    $path configure -relief flat -highlightthickness 0 -height 30 -width 30 \
                -border 1
    bind $path <Enter> {
    if {[%W cget -state] != "disabled"} {
        %W configure -relief raised
    }
    }
    bind $path <Leave> "%W configure -relief flat"
}

proc vTcl:toolbar_menubutton {args} {
    eval menubutton $args
    set path [lindex $args 0]
    $path configure -relief flat -highlightthickness 0 -height 30 -width 30 -bd 1

    bind $path <Enter> {
    if {[%W cget -state] != "disabled"} {
        %W configure -relief raised
    }
    }
    bind $path <Leave> "%W configure -relief flat"
    bind $path <ButtonPress-1> "%W configure -relief flat"
}

proc vTcl:toolbar_label {args} {
    eval label $args
    set path [lindex $args 0]
    $path configure -relief flat -highlightthickness 0 -height 23 -width 23
    bind $path <Enter> {
    if {[%W cget -state] != "disabled"} {
        %W configure -relief raised
    }
    }
    bind $path <Leave> "%W configure -relief flat"
}

# special button that triggers its command on ButtonRelease
proc vTcl:special_button {path args} {
    eval button $path $args
    set command [$path cget -command]
    $path configure -command {}
    bind _${path}_release <ButtonRelease-1> \
        "if \{\[$path cget -state\] != \"disabled\"\} \{uplevel
 #0 [list $command]\}"
    bindtags $path [concat [bindtags $path] _${path}_release]
}

# radiobutton that accepts a boolean value for the variable
# "on"  can be 1, yes, true
# "off" can be 0, no,  false
proc vTcl:boolean_radio {path args} {
    eval radiobutton $path $args
    set var [$path cget -variable]
    set com [$path cget -command]
    $path configure -variable "_$var" -command "set $var \$_$var; $com"

    ## configure initial value
    vTcl:boolean_radio_get $var _$var

    ## use the new variable for setting the old one
    ## good enough for now since we always use vTcl(...) here as variable
    global vTcl
    trace variable $var w "vTcl:boolean_radio_get $var _$var"
}

proc vTcl:boolean_radio_get {var old_var args} {
    upvar #0 $var vari
    upvar #0 $old_var old_vari
    set value(1)     1
    set value(yes)   1
    set value(true)  1
    set value(on)    1
    set value(0)     0
    set value(no)    0
    set value(false) 0
    set value(off)   0
    set value($)     0
    set val $vari
    set old_vari $value($val)
}

proc vTcl:portable_filename {filename} {
    set result "\[file join "
    append result "[file split $filename]"
    append result "\]"
    return $result
}
proc vTcl:portable_filename_new {filename} {
    set curr_dir [pwd]
set last [expr [string length $curr_dir] - 1]
set new [string replace $filename 0 $last "\$\[pwd\]"]
set result $new
return $result


    set result "\[file join "
    append result "[file split $filename]"
    append result "\]"
    return $result
}

proc vTcl:at {varname} {
    upvar $varname localvar
    return $localvar
}

proc vTcl:util:greatest_of {numlist} {
    set max 0
    foreach i $numlist {
        if {$i > $max} {
            set max $i
        }
    }
    return $max
}

proc vTcl:upper_first {string} {
    return [string toupper [string index $string 0]][string range $string 1 end]
}

proc vTcl:lower_first {string} {
    return [string tolower [string index $string 0]][string range $string 1 end]
}

proc vTcl:load_images {} {
    global vTcl

    foreach i {fg bg mgr_grid mgr_pack mgr_place
                rel_groove rel_ridge rel_raised rel_sunken justify
                relief border ellipses anchor fontbase fontsize fontstyle
                tconsole up down delete_tag pack_img
                ellipseslight ellipsesdark} {
        image create photo "$i" \
            -file [file join $vTcl(VTCL_HOME) images $i.gif]
    }
    foreach i {n s e w nw ne sw se c} {
        image create photo "anchor_$i" \
            -file [file join $vTcl(VTCL_HOME) images anchor_$i.ppm]
    }
    image create bitmap "file_down" \
        -file [file join $vTcl(VTCL_HOME) images down.xbm]
}

proc vTcl:list {cmd elements list} {
    upvar $list nlist
    switch $cmd {
        add {
            foreach i $elements {
                if {[lsearch -exact $nlist $i] < 0} {
                    lappend nlist $i
                }
            }
        }
        delete {
            foreach i $elements {
                set n [lsearch -exact $nlist $i]
                if {$n > -1} {
                    set nlist [lreplace $nlist $n $n]
                }
            }
        }
    }
    return $nlist
}

proc vTcl:diff_list {oldlist newlist} {
    set output ""
    foreach oldent $oldlist {
        set oldar($oldent) 1
    }
    foreach newent $newlist {
        if {[info exists oldar($newent)] == 0} {
            lappend output $newent
        }
    }
    return [lsort $output]
}

proc vTcl:clean_pairs {list {indent 8}} {
    global vTcl
    set tab [string range "                " 0 [expr $indent - 1]]
    set index $indent
    set output $tab
    set last ""
    foreach i $list {
        if {$last == ""} {
            set last $i
        continue
        }
        # @@change by Christian Gavin 3/18/2000
        # special case to handle image filenames
        # 3/26/2000
        # special case to handle font keys

        set noencase 0
        if {[info exists vTcl(option,noencase,$last)]} {
            if [string match *font* $last] {
                if [string match {\[*\]} $i] { set noencase 1 }
            } else {
                if [info exists vTcl(option,noencasewhen,$last)] {
                    set noencase [$vTcl(option,noencasewhen,$last) $i]
                    # vTcl:puts "noencase :$noencase, $i"
                } else {
                    set noencase 1
                }
            }
        }

    if {$noencase} {
        if {$i == ""} {
            set i "$last {} "
        } else {
            set i "$last $i "
        }
    } else {
        switch $vTcl(pr,encase) {
           list {
          set i "$last [list $i] "
           }
           brace {
          set i "$last \{$i\} "
           }
           quote {
           set i "$last \"$i\" "
           }
       }
    }

    # @@end_change
    set last ""
    set len [string length $i]
    if { [expr $index + $len] > 78 } {
        append output "\\\n${tab}${i}"
        set index [expr $indent + $len]
    } else {
        append output "$i"
        incr index $len
    }
    }
    return $output
}

#############################
# Setting Widget Properties #
#############################
proc vTcl:bounded_incr {var delta} {
    upvar $var newvar
    set newval [expr $newvar + $delta]
    if {$newval < 0} {
        set newvar 0
    } else {
        set newvar $newval
    }
}

proc vTcl:pos_neg {num} {
    if {$num > 0} {return 1}
    if {$num < 0} {return -1}
    return 0
}

proc vTcl:widget_delta {widget x y w h} {
    global vTcl
    switch $vTcl(w,manager) {
        grid {
            vTcl:bounded_incr vTcl(w,grid,-column) [vTcl:pos_neg $x]
            vTcl:bounded_incr vTcl(w,grid,-row) [vTcl:pos_neg $y]
            vTcl:bounded_incr vTcl(w,grid,-columnspan) [vTcl:pos_neg $w]
            vTcl:bounded_incr vTcl(w,grid,-rowspan) [vTcl:pos_neg $h]
            vTcl:manager_update grid
        }
        pack {
            if {$x < 0 || $y < 0} {vTcl:pack_before $vTcl(w,widget)}
            if {$x > 0 || $y > 0} {vTcl:pack_after $vTcl(w,widget)}
        }
        place {
            set newX [expr [winfo x $widget] + $x]
            set newY [expr [winfo y $widget] + $y]
            set newW [expr [winfo width $widget] + $w]
            set newH [expr [winfo height $widget] + $h]
            set do "place $vTcl(w,widget) -x $newX -y $newY \
                -width $newW -height $newH -bordermode ignore"
            set undo [vTcl:dump_widget_quick $widget]
            vTcl:push_action $do $undo
        }
    }
    vTcl:place_handles $widget
}

proc vTcl:set_timestamp { } {
    global vTcl
    set vTcl(timestamp) [clock format [clock seconds] -format {%b %d, %Y %I:%M:%S %p}]
    return
}

##############################################################################
# OTHER PROCEDURES
##############################################################################
proc vTcl:hex {num} {
    if {$num == ""} {set num 0}
    set textnum [format "%x" $num]
    if { $num < 16 } { set textnum "0${textnum}" }
    return $textnum
}

proc vTcl:grid_snap {xy pos} {
    # Function which causes widgets to be placed on (invisible) grid
    # lines. The value returned is the podition of the grid line to
    # the left or above the mouse point.  Rozen comment.
    global vTcl
    # Rozen. Since I am only supporting "place", I think that I can
    # get rid of the next line of code.
    #if { $vTcl(w,manager) != "place" } { return $pos }
    set off [expr $pos % $vTcl(grid,$xy)]

    if { $off > 0 } {
        return [expr $pos - $off]
    } else {
        return $pos
    }
}

proc vTcl:status {{message "Status"}} {
    global vTcl
    set vTcl(status) $message
    update idletasks
}

proc vTcl:right_click {widget X Y x y} {
    global vTcl

    vTcl:set_mouse_coords $X $Y $x $y

    set parent $widget

    # megawidget ?
    if {[info exists ::widgets::${widget}::parent]} {
        set parent [set ::widgets::${widget}::parent]
    }

    vTcl:active_widget $parent
    $vTcl(gui,rc_menu) post $X $Y
    # grab $vTcl(gui,rc_menu)
    bind $vTcl(gui,rc_menu) <ButtonRelease> {
        # grab release $vTcl(gui,rc_menu)
    vTcl:set_mouse_coords %X %Y %x %y
        $vTcl(gui,rc_menu) unpost
    }
}

proc vTcl:statbar {value} {
    global vTcl
    set w [expr [winfo width [winfo parent $vTcl(gui,statbar)]] - 4]
    set h [expr [winfo height [winfo parent $vTcl(gui,statbar)]] - 4]
    set mult [expr ${w}.0 / 100.0]
    if {$value == 0} {
        place forget $vTcl(gui,statbar)
    } else {
        place $vTcl(gui,statbar) -x 1 -y 1 -width [expr $value * $mult] -height $h
    }
    update idletasks
}

proc vTcl:show_bindings {} {
    global vTcl
    if {$vTcl(w,widget) != ""} {
        Window show .vTcl.bind
        vTcl:get_bind $vTcl(w,widget)
    } else {
        ::vTcl::MessageBox -icon error -message "No widget selected!" \
            -title "Error!" -type ok
    }
}

# @@change by Christian Gavin 3/15/2000
# modif to generate widget names starting
# from long Windows 9x filenames with spaces

proc vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

# @@end_change

proc vTcl:cmp_user_menu {} {
    global vTcl
    set m $vTcl(menu,user,m)
    catch {destroy $m}
    menu $m -tearoff 0
    foreach i [lsort $vTcl(cmpd,list)] {
        $m add command -label $i -command "
            vTcl:put_compound [list $i] \$vTcl(cmpd:$i)
        "
    }
    foreach i [lsort [vTcl::compounds::enumerateCompounds user]] {
        $m add command -label [join $i] -command "
            vTcl::compounds::putCompound user $i
        "
    }
}

proc vTcl:cmp_sys_menu {} {
    global vTcl
    return  ;# Rozen  I want to get rid of this menu. Don't support compound.
    set m $vTcl(menu,system,m)
    catch {destroy $m}
    menu $m -tearoff 0
    foreach i [lsort [vTcl::compounds::enumerateCompounds system]] {
        $m add command -label [join $i] -command "
            vTcl::compounds::putCompound system $i
        "
    }
}

proc vTcl:get_children {target {include_megachildren 0}} {
    global vTcl classes

    # @@change by Christian Gavin 3/7/2000
    # mega-widgets children should not be copied
    set wdg_class [vTcl:get_class $target]
    if {[info exists classes(${wdg_class},megaWidget)]} {
        if {$classes(${wdg_class},megaWidget) && (!$include_megachildren)} {
            return ""
        }
    }

    # @@end_change

    set r ""
    set all [winfo children $target]
    set n [pack slaves $target]
    if {$n != ""} {
        foreach i $all {
            if {[lsearch -exact $n $i] < 0} {
                lappend n $i
            }
        }
    } else {
        set n $all
    }
    foreach i $n {
        if ![string match ".__*" $i] {
            lappend r $i
        }
    }
    return $r
}

proc vTcl:find_new_tops {newprocs} {
    global vTcl
    set new ""
    foreach i [concat $vTcl(procs) $newprocs] {
        if [string match $vTcl(winname).* $i] {
            set n [string range $i 10 end]
            if {$n != "."} {
                lappend new [string range $i 10 end]
            }
        }
    }
    foreach i [vTcl:list_widget_tree .] {
        if {$i != ".x" && [winfo class $i] == "Toplevel"} {
            if {[lsearch $new $i] < 0} {
                lappend new $i
            }
        }
    }
    return $new
}

proc vTcl:find_widgets_with_balloon_msg {window} {# Rozen
    # Find all widgets which have balloon messages.
    global vTcl
    set balloon_widgets ""
    #set widgets [vTcl:tix_widget_tree $window]
    # Do I have to do something about my complex widgets??? NEEDS WORK
    set widgets [vTcl:widget_tree $window]
    foreach i $widgets {
        if {[info exists vTcl($i,balloon_msg)]} {
            set m $vTcl($i,balloon_msg)
            lappend balloon_widgets $i
        }
    }
    return $balloon_widgets
}


proc vTcl:error {mesg} {
    ::vTcl::MessageBox -icon error -message $mesg -title "Error!"
}

# procedures to manage modal dialog boxes
# from "Effective Tcl/Tk Programming, by Mark Harrison, Michael McLennan"

##############################################################################
# MODAL DIALOG BOXES
##############################################################################

proc vTcl:dialog_wait {win varName {nopos 0}} {

    vTcl:dialog_safeguard $win

    if {$nopos==0} {

        set x [expr [winfo rootx .] + 50]
        set y [expr [winfo rooty .] + 50]

        wm geometry $win "+$x+$y"
        wm deiconify $win
    }

    grab set $win
    vwait $varName
    grab release $win

    wm withdraw $win
}

bind vTcl:modalDialog <ButtonPress-1> {

    wm deiconify %W
    vTcl:raise %W
}

proc vTcl:dialog_safeguard {win} {

    if {[lsearch [bindtags $win] vTcl:modalDialog] < 0} {

        bindtags $win [linsert [bindtags $win] 0 modalDialog]
    }
}
# This proc has been extensively modified to provide appropriate colorization
# for Python - Rozen.

proc vTcl:forAllMatches {w tags callback {from 1} {to -1}} {

    global vTcl
    scan [$w index end] %d numLines

    for {set i 1} {$i <= $numLines} {incr i} {
        # get the line only once
        set currentLine [$w get $i.0 $i.end]
        # special case - comment line.
        if {[string range [string trim $currentLine] 0 0] == "\#"} {
            $w mark set first $i.0
            $w mark set last "$i.end"
            $callback $w vTcl:comment
            continue
        }
        # Another special case: triple stringing..
        set single [string first "'''" $currentLine]
        set double [string first "\"\"\"" $currentLine]
        if {$single > -1 || $double > -1} {
            set start [max $single $double]
            # Found a line with starting ''' or """.
            # Do we also have closure on line?
            set back_half [string range $currentLine [expr $start + 3] end]
            set single [string first "'''" $back_half]
            set double [string first "\"\"\"" $back_half]
            if {$single > -1 || $double > -1} {
                # Yes
                set stop [max $single $double]
                set stop [expr $stop + $start + 3 + 3]
                $w mark set first $i.$start
                $w mark set last "$i.$stop"
                $callback $w vTcl:string
                continue
            }
            $w mark set first $i.$start
            $w mark set last "$i.end"
            $callback $w vTcl:string
            incr i
            set currentLine [$w get $i.0 $i.end]
            while {[string first "'''" $currentLine] == -1 &&
               [string first "\"\"\"" $currentLine] == -1} {
                # multi line string continues.
                $w mark set first $i.0
                $w mark set last "$i.end"
                $callback $w vTcl:string
                incr i
                set currentLine [$w get $i.0 $i.end]
            }
            set single [string first "'''" $currentLine]
            set double [string first "\"\"\"" $currentLine]
            set stop [max $single $double]
            set stop [expr $stop + 3]
            $w mark set first $i.0
            $w mark set last $i.$stop
            $callback $w vTcl:string
            continue
        }
        # Look for def.
        if {[regexp -indices $vTcl(syntax,vTcl:proc) $currentLine in0 in1]} {
            $w mark set first "$i.0 + [lindex $in1 0] chars"
            $w mark set last "$i.0 + [expr [lindex $in1 1] + 1] chars"
            $callback $w vTcl:proc
        }
        # Look for class.
        if {[regexp -indices $vTcl(syntax,vTcl:class) $currentLine in0 in1]} {
            $w mark set first "$i.0 + [lindex $in1 0] chars"
            $w mark set last "$i.0 + [expr [lindex $in1 1] + 1] chars"
            $callback $w vTcl:class
        }
        foreach tag $tags {
            set lastMark 0
            $w mark set last $i.0
            while {[regexp -indices $vTcl(syntax,$tag) \
                   [string range $currentLine $lastMark end] indices]} {
                $w mark set first "last + [lindex $indices 0] chars"
                $w mark set last "last + 1 chars + [lindex $indices 1] chars"
                set lastMark [expr $lastMark + 1 + [lindex $indices 1]]
                if [info exists vTcl(syntax,$tag,validate)] {
                    if {![$vTcl(syntax,$tag,validate) [$w get first last]]} {
                        continue
                    }
                }
                $callback $w $tag
            }
        }
    }
}

proc max {a b} {
    if {$a > $b} {
        return $a
    }
    return $b
}

proc min {a b} {
    # Returns the min of $a and $b. Rozen.
    if {$a < $b} {
        return $a
    }
    return $b
}

#Borrowed by Rozen from tcllib because I don't want to requiure that
#the user install tcllib and get a lot of stuff not needed for PAGE. I changed the name from ::math::geometry::rectanglesOverlap to vTcl:rectanglesOverlap.

# ::math::geometry::rectanglesOverlap
#
#       Check whether two rectangles overlap (see also intervalsOverlap).
#
# Arguments:
#       P1            upper-left corner of the first rectangle
#       P2            lower-right corner of the first rectangle
#       Q1            upper-left corner of the second rectangle
#       Q2            lower-right corner of the second rectangle
#       strict        choosing strict or non-strict interpretation
#
# Results:
#       dooverlap     a boolean saying whether the rectangles overlap
#
# Examples:
#     - rectanglesOverlap {0 10} {10 0} {10 10} {20 0} 1
#       Result: 0
#     - rectanglesOverlap {0 10} {10 0} {10 10} {20 0} 0
#       Result: 1
#
proc vTcl:rectanglesOverlap {P1 P2 Q1 Q2 strict} {
    set b1x1 [lindex $P1 0]
    set b1y1 [lindex $P1 1]
    set b1x2 [lindex $P2 0]
    set b1y2 [lindex $P2 1]
    set b2x1 [lindex $Q1 0]
    set b2y1 [lindex $Q1 1]
    set b2x2 [lindex $Q2 0]
    set b2y2 [lindex $Q2 1]
    # ensure b1x1<=b1x2 etc.
    if {$b1x1 > $b1x2} {
    set temp $b1x1
    set b1x1 $b1x2
    set b1x2 $temp
    }
    if {$b1y1 > $b1y2} {
    set temp $b1y1
    set b1y1 $b1y2
    set b1y2 $temp
    }
    if {$b2x1 > $b2x2} {
    set temp $b2x1
    set b2x1 $b2x2
    set b2x2 $temp
    }
    if {$b2y1 > $b2y2} {
    set temp $b2y1
    set b2y1 $b2y2
    set b2y2 $temp
    }
    # Check if the boxes intersect
    # (From: Cormen, Leiserson, and Rivests' "Algorithms", page 889)
    if {$strict} {
    return [expr {($b1x2>$b2x1) && ($b2x2>$b1x1) \
        && ($b1y2>$b2y1) && ($b2y2>$b1y1)}]
    } else {
    return [expr {($b1x2>=$b2x1) && ($b2x2>=$b1x1) \
        && ($b1y2>=$b2y1) && ($b2y2>=$b1y1)}]
    }
}


# @@change by Christian Gavin 3/19/2000
# procedure to find patterns in a text control
# based on the procedures by John K. Ousterhout in
# "Tcl and the Tk Toolkit"
# @@end_change

proc vTcl:forAllMatches.no {w tags callback {from 1} {to -1}} {

    global vTcl

    if {$to == -1} {
        scan [$w index end] %d to
    }

    for {set i $from} {$i <= $to} {incr i} {

        # get the line only once
        set currentLine [$w get $i.0 $i.end]

        # special case?
        if {[string range [string trim $currentLine] 0 0] == "\#"} {

                        $w mark set first $i.0
                        $w mark set last "$i.end"

                $callback $w vTcl:comment
                continue
        }

                foreach tag $tags {

            set lastMark 0
            $w mark set last $i.0

            while {[regexp -indices $vTcl(syntax,$tag) \
                   [string range $currentLine $lastMark end] indices]} {

                 $w mark set first "last + [lindex $indices 0] chars"

                 $w mark set last "last + 1 chars + [lindex $indices 1] chars"

                     set lastMark [expr $lastMark + 1 + [lindex $indices 1]]

                     if [info exists vTcl(syntax,$tag,validate)] {

                         if {! [$vTcl(syntax,$tag,validate) [$w get first last] ] } {

                                continue
                         }
                     }

                     $callback $w $tag
            }
        }
    }
}

# @@change by Christian Gavin 3/19/2000
# syntax colouring for text widget
# @@end_change

proc vTcl:syntax_item {w tag} {

    # already a tag there ?
    if { [$w tag names first] != ""} return

    $w tag add $tag first last
}

# from, to indicate the line numbers of the area to colorize
# if not specified, the full text widget is colorized

proc vTcl:syntax_color {w {from 1} {to -1}} {

    global vTcl

    set patterns ""

    if {$to == -1} {
        scan [$w index end] %d to
    }

    foreach tag $vTcl(syntax,tags) {

        $w tag remove $tag $from.0 $to.end
    }

    vTcl:forAllMatches $w $vTcl(syntax,tags) vTcl:syntax_item \
        $from $to

    foreach tag $vTcl(syntax,tags) {

        eval $w tag configure $tag $vTcl(syntax,$tag,configure)
    }
}

# @@change by Christian Gavin 4/22/2000
#
# procedure to prepare a pull-down modal window
#
# on Windows systems, Tk8.2 does not set the geometry of a window if it
# is withdraw
#
# to avoid seeing the window change in size and move around, we move it
# out of the way of the current display, then it is created and finally
# repositioned using display_pulldown
#
# @@end_change

proc vTcl:prepare_pulldown {base xl yl} {

    global tcl_platform

    set size $xl
    set size [append size x]
    set size [append size $yl]

    if {$tcl_platform(platform)=="windows"} {

        wm geometry $base $size+1600+1200
    } else {

        wm geometry $base $size+0+0
    }
}

# @@change by Christian Gavin 4/22/2000
#
# procedure to position a pull-down modal window near the mouse pointer
# arrange the window so that it fits inside the current display
#
# xl is the requested width
# yl is the requested height
#
# close_action is a script to execute when the user clicks outside
# the pulldown menu
#
# @@end_change

proc vTcl:display_pulldown {base xl yl {close_action ""}} {

    global tcl_platform

    wm withdraw $base

    wm overrideredirect $base 1
    update

    # move it near mouse pointer
    set xm [winfo pointerx $base]
    set ym [winfo pointery $base]

    vTcl:log "mouse=$xm,$ym"

    set x0 [expr $xm - $xl ]
    set y0 $ym

    set x1 $xm
    set y1 [expr $ym + $yl ]

    set xmax [winfo screenwidth $base]
    set ymax [winfo screenheight $base]

    if {$x1 > $xmax } {
        set x0 [expr $xmax - $xl ]
    }

    if {$y1 > $ymax } {
        set y0 [expr $ymax - $yl ]
    }

    if {$x0 < 0} "set x0 0"
    if {$y0 < 0} "set y0 0"

    wm geometry $base "+$x0+$y0"
    wm deiconify $base

    # add this line for $%@^! Windows
    # apparently the 8.2 implementation of Tk does not change the
    # geometry of the window if it is "withdrawn"

    if {$tcl_platform(platform)=="windows"} {
        wm geometry $base "+$x0+$y0"
    }

    bind $base <ButtonPress-1> "
       set where \[winfo containing %X %Y\]
       if \{\"\$where\" != \"%W\"\} \{$close_action\}
       unset where"
}

proc vTcl:split_geom {geom} {
    set vars {height width x y}
    foreach var $vars { set $var {} }
    regexp {([0-9-]+)x([0-9-]+)\+([0-9-]+)\+([0-9-]+)} $geom \
        trash width height x y
    return [list $width $height $x $y]
}

proc vTcl:get_win_position {w} {
    lassign [vTcl:split_geom [wm geometry $w]] width height x y
    return "+$x+$y"
}

proc ::vTcl::lremove {varName args} {
    upvar 1 $varName list

    set found 0
    foreach pattern $args {
    set s [lsearch $list $pattern]
    while {$s > -1} {
        set list [lreplace $list $s $s]
        set s [lsearch $list $pattern]
        incr found
    }
    }
    return $found
}

proc lempty {list} {
    if {[catch {expr [llength $list] == 0} res]} { return 0 }
    return $res
}

proc lassign {list args} {
    foreach elem $list varName $args {
        upvar 1 $varName var
    set var $elem
    }
}

proc vTcl:namespace_tree {{root "::"}} {

    set children [namespace children $root]
    set result ""
    lappend result $root

    foreach child $children {
        foreach subchild [vTcl:namespace_tree $child] {

            lappend result $subchild
        }
    }
    return $result
}

proc vTcl:copy_widgetname {} {
    .vTcl.widgetname selection range 0 end
}

proc echo {args} {
    ::vTcl::InitTkcon
    tkcon_puts $args
}

proc incr0 {varName {num 1}} {
    upvar 1 $varName var
    if {![info exists var]} { set var 0 }
    incr var $num
}

proc vTcl:WrongNumArgs {string} {
    return "wrong # args: should be \"$string\""
}

proc vTcl:check_mouse_coords {} {

    global vTcl

    if {$vTcl(mouse,X) == 0} {
        set vTcl(mouse,X) [expr [winfo screenwidth .] / 2]
    }
    if {$vTcl(mouse,Y) == 0} {
        set vTcl(mouse,Y) [expr [winfo screenheight .] / 2]
    }
}

proc vTcl:set_mouse_coords {X Y x y} {
    global vTcl
    foreach var [list X Y x y] {
        set vTcl(mouse,$var) [set $var]
    }
}

proc vTcl:rebind_button_1 {} {
    global vTcl
    bind vTcl(b) <Button-1> {vTcl:bind_button_1 %W %X %Y %x %y}
}

proc vTcl:lib:add_widgets_to_toolbar { list  band_name headerLabel } {
    global classes
    if {$headerLabel != ""} {
        vTcl::toolbar_header $band_name $headerLabel
    }


    foreach i $list {
        if {![info exists classes($i,lib)]} { continue }
        ## If there is a special proc, call it and continue.
        if {![lempty [info procs vTcl:$i:ToolBarSetup]]} {
            vTcl:$i:ToolBarSetup
            continue
        }

    vTcl:toolbar_add $band_name $i $classes($i,balloon) \
        $classes($i,icon) $classes($i,addOptions)
    }
}

proc vTcl:lrmdups {list} {
    # Rozen. Removes duplicates from the list.
    if {[lempty $list]} { return }
    if {[info tclversion] > 8.2} { return [lsort -unique $list] }
    # Rozen. We never get to this stuff because of version.
    set list [lsort $list]
    set last [lindex $list 0]
    set list [lrange $list 1 end]
    lappend result $last
    foreach elem $list {
        if {[string compare $last $elem] != 0} {
        lappend result $elem
        set last $elem
    }
    }
    return $result
}

proc vTcl:center {target {w 0} {h 0}} {
    if {[vTcl:get_class $target] != "Toplevel"} { return }
    update
    if {$w == 0} { set w [winfo reqwidth $target] }
    if {$h == 0} { set h [winfo reqheight $target] }
    set sw [winfo screenwidth $target]
    set sh [winfo screenheight $target]
    set x0 [expr ([winfo screenwidth $target] - $w)/2 - [winfo vrootx $target]]
    set y0 [expr ([winfo screenheight $target] - $h)/2 - [winfo vrooty $target]]
    set x "+$x0"
    set y "+$y0"
    if { $x0+$w > $sw } {set x "-0"; set x0 [expr {$sw-$w}]}
    if { $x0 < 0 }      {set x "+0"}
    if { $y0+$h > $sh } {set y "-0"; set y0 [expr {$sh-$h}]}
    if { $y0 < 0 }      {set y "+0"}

    wm geometry $target $x$y
    update
}

proc vTcl:raise_last_button {newButton} {
    global vTcl

    if {![info exists vTcl(x,lastButton)]} { return }

    if {$vTcl(x,lastButton) == $newButton} { return }

    if {[winfo exists $vTcl(x,lastButton)]} {
        $vTcl(x,lastButton) configure -relief raised
    }

    set vTcl(x,lastButton) $newButton
}

#####################################################################
#                                                                   #
# The following routines are used for in-line images support        #
#                                                                   #
# In-line images are stored in the main project file instead of     #
# beeing contained in separate files. They are encoded using base64 #
#                                                                   #
#####################################################################

# -------------------------------------------------------------------
# Routines for encoding and decoding base64
# encoding from Time Janes,
# decoding from Pascual Alonso,
# namespace'ing and bugs from Parand Tony Darugar
# (tdarugar@binevolve.com)
#
# $Id: misc.tcl,v 1.74 2005/12/05 06:51:02 kenparkerjr Exp $
# -------------------------------------------------------------------

namespace eval base64 {
  set charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  # this proc by Christian Gavin
  proc encode_file {filename} {

     set inID [open $filename r]
     fconfigure $inID -translation binary
     set contents [read $inID]
     close $inID

     set encoded [::base64::encode $contents]
     set length  [string length $encoded]
     set chunk   60
     set result  ""

     for {set index 0} {$index < $length} {set index [expr $index + $chunk] } {

         set index_end [expr $index + $chunk - 1]

         if {$index_end >= $length} {

             set index_end [expr $length - 1]
             append result [string range $encoded $index $index_end]

         } else {

             append result [string range $encoded $index $index_end]
             append result \n
         }
     }

     return $result
  }

  # ----------------------------------------
  # encode the given text
  proc encode {text} {
    set encoded ""
    set y 0
    for {set i 0} {$i < [string length $text] } {incr i} {
      binary scan [string index $text $i] c x
      if { $x < 0 } {
        set x [expr $x + 256 ]
      }
      set y [expr ( $y << 8 ) + $x]
      if { [expr $i % 3 ] == 2}  {
        append  encoded [string index $base64::charset [expr ( $y & 0xfc0000 ) >> 18 ]]
        append  encoded [string index $base64::charset [expr ( $y & 0x03f000 ) >> 12 ]]
        append  encoded [string index $base64::charset [expr ( $y & 0x000fc0 ) >> 6 ]]
        append  encoded [string index $base64::charset [expr ( $y & 0x00003f ) ]]
        set y 0
      }
    }
    if { [expr $i % 3 ] == 1 } {
      set y [ expr $y << 4 ]
      append encoded [string index $base64::charset [ expr ( $y & 0x000fc0 ) >> 6]]
      append encoded [string index $base64::charset [ expr ( $y & 0x00003f ) ]]
      append encoded "=="
    }
    if { [expr $i % 3 ] == 2 } {
      set y [ expr $y << 2 ]
      append  encoded [string index $base64::charset [expr ( $y & 0x03f000 ) >> 12 ]]
      append  encoded [string index $base64::charset [expr ( $y & 0x000fc0 ) >> 6 ]]
      append  encoded [string index $base64::charset [expr ( $y & 0x00003f ) ]]
      append encoded "="
    }
    return $encoded
  }

  # ----------------------------------------
  # decode the given text
  # Generously contributed by Pascual Alonso
  proc decode {text} {
    set decoded ""
    set y 0
    if {[string first = $text] == -1} {
      set lenx [string length $text]
    } else {
      set lenx [string first = $text]
    }
    for {set i 0} {$i < $lenx } {incr i} {
      set x [string first [string index $text $i] $base64::charset]
      set y [expr ( $y << 6 ) + $x]
      if { [expr $i % 4 ] == 3}  {
        append decoded \
      [binary format c [expr $y >> 16 ]]
    append decoded \
      [binary format c [expr ( $y & 0x00ff00 ) >> 8 ]]
    append decoded \
      [binary format c [expr ( $y & 0x0000ff ) ]]
    set y 0
      }
    }
    if { [expr $i % 4 ] == 3 } {
      set y [ expr $y >> 2 ]
    append decoded \
      [binary format c [expr ( $y & 0x00ff00 ) >> 8 ]]
    append decoded \
      [binary format c [expr ( $y & 0x0000ff ) ]]
    }
    if { [expr $i % 4 ] == 2 } {
      set y [ expr $y >> 4 ]
    append decoded \
      [binary format c [expr ( $y & 0x0000ff ) ]]
    }
    return $decoded
  }
}

# adds a widget into a frame, automatically names it and packs it,
# returns the window path

proc vTcl:formCompound:add {cpd type args} {
    global widget
    set varname [vTcl:rename $cpd]

    global ${varname}_count

    if {! [info exists ${varname}_count] } {

       set ${varname}_count 0
    }

    set count [set ${varname}_count]

    if {$type == "entry"} { set type vTcl:entry }
    set window_name $cpd.i$count
    set cmd "$type $window_name $args"
    eval $cmd
    pack $window_name -side top -anchor nw

    incr ${varname}_count

    return $window_name
}

# transfers the value from var1 to var2 if save_and_validate = 0
# transfers the value from var2 to var1 if save_and_validate = 1

proc vTcl:data_exchange_var {var1 var2 save_and_validate} {
    global widget

    # hum... we need to be smart here
    if [string match *(*) $var1] {
       regexp {([a-zA-Z]+)\(} $var1 matchAll arrayName
       global $arrayName
    } else {
       global $var1
    }

    global $var2
    eval set value1 $$var1
    eval set value2 $$var2
    if {$save_and_validate} {
       set $var1 $value2
    } else {
       set $var2 $value1
    }
}

proc vTcl:streq {s1 s2} {
    return [expr [string compare $s1 $s2] == 0]
}

proc vTcl:entry {w args} {
    global vTcl
    eval entry $w $args
    # shall we add some default bindings ?
    if {[bind _Entry] == ""} {

        # only if background color and highlight color are different
        if {$vTcl(pr,entrybgcolor) != $vTcl(pr,entryactivecolor)} {
            bind _Entry <FocusIn>  "%W configure -bg $vTcl(pr,entryactivecolor)"
            bind _Entry <FocusOut> "%W configure -bg $vTcl(pr,entrybgcolor)"
        }
        # this one is always defined
        bind _Entry <Control-Key-u> "%W delete 0 end"
    }
    bindtags $w "[bindtags $w] _Entry"
}

proc vTcl:read_file {file} {
    set fp [open $file]
    set x [read $fp]
    close $fp
    return $x
}

proc ::vTcl::change {} {
    global vTcl
    if {!$vTcl(change)} {
        wm title .vTcl "[wm title .vTcl]*"
        set vTcl(change) 1
    }
    set vTcl(gui_change_time) [clock milliseconds]
}

proc vTclWindow.vTcl.tkcon {args} {
    if {[winfo exists .vTcl.tkcon]} {
    wm deiconify .vTcl.tkcon
    } else {
    tkcon show
    after idle {
        catch {wm geometry .vTcl.tkcon $vTcl(geometry,.vTcl.tkcon)}
    }
    }
}

proc vTcl:show_console {} {
    vTcl:attrbar:toggle_console
}

proc ::vTcl::InitTkcon {} {
    if {[catch {winfo exists $::tkcon::PRIV(root)}]} {
        ::tkcon::Init
    ::tkcon::Attach Main slave
    tkcon title "PAGE"
    }
}

proc vTcl:canvas:see {c item} {
    lassign [$c cget -scrollregion] foo foo cx cy
    lassign [$c bbox $item] ix iy
    set x [expr $ix.0 / $cx]
    set y [expr $iy.0 / $cy]
    $c xview moveto $x
    $c yview moveto $y
}

# Rozen: What does this do???
proc vTcl:WidgetVar {w varName {newVar ""}} {
    # Rozen. This seems to fetch the value of save in the namespace of
    # the widget and put it into the a variable of the same variable
    # name or the new name passed in.
    if {[lempty $newVar]} { set newVar $varName }
    uplevel 1 "upvar #0 ::widgets::${w}::$varName $newVar"
    return [info exists ::widgets::${w}::$varName]
}


proc vTcl:replace_fixed_name {orig_name var_name} {
    # Rozen. Not sure I actually can use this.
    global vTcl
    if {$vTcl(copy)} {
        regsub $target $orig_name  {$var_name} orig_name
    }
    return $orig_name
}

proc ::vTcl::web_browser {} {
    global env tcl_platform

    if {$tcl_platform(platform) == "windows"} {
        foreach elem [array names env] {
        if {[string tolower $elem] == "comspec"} {
        regsub -all {\\} $env($elem) {\\\\} comspec
            return "$comspec /c start"
        }
    }
    }

    foreach path [split $env(PATH) :] {
        #if {![file executable [file join $path mozilla]]} { continue }

        #if {![file executable [file join $path netscape]]} { continue }

    #return [file join $path netscape]
    return mozilla
    }
}

proc ::vTcl::OkButton {path args} {
    global vTcl
    vTcl:toolbar_button $path -image [vTcl:image:get_image ok.gif]
    eval $path configure $args
}

proc ::vTcl::CancelButton {path args} {
    global vTcl
    vTcl:toolbar_button $path -image [vTcl:image:get_image remove.gif]
    eval $path configure $args
}

proc ::vTcl::BrowseButton {path args} {
    button $path -image [vTcl:image:get_image browse.gif]
    eval $path configure $args
}

proc ::vTcl::MessageBox {args} {
    global tk_strictMotif
    set tk_strictMotif 0
    set response [eval tk_messageBox $args]
    set tk_strictMotif 1
    return $response
}

##############################################################################
## Notification system

namespace eval ::vTcl::notify {

    proc publish {event args} {
        variable subscribers
    if {[info exists subscribers($event)]} {
            set recipients $subscribers($event)
        foreach recipient $recipients {
            lassign $recipient id callback
            uplevel #0 $callback $id $args
        }
    }
    }

    proc subscribe {event id callback} {
        variable subscribers
        lappend subscribers($event) [list $id $callback]
    }

    proc unsubscribe {event id} {
        variable subscribers
    set recipients $subscribers($event)
    set i 0
    foreach recipient $recipients {
        lassign $recipient rid callback
        if {$rid == $id} {
            set subscribers($event) [lreplace $subscribers($event) $i $i]
        break
        }
        incr i
    }
    }

    variable subscribers
}

##############################################################################
## Attributes editing

namespace eval ::vTcl::ui::attributes {

    variable pendingCmds
    variable checked
    variable counter 0
    array set pendingCmds {}
    array set checked {}

    proc show_color {w variable args} {
        global vTcl
        #catch {
            set color_value [set $variable]
            if {$color_value == ""} {
                set color_value [[winfo parent $w] cget -background]
            }
            # Rozen. Added the ell_image stuff to handle dark color better.
            if {[::colorDlg::dark_color $color_value]} {
                set ell_image ellipseslight
            } else {
                set ell_image ellipsesdark
            }
            $w configure -bg $color_value -image $ell_image
        #}
    }

    proc select_color {w config_cmd variable args } {
        set initial [::set $variable]
        set $variable [::vTcl:get_color $initial $w]
        eval $config_cmd
    }

    proc set_command {target option config_cmd variable} {
        variable counter

        set cmd [::set $variable]
        incr counter
        ## if the command is in the form "vTcl:DoCmdOption target cmd",
        ## then extracts the command, otherwise use the command as is
        if {[regexp {vTcl:DoCmdOption [^ ]+ (.*)} $cmd matchAll realCmd]} {
            lassign $cmd dummy1 dummy2 cmd
        }
        set result [::vTcl:get_command "Edit $option" $cmd .vTcl.cmdEdit_$counter]
        if {$result == -1} {
            return
        }

        ## if the command is non null, replace it by DoCmdOption
        set cmd [string trim $result]
        if {$cmd != "" && [string match *%* $cmd]} {
            set cmd [list vTcl:DoCmdOption $target $cmd]
        }
        set $variable $cmd
        eval $config_cmd
    }

    proc set_font {config_cmd variable} {
        # Rozen. Inexplicably, the menu font settings is slightly
        # different than that of the attribute editor. In fact, I
        # don't even like the way it works!  I think that if one
        # changes the font for one element of the menu then that
        # change should apply to all elements of the menu!!  Will see
        # if I can cludge it up to work that way.
        set font [::set $variable]
        set desc [font actual $font]
        #set r [::vTcl:font:prompt_noborder_fontlist $font] Rozen
        set font_desc \
               [::vTcl:font:prompt_user_font_2 $desc]    ;# Rozen 1-21-13
              #[::vTcl:font:prompt_user_font_2 "-family helvetica -size 12"]
        set r [vTcl:font:add_font $font_desc user]   ;# Rozen 1-21-13
        if {$r == ""} {
            return
        }
        set $variable $r
        eval $config_cmd
    }

    proc set_image {config_cmd variable} {
        set image [::set $variable]
        set r [::vTcl:prompt_user_image2 $image]
        set $variable $r
        eval $config_cmd
    }

    proc enableAttribute {enableData enable} {
        set state(1) normal
        set state(0) disabled
        foreach widget $enableData {
            $widget configure -state $state($enable)
        }
    }

    proc checkAttribute {top option variable keyrelease_cmd} {
        set base $top.t${option}
        eval $keyrelease_cmd $option $variable \
            ::vTcl::ui::attributes::checked($base)
    }


    ## returns: a string used to enable/disable the option
    proc newAttribute {target top option variable \
                      config_cmd check_cmd keyrelease_cmd} {
        variable pendingCmds
        variable checked
        global vTcl
        set class $::vTcl(w,class)
        if {[info exists ::specialOpts($class,$option,type)]} {
          set text    $::specialOpts($class,$option,text)
          set type    $::specialOpts($class,$option,type)
          set choices $::specialOpts($class,$option,choices)
        } elseif {[info exists ::options($option,text)]} {
            set text    $::options($option,text)
            set type    $::options($option,type)
            set choices $::options($option,choices)
        } else {
            set text    [string trimleft $option -]
            set type    type
            set choices {}
        }
        ## standard relief options
        if {[vTcl:streq $type "relief"]} {
        set type    choice
            set choices $::vTcl(reliefs)
        }

        ## the option label
        set label $top.$option
        # Rozen Changed the foreground color from black to be that of
        # the preferences because the user may have decided to use a
        # dark color for page.
        label $label -text $text -anchor w -width 11 -fg $vTcl(pr,fgcolor) \
            -relief $::vTcl(pr,proprelief)
        #label $label -text $text -anchor w -width 11 -fg black \
            -relief $::vTcl(pr,proprelief)
        ## the option value
        set base $top.t${option}
        set focusControl $base
        set enableData $label

        switch $type {
            boolean {
                frame $base
                radiobutton ${base}.y \
                    -variable $variable -value 1 -text "Yes" -relief sunken  \
                    -command "$config_cmd
            $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)" \
            -padx 0 -pady 1
                radiobutton ${base}.n \
                    -variable $variable -value 0 -text "No" -relief sunken  \
                    -command "$config_cmd
            $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)" \
            -padx 0 -pady 1
                pack ${base}.y ${base}.n -side left -expand 1 -fill both
                lappend enableData ${base}.y ${base}.n
            }
            choice {
                ComboBox ${base} -editable 0 -width 12 -values $choices \
                    -modifycmd "vTcl:prop:choice_select ${base} $variable; $config_cmd
            $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)"
                trace variable $variable w "vTcl:prop:choice_update ${base} $variable"
                vTcl:prop:choice_update ${base} $variable
                lappend enableData ${base}
            }
            color {
                frame $base
                vTcl:entry ${base}.l -relief sunken  \
                    -textvariable $variable -width 8 \
                    -highlightthickness 1 -fg black
                bind ${base}.l <KeyRelease-Return> \
                    "$config_cmd; ${base}.f conf -bg \$$variable"
                # This special button seems to be the only difference with
                # the font entry below. It used to be
                #vtcl:special_button ...   Rozen 12/24/11
                button ${base}.f -image ellipses -width 12 -padx 0 -pady 1 \
                    -command \
                    "::vTcl::ui::attributes::select_color ${base}.f [list $config_cmd] $variable
             $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)"
                pack ${base}.l -side left -expand 1 -fill x
                pack ${base}.f -side right -fill y -pady 0 -padx 1 -ipady 0
            set focusControl ${base}.l
                trace variable $variable w \
                    "::vTcl::ui::attributes::show_color ${base}.f $variable"
                ::vTcl::ui::attributes::show_color ${base}.f $variable
                lappend enableData ${base}.l ${base}.f
            }
            command {
                frame $base
                vTcl:entry ${base}.l -relief sunken  \
                    -textvariable $variable -width 8 \
                    -highlightthickness 1 -fg black
                namespace eval ::${base}.f "set target $target"
                button ${base}.f \
                    -image ellipses  -width 12 \
                    -highlightthickness 1 -fg black -padx 0 -pady 1 \
                    -command "::vTcl::ui::attributes::set_command \[set ::${base}.f::target\] $option [list $config_cmd] $variable
                      $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)"
                bind ${base}.f <Destroy> "
                    namespace delete ::${base}.f"
                pack ${base}.l -side left -expand 1 -fill x
                pack ${base}.f -side right -fill y -pady 1 -padx 1
                ::vTcl::ui::attributes::show_color ${base}.f $variable
                set focusControl ${base}.l
                lappend enableData ${base}.l
            }
            font {
                frame $base
                vTcl:entry ${base}.l -relief sunken  \
                    -textvariable $variable -width 8 \
                    -highlightthickness 1 -fg black
                button ${base}.f \
                    -image ellipses  -width 12 \
                    -highlightthickness 1 -fg black -padx 0 -pady 1 \
                    -command "::vTcl::ui::attributes::set_font [list $config_cmd] $variable
                      $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)"
                pack ${base}.l -side left -expand 1 -fill x
                pack ${base}.f -side right -fill y -pady 1 -padx 1
                ::vTcl::ui::attributes::show_color ${base}.f $variable
                set focusControl ${base}.l
                lappend enableData ${base}.l ${base}.f
            }
            image {
                frame $base
                vTcl:entry ${base}.l -relief sunken  \
                    -textvariable $variable -width 8 \
                    -highlightthickness 1 -fg black
                button ${base}.f \
                    -image ellipses  -width 12 \
                    -highlightthickness 1 -fg black -padx 0 -pady 1 \
                    -command "::vTcl::ui::attributes::set_image [list $config_cmd] $variable
                      $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)"
                pack ${base}.l -side left -expand 1 -fill x
                pack ${base}.f -side right -fill y -pady 1 -padx 1
                ::vTcl::ui::attributes::show_color ${base}.f $variable
                set focusControl ${base}.l
                lappend enableData ${base}.l ${base}.f
            }
            default {
                vTcl:entry $base \
                    -textvariable $variable -width 12 -highlightthickness 1
                lappend enableData ${base}
        }
        }

        ## When the user presses <Return>, the option is set
        bind $focusControl <KeyRelease-Return> "::vTcl::ui::attributes::setPending"
        bind $focusControl <FocusOut> "::vTcl::ui::attributes::setPending"
        bind $focusControl <KeyRelease> \
        "set ::vTcl::ui::attributes::pendingCmds($focusControl) [list $config_cmd]
         $keyrelease_cmd $option $variable ::vTcl::ui::attributes::checked($base)"

        ## Checkbox to save/not save the option
        set theCheck $top.${option}check
        checkbutton $theCheck -text "" \
            -variable "::vTcl::ui::attributes::checked($base)" \
            -command "$check_cmd $option ::vTcl::ui::attributes::checked($base)"
        set [$theCheck cget -variable] [eval $check_cmd $option]
        bind $theCheck <Destroy> "unset ::vTcl::ui::attributes::checked($base)"

        grid $label $base $theCheck -sticky news
        grid columnconf $top 1 -weight 1
        lappend enableData $theCheck
        return $enableData
    }

    ## Returns the variable to check or uncheck a checkbox for
    ## saving/not saving an option
    proc getCheckVariable {top option} {
        set base $top.t${option}
        return ::vTcl::ui::attributes::checked($base)
    }

    ## Sets the current target for a -command option
    proc setCommandTarget {top option target} {
        set base $top.t${option}
        namespace eval ::${base}.f "set target $target"
    }

    ## Sets all pending options (eg. for which user didn't press the <Return> key)
    proc setPending {} {
        variable pendingCmds
        set names [array names pendingCmds]
        foreach name $names {
            uplevel #0 $pendingCmds($name)
            unset pendingCmds($name)
        }
    }
}

