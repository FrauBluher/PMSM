##############################################################################
# $Id: attrbar.tcl,v 1.16 2005/11/12 01:16:50 kenparkerjr Exp $
#
# attrbar.tcl - attribute icon bar under menus / attributes in main window
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

proc vTcl:fill_font_menu {menu} {
    global vTcl
    set fams [lsort [font families]]
        if { [llength $fams] > 26 } {
                foreach i "a b c d e f g h i j k l m n o p q r s t u v w x y z" {
                        set submenu "$menu.$i"
                        menu $submenu -tearoff 0
                        $menu add cascade -label $i -menu $submenu
                        foreach x $fams {
                                if { [string first $i [string tolower $x]] == 0 } {
                                        $submenu add radiobutton -label $x -variable vTcl(w,font) \
                                        -value $x -command "vTcl:set_font base \$vTcl(w,widget) \{$x\}"
                                }
                        }
                }
        } else {
                foreach i $fams {
                        $menu add radiobutton -label $i -variable vTcl(w,font) \
                        -value $i -command "vTcl:set_font base \$vTcl(w,widget) \{$i\}"
                }
        }
}

proc vTcl:fill_fontsize_menu {menu} {
    global vTcl
    foreach i {8 9 10 11 12 14 18 24 36 48 72} {
        $menu add radiobutton -label $i -variable vTcl(w,font) \
        -value $i -command "vTcl:set_font size \$vTcl(w,widget) $i"
    }
    $menu add separator
    $menu add command -label other
}

proc vTcl:set_justify {widget option} {
    catch {
        $widget conf -justify $option
    }
}

proc vTcl:set_font {which widget option} {
    global vTcl
    if {[catch {set was [$widget cget -font]}]} {return}
    set base [lindex $was 0]
    set size [lindex $was 1]
    set style [lindex $was 2]
    switch $which {
        base {
            $widget conf -font [list $option $size $style]
        }
        size {
            $widget conf -font [list $base $option $style]
        }
        style {
            set style ""
            foreach i {bold italic underline} {
                if {$vTcl(w,fontstyle,$i)} {
                    lappend style $i
                }
            }
            $widget conf -font [list $base $size $style]
        }
    }
    set vTcl(w,opt,-font) [$widget cget -font]
    vTcl:prop:save_opt $widget -font vTcl(w,opt,-font)
}

proc vTcl:widget_set_relief {relief} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {$vTcl(w,widget) cget -relief}]} {return}
    $vTcl(w,widget) conf -relief $relief
    vTcl:prop:save_opt $vTcl(w,widget) -relief vTcl(w,opt,-relief)
}

proc vTcl:widget_set_border {border} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {$vTcl(w,widget) cget -bd}]} {return}
    $vTcl(w,widget) conf -bd $border
}

proc vTcl:widget_set_anchor {anchor} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {$vTcl(w,widget) cget -anchor}]} {return}
    $vTcl(w,widget) conf -anchor $anchor
    vTcl:prop:save_opt $vTcl(w,widget) -anchor vTcl(w,opt,-anchor)
}

proc vTcl:widget_set_pack_side {side} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    set mgr [winfo manager $vTcl(w,widget)]
    if {$mgr != "pack"} {return}
    pack configure $vTcl(w,widget) -side $side
    vTcl:place_handles $vTcl(w,widget)
}

proc vTcl:widget_set_fg {target} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {set fg [$vTcl(w,widget) cget -foreground]}]} {return}
    set vTcl(w,opt,-foreground) $fg
    vTcl:show_color $target -foreground vTcl(w,opt,-foreground) $target
}

proc vTcl:widget_set_bg {target} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {set bg [$vTcl(w,widget) cget -background]}]} {return}
    set vTcl(w,opt,-background) $bg
    vTcl:show_color $target -background vTcl(w,opt,-background) $target
}

proc vTcl:set_manager {mgr} {
    global vTcl
    foreach i $vTcl(w,mgrs) {
        if { $i == $mgr } {
            $vTcl(mgrs,$i,widget) configure -relief sunken
        } else {
            $vTcl(mgrs,$i,widget) configure -relief raised
        }
    }
    set vTcl(w,def_mgr) $mgr
}

