##############################################################################
# $Id: var.tcl,v 1.17 2001/10/04 05:11:33 cgavin Exp $
#
# var.tcl - procedures for manipulating variables and the variable browser
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

namespace eval ::inspector {

    proc {::inspector::contract_node} {listbox index} {
        upvar #0 ::${listbox}::contents contents

        set content_line [lindex $contents $index]
        set node_text [$listbox get $index]

        lassign $content_line has_children node_info item_commands level expanded
        set content_line [list $has_children $node_info $item_commands $level 0]

        regsub -all {\[\-\]} $node_text {[+]} node_text
        $listbox delete $index
        $listbox insert $index $node_text

        set contents [lreplace $contents  $index  $index  $content_line]

        # now, remove all children
        ::inspector::delete_children $listbox [expr $index + 1] [expr $level + 1]

        $listbox selection clear 0 end
        $listbox selection set $index
        $listbox activate $index
        focus $listbox
    }

    proc {::inspector::delete_children} {listbox index level} {
        upvar #0 ::${listbox}::contents contents

        set last [expr [llength $contents] -1]

        set content_line [lindex $contents $index]
        lassign $content_line has_children node_info item_commands current_level expanded

        while {$current_level >= $level && $index <= $last} {

            set contents [lreplace $contents $index $index]
            set last [expr [llength $contents] -1]
            $listbox delete $index

            set content_line [lindex $contents $index]
            lassign $content_line has_children node_info item_commands current_level expanded
        }
    }

