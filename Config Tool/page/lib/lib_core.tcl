##############################################################################
# $Id: lib_core.tcl,v 1.1 2012/01/22 03:26:03 rozen Exp rozen $
#
# lib_core.tcl - core tcl/tk widget support library
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

#
# initializes this library
#
proc vTcl:lib_core:init {} {
    global vTcl

    lappend vTcl(libNames) "Tcl/Tk Core Widget Library"
    return 1
}

proc vTcl:widget:lib:lib_core {args} {
    global vTcl

#    Menubutton
#      CompoundContainer
#      MegaWidget
#    UnmanagedFrame
#    Scrollbar

    set order {
        Toplevel
        Message
        Frame
        Canvas
        Button
        Entry
        Label
        Listbox
        Text
        Checkbutton
        Radiobutton
        Scale
        Spinbox
    }

# Rozen
#     if {[info tclversion] >= 8.4} {
#     lappend order Spinbox
#     lappend order Labelframe
#     lappend order Panedwindow
#     }

    vTcl:lib:add_widgets_to_toolbar $order core "Tk Widgets"

    # Since there is only one band for PAGE, let's expand it. Rozen
    kpwidgets::SBands::Expand .vTcl.toolbar.sbands.sw.sff.frame.bfrmcore

    append vTcl(head,core,importheader) {
        package require Tk
        switch $tcl_platform(platform) {
            windows {
                option add *Button.padY 0
            }
            default {
                option add *Scrollbar.width 10
                option add *Scrollbar.highlightThickness 0
                option add *Scrollbar.elementBorderWidth 2
                option add *Scrollbar.borderWidth 2
            }
        }
    }
}

####################################################################
# Tooltip support
#

proc vTcl:get_balloon {target} {
    set events [bind $target]
    if {[lsearch -exact $events <<SetBalloon>>] == -1} {
        return ""
    }
    set event [string trim [bind $target <<SetBalloon>>]]
    if {[string match {set ::vTcl::balloon::%W*} $event]} {
        return [lindex $event 2]
    }
    return ""
}

proc vTcl:update_balloon {target var} {
    set ::$var [vTcl:get_balloon $target]
}

proc vTcl:config_balloon {target value} {
    set old [vTcl:get_balloon $target]
    set new $value
    if {$old == "" && $new == ""} {
        return
    }
    if {$old != "" && $new == ""} {
        bind $target <<SetBalloon>> {}
        ::widgets_bindings::remove_tag_from_widget $target _vTclBalloon
    } else {
        bind $target <<SetBalloon>> "set ::vTcl::balloon::%W \{$new\}"
        ::widgets_bindings::add_tag_to_widget $target _vTclBalloon
        ::widgets_bindings::add_tag_to_tagslist _vTclBalloon
    }

    ## if the bindings editor is there, refresh it
    if {[winfo exists .vTcl.bind]} {
        ::widgets_bindings::save_current_binding
        vTcl:get_bind $target
    }
}

####################################################################
# Procedures to support extra geometry mgr configuration
#

proc vTcl:grid:conf_ext {target var value} {
    global vTcl
    set parent [winfo parent $target]
    grid columnconf $parent $vTcl(w,grid,-column) -weight  $vTcl(w,grid,column,weight)
    grid columnconf $parent $vTcl(w,grid,-column) -minsize $vTcl(w,grid,column,minsize)
    grid rowconf    $parent $vTcl(w,grid,-row)    -weight  $vTcl(w,grid,row,weight)
    grid rowconf    $parent $vTcl(w,grid,-row)    -minsize $vTcl(w,grid,row,minsize)
    # Both required for better compatibilty!
    grid propagate  $target $vTcl(w,grid,propagate)
    pack propagate  $target $vTcl(w,grid,propagate)
}

proc vTcl:pack:conf_ext {target var value} {
    global vTcl
    # Both required for better compatibilty!
    pack propagate  $target $vTcl(w,pack,propagate)
    grid propagate  $target $vTcl(w,pack,propagate)
}

