##############################################################################
# $Id: color.tcl,v 1.8 2001/11/30 04:22:49 cgavin Exp $
#
# color.tcl - color browser
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

proc vTcl:get_color {color w {t {Choose a color}}} {
    # Rozen.  Changed this routine to use the colorDlg color picker
    # written by Alain (he gives no last name.) Mainly I added the
    # third parameter and changed the call below to colorDlg.

    # apparently Iwidgets 3.0 returns screwed up colors
    #
    # tk_chooseColor accepts the following:
    # #RGB           (4 chars)
    # #RRGGBB        (7 chars)
    # #RRRGGGBBB     (10 chars)
    # #RRRRGGGGBBBB  (13 chars)
    if {[string length $color] == 11} {

        set extend [string range $color 10 10]
        set color $color$extend$extend

        vTcl:log "Fixed color: $color"

    } else {

    if {[string length $color] == 9} {
        set extend [string range $color 8 8]
        set color $color$extend$extend$extend$extend
        vTcl:log "Fixed color: $color"
        }
    }

    global vTcl tk_version
    set oldcolor $color
    if {$color == ""} {
        set color white
    }
    # Rozen. I decided to use this form of a color chooser,
    # where I can enter X11 color names.

    #set newcolor [SelectColor::menu [winfo toplevel $w].color [list below $w] -color $color]
    set newcolor [::colorDlg::colorDlg -initialcolor $color -title $t]
    #set newcolor [colorDlg -initialcolor $color -title $t]

    if {$newcolor != ""} {
        return $newcolor
    } else {
        return $oldcolor
    }
}

proc vTcl:show_color {widget option variable w} {
    global vTcl
    set vTcl(color,widget)   $widget
    set vTcl(color,option)   $option
    set vTcl(color,variable) $variable
    set color [vTcl:at $variable]
    if {$color == ""} {
        set color "#000000"
    } elseif {[string range $color 0 0] != "#" } {
        set clist [winfo rgb . $color]
        set r [lindex $clist 0]
        set g [lindex $clist 1]
        set b [lindex $clist 2]
        set color "#[vTcl:hex $r][vTcl:hex $g][vTcl:hex $b]"
    }
    set vTcl(color) [vTcl:get_color $color $w]
    if {[::colorDlg::dark_color $vTcl(color)]} {
        set ell_image ellipseslight
    } else {
        set ell_image ellipsesdark
    }
    set $vTcl(color,variable) $vTcl(color)
    $vTcl(color,widget) configure -bg $vTcl(color) -image $ell_image
    $vTcl(w,widget) configure $vTcl(color,option) $vTcl(color)
}

proc vTcl:set_actuals { } {
    # These setting are done after the preferences (.pagerc) are read
    # which might change the following preference variable. Called in
    # page.tcl.
    global vTcl
    set vTcl(actual_gui_bg) $vTcl(pr,guibgcolor)
    set vTcl(actual_gui_fg) $vTcl(pr,guifgcolor)
    set vTcl(actual_gui_menu_bg) $vTcl(pr,menubgcolor)
    set vTcl(actual_gui_menu_fg) $vTcl(pr,menufgcolor)
    set vTcl(complement_color) $vTcl(pr,guicomplement_color)
    set vTcl(analog_color_p) $vTcl(pr,guianalog_color_p)
    set vTcl(analog_color_m) $vTcl(pr,guianalog_color_m)

    if {[::colorDlg::dark_color $vTcl(analog_color_m)]} {
        set fg_color  #000000
    } else {
        set fg_color  #111111
    }
    set vTcl(active_fg) $fg_color

    set vTcl(actual_gui_font_dft) $vTcl(font,gui_font_dft)
    set vTcl(actual_gui_font_fixed) $vTcl(font,gui_font_fixed)
    set vTcl(actual_gui_font_text) $vTcl(font,gui_font_text)
    set vTcl(actual_gui_font_menu) $vTcl(font,gui_font_menu)
}

proc vTcl:set_GUI_color_defaults { fileID } {
    # Rozen. This writes out code to set default upon loading the
    # generated GUI tcl file.
    global vTcl
    puts $fileID "set vTcl(actual_gui_bg) $vTcl(actual_gui_bg)"
    puts $fileID "set vTcl(actual_gui_fg) $vTcl(actual_gui_fg)"
    puts $fileID "set vTcl(actual_gui_menu_bg) $vTcl(actual_gui_menu_bg)"
    puts $fileID "set vTcl(actual_gui_menu_fg) $vTcl(actual_gui_menu_fg)"

    puts $fileID "set vTcl(complement_color) $vTcl(complement_color)"
    puts $fileID "set vTcl(analog_color_p) $vTcl(analog_color_p)"
    puts $fileID "set vTcl(analog_color_m) $vTcl(analog_color_m)"
    puts $fileID "set vTcl(active_fg) $vTcl(active_fg)"

}