#############################################################################
# $Id: input.tcl,v 1.19 2003/05/10 03:39:52 cgavin Exp $
#
# input.tcl - procedures for prompting windowed string input
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

proc vTcl:get_string {title target {value ""}} {
    global vTcl
    set tmpname .vTcl.[vTcl:rename $target]
    set vTcl(x,$tmpname) ""
    vTcl:string_window $title $tmpname $value
    tkwait window $tmpname
    return $vTcl(x,$tmpname)
}

proc vTcl:set_string {base str} {
    global vTcl
    if {$str != "*{<cancel>}"} {
        set vTcl(x,$base) $str
    }
    grab release $base
    destroy $base
}

proc vTcl:snarf_string {base} {
    global vTcl
    vTcl:set_string $base "[$base.ent18 get]"
}

proc vTcl:string_window {title base {value ""}} {
    global vTcl
    vTcl:check_mouse_coords
    toplevel $base
    wm transient $base .vTcl
    wm focusmodel $base passive
    #wm geometry $base 225x49+[expr $vTcl(mouse,X)-120]+[expr $vTcl(mouse,Y)-20]
wm geometry $base 225x60+[expr $vTcl(mouse,X)-120]+[expr $vTcl(mouse,Y)-20]
    wm maxsize $base 500 870
    wm minsize $base 225 1
    wm overrideredirect $base 0
    wm resizable $base 1 1               ;# Rozen trailing ! for height resize.
    wm deiconify $base
    wm title $base "$title"
    frame $base.fra19 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.fra19 \
        -in $base -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    # Rozen. The *{<cancel>} is a nonsense phrase not expected of the user.
    ::vTcl::CancelButton $base.fra19.but21 -command "
    $base.ent18 delete 0 end
    vTcl:set_string \{$base\} *{<cancel>}
    "
    pack $base.fra19.but21 \
        -in $base.fra19 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right
    ::vTcl::OkButton $base.fra19.but20 -command "vTcl:snarf_string \{$base\}"
    pack $base.fra19.but20 \
        -in $base.fra19 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right
    vTcl:entry $base.ent18 \
        -insertborderwidth 3 \
        -cursor {} -background white -foreground black ;# Rozen fg 2-3-13
    pack $base.ent18 \
        -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    bind $base <Key-Return> "vTcl:snarf_string \{$base\}; break"
    bind $base <Key-Escape> "$base.fra19.but21 invoke"
    $base.ent18 insert end $value
    update idletasks
    focus $base.ent18
    grab $base
}

# proc vTcl:values_window {title base {values ""}} {
#     # Written by Rozen out of desperation.
#     global vTcl
#     vTcl:check_mouse_coords

#     toplevel $base
#     wm transient $base .vTcl
#     wm focusmodel $base passive
#     wm geometry $base 225x200+[expr $vTcl(mouse,X)-120]+[expr $vTcl(mouse,Y)-20]
#     wm maxsize $base 500 870
#     wm minsize $base 225 1
#     wm overrideredirect $base 0
#     wm resizable $base 1 1
#     wm deiconify $base
#     wm title $base "$title"
#     frame $base.fra19 \
#         -borderwidth 1 -height 30 -relief sunken -width 30 -bg green
#     pack $base.fra19 \
#         -in $base -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
#         -padx 0 -pady 0 -side top
#     ::vTcl::CancelButton $base.fra19.but21 -command "
#     $base.ent18 delete 0 end
#     vTcl:set_string \{$base\} \"\"
#     "
#     pack $base.fra19.but21 \
#         -in $base.fra19 -anchor center -expand 0 -fill none -ipadx 0 \
#         -ipady 0 -padx 0 -pady 0 -side right
#     ::vTcl::OkButton $base.fra19.but20 -command "vTcl:snarf_string \{$base\}"
#     pack $base.fra19.but20 \
#         -in $base.fra19 -anchor center -expand 0 -fill none -ipadx 0 \
#         -ipady 0 -padx 0 -pady 0 -side right

#     frame $base.fra23 -bg blue -height 170
#     pack $base.fra23 \
#          -in $base -anchor center -expand 1 -fill both  -ipadx 0 -ipady 0 \
#         -padx 0 -pady 0 ;#-side bottom


