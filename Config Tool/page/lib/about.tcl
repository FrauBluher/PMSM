##############################################################################
# $Id: about.tcl,v 1.31 2006/01/19 07:38:32 kenparkerjr Exp $
#
# about.tcl - dialog "about Visual Tcl"
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

proc vTclWindow.vTcl.about {args} {
    # Modified by Rozen to put out a different Help menu that the
    # original Visual Tcl menu.  That was pretty poor anyway. 3/20/14.
    global vTcl
    set base .vTcl.about
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    set about_text \
"

Python Automated GUI Generator - PAGE
Version $vTcl(version)
http://page.sourceforge.net/

Written by Donald Rozenberg
don.rozenberg@gmail.com

Copyright (C) Stewart Allen 1996-2000
Copyright (C) Donald Rozenberg 2001-2014

Licensed under GNU General Public License
version 2

"

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel -background black
    wm focusmodel $base passive
    wm withdraw $base
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 0 0
    wm transient $base .vTcl
    wm title $base "About PAGE"
    bind $base <Key-Escape> "$base.fra30.but31 invoke"
    bind $base <Key-Return> "$base.fra30.but31 invoke"

    #label $base.lab28 \
        -background #000000 -borderwidth 1 -image title -relief groove \
        -text label
    frame $base.fra30 \
        -borderwidth 2 -height 75 -width 125 -background black
    button $base.fra30.but31 \
        -text Close -width 8 \
        -command "Window hide $base" \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"]
    button $base.fra30.but32 \
        -command "vTcl:open_help_in_browser;after 5000 Window hide $base" \
        -text "Open Help" -width 8 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"]

    label $base.lab21 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"] \
        -text $about_text -foreground white -background black
    ###################
    # SETTING GEOMETRY
    ###################
    #pack $base.lab28 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.fra30 \
        -in $base -anchor center -expand 0 -fill none -side bottom
    pack $base.fra30.but31 \
        -in $base.fra30 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right
    pack $base.fra30.but32 \
        -in $base.fra30 -anchor center -expand 0 -fill none -padx 5 \
        -side left
    pack $base.lab21 \
        -in $base -anchor center -expand 0 -fill none -pady 2 -side top

    update idletasks

    vTcl:center $base
    wm deiconify $base
}

proc vTcl:open_help_in_browser { } {
    # Rozen to open the html version of help in the default
    # browser. It works on Linux if the default browser is either
    # Firefox or Chrome as of 3/20/14.
    global tcl_platform
    global vTcl
    # if {$tcl_platform(platform) == "unix"} {
    #     set help_file [file join $vTcl(VTCL_HOME) docs html index.html]
    #     set browser $::env(BROWSER)
    #     if {$browser == "firefox"} {
    #         exec $browser --new-window  $help_file &
    #     }
    # }
    # if {$tcl_platform(platform) == "macintosh"} {
    # }

    set help_file [file join $vTcl(VTCL_HOME) docs html index.html]
    if {$tcl_platform(platform) == "windows"} {
        set command "[auto_execok start] {} [list $help_file]"
    } elseif {$tcl_platform(os) == "Darwin"} {
        set command [list open $help_file]
    } elseif {$tcl_platform(platform) == "unix"} {
        set browser $::env(BROWSER)
        if {$browser == "firefox"} {
            #exec $browser --new-window  $help_file &
            set command [list $browser --new-window  $help_file]
        }
    }
    exec {*}$command &

    # Wait for 5 seconds and then hide About box.
}



proc vTcl:fill_credits {} {

    global vTcl tcl_version tk_version

    set inID [open [file join $vTcl(VTCL_HOME) lib Help about.ttd]]
    set contents [read $inID]
    CreditsText delete 0.0 end
    ::ttd::insert [CreditsText] $contents

    CreditsText insert end \
        "\nTcl version $tcl_version\nTk version $tk_version"
    CreditsText configure -state disabled
    close $inID
}

proc vTclWindow.vTcl.credits {base} {

    if {$base == ""} {
        set base .vTcl.credits
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget tcl_version tk_version
    vTcl:DefineAlias $base CreditsWindow vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias $base.cpd24.03 CreditsText vTcl:WidgetProc CreditsWindow 1

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm transient $base .vTcl
    wm overrideredirect $base 0
    wm focusmodel $base passive
    wm withdraw $base
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm resizable $base 1 1
    wm title $base "Visual Tcl Credits"
    bind $base <Key-Escape> "$base.but23 invoke"
    bind $base <<Ready>> {
        vTcl:fill_credits
        wm geometry %W 500x420
        vTcl:center %W 500 420
        wm deiconify %W
    }

    ::vTcl::OkButton $base.but23 -command "Window hide $base"
    ScrolledWindow $base.cpd24 -auto vertical
    text $base.cpd24.03 -height 1 -background white \
        -font {-family helvetica -size 12} \
        -width 8 -wrap word
    $base.cpd24 setwidget $base.cpd24.03
    bind $base.cpd24.03 <KeyRelease> "break"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.but23 \
        -in $base -anchor e -expand 0 -fill none -pady 5 -side top
    pack $base.cpd24 \
        -in $base -anchor center -expand 1 -fill both -side top
    #pack $base.cpd24.03    Rozen

    vTcl:FireEvent $base <<Ready>>
}