    proc {::inspector::expand_array} {listbox node_index node_info level} {
        global widget

        set children [lsort [array names $node_info]]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            set varname $node_info
            append varname (${child})

            set tmp $node_info
            regsub -all {\:\:} $tmp @ tmp
            set short [lindex [split $tmp @] end]
            append short (${child})

            ::inspector::insert_node $listbox  $node_index  $short  $level  no $varname {{} ::inspector::show_variable}

            incr node_index
        }
    }

    proc {::inspector::expand_namespace} {listbox node_index node_info level} {
        global widget

        set children [lsort [namespace children $node_info]]

        # insert just after the node
        incr node_index
        incr level

        ::inspector::insert_node $listbox $node_index Variables $level yes $node_info ::inspector::expand_variables
        incr node_index
        ::inspector::insert_node $listbox $node_index Procedures $level yes $node_info ::inspector::expand_procedures
        incr node_index

        foreach child $children {

            ::inspector::insert_node $listbox  $node_index  $child  $level  yes  $child  ::inspector::expand_namespace

            incr node_index
        }
    }

    proc {::inspector::expand_node} {listbox index} {
        upvar #0 ::${listbox}::contents contents

        set content_line [lindex $contents $index]
        set node_text [$listbox get $index]

        lassign $content_line has_children node_info item_commands level expanded
        set content_line [list $has_children $node_info $item_commands $level 1]

        regsub -all {\[\+\]} $node_text {[-]} node_text
        $listbox delete $index
        $listbox insert $index $node_text

        set contents [lreplace $contents  $index  $index  $content_line]

        set expand_cmd [lindex $item_commands 0]
        $expand_cmd $listbox  $index  $node_info  $level

        $listbox selection clear 0 end
        $listbox selection set $index
        $listbox activate $index
        focus $listbox
    }

    proc {::inspector::expand_procedures} {listbox node_index node_info level} {
        set children [lsort [info procs ::${node_info}::*]]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            set procname $child
            set tmp $child
            regsub -all {\:\:} $tmp @ tmp
            set child [lindex [split $tmp @] end]
            ::inspector::insert_node $listbox  $node_index  $child  $level  no $procname {{} ::inspector::show_procedure}

            incr node_index
        }
    }

    proc {::inspector::expand_variables} {listbox node_index node_info level} {
        set children [lsort [info vars ::${node_info}::*]]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            set varname $child
            set tmp $child
            regsub -all {\:\:} $tmp @ tmp
            set child [lindex [split $tmp @] end]

            # is it an array
            if { [llength [array names $varname]] != 0 } {
            ::inspector::insert_node $listbox  $node_index  $child  $level  yes $varname ::inspector::expand_array
            } else {
            ::inspector::insert_node $listbox  $node_index  $child  $level  no $varname {{} ::inspector::show_variable}
            }

            incr node_index
        }
    }

    proc {::inspector::init} {listbox} {
        global widget

        namespace eval ::${listbox} {

            variable contents
            set contents ""
        }

        $listbox delete 0 end
    }

    proc {::inspector::insert_node} {listbox before_index node_text level {has_children no} {node_info {}} {item_commands {}}} {
        upvar #0 ::${listbox}::contents contents

        set expanded 0

        set content_line  [list $has_children $node_info $item_commands $level $expanded]

        if {$has_children} {
            set node_text "\[+\] $node_text"
        }

        for {set i 0} {$i < $level} {incr i} {
            set node_text "    $node_text"
        }

        # the contents variable keeps a record of what is inside
        # the listbox
        set contents [linsert $contents $before_index $content_line]

        # now we insert text inside the actual listbox
        $listbox insert $before_index $node_text
    }

    proc {::inspector::show_procedure} {node_info} {
        global widget

        InspectorItem delete 0 end
        InspectorItem insert end $node_info

        InspectorArgumentsLabel configure -state normal
        InspectorArguments      configure -state normal

        set theargs [::vTcl:proc:get_args $node_info]
        InspectorArguments delete 0 end
        InspectorArguments insert end $theargs

        InspectorValue configure -state normal
        InspectorValue delete 0.0 end
        InspectorValue insert end "proc $node_info \{$theargs\} \{"
        InspectorValue insert end [info body $node_info]
        InspectorValue insert end \n\}
        InspectorValue configure -state disabled -wrap none

        vTcl:syntax_color $widget(InspectorValue) 0 -1
    }

    proc {::inspector::show_variable} {node_info} {
        InspectorItem delete 0 end
        InspectorItem insert end $node_info

        InspectorArgumentsLabel configure -state disabled
        InspectorArguments configure -state normal
        InspectorArguments delete 0 end
        InspectorArguments configure -state disabled

        InspectorValue configure -state normal
        InspectorValue delete 0.0 end

        if {[info exists $node_info]} {
            InspectorValue insert end [vTcl:at $node_info]
        }

        InspectorValue configure -state disabled -wrap word
    }

    proc {::inspector::expand_packages} {listbox node_index node_info level} {
        global widget

        set children [lsort [package names]]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            ::inspector::insert_node $listbox  $node_index  $child  $level  no $child {{} ::inspector::show_package}

            incr node_index
        }
    }

    proc {::inspector::show_package} {node_info} {
        InspectorItem delete 0 end
        InspectorItem insert end $node_info

        InspectorArgumentsLabel configure -state disabled
        InspectorArguments configure -state normal
        InspectorArguments delete 0 end
        InspectorArguments configure -state disabled

        InspectorValue configure -state normal
        InspectorValue delete 0.0 end

        set result [catch {package present $node_info}]
        if {$result == 1} {
            InspectorValue insert end "Package $node_info not loaded"
            InspectorValue configure -state disabled
            return
        }

        InspectorValue insert end "Package $node_info version "
        InspectorValue insert end [package present $node_info]
        InspectorValue configure -state disabled
    }

    proc {::inspector::expand_windows} {listbox node_index node_info level} {
        global widget

        # insert just after the node
        incr node_index
        incr level

        foreach child "." {

            ::inspector::insert_node $listbox  $node_index  $child  $level  yes $child \
                {::inspector::expand_widget ::inspector::show_widget}

            incr node_index
        }
    }

    proc {::inspector::expand_widget} {listbox node_index node_info level} {
        global widget

        set children [winfo children $node_info]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            set class [winfo class $child]

            ::inspector::insert_node $listbox  $node_index  "$child ($class)" $level \
                yes $child {::inspector::expand_widget ::inspector::show_widget}
            incr node_index
        }

        ::inspector::insert_node $listbox  $node_index "Bindtags" $level yes $node_info \
            {::inspector::expand_bindtags}
        incr node_index
    }

    proc {::inspector::show_widget} {node_info} {
        InspectorItem delete 0 end
        InspectorItem insert end $node_info

        InspectorValue configure -state normal
        InspectorValue delete 0.0 end

        if {[info command $node_info] == ""} {
            InspectorValue insert end "Invalid window"
            InspectorValue configure -state disabled
            return
        }

        set options [$node_info configure]
        foreach option $options {
            InspectorValue insert end ${option}\n
        }
        InspectorValue configure -state disabled
    }

    proc {::inspector::expand_bindtags} {listbox node_index node_info level} {

        set children [bindtags $node_info]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            ::inspector::insert_node $listbox  $node_index  $child  $level  yes $child \
                 {::inspector::expand_bindtag}

            incr node_index
        }
    }

    proc {::inspector::expand_bindtag} {listbox node_index node_info level} {

        set children [lsort [bind $node_info]]

        # insert just after the node
        incr node_index
        incr level

        foreach child $children {

            ::inspector::insert_node $listbox  $node_index  $child  $level  no "$node_info $child" \
                 {{} ::inspector::show_bind}

            incr node_index
        }
    }

    proc {::inspector::show_bind} {node_info} {

        global widget

        set bindtag [lindex $node_info 0]
        set binding [lindex $node_info 1]

        set bindcmd [bind $bindtag $binding]

        InspectorItem delete 0 end
        InspectorItem insert end $node_info

        InspectorValue configure -state normal
        InspectorValue delete 0.0 end
        InspectorValue insert end $bindcmd

        vTcl:syntax_color $widget(InspectorValue) 0 -1
        InspectorValue configure -state disabled
    }

    proc {::inspector::expand_or_contract} {W {x -1} {y -1}} {

        set listbox $W
        if {$x == -1} {
           set index [$W curselection]
        } else {
           set index [$W index @$x,$y]
        }

        set content_line [lindex [vTcl:at ::${W}::contents] $index]

        lassign $content_line has_children  node_info  item_commands  level  expanded

        if {$has_children && (!$expanded)} {

            ::inspector::expand_node $listbox $index
        } elseif {$has_children && $expanded} {

            ::inspector::contract_node $listbox $index
        }
    }

    proc {::inspector::listbox_select} {W} {

        set listbox $W
        set index [$W curselection]

        set content_line [lindex [vTcl:at ::${W}::contents] $index]

        lassign $content_line has_children  node_info  item_commands  level  expanded

        if {[llength $item_commands] >= 2} {

            set click_cmd [lindex $item_commands 1]
            $click_cmd $node_info
        }
    }
}