#     eval {text $base.fra23.text18 -wrap none -bg wheat \
#         -xscrollcommand [list $base.fra23.text18.xscroll set] \
#         -yscrollcommand [list $base.fra23.text18.yscroll set]}
#     scrollbar $base.fra23.text18.xscroll -orient horizontal \
#         -command [list $base.fra23.text18.text xview]
#     scrollbar $base.fra23.text18.yscroll -orient vertical \
#         -command [list $base.fra23.text18.text yview]
#     grid $base.fra23.text18 $base.fra23.text18.yscroll -sticky news
#     grid $base.fra23.text18.xscroll -sticky news
#     grid rowconfigure $base.fra23.text18 0 -weight 1
#     grid columnconfigure $base.fra23.text18 0 -weight 1
#     pack $base.text18 \
#         -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
#         -padx 0 -pady 0 -side top
#     # set f $base
#     # text $f.text -wrap none \
#     #     -xscrollcommand [list $f.xscroll set] \
#     #     -yscrollcommand [list $f.yscroll set] -width 40 -height 8
#     # scrollbar $f.xscroll -orient horizontal \
#     #     -command [list $f.text xview]
#     # scrollbar $f.yscroll -orient vertical \
#     #     -command [list $f.text yview]
#     # grid $f.text $f.yscroll -sticky news
#     # grid $f.xscroll -sticky news
#     # grid rowconfigure $f 0 -weight 1
#     # grid columnconfigure $f 0 -weight 1
#     # pack $f.text \
#     #     -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
#     #     -padx 0 -pady 0 -side top
#     # bind $base <Key-Return> "vTcl:snarf_string \{$base\}; break"
#     # bind $base <Key-Escape> "$base.fra19.but21 invoke"
#     # #$base.ent18 insert end $value
#     # update idletasks
#     # focus $base.ent18
#     grab $base
# }

# proc vTcl:Scrolled_Text { f args } {
#     # Rozen from Welch's book, example 30-1.
#     frame $f
#     eval {text $f.text -wrap none \
#         -xscrollcommand [list $f.xscroll set] \
#         -yscrollcommand [list $f.yscroll set]} $args
#     scrollbar $f.xscroll -orient horizontal \
#         -command [list $f.text xview]
#     scrollbar $f.yscroll -orient vertical \
#         -command [list $f.text yview]
#     grid $f.text $f.yscroll -sticky news
#     grid $f.xscroll -sticky news
#     grid rowconfigure $f 0 -weight 1
#     grid columnconfigure $f 0 -weight 1
#     return $f.text
# }


proc vTcl:set_label {t} {
    global vTcl
    if {$t == ""} {return}
    if [catch {set txt [$t cget -text]}] {
        return
    }
    set label [vTcl:get_string "Setting label for $t" $t $txt]
    if {$label == ""} {
        return
    }
    $t conf -text $label
    vTcl:place_handles $t
    set vTcl(w,opt,-text) $label
}

proc vTcl:set_text {target} {
    global vTcl
    set base .vTcl.[vTcl:rename $target]
    vTcl:text_window $base "Set Text" $target
    tkwait window $base

    ## They closed it without hitting the done button.  Just forget it.
    if {![info exists vTcl(x,$base)]} { return }

    $target configure -text $vTcl(x,$base)
    unset vTcl(x,$base)
    vTcl:create_handles $target
}

proc vTcl:set_values {target} {
    # Added by Rozen, based on vTcl:set_text.
    global vTcl
    vTcl:WidgetVar $target defaults
    vTcl:WidgetVar $target options
    vTcl:WidgetVar $target saveXW
    set base .vTcl.[vTcl:rename $target]
    vTcl:values_window $base "Set Values" $target
    tkwait window $base
    set opt "-values"
    ## They closed it without hitting the done button.  Just forget it.
    if {![info exists vTcl(x,$base)]} { return }
    # Save the widget with the option.
    $target configure -values $vTcl(x,$base)
    # Save the option.
    set vTcl(w,opt,$opt) $vTcl(x,$base)
    vTcl:prop:save_opt_value $target $opt  $vTcl(w,opt,$opt)
    unset vTcl(x,$base)
    vTcl:create_handles $target
}

proc vTcl:get_text {base text} {
    global vTcl

    ## Remove the last character which is a \n the text widget puts in for
    ## some reason.
    set string [$text get 0.0 end]
    set end [expr [string length $string] - 1]
    set vTcl(x,$base) [string range $string 0 [expr $end - 1]]
    destroy $base
}