proc vTcl:wm:enable_geom {} {
    global vTcl
    # Enable/disable UI elements
    array set state {0 disabled 1 normal}
    if {$vTcl(w,class) == "Menu"} {
        set origin_state disabled
        set size_state   disabled
    } else {
        set origin_state $state($vTcl(w,wm,set,origin))
        set size_state   $state($vTcl(w,wm,set,size))
    }

    vTcl:prop:enable_manager_entry geometry,x $origin_state
    vTcl:prop:enable_manager_entry geometry,y $origin_state
    vTcl:prop:enable_manager_entry geometry,w $size_state
    vTcl:prop:enable_manager_entry geometry,h $size_state
}

proc vTcl:wm:conf_geom {target var value} {
    global vTcl
    set ::widgets::${target}::set,origin $vTcl(w,wm,set,origin)
    set ::widgets::${target}::set,size   $vTcl(w,wm,set,size)
    set ::widgets::${target}::runvisible $vTcl(w,wm,runvisible)
    set x $vTcl(w,wm,geometry,x)
    set y $vTcl(w,wm,geometry,y)
    set w $vTcl(w,wm,geometry,w)
    set h $vTcl(w,wm,geometry,h)
    wm geometry $target ${w}x${h}+${x}+${y}
    vTcl:wm:enable_geom
}

proc vTcl:wm:conf_resize {target var value} {
    global vTcl
    set w $vTcl(w,wm,resizable,w)
    set h $vTcl(w,wm,resizable,h)
    wm resizable $target $w $h
}

proc vTcl:wm:conf_minmax {target var value} {
    global vTcl
    set min_x $vTcl(w,wm,minsize,x)
    set min_y $vTcl(w,wm,minsize,y)
    set max_x $vTcl(w,wm,maxsize,x)
    set max_y $vTcl(w,wm,maxsize,y)
    wm minsize $target $min_x $min_y
    wm maxsize $target $max_x $max_y
}

proc vTcl:wm:conf_state {target var value} {
    global vTcl
    catch {wm $vTcl(w,wm,state) $target}
}

proc vTcl:wm:conf_title {target var value} {
    global vTcl
    wm title $target "$vTcl(w,wm,title)"
}

proc vTcl:wm:dump_info {target basename} {
    global vTcl
    set out ""
    append out $vTcl(tab)
    append out "namespace eval ::widgets::$basename \{\n"
    foreach wm_option $vTcl(m,wm,savelist) {
        if {[info exists ::widgets::${target}::${wm_option}]} {
            append out $vTcl(tab2)
            append out "set $wm_option [vTcl:at ::widgets::${target}::${wm_option}]\n"
        }
    }
    append out "$vTcl(tab)\}\n"
    return $out
}

####################################################################
# Procedures to support "double-click" action on widets
# There are mostly procedures to support the special case of menus
#

proc vTcl:edit_target_menu {target} {
    global vTcl
    #  vTcl:prop:default_opt is in propmgr.tcl
    if [catch {set menu [$target cget -menu]}] {
        return
    }
    if {$menu == ""} {  # It's a new menu. Rozen
        set menu [vTcl:new_widget_name m $target]
        menu $menu -bg $vTcl(pr,menubgcolor) -tearoff 0
        #$menu configure -bg $vTcl(pr,menubgcolor)  ;# Rozen
        set menu_opts [$menu configure]
        vTcl:widget:register_widget $menu -tearoff
        vTcl:setup_vTcl:bind $menu
        $target conf -menu $menu
        # foreach def {-activebackground -activeforeground
        #              -background -foreground -font} {
        #     switch -exact -- $def {
        #         -background {
        #  vTcl:prop:default_opt $menu $def vTcl(w,opt,$def) $vTcl(pr,menubgcolor)
        #         }
        #         -foreground {
        #  vTcl:prop:default_opt $menu $def vTcl(w,opt,$def) $vTcl(pr,menufgcolor)
        #         }
        #         -font {
        #  vTcl:prop:default_opt $menu $def vTcl(w,opt,$def) $vTcl(pr,font_menu)
        #         }
        #         default {
        #             vTcl:prop:default_opt $menu $def vTcl(w,opt,$def)
        #         }
        #     }
        # }
        ::menu_edit::set_menu_item_defaults $menu ""  ;# Rozen
    }

    set name [vTcl:rename $menu]
    set base ".vTcl.menu_$name"

    vTclWindow.vTclMenuEdit $base $menu
}

