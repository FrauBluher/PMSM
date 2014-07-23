##############################################################################
# $Id: help.tcl,v 1.27 2005/11/12 10:29:58 kenparkerjr Exp $
#
# help.tcl - help dialog
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

proc vTclWindow.vTcl.help {args} {
    global vTcl
    set base .vTcl.help
    if {[winfo exists $base]} { wm deiconify $base; return }

    toplevel $base -class Toplevel
    wm withdraw $base
    wm geometry $base 600x425
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm title $base "Help for Visual Tcl"
    wm maxsize $base 1137 870
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1

    ScrolledWindow $base.fra18
    text $base.fra18.tex22 \
        -height 15 -width 80 -background white -wrap word -font {Arial 8}
    $base.fra18 setwidget $base.fra18.tex22

    ::vTcl::OkButton $base.but21 -command "Window hide $base"
    pack $base.but21 \
        -anchor e -expand 0 -fill none -padx 2 -pady 2 -side top
    pack $base.fra18 \
        -anchor center -expand 1 -fill both -padx 5 -pady 5 -side top
    pack $base.fra18.tex22

    set fileName [file join $vTcl(VTCL_HOME) lib Help reference.ttd]
    if {[file exists $fileName]} {
        set inID [open $fileName]
        set contents [read $inID]
        $base.fra18.tex22 delete 0.0 end
        ::ttd::insert $base.fra18.tex22 $contents
        close $inID
    }

    $base.fra18.tex22 configure -state disabled

    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base
}

###
## Open the help window and set the text to the text of the file referenced
## by helpName.
###
proc vTcl:Help {helpName} {
    global vTcl

    set base .vTcl.help

    set file [file join $vTcl(VTCL_HOME) lib Help $helpName]
    if {![file exist $file]} {
    set helpName Main
    set file [file join $vTcl(VTCL_HOME) lib Help Main]
    }

    if {[vTcl:streq $helpName "Main"]} { set helpName "Visual Tcl" }

    Window show $base

    wm title $base $helpName

    $base.fra18.tex22 configure -state normal

    set fp [open $file]
    $base.fra18.tex22 delete 0.0 end
    $base.fra18.tex22 insert end [read $fp]
    close $fp

    $base.fra18.tex22 configure -state disabled

    update
}

###
## Bind a particular help file to a window or widget.
###
proc vTcl:BindHelp {w help} {
    bind $w <Key-F1> "vTcl:Help $help"
}