proc vTcl:text_window {base title target} {
    global vTcl
    toplevel $base -class Toplevel
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 400x289+[expr $vTcl(mouse,X)-130]+[expr $vTcl(mouse,Y)-20]
    wm maxsize $base 1265 994
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title
    ScrolledWindow $base.cpd48
    # none added by Rozen and forground 2-3-13
    text $base.cpd48.03 -width 8 -background white -wrap none \
        -foreground black -insertborderwidth 3      ;# Rozen
    $base.cpd48 setwidget $base.cpd48.03

    # avoid syntax coloring here (automatic for text widgets in vTcl)
    global $base.cpd48.03.nosyntax
    set $base.cpd48.03.nosyntax 1

    frame $base.butfr

    ::vTcl::OkButton $base.butfr.but52 \
    -command "vTcl:get_text $base $base.cpd48.03"
    vTcl:set_balloon $base.butfr.but52 "Save Changes"

    ::vTcl::CancelButton $base.butfr.but53 -command "destroy $base"
    vTcl:set_balloon $base.butfr.but53 "Discard Changes"

    bind $base <Key-Escape> "$base.butfr.but53 invoke"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.butfr -side top -anchor e
    pack $base.butfr.but53 -side right
    pack $base.butfr.but52 -side right
    pack $base.cpd48 -fill both -expand 1
    #pack $base.cpd48.03

    $base.cpd48.03 insert end [$target cget -text]
    focus $base.cpd48.03
}

proc vTcl:get_values {base text} {
    global vTcl
    ## Remove the last character which is a \n the text widget puts in for
    ## some reason.
    set string [$text get 0.0 end]
    set end [expr [string length $string] - 1]
    set text [string range $string 0 [expr $end - 1]]
    set values [split $text "\n"]
    set vTcl(x,$base) $values
    destroy $base
}


proc vTcl:values_window {base title target} {
    # Added by Rozen based on vTcl:text_window.
    global vTcl
    toplevel $base -class Toplevel
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 400x289+[expr $vTcl(mouse,X)-130]+[expr $vTcl(mouse,Y)-20]
    wm maxsize $base 1265 994
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title

    ScrolledWindow $base.cpd48
    text $base.cpd48.03 -width 8 -background white -wrap none \
        -insertborderwidth 3  ;# Rozen
    $base.cpd48 setwidget $base.cpd48.03

    # avoid syntax coloring here (automatic for text widgets in vTcl)
    global $base.cpd48.03.nosyntax
    set $base.cpd48.03.nosyntax 1

    frame $base.butfr

    ::vTcl::OkButton $base.butfr.but52 \
    -command "vTcl:get_values $base $base.cpd48.03"
    vTcl:set_balloon $base.butfr.but52 "Save Changes"

    ::vTcl::CancelButton $base.butfr.but53 -command "destroy $base"
    vTcl:set_balloon $base.butfr.but53 "Discard Changes"

    bind $base <Key-Escape> "$base.butfr.but53 invoke"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.butfr -side top -anchor e
    pack $base.butfr.but53 -side right
    pack $base.butfr.but52 -side right
    pack $base.cpd48 -fill both -expand 1
    #pack $base.cpd48.03     Rozen

    #$base.cpd48.03 insert end [$target cget values]  ;# Needs changed to values.
    vTcl:load_text_box $base.cpd48.03 $target "values"
    focus $base.cpd48.03
}

proc vTcl:load_text_box {box target option} {
    # Rozen takes a list and puts it into the text box placing a
    # newline at the end of each item in the option list.
    set o_list [$target cget -$option]
    set str ""
    foreach item $o_list {
        append str $item "\n"
    }
        $box insert end $str
}

namespace eval ::vTcl::input::lineInput {

proc getLine {title description legend args} {
    set base .vTcl.lineInput
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm focusmodel $top passive
    wm geometry $top 5x5+341+318; update
    wm maxsize $top 1284 1006
    wm minsize $top 111 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "$title"
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm transient .vTcl.lineInput .vTcl
    wm protocol $top WM_DELETE_WINDOW "set ::${top}::status cancel"

    bind $top <KeyPress-Return> "set ::${top}::status ok"
    bind $top <KeyPress-Escape> "set ::${top}::status cancel"

    set ::${top}::description $description
    set ::${top}::legend $legend
    set ::${top}::status ""

    label $top.lab80 \
        -anchor w -textvariable "$top\::description" -justify left
    frame $top.fra81 \
        -borderwidth 2 -height 75 -width 125
    set site_3_0 $top.fra81
    entry $site_3_0.ent83 \
        -background white -textvariable "$top\::entry"
    vTcl:DefineAlias "$site_3_0.ent83" "LineEntry" vTcl:WidgetProc "$top" 1
    label $site_3_0.lab82 \
        -anchor w -textvariable "$top\::legend" -justify left
    pack $site_3_0.ent83 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 5 -pady 5 \
        -side right
    pack $site_3_0.lab82 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left
    frame $top.fra84 \
        -borderwidth 2 -height 75 -width 125
    set site_3_0 $top.fra84
    button $site_3_0.but85 -command "set ::${top}::status ok" \
        -pady 0 -text OK -width 8
    button $site_3_0.but86 -command "set ::${top}::status cancel" \
        -pady 0 -text Cancel -width 8
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab80 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -pady 5 -side top
    pack $top.fra81 \
        -in $top -anchor center -expand 0 -fill x -side top
    pack $top.fra84 \
        -in $top -anchor center -expand 0 -fill none -side top

    vTcl:FireEvent $base <<Ready>>
    wm deiconify $top
    wm geometry $top {}

    grab set $base
    vwait ::${top}::status
    grab release $base
    if {[set ::${top}::status] == "cancel"} {
        destroy $base
        return ""
    }

    destroy $base
    return [set ::${top}::entry]
}
}; ## namespace eval ::vTcl::input::lineInput