proc vTclWindow.vTcl.inspector {base} {

    if {$base == ""} {
        set base .vTcl.inspector
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget
    vTcl:DefineAlias $base.cpd26.01.cpd27.01 InspectorListbox vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd26.02.cpd28.03 InspectorValue vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd26.02.ent24 InspectorItem vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd26.02.ent26 InspectorArguments vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd26.02.lab22 InspectorItemLabel vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd26.02.lab25 InspectorArgumentsLabel vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd26.02.lab27 InspectorValueLabel vTcl:WidgetProc $base 1

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm transient .vTcl.inspector .vTcl
    wm withdraw $base
    wm geometry $base 550x400
    wm maxsize $base 1600 1200
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "System Inspector"
    wm protocol $base WM_DELETE_WINDOW "Window hide $base"

    frame $base.fra23 \
        -borderwidth 2
    ::vTcl::OkButton $base.fra23.but24 -command "Window hide $base"
    frame $base.cpd26 \
        -background #000000
    frame $base.cpd26.01

    ScrolledWindow $base.cpd26.01.cpd27
    listbox $base.cpd26.01.cpd27.01
    $base.cpd26.01.cpd27 setwidget $base.cpd26.01.cpd27.01
    bindtags $base.cpd26.01.cpd27.01 "Listbox $base.cpd26.01.cpd27.01 $base all"
    bind $base.cpd26.01.cpd27.01 <<ListboxSelect>> {
        ::inspector::listbox_select %W
    }
    bind $base.cpd26.01.cpd27.01 <Double-Button-1> {
        ::inspector::expand_or_contract %W %x %y
    }
    bind $base.cpd26.01.cpd27.01 <Key-Return> {
        ::inspector::expand_or_contract %W
    }
    frame $base.cpd26.01.fra29 \
        -borderwidth 2
    vTcl:toolbar_button $base.cpd26.01.fra29.but30 \
        -image [vTcl:image:get_image "refresh.gif"]
    frame $base.cpd26.02
    label $base.cpd26.02.lab22 \
        -anchor w  -padx 1 -text Item
    entry $base.cpd26.02.ent24
    label $base.cpd26.02.lab25 \
        -anchor w -padx 1 -text Arguments
    entry $base.cpd26.02.ent26
    label $base.cpd26.02.lab27 \
        -anchor w -padx 1 -text Value

    ScrolledWindow $base.cpd26.02.cpd28
    text $base.cpd26.02.cpd28.03 \
        -background #dcdcdc  \
        -padx 1 -pady 1
    $base.cpd26.02.cpd28 setwidget $base.cpd26.02.cpd28.03

    frame $base.cpd26.03 \
        -background #ff0000 -borderwidth 2 -height 0 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 0
    bind $base.cpd26.03 <B1-Motion> {
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
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra23 \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.fra23.but24 \
        -in $base.fra23 -anchor center -expand 0 -fill none -side right
    pack $base.cpd26 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd26.01 \
        -x 0 -y 0 -width -1 -relwidth 0.3466 -relheight 1 -anchor nw \
        -bordermode ignore

    pack $base.cpd26.01.cpd27 \
        -in $base.cpd26.01 -anchor center -expand 1 -fill both -side bottom
    #pack $base.cpd26.01.cpd27.01     Rozen  2/19 pm

    pack $base.cpd26.01.fra29 \
        -in $base.cpd26.01 -anchor center -expand 0 -fill x -side top
    pack $base.cpd26.01.fra29.but30 \
        -in $base.cpd26.01.fra29 -anchor center -expand 0 -fill none \
        -side left
    place $base.cpd26.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.6534 -relheight 1 -anchor ne \
        -bordermode ignore
    pack $base.cpd26.02.lab22 \
        -in $base.cpd26.02 -anchor w -expand 0 -fill none -padx 3 -side top
    pack $base.cpd26.02.ent24 \
        -in $base.cpd26.02 -anchor center -expand 0 -fill x -padx 3 -side top
    pack $base.cpd26.02.lab25 \
        -in $base.cpd26.02 -anchor w -expand 0 -fill none -padx 3 -side top
    pack $base.cpd26.02.ent26 \
        -in $base.cpd26.02 -anchor center -expand 0 -fill x -padx 3 -side top
    pack $base.cpd26.02.lab27 \
        -in $base.cpd26.02 -anchor w -expand 0 -fill none -padx 3 -side top

    pack $base.cpd26.02.cpd28 \
        -in $base.cpd26.02 -anchor center -expand 1 -fill both -padx 3 \
        -pady 3 -side top
    #pack $base.cpd26.02.cpd28.03   Rozen 2/19 pm

    place $base.cpd26.03 \
        -x 0 -relx 0.3466 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore

    global vTcl
    ::inspector::init $widget(InspectorListbox)
    ::inspector::insert_node $widget(InspectorListbox)  end  "::"  0  yes  "::"  ::inspector::expand_namespace
    ::inspector::insert_node $widget(InspectorListbox)  end  "Packages"  0  yes  "Packages"  ::inspector::expand_packages
    ::inspector::insert_node $widget(InspectorListbox)  end  "Windows"  0 yes "Windows" ::inspector::expand_windows

    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base

    vTcl:setup_vTcl:bind $base
}
