##############################################################################
# $Id: compounds.tcl,v 1.16 2003/05/20 05:14:18 cgavin Exp $
#
# compounds.tcl - bundled system compound widgets
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

# Rozen this is where they define compound widget which they ship with
# vtcl. There appears to be one namesspace for each one.

# Obviously I will start here. I will want to have a scrollable list
# box using ttkwidgets since they are abailiable in tk 8.5.

# This also probably means that I will need to go back and put in the
# compound menue.

namespace eval {vTcl::compounds::system::{Scrollable Listbox}} {

set bindtags {}

set source .top80.cpd85

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-background 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-command 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -height 30 -width 30
    vTcl:DefineAlias "$target" "Frame8" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    listbox $site_3_0.01  -background white -xscrollcommand "$site_3_0.02 set" -yscrollcommand "$site_3_0.03 set"
    vTcl:DefineAlias "$site_3_0.01" "Listbox1" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_3_0.02  -command "$site_3_0.01 xview" -orient horizontal
    vTcl:DefineAlias "$site_3_0.02" "Scrollbar3" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_3_0.03  -command "$site_3_0.01 yview"
    vTcl:DefineAlias "$site_3_0.03" "Scrollbar4" vTcl:WidgetProc "Toplevel1" 1
    grid $site_3_0.01  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw
    grid $site_3_0.02  -in $site_3_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $site_3_0.03  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Labeled Frame}} {

set bindtags {}

set source .top80.cpd81

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.01
    namespace eval ::widgets::$site_4_0.fra82 {
        array set save {-borderwidth 1 -height 1}
    }
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-borderwidth 1 -text 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 2
    vTcl:DefineAlias "$target" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    frame $site_3_0.01  -borderwidth 2 -height 75 -relief groove -width 125
    vTcl:DefineAlias "$site_3_0.01" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.01
    frame $site_4_0.fra82  -borderwidth 2 -height 10
    vTcl:DefineAlias "$site_4_0.fra82" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    frame $site_4_0.fra83  -background #cccccc -borderwidth 2 -height 75 -width 150
    vTcl:DefineAlias "$site_4_0.fra83" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    pack $site_4_0.fra82  -in $site_4_0 -anchor center -expand 0 -fill none -side top
    pack $site_4_0.fra83  -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -pady 2  -side top
    label $site_3_0.02  -borderwidth 1 -text {TODO: type label here}
    vTcl:DefineAlias "$site_3_0.02" "Label1" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01  -in $site_3_0 -anchor center -expand 1 -fill both -padx 5 -pady 5  -side top
    place $site_3_0.02  -x 15 -y 0 -anchor nw -bordermode ignore

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Scrollable Text}} {

set bindtags {}

set source .top82.cpd83

set class Frame

set procs {}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-height 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }

}


proc bindtagsCmd {} {}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -height 30 -width 30
    vTcl:DefineAlias "$target" "Frame1" vTcl:WidgetProc "Toplevel2" 1
    set site_3_0 $target
    scrollbar $site_3_0.01  -command "$site_3_0.03 xview" -orient horizontal
    vTcl:DefineAlias "$site_3_0.01" "Scrollbar1" vTcl:WidgetProc "Toplevel2" 1
    scrollbar $site_3_0.02  -command "$site_3_0.03 yview"
    vTcl:DefineAlias "$site_3_0.02" "Scrollbar2" vTcl:WidgetProc "Toplevel2" 1
    text $site_3_0.03  -height 10 -width 20 -xscrollcommand "$site_3_0.01 set"  -yscrollcommand "$site_3_0.02 set"
    vTcl:DefineAlias "$site_3_0.03" "Text1" vTcl:WidgetProc "Toplevel2" 1
    grid $site_3_0.01  -in $site_3_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $site_3_0.02  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $site_3_0.03  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Label And Entry}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1 -height 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-cursor 1}
    }

}