proc vTcl:edit_menu {menu} {
    set name [vTcl:rename $menu]
    set base ".vTcl.menu_$name"

    vTclWindow.vTclMenuEdit $base $menu
}

# translation for options when saving files

TranslateOption    -menu vTcl:core:menutranslate
NoEncaseOption     -menu 1
NoEncaseOptionWhen -menu vTcl:core:noencasewhen

proc vTcl:core:menutranslate {value} {

    global vTcl

    if [regexp {((\.[a-zA-Z0-9_]+)+)} $value matchAll path] {

        if {$matchAll == $value} {

                    set path [vTcl:base_name $path]

            return "\"$path\""
        }
    }

        return $value
}

TranslateOption    -xscrollcommand vTcl:core:scrolltranslate
NoEncaseOption     -xscrollcommand 1
NoEncaseOptionWhen -xscrollcommand vTcl:core:noencasewhen

TranslateOption    -yscrollcommand vTcl:core:scrolltranslate
NoEncaseOption     -yscrollcommand 1
NoEncaseOptionWhen -yscrollcommand vTcl:core:noencasewhen

TranslateOption    -command vTcl:core:commandtranslate
NoEncaseOption     -command 1
NoEncaseOptionWhen -command vTcl:core:noencasecommandwhen

TranslateOption    -listvariable vTcl:core:variabletranslate
NoEncaseOption     -listvariable 1
NoEncaseOptionWhen -listvariable vTcl:core:noencasewhen

TranslateOption    -variable vTcl:core:variabletranslate
NoEncaseOption     -variable 1
NoEncaseOptionWhen -variable vTcl:core:noencasewhen

TranslateOption    -textvariable vTcl:core:variabletranslate
NoEncaseOption     -textvariable 1
NoEncaseOptionWhen -textvariable vTcl:core:noencasewhen

proc vTcl:core:variabletranslate {value} {

        global vTcl
    if {[regexp {(\.[\.a-zA-Z0-9_]+)::(.*)} $value matchAll path variable]} {

            ## potential candidate, is it a window ?
            if {![winfo exists $path]} {return $value}

        if {"$path" == "[winfo toplevel $path]"} {
            set path {$top}
        } else {
                set path [vTcl:base_name $path]
        }

            return "\"${path}\\::${variable}\""
        }

        return $value
}

proc vTcl:core:scrolltranslate {value} {

    global vTcl
    if [regexp {((\.[a-zA-Z0-9_]+)+) set} $value matchAll path] {

                set path [vTcl:base_name $path]

        return "\"$path set\""
    }

        return $value
}

proc vTcl:core:commandtranslate {value} {

    global vTcl
    if {[regexp {(\.[\.a-zA-Z0-9_]+) (x|y)view} $value matchAll path axis]} {

        set path [vTcl:base_name $path]

    return "\"$path ${axis}view\""

    } elseif {[regexp {vTcl:DoCmdOption (\.[\.a-zA-Z0-9_]+) (.*)} $value matchAll path cmd]} {

        set path [vTcl:base_name $path]

        return "\[list vTcl:DoCmdOption $path $cmd\]"
    }

    return $value
}

