##############################################################################
# $Id: bgerror.tcl,v 1.26 2005/11/11 07:42:44 kenparkerjr Exp $
#
# bgerror.tcl - a replacement for the standard bgerror message box
#
# Copyright (C) 2000 Christian Gavin
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
#
##############################################################################

namespace eval ::stack_trace {
    variable boxIndex 0
}

proc vTclWindow.vTcl.bgerror {base} {
    if {$base == ""} {
        set base .vTcl.bgerror
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global [vTcl:rename $base.error]
    global [vTcl:rename $base.errorInfo]

    eval set error     $[vTcl:rename $base.error]
    eval set errorInfo $[vTcl:rename $base.errorInfo]
    global widget
    vTcl:DefineAlias $base error_box vTcl:Toplevel:WidgetProc "" 0
    vTcl:DefineAlias $base.fra20.cpd23.03 error_box_text vTcl:WidgetProc $base 0
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 333x248+196+396
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Error"
    wm protocol $base WM_DELETE_WINDOW "
            set [vTcl:rename $base.dialogStatus] ok
            destroy $base"

    frame $base.fra20 \
        -borderwidth 2
    label $base.fra20.lab21 \
        -bitmap error -borderwidth 0 \
        -padx 0 -pady 0 -relief raised -text label
    ScrolledWindow $base.fra20.cpd23
    text $base.fra20.cpd23.03 \
        -background #dcdcdc -font [vTcl:font:get_font "vTcl:font8"] \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff \
    -width 8 -wrap word

    $base.fra20.cpd23 setwidget $base.fra20.cpd23.03

    frame $base.fra25 \
        -borderwidth 2
    button $base.fra25.but26 \
        -padx 9 -text OK \
        -command "
            set [vTcl:rename $base.dialogStatus] ok
            destroy $base"
    button $base.fra25.but27 \
        -padx 9 -text {Skip messages} \
        -command "set [vTcl:rename $base.dialogStatus] skip
                  destroy $base"
    button $base.fra25.but28 \
        -padx 9 -text {Stack Trace...}  \
        -command "::vTcl::InitTkcon
              edit -attach \[::tkcon::Attach\] -type error -- [list $errorInfo]
                  set [vTcl:rename $base.dialogStatus] ok
                  after idle \{destroy $base\}"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor center -expand 1 -fill both -pady 2 -side top
    pack $base.fra20.lab21 \
        -in $base.fra20 -anchor e -expand 0 -fill none -padx 5 -side left

    pack $base.fra20.cpd23 \
        -in $base.fra20 -anchor center -expand 1 -fill both -padx 2 -side top
    #pack $base.fra20.cpd23.03      Rozen BWidget

    pack $base.fra25 \
        -in $base -anchor center -expand 0 -fill x -pady 4 -side top
    pack $base.fra25.but26 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    pack $base.fra25.but27 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    pack $base.fra25.but28 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    $widget($base,error_box_text) insert 1.0 $error
    #The box must be disabled after the error is inserted
    $widget($base,error_box_text) configure -state disabled
}

proc bgerror {error} {
    global widget errorInfo
    incr ::stack_trace::boxIndex

    set top ".vTcl.bgerror$::stack_trace::boxIndex"

    global [vTcl:rename $top.error]
    global [vTcl:rename $top.errorInfo]
    global [vTcl:rename $top.dialogStatus]

    set [vTcl:rename $top.error] $error
    set [vTcl:rename $top.errorInfo] $errorInfo
    set [vTcl:rename $top.dialogStatus] 0
    vTclWindow.vTcl.bgerror $top
    vwait [vTcl:rename $top.dialogStatus]

    eval set status $[vTcl:rename $top.dialogStatus]

    # don't leak memory, please !
    unset [vTcl:rename $top.error]
    unset [vTcl:rename $top.errorInfo]
    unset [vTcl:rename $top.dialogStatus]

    if {$status != "skip"} {

        return
    }

    return -code break
}