proc vTcl:attrbar_color {target} {
    set dbg [lindex [. conf -bg] 3]
    if {[catch {set fg [$target cget -fg]}] == 1} {
        set fg $dbg
    } else {
        set fg [$target cget -fg]
    }
    if {[catch {set bg [$target cget -bg]}] == 1} {
        set fg $dbg
    } else {
        set bg [$target cget -bg]
    }
    catch {
        .vTcl.attr.010.lab41 conf -bg $fg
        .vTcl.attr.010.lab42 conf -bg $bg
    }
}

#   vTcl:attrbar:toggle_console
#
#   Handle the display and hiding of the console
#
#   First, check to see if the variable, "vTcl(attrbar,console_state)"
#   even exists.  If not, we need to initialize tkcon for
#   this session.

proc vTcl:attrbar:toggle_console {} {
    # Routine to toggle the Tcl console on and off. Since I removed
    # the toolbar buttons from the main menu, I better not refer to
    # them in here.  Actually I shoule get rid of the whole consule
    # stuff. Rozen
    global vTcl
    if {![info exists vTcl(attrbar,console_state)]} {
    ::vTcl::InitTkcon
    tkcon show
    set vTcl(attrbar,console_state) 1
    } elseif {!$vTcl(attrbar,console_state)} {
        tkcon show
        #.vTcl.attr.console.console_toggle configure -relief sunken
        set vTcl(attrbar,console_state) 1
    } elseif {$vTcl(attrbar,console_state)} {
        tkcon hide
        #.vTcl.attr.console.console_toggle configure -relief flat
        set vTcl(attrbar,console_state) 0
    }
}