proc vTclWindow.vTcl.tip {base} {

    global vTcl

    if {$base == ""} {
        set base .vTcl.tip
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    image create photo light_bulb -file \
        [file join $vTcl(VTCL_HOME) images tip.gif]

    global widget
    vTcl:DefineAlias $base TipWindow vTcl:TopLevel:WidgetProc "" 1
    vTcl:DefineAlias $base.cpd25.03 TipText vTcl:WidgetProc TipWindow 1
    vTcl:DefineAlias $base.fra20.che26 DontShowTips vTcl:WidgetProc TipWindow 1

    if {[info exists vTcl(pr,dontshowtips)]} {
        set ::tip::dontshow $vTcl(pr,dontshowtips)
    }
    if {[info exists vTcl(pr,tipindex)]} {
        set ::tip::Index $vTcl(pr,tipindex)
    }

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm withdraw $base
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Tip of the day"
    wm protocol $base WM_DELETE_WINDOW {
         Window hide .vTcl.tip
         set vTcl(pr,dontshowtips) $::tip::dontshow
         set vTcl(pr,tipindex)     $::tip::Index
    }

    frame $base.fra20 \
        -borderwidth 2 -height 75 -width 125
    button $base.fra20.but22 \
        -text Close -width 8 \
        -command {
             Window hide .vTcl.tip
             set vTcl(pr,dontshowtips) $::tip::dontshow
             set vTcl(pr,tipindex)     $::tip::Index
         }
    checkbutton $base.fra20.che26 \
        -text {Don't show tips on startup} -variable ::tip::dontshow
    button $base.fra20.but19 \
        \
        -command {
             TipWindow.TipText configure -state normal
             TipWindow.TipText delete 0.0 end
             TipWindow.TipText insert end [::tip::get_next_tip]
             TipWindow.TipText configure -state disabled
        } \
        -text {Next >} -width 8

    button $base.fra20.but20        -command {
                  TipWindow.TipText configure -state normal
                  TipWindow.TipText delete 0.0 end
                  TipWindow.TipText insert end  [::tip::get_previous_tip]
                  TipWindow.TipText configure -state disabled
             }     -text {< Previous} -width 8

    frame $base.fra23 \
        -borderwidth 2
    label $base.fra23.lab24 \
        -borderwidth 1 \
        -image light_bulb \
        -relief raised -text label

    ScrolledWindow $base.cpd25
    text $base.cpd25.03 -background white \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* -height 1
    $base.cpd25 setwidget $base.cpd25.03

    label $base.lab19 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font8"] \
        -text {Did you know ...?}
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor e -expand 0 -fill x -side bottom
    pack $base.fra20.but22 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right
    pack $base.fra20.che26 \
        -in $base.fra20 -anchor center -expand 0 -fill none -side left

   pack $base.fra20.but19 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right
   pack $base.fra20.but20 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right

    pack $base.fra23 \
        -in $base -anchor center -expand 0 -fill y -side left
    pack $base.fra23.lab24 \
        -in $base.fra23 -anchor center -expand 0 -fill none -padx 5 \
        -side left
    pack $base.cpd25 \
        -in $base -anchor center -expand 1 -fill both -padx 5 -pady 5 \
        -side bottom
    #pack $base.cpd25.03    Rozen
    pack $base.lab19 \
        -in $base -anchor center -expand 0 -fill none -side top

    wm geometry $base 506x292
    update
    vTcl:center $base 506 292
    wm deiconify $base

    $base.fra20.but19 invoke
}

namespace eval ::tip {
    variable Tips ""
    variable Index 0

    proc {::tip::get_next_tip} {} {
    variable Tips
        variable Index

    if {[lempty $Tips]} {
        global vTcl
        set tipFile [file join $vTcl(VTCL_HOME) lib Help Tips]
        foreach tip [vTcl:read_file $tipFile] {
        lappend Tips [string trim $tip]
        }
    }

        set length [llength $Tips]
        set Index  [expr ($Index + 1) % $length]

        return [lindex $Tips $Index]
    }
    proc {::tip::get_previous_tip} {} {
        variable Tips
    variable Index
    set length [llength $Tips]
    set Index [expr ($Index - 1) % $length]
    return [lindex $Tips $Index]
    }

}

namespace eval ::vTcl::news {
    variable http   ""
    variable URL    "http://vtcl.sourceforge.net/news/news.txt"

    proc ::vTcl::news::Init {} {
    variable http
        if {[catch {package require http} error]} { return 0 }

    set http ::http::geturl
    if {$error < 2.3} { set http http_get }
    return 1
    }

    proc ::vTcl::news::get_news {} {
    global vTcl
    variable http
    variable URL

    catch {after cancel $vTcl(tmp,newsAfter)}

    vTcl:status "Getting news..."

        if {![::vTcl::news::Init]} { vTcl:status; return }

    if {[catch {
        $http $URL -timeout 30000 -command ::vTcl::news::display_news
        } token]} {
        vTcl:status

            ## too bad, we couldn't show news, so we won't bother the user
            ## again on the next startup
            set vTcl(pr,dontshownews) 1
    }
    }

    proc ::vTcl::news::display_news {token} {
    upvar #0 $token state

    vTcl:status

    if {[lindex $state(http) 1] != 200} { return }

    set base .vTcl.news

    if {[winfo exists $base]} {
        ::vTcl::news::parse_news $base $state(body)
        wm deiconify $base
        return
    }

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm transient $base .vTcl
    wm withdraw $base
    wm focusmodel $base passive
    wm geometry $base 494x257+214+102; update
    wm maxsize $base 1028 753
    wm minsize $base 104 1
    wm overrideredirect $base 0
    wm resizable $base 0 0
    vTcl:center $base 494 257
    wm deiconify $base
    wm title $base "Visual Tcl News"

    ScrolledWindow $base.f
    text $base.f.t -background white -wrap none -cursor arrow -height 4
    $base.f setwidget $base.f.t

    ::vTcl::OkButton $base.b -anchor center -command "Window hide $base"

    label $base.l -anchor w
        checkbutton $base.dontshow -text "Do not show news on startup" \
            -anchor w -variable vTcl(pr,dontshownews)

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.b \
        -in $base -anchor e -expand 0 -fill none -side top
    pack $base.f \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.f.t
        pack $base.dontshow -side bottom -fill x
    pack $base.l -side bottom -fill x

    wm protocol $base WM_DELETE_WINDOW "$base.b invoke"

    font create link -family Arial -size 10 -underline 1

    ::vTcl::news::parse_news $base $state(body)
    }

    proc ::vTcl::news::parse_news {base string} {
    global env

    foreach child \[$base.f.t window names] { destroy \$child }

    $base.f.t configure -state normal
    $base.f.t delete 0.0 end

    set lines [split [string trim $string] \n]
    set  i 0
    foreach line $lines {
        if {[lempty $line]} { continue }
        if {[string index $line 0] == "#"} { continue }
        lassign $line command date text link
        set text "$date - $text"

        incr i
        switch -- $command {
            "News"  {
            set l [label $base.f.t.link$i -text $text \
                -background white -foreground blue -font link \
            -cursor hand1]
            bind $l <Button-1> "exec [::vTcl::web_browser] $link &"
            bind $l <Enter> "$base.l configure -text $link"
            bind $l <Leave> "$base.l configure -text {}"
            $base.f.t window create end -window $l
            $base.f.t insert end \n
        }
        }
    }
    $base.f.t configure -state disabled
    }
}

proc vTclWindow.vTcl.infolibs {{base ""}} {

    if {$base == ""} {
        set base .vTcl.infolibs
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global vTcl

    # let's keep widget local
    set widget(libraries_close)         "$base.but40"
    set widget(libraries_frame_listbox) "$base.cpd39"
    set widget(libraries_header)        "$base.lab38"
    set widget(libraries_listbox)       "$base.cpd39.01"

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm withdraw $base
    wm focusmodel $base passive
    wm transient  $base .vTcl
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Visual Tcl Libraries"

    label $base.lab38 \
        -borderwidth 1 -text {The following libraries are available:}

    ScrolledWindow $base.cpd39
    listbox $base.cpd39.01 -width 0
    $base.cpd39 setwidget $base.cpd39.01

    ::vTcl::OkButton $base.but40 -command "Window hide $base"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.but40 \
        -in $base -anchor center -expand 0 -fill none -side top -anchor e
    pack $base.lab38 \
        -in $base -anchor center -expand 0 -fill x -ipadx 1 -side top
    pack $base.cpd39 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.cpd39.01

    $widget(libraries_listbox) delete 0 end

    foreach name [lsort $vTcl(libNames)] {
        $widget(libraries_listbox) insert end $name
    }

    wm geometry $base 446x322
    vTcl:center $base 446 322
    wm deiconify $base
}