proc vTcl:core:noencasewhen {value} {

    if { [string match {"$base*} $value] ||
         [string match {"$site*} $value] ||
         [string match {"$target*} $value] ||
     [string match {"$top*} $value] } {
        return 1
    }

    return 0
}

proc vTcl:core:noencasecommandwhen {value} {

    if { [string match {"$base*?view"} $value] ||
             [string match {"$site*?view"} $value] ||
             [string match {"$top*?view"} $value] ||
             [string match {\[list vTcl:DoCmdOption $base*} $value] ||
             [string match {\[list vTcl:DoCmdOption $top*} $value] ||
             [string match {\[list vTcl:DoCmdOption $site*} $value] } {
        return 1
    } else {
        return 0
    }
}

proc vTcl:core:set_option {target option description} {
    global vTcl
    set value [$target cget $option]
    set newvalue [vTcl:get_string $description $target $value]
    # cancelled?
    if {$newvalue == "*"} {
        # Rozen changfed this to be an illegal character in a python
        # variable name so that I could use this to remove a specified
        # variable by returning a null.
        return
    }
    if {! [vTcl:streq $value $newvalue]} {
        # we better save that option, too
        set vTcl(w,opt,$option) $newvalue
        vTcl:prop:save_opt $target $option vTcl(w,opt,$option)

        # keep showing the selection in the toplevel
        # (do not destroy the selection handles)
        vTcl:init_wtree 0
    }
}

namespace eval vTcl::widgets::core {

    ## Utility proc.  Dump a megawidget's children, but not those that are
    ## part of the megawidget itself.  Differs from vTcl:dump:widgets in that
    ## it dumps the geometry of $subwidget, but it doesn't dump $subwidget
    ## itself (`vTcl:dump:widgets $subwidget' doesn't do the right thing if
    ## the grid geometry manager is used to manage children of $subwidget.
    proc dump_subwidgets {subwidget {sitebasename {}}} {
        puts "dump_subwidgets $subwidget"
        global vTcl basenames classes
        set output ""
        set geometry ""
        set length      [string length $subwidget]
        set basenames($subwidget) $sitebasename

        foreach i [vTcl:get_children $subwidget] {

            set basename [vTcl:base_name $i]

            # don't try to dump subwidget itself
            if {"$i" != "$subwidget"} {
                set basenames($i) $basename
                set class [vTcl:get_class $i]
                append output [$classes($class,dumpCmd) $i $basename]
                append geometry [vTcl:dump_widget_geom $i $basename]
                unset basenames($i)
            }
        }
        append output $geometry

        unset basenames($subwidget)
        return $output
    }
}

####################################################################
# Add/remove pages to notebooks, columns to the multicolumn listbox,
# edit sites in a paned window, etc.

proc vTclWindow.vTcl.itemEdit {base} {
    if {$base == ""} {
        set base .vTcl.itemEdit
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $base -class Toplevel -menu $base.m73
    wm focusmodel $base passive
    set defaultGeometry 1
    if {[info exists ::vTcl(pr,edit[vTcl:at ::vTcl::itemEdit::class($base)])]} {
        wm geometry $base $::vTcl(pr,edit[vTcl:at ::vTcl::itemEdit::class($base)])
        set defaultGeometry 0
    } else {
        wm geometry $base 490x343
    }
    wm withdraw $base
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Edit"
    vTcl:FireEvent $base <<Create>>
    wm protocol $base WM_DELETE_WINDOW "::vTcl::itemEdit::close $base"
    wm transient $base .vTcl
    ###################
    # DEFINING ALIASES
    ###################
    vTcl:DefineAlias $base.cpd37.01.cpd38.01 ItemsListbox vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd37.02.sw.c.f PropertiesFrame vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd37.02.sw.c PropertiesCanvas vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra34.but36 ItemsEditDelete vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.m73.men74 ItemsEditMenuAddDelete vTcl:WidgetProc $base 1
    menu $base.m73 -relief flat
    $base.m73 add cascade \
        -menu "$base.m73.men74" -label Item
    $base.m73 add cascade \
        -menu "$base.m73.men75" -label Move
    menu $base.m73.men74 \
        -tearoff 0
    $base.m73.men74 add command \
        -command "::vTcl::itemEdit::addItem $base" -label Add
    $base.m73.men74 add command \
        -command "::vTcl::itemEdit::removeItem $base" -label Delete
    menu $base.m73.men75 \
        -tearoff 0
    $base.m73.men75 add command \
        -command "::vTcl::itemEdit::moveUpOrDown $base up" -label Up
    $base.m73.men75 add command \
        -command "::vTcl::itemEdit::moveUpOrDown $base down" -label Down
    frame $base.fra34 \
        -width 125
    vTcl:toolbar_button $base.fra34.but35 \
        -image [vTcl:image:get_image add.gif] \
        -command "::vTcl::itemEdit::addItem $base"
    vTcl:set_balloon $base.fra34.but35 {Add}
    vTcl:toolbar_button $base.fra34.but36 \
        -image [vTcl:image:get_image remove.gif] \
        -command "::vTcl::itemEdit::removeItem $base"
    vTcl:set_balloon $base.fra34.but36 {Delete}
    vTcl:toolbar_button $base.fra34.but37 \
        -image up -command "::vTcl::itemEdit::moveUpOrDown $base up"
    vTcl:set_balloon $base.fra34.but37 {Move Up}
    vTcl:toolbar_button $base.fra34.but38 \
        -image down -command "::vTcl::itemEdit::moveUpOrDown $base down"
    vTcl:set_balloon $base.fra34.but38 {Move Down}
    vTcl:toolbar_button $base.fra34.but39 \
        -image [vTcl:image:get_image ok.gif] \
        -command "::vTcl::itemEdit::close $base"
    vTcl:set_balloon $base.fra34.but39 {Close}
    frame $base.cpd37 \
        -background #000000 -height 100 -width 200
    frame $base.cpd37.01
    frame $base.cpd37.01.cpd38 \
        -borderwidth 1 -height 30 -relief raised -width 30
    # Rozen the list box where the pages are listed.
    listbox $base.cpd37.01.cpd38.01 \
        -background #ffffff \
        -xscrollcommand "$base.cpd37.01.cpd38.02 set" \
        -yscrollcommand "$base.cpd37.01.cpd38.03 set" \
        -listvariable ::${base}::list_items
    # Rozen to aid in debugging
    bind $base.cpd37.01.cpd38.01 <<ListboxSelect>> {
        ::vTcl::itemEdit::selectItem [winfo toplevel %W] \
            [lindex [%W curselection] 0]
    }
#     bind $base.cpd37.01.cpd38.01 <<ListboxSelect>> {
#         ::vTcl::itemEdit::listboxSelect \
#         ::vTcl::itemEdit::selectItem [winfo toplevel %W] \
# $            [lindex [%W curselection] 0]
#         ::vTcl::itemEdit::selectItem [winfo toplevel %W] \
#             [lindex [%W curselection] 0]
#     }
    scrollbar $base.cpd37.01.cpd38.02 \
        -command "$base.cpd37.01.cpd38.01 xview" -orient horizontal
    scrollbar $base.cpd37.01.cpd38.03 \
        -command "$base.cpd37.01.cpd38.01 yview"
    frame $base.cpd37.02
    frame $base.cpd37.03 \
        -background #ff0000 -borderwidth 2 -relief raised
    bind $base.cpd37.03 <B1-Motion> {
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
    ScrolledWindow $base.cpd37.02.sw
    canvas $base.cpd37.02.sw.c \
        -highlightthickness 0 -yscrollincrement 20
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra34 \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.fra34.but35 \
        -in $base.fra34 -anchor center -expand 0 -fill none -side left
    pack $base.fra34.but36 \
        -in $base.fra34 -anchor center -expand 0 -fill none -side left
    pack $base.fra34.but37 \
        -in $base.fra34 -anchor center -expand 0 -fill none -side left
    pack $base.fra34.but38 \
        -in $base.fra34 -anchor center -expand 0 -fill none -side left
    pack $base.fra34.but39 \
        -in $base.fra34 -anchor center -expand 0 -fill none -side right
    pack $base.cpd37 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd37.01 \
        -x 0 -y 0 -width -1 -relwidth 0.55 -relheight 1 -anchor nw \
        -bordermode ignore
    pack $base.cpd37.01.cpd38 \
        -in $base.cpd37.01 -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd37.01.cpd38 0 -weight 1
    grid rowconf $base.cpd37.01.cpd38 0 -weight 1
    grid $base.cpd37.01.cpd38.01 \
        -in $base.cpd37.01.cpd38 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.cpd37.01.cpd38.02 \
        -in $base.cpd37.01.cpd38 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.cpd37.01.cpd38.03 \
        -in $base.cpd37.01.cpd38 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    place $base.cpd37.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.45 -relheight 1 -anchor ne \
        -bordermode ignore
    place $base.cpd37.03 \
        -x 0 -relx 0.55 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore
    pack $base.cpd37.02.sw \
        -in $base.cpd37.02 -anchor center -expand 1 -fill both -side top
#    pack $base.cpd37.02.sw.c \      Rozen BWidget
#        -in $base.cpd37.02.sw

    ## tell the scrolledwindow what widget it should scroll
    $base.cpd37.02.sw setwidget $base.cpd37.02.sw.c

    ## insert a frame into the canvas so we can put stuff in it
    frame $base.cpd37.02.sw.c.f
    $base.cpd37.02.sw.c create window 0 0 -window $base.cpd37.02.sw.c.f \
        -anchor nw -tag properties
    ## set up visual Tcl keyboard accelerators
    vTcl:setup_vTcl:bind $base

    if {$defaultGeometry} {
       vTcl:center $base 490 343
    }
    wm deiconify $base

    vTcl:FireEvent $base <<Ready>>
}

namespace eval ::vTcl::itemEdit {

    variable cmds
    variable target
    variable counter
    variable suffix
    variable current
    variable allOptions
    variable enableData
    variable adding
    variable class
    set counter 0

    proc edit {target cmds} {
        variable counter
        variable suffix
        variable class
        incr counter                    ;# NEEDS WORK - dii I want this line???
        set top .vTcl.itemEdit_$counter
        set suffix($top) $counter
        set class($top) [vTcl:get_class $target]
        Window show .vTcl.itemEdit $top
        init $top $target $cmds
    }

    ## get initial values for the checkboxes
    proc initBoxes {top} {
        variable target
        variable allOptions
        variable cmds
        set w $target($top)
        set nm ::widgets::${w}::subOptions
        namespace eval $nm {}

    ## first time ? if so, check values that are not the default
    if {![info exists ${nm}::save]} {
            ## how many subitems ?
            set size [llength [vTcl:at ::${top}::list_items]]
            for {set i 0} {$i < $size} {incr i} {
            set conf [::$cmds($top)::itemConfigure $target($top) $i]
                foreach opt $conf {
            set option  [lindex $opt 0]
                    set default [lindex $opt 3]
            set value   [lindex $opt 4]
            if {$value != $default} {
                set ${nm}::save($option) 1
            }
                }
            }
    }
    }

    ## action to take when a box is checked
    proc setGetBox {top option {var {}}} {
        variable target
        set w $target($top)
        set nm ::widgets::${w}::subOptions
        if {$var != ""} {
            set ${nm}::save($option) [vTcl:at $var]
        } else {
            if {[info exists ${nm}::save($option)]} {
                return [vTcl:at ${nm}::save($option)]
            } else {
                return 0
            }
        }
    }

    ## action to take when a key is released in an option
    proc keyRelease {top option var boxvar} {
        variable cmds
        variable current
        variable target

    set conf [::$cmds($top)::itemConfigure $target($top) $current($top) $option]
    set default [lindex $conf 3]
    set value [vTcl:at $var]

    if {$value != $default} {
        set $boxvar 1
        setGetBox $top $option $boxvar
    }
    }

    proc init {top w cmdsEdit} {
        variable cmds
        variable target
        variable current
        variable adding
        set cmds($top) $cmdsEdit
        set target($top) $w
        set adding($top) 0
        set list_items [::$cmds($top)::getItems $target($top)]
        set current($top) [lindex $list_items 0]
        set list_items [lrange $list_items 1 end]
        set ::${top}::list_items $list_items
        initBoxes $top
        initProperties $top   ;# initProperties at about line 770
        selectItem $top $current($top) ;# selectItem at about line 840
        wm title $top [::$cmds($top)::getTitle $w]

        ::vTcl::notify::subscribe delete_widget $top ::vTcl::itemEdit::widgetDeleted
        ::vTcl::notify::subscribe deleted_childsite $top ::vTcl::itemEdit::childsiteDeleted
    }

    ## find the superset of all options for all subitems
    proc allOptions {top} {
        variable cmds
        variable target
        set optionsList ""
        if {[info proc ::$cmds($top)::getMinimumOptions] != ""} {
            return [::$cmds($top)::getMinimumOptions]
        }
        ## how many subitems ?
        set size [llength [vTcl:at ::${top}::list_items]]
        for {set i 0} {$i < $size} {incr i} {
            set conf [::$cmds($top)::itemConfigure $target($top) $i]
            foreach option $conf {
                lappend optionsList [lindex $option 0]
            }
        }

        ## remove duplicates
        set optionsList [vTcl:lrmdups $optionsList] ;# Rozen
        return $optionsList
    }

    proc initProperties {top} {
        variable cmds
        variable target
        variable suffix
        variable current
        variable allOptions
        variable enableData
        set options [allOptions $top]
        set allOptions($top) $options
        foreach option $options {
            set variable ::vTcl::itemEdit::${option}_$suffix($top)
            set $variable ""
            set f [$top.PropertiesFrame].$option
            frame $f
            set config_cmd "
               ::$cmds($top)::itemConfigure $target($top) \
                   \[vTcl:at ::vTcl::itemEdit::current($top)\] \
                   $option \[vTcl:at $variable\]
               "
            set enableData($top,$option) [::vTcl::ui::attributes::newAttribute \
                $target($top) $f $option $variable $config_cmd \
                "::vTcl::itemEdit::setGetBox $top" \
        "::vTcl::itemEdit::keyRelease $top"]
            pack $f -side top -fill x -expand 0
        }
#after 5000 {vTcl:exit}

        ## the label option is kinda special, it updates the label in the
        ## listbox as well
        set labelOption [::$cmds($top)::getLabelOption]
        if {$labelOption != ""} {
            set variable ::vTcl::itemEdit::${labelOption}_$suffix($top)
            trace variable $variable w \
                "::vTcl::itemEdit::setLabel $top $labelOption $variable"
        }

        ## calculate the scrolling region
        update idletasks
        set w [winfo width  [$top.PropertiesFrame]]
        set h [winfo height [$top.PropertiesFrame]]
        ${top}.PropertiesCanvas configure -scrollregion [list 0 0 $w $h]

    ## keyboard accelerators
        vTcl:setup_vTcl:bind [$top.PropertiesFrame]
    }

    proc setLabel {top option variable args} {
        variable current
        variable target
        variable cmds
        variable adding
        ## when adding items, prevent the trace from being executed
        if {$adding($top)} {return}

        set label [::vTcl:at $variable]
        set ::${top}::list_items [lreplace [::vTcl:at ::${top}::list_items] \
            $current($top) $current($top) $label]
        ::$cmds($top)::itemConfigure $target($top) $current($top) \
            $option $label
    }

    proc selectItem {top index} {
        variable cmds
        variable target
        variable suffix
        variable current
        variable allOptions
        variable enableData
        ## first, sets any pending options
        ::vTcl::ui::attributes::setPending
        ${top}.ItemsListbox selection clear 0 end
        ${top}.ItemsListbox selection set $index
        set current($top) $index
        set properties [::$cmds($top)::itemConfigure $target($top) $index]

        foreach property $properties {
            set option [lindex $property 0]
            #set value  [lindex $property 4]
            set value  [lindex $property 1]
            set variable ::vTcl::itemEdit::${option}_$suffix($top)
            set $variable $value
            lappend currentOptions $option
        }
        foreach option $allOptions($top) {
            # enable/disable option if it does/does not apply to subitem
            if {[lsearch -exact $currentOptions $option] == -1} {
              ::vTcl::ui::attributes::enableAttribute $enableData($top,$option) 0
            } else {
              ::vTcl::ui::attributes::enableAttribute $enableData($top,$option) 1
            }
        }
    }

    proc widgetDeleted {top w} {
        variable target
        if {$target($top) == $w} {
            close $top
        }
    }

    proc close {top} {
        # Routine called when the check is selected.
        variable cmds
        variable target
        variable suffix
        variable current
        variable allOptions
        variable enableData
        variable class

        ## first, sets any pending options
        ::vTcl::ui::attributes::setPending   ;# in misc.tcl bottom

        set ::vTcl(pr,edit$class($top)) [wm geometry $top]
        destroy $top
        ## clean up after ourselves
        foreach option $allOptions($top) {
            set variable ${option}_$suffix($top)
            variable $variable
            unset $variable
            unset enableData($top,$option)
        }
        unset cmds($top)
        unset target($top)
        unset suffix($top)
        unset current($top)
        unset allOptions($top)

        ::vTcl::notify::unsubscribe delete_widget $top
        ::vTcl::notify::unsubscribe deleted_childsite $top
    }

    proc addItem {top} {
        variable cmds
        variable target
        variable adding
        ::vTcl::ui::attributes::setPending
        vTcl:setup_unbind_widget $target($top)
        set added [::$cmds($top)::addItem $target($top)]
        vTcl:setup_bind_widget $target($top)
        ## user canceled ?
        if {$added == ""} {return}
        set adding($top) 1
        lappend ::${top}::list_items $added
        set length [llength [vTcl:at ::${top}::list_items]]
        selectItem $top [expr $length - 1]
        set adding($top) 0
        enableMenus $top

    ## update attributes editor
    if {$::vTcl(w,widget) == $target($top)} {
        vTcl:update_widget_info $target($top)
    }
    }

    ## a childsite has been deleted, need to refresh the display
    proc childsiteDeleted {top w index} {
        variable cmds
        variable target
        variable current

        if {$index == -1} {return}
        ::vTcl::ui::attributes::setPending
        set ::${top}::list_items [lreplace [::vTcl:at ::${top}::list_items] \
            $index $index]
        set length [llength [::vTcl:at ::${top}::list_items]]

        set current($top) [expr $current($top) % $length]
        selectItem $top $current($top)

        enableMenus $top
    }

    proc removeItem {top} {
        variable cmds
        variable target
        variable current

        ::vTcl::ui::attributes::setPending
        vTcl:setup_unbind_widget $target($top)
        ::$cmds($top)::removeItem $target($top) $current($top)
        vTcl:setup_bind_widget $target($top)
        set ::${top}::list_items [lreplace [::vTcl:at ::${top}::list_items] \
            $current($top) $current($top)]
        set length [llength [::vTcl:at ::${top}::list_items]]
        set current($top) [expr $current($top) % $length]
        selectItem $top $current($top)
    enableMenus $top

    ## update attributes editor
    if {$::vTcl(w,widget) == $target($top)} {
        vTcl:update_widget_info $target($top)
    }
    }

    proc moveUpOrDown {top direction} {
        variable cmds
        variable target
        variable current

        ::vTcl::ui::attributes::setPending
        set offset(up) -1
        set offset(down) 1
        ::$cmds($top)::moveUpOrDown $target($top) $current($top) $direction
        set list_items [::$cmds($top)::getItems $target($top)]
        set list_items [lrange $list_items 1 end]
        set ::${top}::list_items $list_items
        set length [llength $list_items]
        set current($top) [expr ($current($top) + $offset($direction)) % $length]
        selectItem $top $current($top)
    }

    proc enableMenus {top} {
        set length [llength [vTcl:at ::${top}::list_items]]

    ## if there is only one item left, we don't allow the user to
    ## delete it (it wouldn't make much sense to have a tabnotebook
    ## with no pages or a toolbar with no buttons)
    set enabled [expr $length > 1]
    set state(1) normal
    set state(0) disabled
    $top.ItemsEditDelete configure -state $state($enabled)
    $top.ItemsEditMenuAddDelete entryconfigure 1 -state $state($enabled)
    }
    proc listboxSelect { args} {
         # Rozen to be able to debug the list box selection process
   }
}





