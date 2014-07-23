##############################################################################
# $Id: command.tcl,v 1.16 2005/11/11 07:42:44 kenparkerjr Exp $
#
# command.tcl - procedures to update widget commands
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

proc vTcl:set_command {target {option -command} {variable vTcl(w,opt,-command)}} {
    global vTcl
    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"

    if {[catch {set cmd [$target cget $option]}] == 1} { return }

    ## if the command is in the form "vTcl:DoCmdOption target cmd",
    ## then extracts the command, otherwise use the command as is
    if {[regexp {vTcl:DoCmdOption [^ ]+ (.*)} $cmd matchAll realCmd]} {
        lassign $cmd dummy1 dummy2 cmd
    }
    set r [vTcl:get_command "$option for $target" $cmd $base]
    if {$r == -1} { return }
    set cmd [string trim $r]

    ## if the command is non null, replace it by DoCmdOption
    if {$cmd != "" && [string match *%* $cmd]} {
        set cmd [list vTcl:DoCmdOption $target $cmd]
    }

    $target configure $option $cmd

    global $variable
    set $variable $cmd
    vTcl:prop:save_opt $target $option $variable
}

proc vTcl:get_command {title initial base} {
    global vTcl
    if {[winfo exists $base]} {wm deiconify $base; raise $base; return -1}
    set vTcl(x,$base) -1
    toplevel $base -class vTcl
    wm transient $base .vTcl
    vTcl:check_mouse_coords
    set geom 350x200+[expr $vTcl(mouse,X)-120]+[expr $vTcl(mouse,Y)-20]
    if {[info exists vTcl(pr,geom_comm)]} { set geom $vTcl(pr,geom_comm) }
    wm geometry $base $geom
    wm resizable $base 1 1
    wm title $base $title
    set vTcl(comm,$base,chg) 0

    ScrolledWindow $base.f
    text $base.f.text \
        -insertborderwidth 3 \
        -background white -borderwidth 0 -height 3 -wrap none \
        -relief flat -width 20 -foreground black -cursor {}  ;# Rozen -fg 2-3-13
    $base.f setwidget $base.f.text

    pack $base.f \
        -in "$base" -anchor center -expand 1 -fill both -side bottom
    #pack $base.f.text     Rozen 7/19  pm

    frame $base.f21 \
        -height 30 -relief flat -width 30
    pack $base.f21 \
        -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 3 -side top
    ::vTcl::CancelButton $base.f21.button23 \
    -command "vTcl:command:edit_cancel $base"
    pack $base.f21.button23 \
        -in $base.f21 -anchor center -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side right
    vTcl:set_balloon $base.f21.button23 "Discard changes"
    ::vTcl::OkButton $base.f21.button22 -command "vTcl:command:edit_save $base"
    pack $base.f21.button22 \
        -in $base.f21 -anchor center -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side right
    vTcl:set_balloon $base.f21.button22 "Save changes"
    update idletasks
    bind $base <KeyPress> "
        set vTcl(comm,$base,chg) 1
    "
    bind $base <Key-Escape> "
        vTcl:command:edit_save $base
        break
    "
    $base.f.text delete 0.0 end
    $base.f.text insert end $initial
    focus $base.f.text

    ## syntax colouring
    vTcl:syntax_color $base.f.text

    tkwait window $base
    update idletasks
    switch -- $vTcl(x,$base) {
        "-1"      {return -1}
        default "return $vTcl(x,$base)"
    }
}

proc vTcl:command:save_geom {base} {
    global vTcl
    set vTcl(pr,geom_comm) [winfo geometry $base]
}

proc vTcl:command:edit_save {base} {
    global vTcl
    vTcl:command:save_geom $base
# Check to see that it is in correct format before submitting
    if { [info complete [$base.f.text get 0.0 end] ] == 1 } {
        set vTcl(x,$base) [$base.f.text get 0.0 end]
        destroy $base
    } else {
        ::vTcl::MessageBox -icon error -parent $base \
    -message "Syntax Error: Please check you're code and try again." \
    -title "Syntax Error"
    }

}

proc vTcl:command:edit_cancel {base} {
    global vTcl
    vTcl:command:save_geom $base
    if {$vTcl(comm,$base,chg) == 0} {
        grab release $base
        destroy $base
    } else {
        set result [::vTcl::MessageBox -icon question -parent $base \
    -default yes \
        -message "Buffer has changed. Do you wish to save the changes?" \
        -title "Changed buffer!" -type yesnocancel]

        switch $result {
            no {
                grab release $base
                destroy $base
            }
            yes {vTcl:command:edit_save $base}
            cancel {}
        }
    }
}