#If you want to change the appearance of the main toolbar then you can use
#the misc.tcl procs toolbar_menubutton and toolbar_button.
proc vTcl:attrbar {args} {
    global vTcl tk_version
    if {[expr [lsearch -exact $vTcl(gui,showlist) .vTcl.tkcon] != -1]} {
    vTcl:attrbar:toggle_console
    }

    set base .vTcl
    frame .vTcl.attr \
        -borderwidth 1 -height 10 -relief ridge  -width 30
    pack .vTcl.attr \
        -expand 1  -side top
# FILE BAR----------------------------------------------------------------------
    frame .vTcl.attr.filebar \
        -borderwidth 1 -height 20 -width 20 -relief groove
    pack .vTcl.attr.filebar \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0  -pady 0 \
    -side left

    vTcl:toolbar_button .vTcl.attr.filebar.new -image image5\
        -command vTcl:new
    vTcl:set_balloon .vTcl.attr.filebar.new "New Project"
    pack .vTcl.attr.filebar.new -side left -padx 1 -pady 1

    vTcl:toolbar_button  .vTcl.attr.filebar.open -image image7 \
        -command vTcl:open
    vTcl:set_balloon .vTcl.attr.filebar.open "Open Project"
    pack .vTcl.attr.filebar.open -side left -padx 1 -pady 1

    vTcl:toolbar_button .vTcl.attr.filebar.save -image image8 \
        -command vTcl:save
    vTcl:set_balloon .vTcl.attr.filebar.save "Save Project"
    pack .vTcl.attr.filebar.save -side left -padx 1 -pady 1
#--------------------------------------------------------------------------------

#CLIPBOARD BAR-------------------------------------------------------------------
    frame .vTcl.attr.clipbar \
        -borderwidth 1 -height 20 -width 20 -relief groove
    pack .vTcl.attr.clipbar \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
    -side left

    vTcl:toolbar_button .vTcl.attr.clipbar.cut -image image2 -command vTcl:cut
    vTcl:set_balloon .vTcl.attr.clipbar.cut "Cut"
    pack .vTcl.attr.clipbar.cut -side left -padx 1 -pady 1


    vTcl:toolbar_button .vTcl.attr.clipbar.copy -image image1 -command vTcl:copy
    vTcl:set_balloon .vTcl.attr.clipbar.copy "Copy"
    pack .vTcl.attr.clipbar.copy -side left -padx 1 -pady 1

    vTcl:toolbar_button .vTcl.attr.clipbar.paste -image image4 -command vTcl:paste
    vTcl:set_balloon .vTcl.attr.clipbar.paste "Paste"
    pack .vTcl.attr.clipbar.paste -side left -padx 1 -pady 1


#--------------------------------------------------------------------------------

    frame .vTcl.attr.01 \
        -borderwidth 1 -height 20 -width 20 -relief groove
    vTcl:entry .vTcl.attr.01.02 \
        -highlightthickness 0 -width 15 -textvariable vTcl(w,opt,-text) \
        -bg white
    bind .vTcl.attr.01.02 <Return> {
        .vTcl.attr.01.02 insert end "\n"
        vTcl:update_label $vTcl(w,widget)
    }
    bind .vTcl.attr.01.02 <KeyRelease> {
        vTcl:update_label $vTcl(w,widget)
    }
    vTcl:set_balloon .vTcl.attr.01.02 "text"
    pack .vTcl.attr.01.02 \
        -anchor center -expand 1 -fill both -padx 2 -pady 2 -side left
    vTcl:toolbar_button .vTcl.attr.01.03 -image ellipses \
       -command  {   vTcl:set_command $vTcl(w,widget)  }

    vTcl:set_balloon .vTcl.attr.01.03 "command"
    pack .vTcl.attr.01.03 \
        -anchor center -padx 2 -pady 2 -side left

    frame .vTcl.attr.console -borderwidth 1 -relief groove
    button .vTcl.attr.console.console_toggle -image tconsole -highlightthickness 0  -height 30 -width 30\
        -command vTcl:attrbar:toggle_console -relief flat -bd 1
    if {[info exist vTcl(attrbar,console_state)] && $vTcl(attrbar,console_state)} {
        .vTcl.attr.console.console_toggle configure -relief flat }
    vTcl:set_balloon .vTcl.attr.console.console_toggle "show/hide console"
    pack .vTcl.attr.console -side left -fill y
    pack .vTcl.attr.console.console_toggle -side left -padx 2 -pady 1


    frame .vTcl.attr.04 \
        -borderwidth 1 -height 20 -relief groove -width 200
    pack .vTcl.attr.04 \
        -anchor center -expand yes -fill y -padx 0 -pady 0 -side left

    vTcl:toolbar_menubutton .vTcl.attr.04.relief -image relief -menu .vTcl.attr.04.relief.m
    menu .vTcl.attr.04.relief.m -tearoff 0
    .vTcl.attr.04.relief.m add radiobutton -image rel_raised -command {
        vTcl:widget_set_relief raised
    } -variable vTcl(w,opt,-relief) -value raised
    .vTcl.attr.04.relief.m add radiobutton -image rel_sunken -command {
        vTcl:widget_set_relief sunken
    } -variable vTcl(w,opt,-relief) -value sunken
    .vTcl.attr.04.relief.m add radiobutton -image rel_groove -command {
        vTcl:widget_set_relief groove
    } -variable vTcl(w,opt,-relief) -value groove
    .vTcl.attr.04.relief.m add radiobutton -image rel_ridge -command {
        vTcl:widget_set_relief ridge
    } -variable vTcl(w,opt,-relief) -value ridge
    .vTcl.attr.04.relief.m add separator
    .vTcl.attr.04.relief.m add radiobutton -label "none" -command {
        vTcl:widget_set_relief flat
    } -variable vTcl(w,opt,-relief) -value flat
    vTcl:set_balloon .vTcl.attr.04.relief "border"


    vTcl:toolbar_menubutton .vTcl.attr.04.border -image border -menu .vTcl.attr.04.border.m
    menu .vTcl.attr.04.border.m -tearoff 0
    .vTcl.attr.04.border.m add radiobutton -label 1 -command {
        vTcl:widget_set_border 1
    } -variable vTcl(w,opt,-borderwidth) -value 1
    .vTcl.attr.04.border.m add radiobutton -label 2 -command {
        vTcl:widget_set_border 2
    } -variable vTcl(w,opt,-borderwidth) -value 2
    .vTcl.attr.04.border.m add radiobutton -label 3 -command {
        vTcl:widget_set_border 3
    } -variable vTcl(w,opt,-borderwidth) -value 3
    .vTcl.attr.04.border.m add radiobutton -label 4 -command {
        vTcl:widget_set_border 4
    } -variable vTcl(w,opt,-borderwidth) -value 4
    .vTcl.attr.04.border.m add separator
    .vTcl.attr.04.border.m add radiobutton -label none -command {
        vTcl:widget_set_border 0
    } -variable vTcl(w,opt,-borderwidth) -value 0
    vTcl:set_balloon .vTcl.attr.04.border "border width"

    vTcl:toolbar_menubutton .vTcl.attr.04.anchor -image anchor -menu .vTcl.attr.04.anchor.m
    menu .vTcl.attr.04.anchor.m -tearoff 0
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_c -command {
        vTcl:widget_set_anchor center
    } -variable vTcl(w,opt,-anchor) -value center
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_n -command {
        vTcl:widget_set_anchor n
    } -variable vTcl(w,opt,-anchor) -value n
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_s -command {
        vTcl:widget_set_anchor s
    } -variable vTcl(w,opt,-anchor) -value s
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_e -command {
        vTcl:widget_set_anchor e
    } -variable vTcl(w,opt,-anchor) -value e
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_w -command {
        vTcl:widget_set_anchor w
    } -variable vTcl(w,opt,-anchor) -value w
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_nw -command {
        vTcl:widget_set_anchor nw
    } -variable vTcl(w,opt,-anchor) -value nw
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_ne -command {
        vTcl:widget_set_anchor ne
    } -variable vTcl(w,opt,-anchor) -value ne
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_sw -command {
        vTcl:widget_set_anchor sw
    } -variable vTcl(w,opt,-anchor) -value sw
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_se -command {
        vTcl:widget_set_anchor se
    } -variable vTcl(w,opt,-anchor) -value se
    vTcl:set_balloon .vTcl.attr.04.anchor "label anchor"

    vTcl:toolbar_menubutton .vTcl.attr.04.pack -image pack_img -menu .vTcl.attr.04.pack.m
    menu .vTcl.attr.04.pack.m -tearoff 0
    .vTcl.attr.04.pack.m add radiobutton -image anchor_n -command {
        vTcl:widget_set_pack_side top
    } -variable vTcl(w,pack,-side) -value top
    .vTcl.attr.04.pack.m add radiobutton -image anchor_s -command {
        vTcl:widget_set_pack_side bottom
    } -variable vTcl(w,pack,-side) -value bottom
    .vTcl.attr.04.pack.m add radiobutton -image anchor_e -command {
        vTcl:widget_set_pack_side right
    } -variable vTcl(w,pack,-side) -value right
    .vTcl.attr.04.pack.m add radiobutton -image anchor_w -command {
        vTcl:widget_set_pack_side left
    } -variable vTcl(w,pack,-side) -value left
    vTcl:set_balloon .vTcl.attr.04.pack "pack side"
    pack .vTcl.attr.04.relief -side left -padx 1 -pady 1 -fill both
    pack .vTcl.attr.04.border -side left -padx 1 -pady 1 -fill both
    pack .vTcl.attr.04.anchor -side left -padx 1 -pady 1 -fill both
    pack .vTcl.attr.04.pack   -side left -padx 1 -pady 1 -fill both

    frame .vTcl.attr.010 \
        -borderwidth 1 -height 20 -relief groove -width 20
    pack .vTcl.attr.010 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:toolbar_button .vTcl.attr.010.lab41 -image fg  -command {
            vTcl:widget_set_fg .vTcl.attr.010.lab41
        }

    vTcl:set_balloon .vTcl.attr.010.lab41 "foreground"
    pack .vTcl.attr.010.lab41 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 1 -padx 1 -pady 0 \
        -side left
    vTcl:toolbar_button .vTcl.attr.010.lab42 -image bg -command {
            vTcl:widget_set_bg .vTcl.attr.010.lab42
        }

    vTcl:set_balloon .vTcl.attr.010.lab42 "background"
    pack .vTcl.attr.010.lab42 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 1 -pady 1 \
        -side left

    ## Font Browsing
    #
    frame .vTcl.attr.011 \
        -borderwidth 1 -height 20 -relief groove -width 20
    pack .vTcl.attr.011 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left

    vTcl:toolbar_menubutton .vTcl.attr.011.lab41 \
        -image fontbase -menu .vTcl.attr.011.lab41.m
    menu .vTcl.attr.011.lab41.m -tearoff 0
    vTcl:fill_font_menu .vTcl.attr.011.lab41.m
    vTcl:set_balloon .vTcl.attr.011.lab41 "font"

    vTcl:toolbar_menubutton .vTcl.attr.011.lab42 \
        -image fontsize -menu .vTcl.attr.011.lab42.m
    menu .vTcl.attr.011.lab42.m -tearoff 0
    vTcl:fill_fontsize_menu .vTcl.attr.011.lab42.m
    vTcl:set_balloon .vTcl.attr.011.lab42 "font size"


    vTcl:toolbar_menubutton .vTcl.attr.011.lab43 -image fontstyle -menu .vTcl.attr.011.lab43.m
    menu .vTcl.attr.011.lab43.m -tearoff 0
    .vTcl.attr.011.lab43.m add check -variable vTcl(w,fontstyle,bold) \
        -label bold -command "vTcl:set_font style \$vTcl(w,widget) bold"
    .vTcl.attr.011.lab43.m add check -variable vTcl(w,fontstyle,italic) \
        -label italic -command "vTcl:set_font style \$vTcl(w,widget) italic"
    .vTcl.attr.011.lab43.m add check -variable vTcl(w,fontstyle,underline) \
        -label underline -comm "vTcl:set_font style \$vTcl(w,widget) underline"
    vTcl:set_balloon .vTcl.attr.011.lab43 "font style"

    vTcl:toolbar_menubutton .vTcl.attr.011.lab44 \
        -image justify -menu .vTcl.attr.011.lab44.m
    menu .vTcl.attr.011.lab44.m -tearoff 0
    .vTcl.attr.011.lab44.m add radiobutton -variable vTcl(w,opt,-justify) \
        -label left -command "vTcl:set_justify \$vTcl(w,widget) left"
    .vTcl.attr.011.lab44.m add radiobutton -variable vTcl(w,opt,-justify) \
        -label center -command "vTcl:set_justify \$vTcl(w,widget) center"
    .vTcl.attr.011.lab44.m add radiobutton -variable vTcl(w,opt,-justify) \
        -label right -command "vTcl:set_justify \$vTcl(w,widget) right"
    vTcl:set_balloon .vTcl.attr.011.lab44 "justification"
    pack .vTcl.attr.011.lab41 .vTcl.attr.011.lab42 .vTcl.attr.011.lab43 \
        .vTcl.attr.011.lab44 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
#PACKAGE MANAGER CONTROL USES STANDARD BUTTONS. WE REALLY NEED A NEW CONTROL FOR
#TOGGLE BUTTONS
    frame .vTcl.attr.016 \
        -borderwidth 1 -height 20 -relief groove -width 20
    pack .vTcl.attr.016 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    set vTcl(mgrs,grid,widget) .vTcl.attr.016.017


    button .vTcl.attr.016.017  -height 30 -width 30 \
        -highlightthickness 0 -padx 0 -pady 0 -bd 1 \
        -image mgr_grid \
        -command {vTcl:set_manager grid}
    vTcl:set_balloon .vTcl.attr.016.017 "use grid manager"
    pack .vTcl.attr.016.017 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    set vTcl(mgrs,pack,widget) .vTcl.attr.016.018
    button .vTcl.attr.016.018  -height 30 -width 30\
        -command {vTcl:set_manager pack} \
        -highlightthickness 0 -image mgr_pack -padx 0 -pady 0 -bd 1
    vTcl:set_balloon .vTcl.attr.016.018 "use packer manager"
    pack .vTcl.attr.016.018 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    set vTcl(mgrs,place,widget) .vTcl.attr.016.019
    button .vTcl.attr.016.019 -height 30 -width 30\
        -command {vTcl:set_manager place} \
        -highlightthickness 0 -image mgr_place -padx 0 -pady 0 -bd 1
    vTcl:set_balloon .vTcl.attr.016.019 "use place manager"
    pack .vTcl.attr.016.019 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    set vTcl(mgrs,wm,widget) .vTcl.attr.016.020
    button .vTcl.attr.016.020 -height 30 -width 30
}