namespace eval ::vTcl::input::listboxSelect {

proc updateSelection {top} {
    upvar ::${top}::selectedItems selectedItems

    set selected [$top.SelectListbox curselection]
    set selectedItems ""

    foreach index $selected {
        lappend selectedItems [$top.SelectListbox get $index]
    }

    if {[lempty $selectedItems]} {
        $top.SelectOK configure -state disabled
    } else {
        $top.SelectOK configure -state normal
    }
}

proc select {contents title {selectMode single} args} {
    set base .vTcl.listboxSelect
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
     set top $base

    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm focusmodel $top passive
    wm withdraw $base
    wm geometry $top 339x247+158+260; update
    wm maxsize $top 1284 1006
    wm minsize $top 111 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top $title
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm transient .vTcl.listboxSelect .vTcl
    wm protocol $top WM_DELETE_WINDOW "set ::${top}::status cancel"

    bind $top <KeyPress-Return> "set ::${top}::status ok"
    bind $top <KeyPress-Escape> "set ::${top}::status cancel"

    set ::${top}::listContents $contents
    set ::${top}::status ""
    set ::${top}::selectedItems ""

    frame $top.fra87 \
        -borderwidth 2
    set site_3_0 $top.fra87
    label $site_3_0.lab88 \
        -text {Select item:} -justify left -anchor w
    vTcl:DefineAlias "$site_3_0.lab88" "SelectLabel" vTcl:WidgetProc "$top" 1
    pack $site_3_0.lab88 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left
    ScrolledWindow $top.fra82 \
        -borderwidth 2 -auto horizontal
    set site_3_0 $top.fra82
    listbox $site_3_0.lis83 \
        -background white -listvariable "::${top}::listContents" \
        -selectmode $selectMode -height 2
    vTcl:DefineAlias "$site_3_0.lis83" "SelectListbox" vTcl:WidgetProc "$top" 1
    $top.fra82 setwidget $site_3_0.lis83
    bind $site_3_0.lis83 <<ListboxSelect>> {
        ::vTcl::input::listboxSelect::updateSelection [winfo toplevel %W]
    }
    frame $top.fra84 \
        -borderwidth 2
    set site_3_0 $top.fra84
    button $site_3_0.but85 -state disabled \
        -pady 0 -text OK -width 8 -command "set ::${top}::status ok"
    vTcl:DefineAlias "$site_3_0.but85" "SelectOK" vTcl:WidgetProc "$top" 1
    button $site_3_0.but86 \
        -pady 0 -text Cancel -width 8 -command "set ::${top}::status cancel"
    vTcl:DefineAlias "$site_3_0.but86" "SelectCancel" vTcl:WidgetProc "$top" 1
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra87 \
        -in $top -anchor center -expand 0 -fill x -padx 2 -side top
    pack $top.fra82 \
        -in $top -anchor center -expand 1 -fill both -side top
    pack $top.fra84 \
        -in $top -anchor center -expand 0 -fill none -side top

    vTcl:FireEvent $base <<Ready>>
    vTcl:center $base 339 247
    wm deiconify $base

    foreach {option value} $args {
        switch -- $option {
            -oktext {
                 $top.SelectOK configure -text $value
            }
            -canceltext {
                 $top.SelectCancel configure -text $value
            }
            -headertext {
                 $top.SelectLabel configure -text $value
            }
            -selecteditems {
                 set index 0
                 foreach item $contents {
                     set found [lsearch -exact $value $item]
                     if {$found != -1} {
                         $top.SelectListbox selection set $index
                     }
                     incr index
                 }
                 ::vTcl::input::listboxSelect::updateSelection $top
            }
        }
    }

    grab set $base
    vwait ::${top}::status
    grab release $base
    if {[vTcl:at ::${top}::status] == "cancel"} {
        destroy $base
        return ""
    }

    destroy $base
    return [vTcl:at ::${top}::selectedItems]
}
} ; ## namespace eval ::vTcl::input::listboxSelect