proc bindtagsCmd {} {}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 1 -height 30
    vTcl:DefineAlias "$target" "Frame5" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    label $site_3_0.01  -anchor w -text Label:
    vTcl:DefineAlias "$site_3_0.01" "Label2" vTcl:WidgetProc "Toplevel1" 1
    entry $site_3_0.02  -cursor {}
    vTcl:DefineAlias "$site_3_0.02" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01  -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -pady 2  -side left
    pack $site_3_0.02  -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -pady 2  -side right

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Split Vertical Panel}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-background 1 -borderwidth 1 -relief 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -background #000000 -height 100 -width 200
    vTcl:DefineAlias "$target" "Frame8" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    frame $site_3_0.01  -background #9900991B99FE
    vTcl:DefineAlias "$site_3_0.01" "Frame5" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.02  -background #9900991B99FE
    vTcl:DefineAlias "$site_3_0.02" "Frame6" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.03  -background #ff0000 -borderwidth 2 -relief raised
    vTcl:DefineAlias "$site_3_0.03" "Frame7" vTcl:WidgetProc "Toplevel1" 1
    bind $site_3_0.03 <B1-Motion> {
        set root [ split %W . ]
    set nb [ llength $root ]
    incr nb -1
    set root [ lreplace $root $nb $nb ]
    set root [ join $root . ]
    set height [ winfo height $root ].0

    set val [ expr (%Y - [winfo rooty $root]) /$height ]

    if { $val >= 0 && $val <= 1.0 } {

        place $root.01 -relheight $val
        place $root.03 -rely $val
        place $root.02 -relheight [ expr 1.0 - $val ]
    }
    }
    place $site_3_0.01  -x 0 -y 0 -relwidth 1 -height -1 -relheight 0.6595 -anchor nw  -bordermode ignore
    place $site_3_0.02  -x 0 -y 0 -rely 1 -relwidth 1 -height -1 -relheight 0.3405 -anchor sw  -bordermode ignore
    place $site_3_0.03  -x 0 -relx 0.9 -y 0 -rely 0.6595 -width 10 -height 10 -anchor e  -bordermode ignore

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Split Horizontal Panel}} {

set bindtags {}

set source .top80.cpd81

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-background 1 -borderwidth 1 -relief 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -background #000000 -height 100 -width 200
    vTcl:DefineAlias "$target" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    frame $site_3_0.01  -background #9900991B99FE
    vTcl:DefineAlias "$site_3_0.01" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.02  -background #9900991B99FE
    vTcl:DefineAlias "$site_3_0.02" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.03  -background #ff0000 -borderwidth 2 -relief raised
    vTcl:DefineAlias "$site_3_0.03" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    bind $site_3_0.03 <B1-Motion> {
        set root [ split %W . ]
    set nb [ llength $root ]
    incr nb -1
    set root [ lreplace $root $nb $nb ]
    set root [ join $root . ]
    set width [ winfo width $root ].0

    set val [ expr (%X - [winfo rootx $root]) /$width ]

    if { $val >= 0 && $val <= 1.0 } {

        place $root.01 -relwidth $val
        place $root.03 -relx $val
        place $root.02 -relwidth [ expr 1.0 - $val ]
    }
    }
    place $site_3_0.01  -x 0 -y 0 -width -1 -relwidth 0.6595 -relheight 1 -anchor nw  -bordermode ignore
    place $site_3_0.02  -x 0 -relx 1 -y 0 -width -1 -relwidth 0.3405 -relheight 1 -anchor ne  -bordermode ignore
    place $site_3_0.03  -x 0 -relx 0.6595 -y 0 -rely 0.9 -width 10 -height 10 -anchor s  -bordermode ignore

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Menu Bar}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.01.02 {
        array set save {-activeborderwidth 1 -borderwidth 1 -font 1 -tearoff 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-anchor 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.03.04 {
        array set save {-activeborderwidth 1 -borderwidth 1 -font 1 -tearoff 1}
    }
    namespace eval ::widgets::$site_3_0.05 {
        array set save {-anchor 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.05.06 {
        array set save {-activeborderwidth 1 -borderwidth 1 -font 1 -tearoff 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 1 -height 25 -relief sunken -width 225
    vTcl:DefineAlias "$target" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    menubutton $site_3_0.01  -anchor w -menu "$site_3_0.01.02" -padx 4 -pady 3 -text File -width 4
    vTcl:DefineAlias "$site_3_0.01" "Menubutton1" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.01.02  -activeborderwidth 1 -borderwidth 1 -font {Tahoma 8} -tearoff 0
    vTcl:DefineAlias "$site_3_0.01.02" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.01.02 add command  -accelerator Ctrl+O -label Open
    $site_3_0.01.02 add command  -accelerator Ctrl+W -label Close
    menubutton $site_3_0.03  -anchor w -menu "$site_3_0.03.04" -padx 4 -pady 3 -text Edit -width 4
    vTcl:DefineAlias "$site_3_0.03" "Menubutton2" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.03.04  -activeborderwidth 1 -borderwidth 1 -font {Tahoma 8} -tearoff 0
    vTcl:DefineAlias "$site_3_0.03.04" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.03.04 add command  -accelerator Ctrl+X -label Cut
    $site_3_0.03.04 add command  -accelerator Ctrl+C -label Copy
    $site_3_0.03.04 add command  -accelerator Ctrl+V -label Paste
    $site_3_0.03.04 add command  -accelerator Del -label Delete
    menubutton $site_3_0.05  -anchor w -menu "$site_3_0.05.06" -padx 4 -pady 3 -text Help -width 4
    vTcl:DefineAlias "$site_3_0.05" "Menubutton3" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.05.06  -activeborderwidth 1 -borderwidth 1 -font {Tahoma 8} -tearoff 0
    vTcl:DefineAlias "$site_3_0.05.06" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.05.06 add command  -label About
    pack $site_3_0.01  -in $site_3_0 -anchor center -expand 0 -fill none -side left
    pack $site_3_0.03  -in $site_3_0 -anchor center -expand 0 -fill none -side left
    pack $site_3_0.05  -in $site_3_0 -anchor center -expand 0 -fill none -side right

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Scrollable Canvas}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -highlightthickness 1 -relief 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }

}


proc bindtagsCmd {} {}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 1 -height 182 -width 222
    vTcl:DefineAlias "$target" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    scrollbar $site_3_0.01  -command "$site_3_0.03 xview" -orient horizontal
    vTcl:DefineAlias "$site_3_0.01" "Scrollbar1" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_3_0.02  -command "$site_3_0.03 yview"
    vTcl:DefineAlias "$site_3_0.02" "Scrollbar2" vTcl:WidgetProc "Toplevel1" 1
    canvas $site_3_0.03  -borderwidth 2 -closeenough 1.0 -height 100 -highlightthickness 1  -relief sunken -width 100 -xscrollcommand "$site_3_0.01 set"  -yscrollcommand "$site_3_0.02 set"
    vTcl:DefineAlias "$site_3_0.03" "Canvas1" vTcl:WidgetProc "Toplevel1" 1
    grid $site_3_0.01  -in $site_3_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $site_3_0.02  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $site_3_0.03  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Single Document Application}} {

set bindtags {
    _TopLevel
}

set source .top81

set class Toplevel

set procs {}


proc bindtagsCmd {} {
#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
        vTcl:Toplevel:WidgetProc %W endmodal
    } else {
        destroy %W; if {$_topcount == 0} {exit}
    }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$target.fra86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $target.fra86
    namespace eval ::widgets::$site_3_0.lab87 {
        array set save {-relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.lab88 {
        array set save {-relief 1 -text 1}
    }
    namespace eval ::widgets::$target.fra89 {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_3_0 $target.fra89
    namespace eval ::widgets::$site_3_0.lab90 {
        array set save {-background 1 -text 1}
    }
    namespace eval ::widgets::$target.m82 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    set site_3_0 $target.m82
    namespace eval ::widgets::$site_3_0.men83 {
        array set save {-activeborderwidth 1 -tearoff 1}
    }
    set site_3_0 $target.m82
    namespace eval ::widgets::$site_3_0.men84 {
        array set save {-activeborderwidth 1 -tearoff 1}
    }
    set site_3_0 $target.m82
    namespace eval ::widgets::$site_3_0.men85 {
        array set save {-activeborderwidth 1 -tearoff 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    if {![info exists ::vTcl(running)]} {
        return [eval ::vTcl:DefineAlias $target $alias $args]
    }
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    vTclWindow.top81 $target
}


proc procsCmd {} {}


proc vTclWindow.top81 {base} {
    if {$base == ""} {
        set base .top81
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel  -menu "$top.m82"
    wm focusmodel $top passive
    wm geometry $top 396x265+269+257; update
    wm maxsize $top 1284 986
    wm minsize $top 111 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "SDI Application"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    bind $top <Control-Key-q> {
        exit
    }
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    frame $top.fra86  -borderwidth 2 -height 75 -width 125
    vTcl:DefineAlias "$top.fra86" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.fra86
    label $site_3_0.lab87  -relief groove -text {Line 1 Col 1}
    vTcl:DefineAlias "$site_3_0.lab87" "Label1" vTcl:WidgetProc "Toplevel1" 1
    label $site_3_0.lab88  -relief groove -text {Status Info}
    vTcl:DefineAlias "$site_3_0.lab88" "Label2" vTcl:WidgetProc "Toplevel1" 1
    grid $site_3_0.lab87  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 1
    grid $site_3_0.lab88  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 1  -sticky ew
    frame $top.fra89  -background #cccccc -height 75 -width 125
    vTcl:DefineAlias "$top.fra89" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.fra89
    label $site_3_0.lab90  -background #cccccc -text {TODO: Your client area here.}
    vTcl:DefineAlias "$site_3_0.lab90" "Label3" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.lab90  -in $site_3_0 -anchor center -expand 1 -fill none -side top
    menu $top.m82  -activeborderwidth 1 -borderwidth 1 -tearoff 1
    $top.m82 add cascade  -menu "$top.m82.men83" -label File
    set site_3_0 $top.m82
    menu $site_3_0.men83  -activeborderwidth 1 -tearoff 0
    $site_3_0.men83 add command  -accelerator {Ctrl + O} -command {TODO}  -label Open...
    $site_3_0.men83 add command  -accelerator {Ctrl + S} -command {TODO}  -label Save
    $site_3_0.men83 add command  -command {TODO} -label {Save As...}
    $site_3_0.men83 add separator
    $site_3_0.men83 add command  -accelerator {Ctrl + P} -command {TODO}  -label Print...
    $site_3_0.men83 add separator
    $site_3_0.men83 add command  -accelerator {Ctrl + Q} -command {TODO}  -label Exit -command exit
    $top.m82 add cascade  -menu "$top.m82.men84" -label Edit
    set site_3_0 $top.m82
    menu $site_3_0.men84  -activeborderwidth 1 -tearoff 0
    $site_3_0.men84 add command  -accelerator {Ctrl + X} -command {TODO}  -label Cut
    $site_3_0.men84 add command  -accelerator {Ctrl + C} -command {TODO}  -label Copy
    $site_3_0.men84 add command  -accelerator {Ctrl + V} -command {TODO}  -label Paste
    $site_3_0.men84 add separator
    $site_3_0.men84 add command  -accelerator {Ctrl + A} -command {TODO}  -label {Select All}
    $site_3_0.men84 add command  -command {TODO} -label {Select None}
    $top.m82 add cascade  -menu "$top.m82.men85" -label Help
    set site_3_0 $top.m82
    menu $site_3_0.men85  -activeborderwidth 1 -tearoff 0
    $site_3_0.men85 add command  -accelerator F1 -command {TODO}  -label Index
    $site_3_0.men85 add separator
    $site_3_0.men85 add command  -accelerator {Shift + F1}  -command {tk_messageBox -message "My Application (C) Myself" -title "My Application"}  -label About...
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra86  -in $top -anchor center -expand 0 -fill x -side bottom
    grid columnconf $top.fra86 1 -weight 1
    pack $top.fra89  -in $top -anchor center -expand 1 -fill both -side top

    vTcl:FireEvent $base <<Ready>>
}

}

#############################################################################
## Compound:: Image listbox
namespace eval {vTcl::compounds::internal::{Image Listbox}} {

set bindtags {}

set libraries {
    bwidget
    core
}

set source .top72.cpd73

set class MegaWidget

set procs {
    ::imagelistbox::cleanList
    ::imagelistbox::getThumbnail
    ::imagelistbox::myWidgetProc
    ::imagelistbox::init
    ::imagelistbox::configureCmd
    ::imagelistbox::configureAllCmd
    ::imagelistbox::cgetCmd
    ::imagelistbox::configureOptionCmd
    ::imagelistbox::getListbox
    ::imagelistbox::fillCmd
    ::imagelistbox::setMouseOver
    ::imagelistbox::selectionCmd
    ::imagelistbox::itemsCmd
    ::imagelistbox::itemconfigureCmd
    ::imagelistbox::itemcgetCmd
    ::imagelistbox::button1
    ::imagelistbox::button1-release
    ::imagelistbox::yviewCmd
    ::imagelistbox::deleteCmd
}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-class 1 -widgetProc 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.scr79 {
        array set save {-auto 1}
    }
    namespace eval ::widgets::$site_3_0.scr79.f.lis80 {
        array set save {-background 1 -deltay 1 -height 1 -padx 1}
    }
    namespace eval ::widgets::$target {
        set sourceFilename "D:/cygwin/home/cgavin/vtcl/Projects/imagelistbox/imagelistbox_compound.tcl"
        set compoundName {Image Listbox}
    }

}


proc vTcl:DefineAlias {target alias args} {
    if {![info exists ::vTcl(running)]} {
        return [eval ::vTcl:DefineAlias $target $alias $args]
    }
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    ::imagelistbox::init $target

    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    vTcl::widgets::core::megawidget::createCmd $target  -widgetProc ::imagelistbox::myWidgetProc
    vTcl:DefineAlias "$target" "MegaWidget1" vTcl::widgets::core::megawidget::widgetProc "Toplevel1" 1
    set site_3_0 $target
    vTcl::widgets::bwidgets::scrolledwindow::createCmd $site_3_0.scr79  -auto horizontal
    vTcl:DefineAlias "$site_3_0.scr79" "ScrolledWindow1" vTcl:WidgetProc "Toplevel1" 1
    ListBox $site_3_0.scr79.f.lis80  -background white -deltay 32 -height 0 -padx 32
    vTcl:DefineAlias "$site_3_0.scr79.f.lis80" "ListBox1" vTcl:WidgetProc "Toplevel1" 1
    bind $site_3_0.scr79.f.lis80 <Configure> {
        ListBox::_resize  %W
    }
    bind $site_3_0.scr79.f.lis80 <Destroy> "
        foreach tempImage \[set ::imagelistbox::${target}::tempImages\] {image delete \$tempImage}
        ListBox::_destroy %W"
    pack $site_3_0.scr79.f.lis80 -fill both -expand 1
    $site_3_0.scr79 setwidget $site_3_0.scr79.f
    pack $site_3_0.scr79  -in $site_3_0 -anchor center -expand 1 -fill both -side top

}


proc procsCmd {} {
#############################################################################
## Procedure:  ::imagelistbox::cleanList

namespace eval ::imagelistbox {
proc cleanList {w} {
upvar ::imagelistbox::${w}::tempImages tempImages
foreach tempImage $tempImages {
    image delete $tempImage
}
set tempImages {}

set l [getListbox $w]
$l delete [$l items]
}
}

#############################################################################
## Procedure:  ::imagelistbox::getThumbnail

namespace eval ::imagelistbox {
proc getThumbnail {w source {size 32}} {
   set source_width  [image width $source]
   set source_height [image height $source]

   if {$source_width <= $size && $source_height <= $size} {
       ## right size or smaller
       return $source
   }

   if {$source_width > $source_height} {
      set target_width $size
      set target_height [expr $size * $source_height / $source_width]
   } else {
      set target_height $size
      set target_width [expr $size * $source_width / $source_height]
   }

   set target [image create photo -width $size -height $size]

   set deltax [expr ($size - $target_width)  / 2]
   set deltay [expr ($size - $target_height) / 2]

   $target copy $source -from 0 0 [expr $source_width - 1] [expr $source_height - 1]  -to   $deltax $deltay [expr $target_width - 1 + $deltax ]  [expr $target_height - 1 + $deltay]  -subsample [expr $source_width  / $target_width]  [expr $source_height / $target_height]

   upvar ::imagelistbox::${w}::tempImages tempImages
   lappend tempImages $target

   return $target
}
}

#############################################################################
## Procedure:  ::imagelistbox::myWidgetProc

namespace eval ::imagelistbox {
proc myWidgetProc {w args} {
set command [lindex $args 0]
set args [lrange $args 1 end]

return [eval ${command}Cmd $w $args]
}
}

#############################################################################
## Procedure:  ::imagelistbox::init

namespace eval ::imagelistbox {
proc init {w} {
namespace eval ::imagelistbox::${w} {
    variable tempImages; set tempImages {}
    variable mouseOver;  set mouseOver 0
}
}
}

#############################################################################
## Procedure:  ::imagelistbox::configureCmd

namespace eval ::imagelistbox {
proc configureCmd {w args} {
if {[llength $args] == 0} {
    return [configureAllCmd $w]
} elseif {[llength $args] == 1} {
    return [configureOptionCmd $w $args]
}

foreach {option value} $args {
    if {$option == "-mouseover"} {
        setMouseOver $w $value
    } else {
        ## delegate options to listbox
        [getListbox $w] configure $option $value
    }
}
}
}

#############################################################################
## Procedure:  ::imagelistbox::configureAllCmd

namespace eval ::imagelistbox {
proc configureAllCmd {w} {
set result [list [configureCmd $w -mouseover]]
set result [concat $result [[getListbox $w] configure]]

return $result
}
}

#############################################################################
## Procedure:  ::imagelistbox::cgetCmd

namespace eval ::imagelistbox {
proc cgetCmd {w args} {
set option $args
if {$option == "-mouseover"} {
    return [set ::imagelistbox::${w}::mouseOver]
}

return [[getListbox $w] cget $option]
}
}

#############################################################################
## Procedure:  ::imagelistbox::configureOptionCmd

namespace eval ::imagelistbox {
proc configureOptionCmd {w option} {
if {$option == "-mouseover"} {
    return [list -mouseover mouseOver MouseOver 0 [set ::imagelistbox::${w}::mouseOver]]
}

set result [[getListbox $w] configure $option]
return $result
}
}

#############################################################################
## Procedure:  ::imagelistbox::getListbox

namespace eval ::imagelistbox {
proc getListbox {w} {
return $w.scr79.f.lis80
}
}

#############################################################################
## Procedure:  ::imagelistbox::fillCmd

namespace eval ::imagelistbox {
proc fillCmd {w imageTextList} {
cleanList $w
set l [getListbox $w]

set i 0
foreach {image text} $imageTextList {
    set reference item_$i
    if {$image == ""} {
        $l insert end $reference -text $text
    } else {
        set thumbnail [getThumbnail $w $image]
        $l insert end $reference -image $thumbnail -text $text
    }
    incr i
}

$l bindImage <Button-1> "::imagelistbox::button1 $w"
$l bindText  <Button-1> "::imagelistbox::button1 $w"
$l bindImage <ButtonRelease-1> "::imagelistbox::button1-release $w"
$l bindText  <ButtonRelease-1> "::imagelistbox::button1-release $w"
}
}

#############################################################################
## Procedure:  ::imagelistbox::setMouseOver

namespace eval ::imagelistbox {
proc setMouseOver {w value} {
namespace eval ::imagelistbox::${w} "set mouseOver $value"

set l [getListbox $w]
if {$value} {
    $l bindImage <Enter> "$l selection set"
    $l bindText <Enter> "$l selection set"
} else {
    $l bindImage <Enter> ""
    $l bindText <Enter> ""
}
}
}

#############################################################################
## Procedure:  ::imagelistbox::selectionCmd

namespace eval ::imagelistbox {
proc selectionCmd {w args} {
eval [getListbox $w] selection $args
}
}

#############################################################################
## Procedure:  ::imagelistbox::itemsCmd

namespace eval ::imagelistbox {
proc itemsCmd {w args} {
eval [getListbox $w] items $args
}
}

#############################################################################
## Procedure:  ::imagelistbox::itemcgetCmd

namespace eval ::imagelistbox {
proc itemcgetCmd {w args} {
eval [getListbox $w] itemcget $args
}
}

#############################################################################
## Procedure: ::imagelistbox::itemconfigureCmd

namespace eval ::imagelistbox {
proc itemconfigureCmd {w args} {
eval [getListbox $w] itemconfigure $args
}
}

#############################################################################
## Procedure:  ::imagelistbox::button1

namespace eval ::imagelistbox {
proc button1 {w node} {
set l [getListbox $w]
focus $l
$l selection set $node
}
}

#############################################################################
## Procedure:  ::imagelistbox::button1-release

namespace eval ::imagelistbox {
proc button1-release {w node} {
vTcl:FireEvent [winfo parent $w] <<ListboxSelect>>
}
}

#############################################################################
## Procedure:  ::imagelistbox::yviewCmd

namespace eval ::imagelistbox {
proc yviewCmd {w args} {
eval [getListbox $w] yview $args
}
}

#############################################################################
## Procedure:  ::imagelistbox::deleteCmd

namespace eval ::imagelistbox {
proc deleteCmd {w args} {
eval [getListbox $w] delete $args
}
}

}
}


