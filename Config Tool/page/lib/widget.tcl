#############################################################################
# $Id: widget.tcl,v 1.1 2012/01/22 03:15:13 rozen Exp rozen $
#
# widget.tcl - procedures for manipulating widget information
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

# vTcl:widget:register_widget - where the default options are set.
# vTcl:create_widget          - where the widget is created.

# deault configuration values are set near line 1540.

###
## A workaround for the winfo toplevel problem. Menus are placed with wm
## and winfo toplevel doesn't return the correct widget.
proc vTcl:get_toplevel {target} {
    set c [vTcl:get_class $target]
    if {$c == "Menu"} {
        # go up until we find the parent toplevel
        return [vTcl:get_toplevel [winfo parent $target]]
    } else {
        return [winfo toplevel $target]
    }
}

#
# Given a full widget path, returns a name with "$base" replacing
# the first widget element.
#
proc vTcl:base_name {target} {

    ## don't change anything if the widget doesn't start with a
    ## period (.) because it could be an alias
    if {[string range $target 0 0] != "."} {
        return $target
    }

    ## let's see if there is a basename to replace
    global basenames
    if {[info exists basenames($target)]} {
        return $basenames($target)
    } else {
        ## let's see if we have a partial match
        foreach name [lsort -decreasing [array names basenames]] {
            if {[string match $name* $target]} {
                set length [string length $name]
                set result [string replace $target 0 [expr $length - 1] \
                    $basenames($name)]
                return $result
            }
        }
    }

    ## otherwise, just replace the toplevel by $top
    set l [split $target .]
    set name "\$top"
    foreach i [lrange $l 2 end] {
        append name ".$i"
    }
    return $name
}

#
# Given two compatible widgets, sets up a scrollbar
# link (i.e. textfield and scrollbar)
#
proc vTcl:bind_scrollbar {t1 t2} {
    global vTcl
    set c1 [winfo class $t1]
    set c2 [winfo class $t2]
    if { $c1 == "Scrollbar" } {
        set t3 $t1; set t1 $t2; set t2 $t3
        set c3 $c1; set c1 $c2; set c2 $c3
    } elseif { $c2 == "Scrollbar" } {
    } else {
        return
    }
    switch [lindex [$t2 conf -orient] 4] {
        vert -
        vertical { set scr_cmd -yscrollcommand; set v_cmd yview }
        default  { set scr_cmd -xscrollcommand; set v_cmd xview }
    }
    switch $c1 {
        Mclistbox -
        Listbox -
        Canvas  -
        Table   -
        Text {
            $t1 conf $scr_cmd "$t2 set"
            $t2 conf -command "$t1 $v_cmd"
        }
        Entry {
            if {$v_cmd == "xview"} {
                $t1 conf $scr_cmd "$t2 set"
                $t2 conf -command "$t1 $v_cmd"
            }
        }
    }
}

#
# Shows a "hidden" object from information stored
# during the hide. Hidden object attributes are
# not currently saved in the project. FIX.
#
proc vTcl:show {target} {
    global vTcl
    if {[vTcl:streq $target "."]} { return }
    if {![winfo viewable $target]} {
        if {[catch {eval $vTcl(hide,$target,m) $target $vTcl(hide,$target,i)}] == 1} {

            ## don't try to change the manager of childsites or menus !!
            ## only show widgets that are not childsites and have been hidden
            if {[::vTcl::widgets::core::frame::containing_megawidget $target] == "" &&
                [lsearch -exact {Menu Busy} [vTcl:get_class $target]] == -1} {
                catch {$vTcl(w,def_mgr) $target $vTcl($vTcl(w,def_mgr),insert)}
            }
        }
    }
}

#
# Withdraws a widget from display.
#
proc vTcl:hide {} {
    global vTcl
    set class [vTcl:get_class $vTcl(w,widget)]
    if {[vTcl:streq $class Toplevel]} {
        vTcl:hide_top $vTcl(w,widget)
        return
    }

    if {$vTcl(w,manager) != "wm" && $vTcl(w,widget) != ""} {
        lappend vTcl(hide) $vTcl(w,widget)
        set vTcl(hide,$vTcl(w,widget),m) $vTcl(w,manager)
        set vTcl(hide,$vTcl(w,widget),i) [$vTcl(w,manager) info $vTcl(w,widget)]
        $vTcl(w,manager) forget $vTcl(w,widget)
        vTcl:destroy_handles
    }
}

#
# Sets the current widget as the insertion point
# for new widgets.
#
proc vTcl:set_insert {} {
    global vTcl
    set vTcl(w,insert) $vTcl(w,widget)
}

proc vTcl:select_parent {} {
    global vTcl
    if {$vTcl(w,widget) == ""} return
    vTcl:active_widget [winfo parent $vTcl(w,widget)]
    vTcl:set_insert
}

proc vTcl:select_toplevel {} {
    global vTcl
    if {$vTcl(w,widget) == ""} return
    vTcl:active_widget [winfo toplevel $vTcl(w,widget)]
    vTcl:set_insert
}

proc vTcl:raise {target} {

    # go figure, but on Unix raise introduces delays of one to
    # 2 seconds at least, which grays out the whole app for a
    # while

    if {$::tcl_platform(platform) != "unix"} {
        raise $target
    } elseif {$::tk_patchLevel >= "8.3.4"} {
        ## tk 8.3.4 fixes the problem
        raise $target
    }
}

proc vTcl:active_widget {target} {
    global vTcl widgetSelected classes
    if {$target == ""} {return}
    if {[vTcl:streq $target "."]} { return }
    if {$vTcl(w,widget) != "$target"} {

        vTcl:destroy_handles
        ## Any custom selection command?
        set class [vTcl:get_class $target]
        if {[info exists classes($class,selectCmd)] &&
            $classes($class,selectCmd) != ""} {
            $classes($class,selectCmd) $target
        }

        vTcl:select_widget $target
        vTcl:attrbar_color $target
        set vTcl(redo) [vTcl:dump_widget_quick $target]
        if {$vTcl(w,class) == "Toplevel"} {
            set vTcl(w,insert) $target
            wm deiconify $target
            vTcl:raise $target
        } else {
            vTcl:create_handles $target
            vTcl:place_handles $target
        if {[info exists classes($class,insertable)] && $classes($class,insertable)} {
                set vTcl(w,insert) $target
            } else {
                set vTcl(w,insert) [winfo parent $target]
            }
        }
    } elseif {$vTcl(w,class) == "Toplevel"} {
        set vTcl(w,insert) $target
        wm deiconify $target
        vTcl:raise $target
    }
    set widgetSelected 1
}

proc vTcl:select_widget {target} {
    global vTcl classes
    if {[vTcl:streq $target "."]} {
        vTcl:prop:clear
        return
    }

    ## Set the focus to an arbitrary widget when a widget is selected.
    ## This is so that focus_out_cmd gets called on the property manager
    ## if a widget is selected.
    focus .vTcl.widgetname
    vTcl:log "vTcl:select_widget $target"
    if {$target == $vTcl(w,widget)} {
        # show selection in widget tree
        vTcl:show_selection_in_tree $target
        return
    }
    set vTcl(w,last_class) $vTcl(w,class)
    set vTcl(w,last_manager) $vTcl(w,manager)
    vTcl:update_widget_info $target
    vTcl:prop:update_attr
    vTcl:get_bind $target
    vTcl:add_functions_to_rc_menu

    # show selection in widget tree
    vTcl:show_selection_in_tree $target
}

#
# Recurses a widget tree ignoring toplevels
#
proc vTcl:widget_tree {target {include_target 1}} {
    global vTcl classes

    if {$target == ".vTcl" || $target == ".tkcon" || [string range $target 0 2] == ".__"} { return }

    set output ""
    if {$include_target} {
        set output "$target "
    }

    set dumpChildren 1
    set class [winfo class $target]
    if {[info exists classes($class,dumpChildren)]} {
    set dumpChildren $classes($class,dumpChildren)
    }
    if {!$dumpChildren} { return $output }

    set c [vTcl:get_children $target]
    foreach i $c {
    if {[string range $i 0 1] == ".#"} { continue }
        set class [vTcl:get_class $i]
        if {$class != "Toplevel"} {
            append output [vTcl:widget_tree $i]
        }
    }
    return $output
}

#
# Recurses a widget tree with the option of not ignoring built-ins
#
# In the normal case we are not interested by children of megawidgets
#
# However, bindings are set for all children, including megawidgets' children
# so that when a user clicks on a child, the parent megawidget will be
# selected

proc vTcl:list_widget_tree {target {which ""} {include_menus 0} {include_megachildren 0}} {
    if {$which == ""} {
        if {$target == ".vTcl" || $target == ".tkcon" ||[string range $target 0 2] == ".__"} {
            return
        }
    }
    set w_tree "$target "
    set children [vTcl:get_children $target $include_megachildren]
    foreach i $children {
        ## Tix leaves some windows behind
        if {[string match .tix* $i]} {continue}

    ## Ignore temporary windows completely.
    if {[string range $i 0 1] == ".#"} { continue }

        ## Don't include temporary windows
        if {[string match {*#*} $i] && (!$include_menus)} { continue }

        ## Don't include unknown widgets
        set c [vTcl:get_class $i]

        if {![vTcl:valid_class $c]} { continue }

        append w_tree \
            "[vTcl:list_widget_tree $i $which $include_menus $include_megachildren] "
    }

    return $w_tree
}

# this func returns the same as list_widget_tree plus all the
# children in megawidgets' childsites
#
# wantsdiff returns along with each megawidget's children the
# level difference for the widget tree (ex. #-4 to skip 4 levels)

proc vTcl:complete_widget_tree {{root .} {wantsdiff 1}} {

    global classes
    set tree [vTcl:list_widget_tree $root]
    set result ""
    foreach i $tree {
        lappend result $i

        set childrenCmd [lindex $classes([vTcl:get_class $i],treeChildrenCmd) 0]
        if {$childrenCmd == ""} {
            continue
        }

        if {$wantsdiff} {
             set children [$childrenCmd $i]
        } else {
             set children [$childrenCmd $i ""]
        }
        eval lappend result $children
    }

    return $result
}

##############################################################################
# WIDGET INFO ROUTINES
##############################################################################
proc vTcl:split_info {target} {
    global vTcl
    set index 0
    set mgr $vTcl(w,manager)
    set mgr_info [$mgr info $target]
    set vTcl(w,info) $mgr_info
    if { $vTcl(var_update) == "yes" } {
        set index a
        foreach i $mgr_info {
            if { $index == "a" } {
                set var vTcl(w,$mgr,$i)
                set last $i
                set index b
            } else {
                set $var $i
                set index a
            }
        }
    }
    if {$mgr == "grid"} {
        set p [winfo parent $target]
        set pre g
        set gcolumn $vTcl(w,grid,-column)
        set grow $vTcl(w,grid,-row)
        foreach a {column row} {
            foreach b {weight minsize} {
                set num [subst $$pre$a]
                if [catch {
                    set x [expr round([grid ${a}conf $p $num -$b])]
                }] {set x 0}
                set vTcl(w,grid,$a,$b) $x
            }
        }
        set vTcl(w,grid,propagate) [grid propagate $target]
    } elseif {$mgr == "pack"} {
        set vTcl(w,pack,propagate) [pack propagate $target]
    }
}

proc vTcl:split_wm_info {target} {
    global vTcl
    set vTcl(w,info) ""
    foreach i $vTcl(attr,tops) {
        if {$i == "geometry"} {
            #
            # because window managers behave unpredictably with wm and
            # winfo, one is used for editing and the other for saving
            #
            ##
            # This causes windows to have the wrong geometry.  At least under
            # my window manager.  Have to look into this further. -D
            ##
            if {$vTcl(mode) == "EDIT"} {
                # set vTcl(w,wm,$i) [winfo $i $target]
                set vTcl(w,wm,$i) [wm $i $target]
            } else {
                set vTcl(w,wm,$i) [wm $i $target]
            }
        } else {
            set vTcl(w,wm,$i) [wm $i $target]
        }
    }
    set vTcl(w,wm,class) [winfo class $target]
    if { $vTcl(var_update) == "yes" } {
        lassign [vTcl:split_geom $vTcl(w,wm,geometry)] w h x y
        set vTcl(w,wm,geometry,w)    $w
        set vTcl(w,wm,geometry,h)    $h
        set vTcl(w,wm,geometry,x)    $x
        set vTcl(w,wm,geometry,y)    $y
        set vTcl(w,wm,minsize,x)     [lindex $vTcl(w,wm,minsize) 0]
        set vTcl(w,wm,minsize,y)     [lindex $vTcl(w,wm,minsize) 1]
        set vTcl(w,wm,maxsize,x)     [lindex $vTcl(w,wm,maxsize) 0]
        set vTcl(w,wm,maxsize,y)     [lindex $vTcl(w,wm,maxsize) 1]
        set vTcl(w,wm,aspect,minnum) [lindex $vTcl(w,wm,aspect) 0]
        set vTcl(w,wm,aspect,minden) [lindex $vTcl(w,wm,aspect) 1]
        set vTcl(w,wm,aspect,maxnum) [lindex $vTcl(w,wm,aspect) 2]
        set vTcl(w,wm,aspect,maxden) [lindex $vTcl(w,wm,aspect) 3]
        set vTcl(w,wm,resizable,w)   [lindex $vTcl(w,wm,resizable) 0]
        set vTcl(w,wm,resizable,h)   [lindex $vTcl(w,wm,resizable) 1]
        # Rozen In hopes that I will pick up the correct geometry when
        # generating the Python code.
        set vTcl($target,x) $x
        set vTcl($target,y) $y
        set vTcl($target,h) $h
        set vTcl($target,w) $w
    }
}

proc vTcl:get_grid_stickies {sticky} {
    global vTcl
    set len [string length $sticky]
    foreach i {n s e w} {
        set vTcl(grid,sticky,$i) ""
    }
    for {set i 0} {$i < $len} {incr i} {
        set val [string index $sticky $i]
        set vTcl(grid,sticky,$val) $val
    }
}

proc vTcl:update_widget_info {target} {
    vTcl:log "update_widget_info $target"
    global vTcl widget
    update idletasks
    set vTcl(w,widget) $target
    set vTcl(w,didmove) 0
    set vTcl(w,options) ""
    set vTcl(w,optlist) ""
    if {![winfo exists $target]} {return}
    foreach i $vTcl(attr,winfo) {
        if {$i == "manager" && $target == "."} {
            # root placer problem
            set vTcl(w,$i) wm
        } elseif { $i == "manager" && [winfo class $target] == "TLabelframe"} {
            set vTcl(w,$i) place
        } else {
            set vTcl(w,$i) [winfo $i $target]
        }
    }
    set vTcl(w,class) [vTcl:get_class $target]
    set vTcl(w,r_class) [winfo class $target]
    set vTcl(w,conf) [$target configure]
    set attrs $vTcl(attr,winfo)
    ##
    # Remove class from the attributes, 'cause we don't want [winfo class]
    # over setting the value we stored from get_class. -Damon
    ##
    lremove attrs class
    switch $vTcl(w,class) {
        Toplevel {
            set vTcl(w,opt,-text) [wm title $target]

            ##
            # Set the geometry based on results from [wm geometry] instead of
            # [winfo geometry].  Remove those attributes from the list of
            # attributes to setup in the vTcl(w,*) array.
            ##
            set remove {geometry height width rootx rooty x y}
            eval lremove attrs $remove
            set geometry [wm geometry $target]
            lassign [vTcl:split_geom $geometry] width height x y
            set rootx $x
            set rooty $y
            foreach var $remove {
                set vTcl(w,$var) [set $var]
            }

            ##
            # Special attributes that do not belong to Tk toplevels but allow
            # control over whether to specify origin and/or size or let the
            # window manager decide instead. Defaults to 1, which means the
            # user has control over toplevel position and size
            ##
            foreach special {set,origin set,size runvisible} {
                if {![info exists ::widgets::${target}::${special}]} {
                    namespace eval ::widgets::${target} "
                        variable $special
                        set $special 1
                    "
                }
                set vTcl(w,wm,$special) [vTcl:at ::widgets::${target}::${special}]
            }
        }
        default {
            set vTcl(w,opt,-text) ""
        }
    }

    foreach i $attrs {
        if {$i == "manager"} {  ;# Rozen
            if {$vTcl(w,class) == "TLabelframe"} {
                set vTcl(w,$i) "place"
            }
        } else {
            set vTcl(w,$i) [winfo $i $target]
        }
    }
    switch $vTcl(w,manager) {
        {} {}
        grid -
        pack -
        place {
            vTcl:split_info $target
        }
        wm {
            if { $vTcl(w,class) != "Menu" } {
                vTcl:split_wm_info $target
            }
        }
    }
    set vTcl(w,options) [vTcl:conf_to_pairs $vTcl(w,conf) set]
    if {[catch {set vTcl(w,alias) $widget(rev,$target)}]} {
        set vTcl(w,alias) ""
    }

    ## special options support
    if {[info exist ::classoption($vTcl(w,class))]} {
        foreach spec_opt $::classoption($vTcl(w,class)) {
            $::configcmd($spec_opt,update) $target vTcl(w,opt,$spec_opt)
        }
    }


}

proc vTcl:conf_to_pairs {conf opt} {
    global vTcl
    set pairs ""
    foreach i $conf {
        set option [lindex $i 0]
        set def [lindex $i 3]
        set value [lindex $i 4]
        if {$value != $def && $option != "-class"} {
            lappend pairs $option $value
        }
        if {$opt == "set"} {
            lappend vTcl(w,optlist) $option
            set vTcl(w,opt,$option) $value
        }
    }
    return $pairs
}

proc vTcl:new_widget_name {class base} {
    # This get the first 3 characters of the class name for the widget
    # name. Donesn't work well for the scrolled widgets. Perhaps it
    # should get the name from the wgt file if it exists there. Rozen
    global vTcl
    set c [vTcl:lower_first $class]
    while { 1 } {
        if $vTcl(pr,shortname) {
            set num "[string range $c 0 2]$vTcl(item_num)"
        } else {
            set num "$c$vTcl(item_num)"
        }
        incr vTcl(item_num)
        if {$base != "." && $class != "Toplevel"} {
            set new_widg $base.$num
        } else {
            set new_widg .$num
        }
        if { [lsearch $vTcl(tops) $new_widg] >= 0 } { continue }
        if { ![winfo exists $new_widg] } { break }
    }
    # Rozen since there is only one toplevel, I can do this.
    if {$class == "Toplevel"} {
        set vTcl(top_widget) $new_widg
    }
    return $new_widg
}

proc vTcl:setup_vTcl:bind {target} {
    global vTcl
    set bindlist [vTcl:list_widget_tree $target all 1 1]
    update idletasks
    foreach i $bindlist {
        if { [lsearch [bindtags $i] vTcl(a)] < 0 } {
            set vTcl(bindtags,$i) [bindtags $i]
            bindtags $i "vTcl(a) $vTcl(bindtags,$i)"
        }
    }
}

proc vTcl:setup_bind {target} {
    global vTcl
    if {[lsearch [bindtags $target] vTcl(b)] < 0 &&
        [lsearch [bindtags $target] vTcl(a)] < 0} {

        set vTcl(bindtags,$target) [bindtags $target]

        set class [vTcl:get_class $target]
        if { $class == "Toplevel"} {
            wm protocol $target WM_DELETE_WINDOW "vTcl:hide_top $target"
            if {$vTcl(pr,winfocus) == 1} {
                wm protocol $target WM_TAKE_FOCUS "vTcl:wm_take_focus $target"
            }
            bindtags $target "vTcl(bindtags,$target) vTcl(b) vTcl(c)"

        } elseif { $class == "Menu" } {
            bindtags $target "vTcl(a) $vTcl(bindtags,$target)"

        } else {
            bindtags $target vTcl(b)
        }
    }
}

proc vTcl:switch_mode {} {
    global vTcl
    if {$vTcl(mode) == "EDIT"} {
        vTcl:propmgr:deselect_attr
        vTcl:setup_unbind_tree .
        #Save unregistered widgets.
        vTcl:widget:register_all_widgets
    } else {
        vTcl:setup_bind_tree .
        #remove widgets created at runtime
        vTcl:widget:remove_unregistered_widgets
    }
}

proc vTcl:setup_bind_tree {target} {
    global vTcl
    vTcl:setup_bind_widget $target
    set vTcl(mode) "EDIT"
    ::widgets_bindings::enable_editor 1
    ::menu_edit::enable_all_editors 1

    ## inform subscribers
    ::vTcl::notify::publish edit_mode
}

proc vTcl:setup_bind_widget {target} {
    global vTcl
    # Include special menu windows under X with '#'
    set bindlist [vTcl:list_widget_tree $target "" 1 1]
    update idletasks
    foreach i $bindlist {
        vTcl:setup_bind $i
    }

    foreach i [vTcl:list_widget_tree $target] {
        # Make sure megawidgets' children are properly tagged
        # as such; test mode could have added/removed children
        vTcl:widget:register_widget_megachildren $i
    }
}

proc vTcl:setup_unbind {target} {
    global vTcl
    if { [lsearch [bindtags $target] vTcl(b)] >= 0 } {
        bindtags $target $vTcl(bindtags,$target)
    }
}

proc vTcl:setup_unbind_tree {target} {
    global vTcl
    vTcl:select_widget .
    vTcl:destroy_handles
    vTcl:setup_unbind_widget $target
    set vTcl(mode) "TEST"
    ::widgets_bindings::enable_editor 0
    ::menu_edit::enable_all_editors 0

    ## inform subscribers
    ::vTcl::notify::publish test_mode
}

proc vTcl:setup_unbind_widget {target} {
    global vTcl
    # Include special menu windows under X with '#'
    set bindlist [vTcl:list_widget_tree $target "" 1 1]
    update idletasks
    foreach i $bindlist {
        vTcl:setup_unbind $i
    }
}

##
## This routine checks that we don't mix pack and grid in the same container.
##
proc vTcl:can_insert {parent manager} {

    if {$parent == ""} {
        return 1
    }
    ## Enumerates children
    foreach child [winfo children $parent] {
        set child_manager [winfo manager $child]

    ## Don't mix pack and grid together (it's a Tk bug). However, you can
    ## mix pack or grid with place.
    if {($child_manager == "grid" && $manager == "pack") ||
        ($child_manager == "pack" && $manager == "grid")} {
        return 0
    }
    }

    ## All clear.
    return 1
}

##############################################################################
# INSERT NEW WIDGET ROUTINE
##############################################################################
proc vTcl:auto_place_widget {class {options ""}} {
    global vTcl
    if {$vTcl(mode) == "TEST"} {
        vTcl:error "Inserting widgets is not\nallowed in Test mode."
        return
    }
    if { ($vTcl(w,insert) == "." && $class != "Toplevel") ||
         ([winfo exists $vTcl(w,insert)] == 0 && $class != "Toplevel")} {
        ::vTcl::MessageBox -icon error -message "No insertion point set!" \
            -title "Error!" -type ok
        return
    }

    ## grid and pack managers cannot be mixed in the same container
    if {![vTcl:can_insert $vTcl(w,insert) $vTcl(w,def_mgr)]} {
        ::vTcl::MessageBox -icon error \
        -message "You cannot mix pack and grid in the same container." \
            -title "Error!" -type ok
        return
    }
    ## last call
    set moreOptions ""
    if {![vTcl::widgets::queryInsertOptions $class $options moreOptions]} {
        return
    }

    #append moreOptions "-bg $vTcl(pr,guibgcolor)"  Rozen added just for testing
    append options $moreOptions
    set vTcl(mgrs,update) no
    if $vTcl(pr,getname) {
        set new_widg [vTcl:get_name $class]
    } else {
        set new_widg [vTcl:new_widget_name $class $vTcl(w,insert)]
    }
    if {[lempty $new_widg]} { return }

    set created_widget [vTcl:create_widget $class $options $new_widg 0 0]

    ## when new widget is inserted, automatically refresh
    ## widget tree
    ## we do not destroy the handles that were just created
    ## (remember, the handles are used to grab and move a widget around)
    after idle "\
        vTcl:init_wtree 0
        vTcl:show_selection_in_tree $created_widget"

    return $created_widget
}

proc vTcl:rozen_dump_config {w spot} {
    set opt [$w configure]
    dmsg spot $spot
    dpr opt
}

proc vTcl:create_widget {class options new_widg x y} {
    global vTcl classes
    set do ""
    set undo ""
    set insert $vTcl(w,insert)
    if {$class == "Toplevel"} {
        set insert .
        set vTcl(ttk_widget_added) 0 ;# This remembers whether any ttk
                                      # widgets were used. If we are
                                      # at the toplevel then reset. It
                                      # is tested in dump.tcl
    }
    if {$vTcl(pr,getname) == 1} {
        if { $vTcl(w,insert) == "." || $class == "Toplevel"} {
            set new_widg ".$new_widg"
        } else {
            set new_widg "$vTcl(w,insert).$new_widg"
        }
    }

    set c $class
    set p ""
    if {[winfo exists $insert]} {
        set p [vTcl:get_class $insert]
    }

    append do "$classes($c,createCmd) $new_widg "
    # This where we pick up the default options specified in the wgt
    # files.  The subst is to allow classes(Buffer,defaultOptions) to
    # be things like \$vTcl(pr,gfui_font_dft).

    append do "[subst $classes($c,defaultOptions)] $options;"

    if {![lempty $classes($c,insertCmd)]} {
        append do "$classes($c,insertCmd) $new_widg;"
    }
    if {$class != "Toplevel"} {
        # Default Colors for Ttk widgets.
        if {[string index $class 0] == "T" &&
            $class != "Text"} {
            set vTcl(ttk_widget_added) 1 ;# We've used a ttk widget.
            # It's a themed widget
            set class_bg [ttk::style lookup $class -background]
            ttk::style configure $class -background $vTcl(actual_gui_bg)
            ttk::style configure $class -font $vTcl(actual_gui_font_dft_name)
        }
        if {[string first "Scrolled" $class 0] > -1} {
            # My scrolled widgets.
            #ttk::style configure Scrollbar  -background $vTcl(pr,guibgcolor)
            #ttk::style configure $class -background $vTcl(pr,guibgcolor)
            option add *vTcl*scrollbar*background $vTcl(actual_gui_bg)
        }
        # Say welcome to the style specs for particular ttk
        # widgets. Here I am trying to be sure the widget is displayed
        # OK. 12/25/12.
        switch $class {
            TNotebook {
                ttk::style configure TNotebook.Tab \
                    -background $vTcl(actual_gui_bg) \
                    -foreground $vTcl(actual_gui_fg) \
                    -font $vTcl(actual_gui_font_dft_name)
                ttk::style map TNotebook.Tab -background \
                [list disabled $vTcl(actual_gui_bg) \
                     selected $vTcl(pr,guicomplement_color)]
                if {[::colorDlg::dark_color $vTcl(pr,guicomplement_color)]} {
                    ttk::style map TNotebook.Tab -foreground \
                        [list selected white]
                } else {
                    ttk::style map TNotebook.Tab -foreground \
                        [list selected black]
                }
            }
            TScale {
                #option add *vTcl*scrollbar*background $vTcl(pr,guibgcolor)
                ttk::style configure TScale -background $vTcl(actual_gui_bg)
            }
            TLabelframe {
                #option add *vTcl*scrollbar*background $vTcl(pr,guibgcolor)
                ttk::style configure TLabelframe.Label \
                    -background $vTcl(actual_gui_bg) \
                    -foreground $vTcl(actual_gui_fg) \
                    -font $vTcl(actual_gui_font_dft_name)
            }
            Scrolledtreeview {
                # Specified tyhe scrollbar colors above.
                #option add *vTcl*scrollbar*background $vTcl(pr,guibgcolor)
                ttk::style configure Treeview.Heading \
                    -background $vTcl(pr,guicomplement_color) \
                    -foreground $vTcl(actual_gui_fg) \
                    -font $vTcl(actual_gui_font_dft_name)
            }
            TPanedwindow {
                ttk::style configure TPanedwindow \
                    -background $vTcl(actual_gui_bg)
                ttk::style configure TLabelframe \
                    -background $vTcl(actual_gui_bg)
                ttk::style configure TLabelframe.Label \
                    -background $vTcl(actual_gui_bg) \
                    -foreground $vTcl(actual_gui_fg) \
                    -font $vTcl(actual_gui_font_dft_name)
            }
            TButton -
            TCheckbutton -
            TRadiobutton -
            TLabel -
            TMenubutton {
                ttk::style configure $class \
                    -foreground $vTcl(actual_gui_fg) \
                    -font $vTcl(actual_gui_font_dft_name)
            }
        }
        if {$class == "TSizegrip"} {
            append do "place $new_widg -anchor se -relx 1.0 -rely 1.0"
        } else {
            append do "$vTcl(w,def_mgr) $new_widg $vTcl($vTcl(w,def_mgr),insert)"
            if {$vTcl(w,def_mgr) == "place"} {
                # Rozen Following code causes a widget to be place on the
                # background grid.
                set xgrid [vTcl:grid_snap "x" $x]
                set ygrid [vTcl:grid_snap "y" $y]
                append do " -x $xgrid -y $ygrid"
                #append do " -x $x -y $y"
            }
        }
        append do ";"
    }
    append do "vTcl:setup_bind_widget $new_widg; "
    append do "vTcl:widget:register_widget $new_widg; "
    if {[info exists classes($p,insertChildCmd)] &&
        ![lempty $classes($p,insertChildCmd)]} {
        append do "$classes($p,insertChildCmd) $insert $new_widg;"
    }
    append do "vTcl:active_widget $new_widg; "
    foreach def $classes($c,defaultValues) {
        append do "vTcl:prop:default_opt $new_widg $def vTcl(w,opt,$def); "
    }
    foreach def $classes($c,dontSaveOptions) {
     append do "vTcl:prop:save_or_unsave_opt $new_widg $def vTcl(w,opt,$def) 0; "
    }
    #give it some time, idle should work but it didn't
        append do "after 500 {vTcl:init_wtree};"

#WAS NOT DELETEING WIDGETS WITH SPECIAL DELETE COMMANDS SUCH AS TOPLEVEL
    if {$undo == ""} {
    append undo "vTcl:unset_alias $new_widg;"
    append undo "::vTcl::notify::publish delete_widget $new_widg;"
    append undo "vTcl:setup_unbind_widget $new_widg;"
    set destroy_command "destroy"
    if {$classes($class,deleteCmd) != ""} {
        set destroy_command $classes($class,deleteCmd)
    }
    append undo "$destroy_command $new_widg;"
    #append undo "set _cmds \[info commands $new_widg.*\];"
    #append undo "foreach _cmd \$_cmds {catch {rename \$_cmd \"\"}};"
    append undo "vTcl:prop:clear;"
    append undo "after idle {vTcl:init_wtree};"

    }
    vTcl:push_action $do $undo
    update idletasks
    set vTcl(mgrs,update) yes

    if {$class == "Toplevel"} {
        set vTcl(widgets,$new_widg) {}
    } else {
        lappend vTcl(widgets,[winfo toplevel $new_widg]) $new_widg
    }
    if { $vTcl(pr,autoalias) } {
        set alias [vTcl:next_widget_name $c $new_widg]
        vTcl:set_alias $new_widg $alias
    }
    return $new_widg
}

proc vTcl:valid_alias {target alias} {

    global widget
    set toplevel [vTcl:get_top_level_or_alias $target]

    if {[info exists widget($toplevel,$alias)] &&
         $widget($toplevel,$alias) != $target} {
        return 0
    } elseif {[info exists widget($alias)] &&
              [vTcl:get_class $widget($alias)] == "Toplevel"} {
        return 0
    } else {
        return 1
    }
}

proc vTcl:set_alias {target {alias ""} {noupdate ""}} {
    global vTcl widget classes

    if {[lempty $target]} { return }

    set c [vTcl:get_class $target]
    set was {}
    if {[lempty $alias]} {
        if {[info exists widget(rev,$target)]} {
            set was $widget(rev,$target)
        }
        set valid 0
        while {!$valid} {
            set alias [vTcl:get_string "Widget alias for $c" $target $was]
            if {$alias != $was && $alias != ""} {
                # make sure no other widget in the same toplevel has the same alias
                set valid [vTcl:valid_alias $target $alias]
                if {!$valid} {
                    vTcl:dialog "Alias '$alias' already exists"
                }
            } else {
                # user decided not to change the alias, or to cancel
                return
            }
        }
    }

    if {![lempty $was] && $alias != $was} {
        vTcl:unset_alias $target
    }

    if {![lempty $alias] && $alias != $was} {
        set widget($alias) $target
        set widget(rev,$target) $alias

        set widget([vTcl:get_top_level_or_alias $target],$alias) $target

        ## Create an alias in the interpreter.
        if { $vTcl(pr,cmdalias) } {
            interp alias {} $alias {} $classes($c,widgetProc) $target

            if {[winfo toplevel $target] != $target} {
                interp alias {} [vTcl:get_top_level_or_alias $target].$alias {} \
                      $classes($c,widgetProc) $target
            }
        }

    ## Remember the list of aliases on a toplevel-basis
    namespace eval ::[winfo toplevel $target] "
        variable _aliases
        lappend _aliases $alias
    "

        # Refresh property manager after changing an alias
        if {[lempty $noupdate]} { vTcl:update_widget_info $target }
    }
}

proc vTcl:unset_alias {w} {
    global widget vTcl classes

    if {![info exists widget(rev,$w)]} { return }
    set alias $widget(rev,$w)
    set class [vTcl:get_class $w]
    set other ""

    catch { unset widget([vTcl:get_top_level_or_alias $w],$alias) }
    catch { unset widget([winfo top level $w],$alias) }
    catch { unset widget(rev,$w) }
    catch {
        if {[winfo toplevel $w] != $w} {
            interp alias {} [vTcl:get_top_level_or_alias $w].$alias {}
        }
    }
    catch { interp alias {} $alias {} {} }

    # if alias is defined for another toplevel, let's be more careful
    foreach name [array names widget] {
        if {[string match *,$alias $name]} {
            set other $widget($name)
            break
        }
    }

    catch {

        if {$other == ""} {
            unset widget($alias)
        } else {
            set widget($alias) $other
            if { $vTcl(pr,cmdalias) } {
                interp alias {} $alias {} $classes($class,widgetProc) $other
            }
        }
    }

    namespace eval ::[vTcl:get_toplevel $w] "
    variable _aliases
    ::vTcl::lremove _aliases $alias
    "
}

proc vTcl:get_top_level_or_alias {target} {

    global widget

    set top [winfo toplevel $target]

    if {[info exists widget(rev,$top)]} {
        return $widget(rev,$top)
    } else {
        return $top
    }
}

proc vTcl:update_label {t} {
    global vTcl
    if {$t == ""} {return}
    switch [vTcl:get_class $t] {
        Toplevel {
            wm title $t $vTcl(w,opt,-text)
            set vTcl(w,wm,title) $vTcl(w,opt,-text)
        }
        default {
            if [catch {set txt [$t cget -text]}] {
                return
            }
            $t conf -text $vTcl(w,opt,-text)
            vTcl:place_handles $t
        }
    }
}

proc vTcl:set_textvar {t} {
    global vTcl
    if {$t == ""} {return}
    set label [vTcl:get_string "Setting textvariable" $t [$t cget -textvar]]
    if {$label == ""} {
        ## user cancelled
        return
    }
    $t conf -textvar $label
    vTcl:place_handles $t
    vTcl:update_widget_info $t
}

proc vTcl:widget_dblclick {target X Y x y} {
    global vTcl classes
    vTcl:set_mouse_coords $X $Y $x $y
    set c [vTcl:get_class $target 1]
    set class [winfo class $target]

    if {![lempty $classes($class,dblClickCmd)]} {
        eval $classes($class,dblClickCmd) $target
    }
}

proc vTcl:pack_after {target} {
if {[winfo manager $target] != "pack" || $target == "."} {return}
    set l [pack slaves [winfo parent $target]]
    set i [lsearch $l $target]
    set n [lindex $l [expr $i + 1]]
    if {$n != ""} {
        pack conf $target -after $n
    }
    vTcl:place_handles $target
}

proc vTcl:pack_before {target} {
if {[winfo manager $target] != "pack" || $target == "."} {return}
    set l [pack slaves [winfo parent $target]]
    set i [lsearch $l $target]
    set n [lindex $l [expr $i - 1]]
    if {$n != ""} {
        pack conf $target -before $n
    }
    vTcl:place_handles $target
}

proc vTcl:manager_update {mgr} {
    global vTcl
    if {$mgr == ""} {return}
    set options ""
    if {$vTcl(w,manager) != "$mgr"} {return}
    update idletasks
    if {$mgr != "wm" } {
        foreach i $vTcl(m,$mgr,list) {
            set value $vTcl(w,$mgr,$i)
            if { $value == "" } { set value {{}} }
            append options "$i $value "
        }
        set vTcl(var_update) "no"
        set undo [vTcl:dump_widget_quick $vTcl(w,widget)]
        set do "$mgr configure $vTcl(w,widget) $options"
        vTcl:push_action $do $undo
        set vTcl(var_update) "yes"
    } else {
        set    vTcl(w,wm,geometry) \
            "$vTcl(w,wm,geometry,w)x$vTcl(w,wm,geometry,h)"
        append vTcl(w,wm,geometry) \
            "+$vTcl(w,wm,geometry,x)+$vTcl(w,wm,geometry,y)"
        set    vTcl(w,wm,minsize) \
            "$vTcl(w,wm,minsize,x) $vTcl(w,wm,minsize,y)"
        set    vTcl(w,wm,maxsize) \
            "$vTcl(w,wm,maxsize,x) $vTcl(w,wm,maxsize,y)"
        set    vTcl(w,wm,aspect) \
            "$vTcl(w,wm,aspect,minnum) $vTcl(w,wm,aspect,minden)"
        append vTcl(w,wm,aspect) \
            "+$vTcl(w,wm,aspect,maxnum)+$vTcl(w,wm,aspect,maxden)"
        set    vTcl(w,wm,resizable) \
            "$vTcl(w,wm,resizable,w) $vTcl(w,wm,resizable,h)"
#            set    do "$mgr geometry $vTcl(w,widget) $vTcl(w,wm,geometry); "
        append do "$mgr minsize $vTcl(w,widget) $vTcl(w,wm,minsize); "
        append do "$mgr maxsize $vTcl(w,widget) $vTcl(w,wm,maxsize); "
        append do "$mgr focusmodel $vTcl(w,widget) $vTcl(w,wm,focusmodel);"
        append do "$mgr resizable $vTcl(w,widget) $vTcl(w,wm,resizable); "
        append do "$mgr title $vTcl(w,widget) \"$vTcl(w,wm,title)\"; "
        switch $vTcl(w,wm,state) {
            withdrawn { append do "$mgr withdraw $vTcl(w,widget); " }
            iconic { append do "$mgr iconify $vTcl(w,widget); " }
            normal { append do "$mgr deiconify $vTcl(w,widget); " }
        }
        eval $do
        vTcl:wm_button_update
    }
    vTcl:place_handles $vTcl(w,widget)
    vTcl:update_top_list
}

# proc to insert widget in text editor

# insert the current widget name (eg. .top30) or alias into
# given text widget

proc vTcl:insert_widget_in_text {t} {
    global vTcl

    if {$vTcl(w,alias) != ""} {
        set name \$widget\($vTcl(w,alias)\)
    } else {
        set name $vTcl(w,widget)
    }

    $t insert insert $name
}

proc vTcl:add_functions_to_rc_menu {} {
    global vTcl classes

    $vTcl(gui,rc_widget_menu) delete 0 end
    .vTcl.m.widget delete 0 end

    set c $vTcl(w,class)
    if {[lempty $classes($c,functionCmds)]} { return }

    foreach cmd $classes($c,functionCmds) text $classes($c,functionText) {
        $vTcl(gui,rc_widget_menu) add command -label $text -command $cmd
        .vTcl.m.widget add command -label $text -command $cmd
    }
}

proc vTcl:new_widget {autoplace class button {options ""}} {
    global vTcl classes
    if {$vTcl(mode) == "TEST"} {
        vTcl:error "Inserting widgets is not\nallowed in Test mode."
        return
    }

    vTcl:raise_last_button $button

    if {$class == "Toplevel"} {
        # Page is intended to be used to create a single toplevel GUI
        # window at atime. Rozen
        if {$vTcl(newtops) > 1} {
            # We already have a Toplevel window. We do not want to
            # create more.
            ::vTcl::MessageBox -type ok -default ok -icon warning \
                -message "Do not create multiple Toplevel windows"
            return
        }
    }

    if {$autoplace || $class == "Toplevel" \
        || $classes($class,autoPlace)} {
        vTcl:status "Status"
        vTcl:rebind_button_1
        return [vTcl:auto_place_widget $class $options]
    }

    # the trick is, ButtonRelease-1 gets processed first (this is
    # how we came here), but then the button class raises the button
    # again, so we wait until we have some free time

    if {[winfo exists $button]} {
       after 0 "$button configure -relief sunken"
    }

    vTcl:status "Insert $class"

    bind vTcl(b) <Button-1> "
        vTcl:place_widget $class $button [list $options] %X %Y %x %y
    "

    bind vTcl(b) <Shift-Button-1> "
        vTcl:place_widget $class $button [list $options] %X %Y %x %y
    "
}

proc vTcl:place_widget {class button options rx ry x y} {
    # Entered when we plop a widget inside of an application window.
    # After we select a wudget in the Widget Toolbar, go to the
    # destination spot in the top level window, this procedure is
    # called when we hit Button-1.  It determines the conntaining
    # window of the spot and that is how it knows to put it into the
    # widget tree.
    global vTcl

    if { !$vTcl(pr,multiplace) } {
        if {[winfo exists $button]} {
            $button configure -relief raised
        }
        vTcl:status "Status"
        vTcl:rebind_button_1
    }

    # the winfo below tell what the containing window.
    set try_insert [winfo containing $rx $ry]
    set tree [vTcl:complete_widget_tree . 0]

    ## we can only insert inside existing widgets
    if {[lsearch -exact $tree $try_insert] == -1} {
        ::vTcl::MessageBox -title "Insert Widget" \
            -message "You cannot insert a widget here!" -type ok
        return ""
    }

    ## grid and pack managers cannot be mixed in the same container
    if {![vTcl:can_insert $try_insert $vTcl(w,def_mgr)]} {
        ::vTcl::MessageBox -icon error \
        -message "You cannot mix pack and grid in the same container." \
            -title "Error!" -type ok
        return
    }

    ## last call
    set moreOptions ""
    if {![vTcl::widgets::queryInsertOptions $class $options moreOptions]} {
        return
    }

    append options $moreOptions
    set vTcl(w,insert) $try_insert

    set vTcl(mgrs,update) no
    if $vTcl(pr,getname) {
        set new_widg [vTcl:get_name $class]
    } else {
        set new_widg [vTcl:new_widget_name $class $vTcl(w,insert)]
    }

    if {[lempty $new_widg]} { return }

    set created_widget [vTcl:create_widget $class $options $new_widg $x $y]

    # when new widget is inserted, automatically refresh
    # widget tree

    # we do not destroy the handles that were just created
    # (remember, the handles are used to grab and move a widget around)

    after idle "
        vTcl:init_wtree 0
        vTcl:show_selection_in_tree $created_widget
    "

    return $created_widget
}

## Get the next available widget number for this class.
## IE: Edit1, Edit2, Edit3...
proc vTcl:next_widget_name {class target {old_alias {}}} {
    global classes vTcl

    if {$old_alias == ""} {
        set prefix $class
        set num 1
        if {[info exists classes($class,aliasPrefix)]} {
            set prefix $classes($class,aliasPrefix)
        }
    } else {
        set prefix $old_alias
    set num 1
    ## If the alias we want to set is in the form <Prefix><Num> we try
    ## to reuse the same number
    regexp {([^0-9]+)([0-9]+)} $old_alias matchall prefix num
    }

    ## If it is a toplevel alias, it must not be the same as any other alias
    ## So we make a list of existing aliases to check for, and increment until
    ## we find a unused name.
    if {$class == "Toplevel"} {
        set tops $vTcl(tops)
    } else {
        set tops [winfo toplevel $target]
    }
    set existing ""
    foreach top $tops {
        namespace eval ::$top {
            variable _aliases
        if {![info exists _aliases]} {
            set _aliases {}
        }
        }
        set existing [concat $existing [vTcl:at ::${top}::_aliases]]
    }
    while {[lsearch -exact $existing $prefix$num] != -1} {
        incr num
    }

    return $prefix$num
}

proc vTcl:update_aliases {} {
    global vTcl widget

    foreach top $vTcl(tops) {
        # all children of the toplevel
        set children [vTcl:list_widget_tree $top "" 1 1]
        foreach child $children {
        if {![info exists widget(rev,$child)]} { continue }

        set alias $widget(rev,$child)
            ## Remember the list of aliases on a toplevel-basis
            namespace eval ::$top "
            variable _aliases
            lappend _aliases $alias
        "
    }
    }
}

proc vTcl:widget:get_image {w} {
    global vTcl classes

    set c [vTcl:get_class $w]

    if {! [info exists classes($c,icon)]} {
        return [vTcl:image:get_image hide.gif]
    }

    set i $classes($c,icon)
    if {[vTcl:streq [string index $i 0] "@"]} {
        set i [[string range $i 1 end] $w]
    }
    return $i
}

proc vTcl:widget:get_tree_label {w} {
    global vTcl classes

    set c [vTcl:get_class $w]

    if {! [info exists classes($c,treeLabel)]} {
        return $c
    }

    set t $classes($c,treeLabel)
    if {[vTcl:streq [string index $t 0] "@"]} {
        set t [[string range $t 1 end] $w]
    }
    return $t
}

####
## Register special widget options not available with configure
##
####
proc vTcl:widget:register_widget_custom {w} {
    set class [vTcl:get_class $w]

    ## special options support
    if {[info exist ::classoption($class)]} {
        foreach spec_opt $::classoption($class) {
            set val [$::configcmd($spec_opt,get) $w]
            set ::widgets::${w}::options($spec_opt) $val
            set ::widgets::${w}::defaults($spec_opt) ""
            set ::widgets::${w}::save($spec_opt) [expr {$val != ""}]
        }
    }
}

proc vTcl:widget:register_widget_megachildren {w} {

    global classes
    set wdg_class [vTcl:get_class $w]

    # if this is a megawidget, register special information in the
    # children to allow the megawidget to be manipulated as one unit
    # when the user clicks on such a child, and such an information is
    # found, then the parent will be selected instead

    if {[info exists classes(${wdg_class},megaWidget)]} {
        if {$classes(${wdg_class},megaWidget)} {
            # get all children
            set children [vTcl:list_widget_tree $w "" 1 1]
            foreach child $children {
                namespace eval ::widgets::${child} {
                    variable parent          ;# this one is for dragging items
                    variable parent_widget   ;# same value, but used for saving
                }
                set ::widgets::${child}::parent $w
                set ::widgets::${child}::parent_widget $w
            }

            # Now, we shall unmark those widgets as parent that
            # are in childsites, because the user should be able
            # to manipulate them. First, let try to get a list of
            # eligible children.

            set childrenCmd [lindex $classes($wdg_class,treeChildrenCmd) 0]
            if {$childrenCmd == ""} {
                return
            }

            # don't include levels info for widget tree display
            #                                 v
            set realChildren [$childrenCmd $w ""]

            foreach realChild $realChildren {
                if {[info exists ::widgets::${realChild}::parent]} {
                   unset ::widgets::${realChild}::parent
                }
                vTcl:widget:register_widget $realChild
            }
        }
    }
}

###
## Register a widget and give it a containing namespace to hold data.
#  save_options lists options that we absolutely want to be saved
#  (e.g. for menus we want to save -menu, -label at least)
#  This also determines the default options for the widget.
###
proc vTcl:widget:register_widget {w {save_options ""}} {
    global classes
    global vTcl
    set opts [$w configure]
    vTcl:widget:register_widget_megachildren $w
    if {![catch {namespace children ::widgets} namespaces]} {
        if {[lsearch $namespaces ::widgets::${w}] > -1} {
            if {![info exists ::widgets::${w}::options] &&
                 [info exists ::widgets::${w}::save]} {

                # at least, if the widget has already been registered
                # (typically just after a "file open" operation), we
                # need to create the options and defaults arrays

                namespace eval ::widgets::${w} {
                    variable options
                    variable defaults
                }
                set defopts $classes([vTcl:get_class $w],defaultValues)
                set newdefopts ""

                foreach list $opts {
                    lassign $list opt x x def val
                    # if the option is not saved in the project, we
                    # want it to take the default value for the most
                    # common options (on the other hand, some options
                    # are better off if we use the option database)

                    if {[lsearch -exact $defopts $opt] != -1 &&
                        ![info exists ::widgets::${w}::save($opt)]} {
                        set ::widgets::${w}::options($opt) $def
                        set ::widgets::${w}::defaults($opt) $def
                        lappend newdefopts $opt $def
                    } else {
                        set ::widgets::${w}::options($opt) $val
                        set ::widgets::${w}::defaults($opt) $def
                    }

                    # if the option is not saved, make sure we keep the settings
                    if {![info exists ::widgets::${w}::save($opt)]} {
                        set ::widgets::${w}::save($opt) 0
                    }
                }

                if {![lempty $newdefopts]} {
                    eval $w configure $newdefopts
                }

                vTcl:widget:register_widget_custom $w
                return
            }
        }
    }
    namespace eval ::widgets::${w} {
        variable options
        variable save
        variable defaults
    }
    set class [vTcl:get_class $w]
    # Rozen. New loop.
    if {$class == "Menu"} {
        set last_index [$w index last]
        if {$last_index != "none"} {
            for {set i 0} {$i <= $last_index} {incr i} {
                set entry_ops [$w entryconfigure $i]
                foreach list $entry_ops {
                    lassign $list opt x x def val
                    switch -exact -- $opt {
                        -background {
                            if {$val == ""} {
                                $w entryconfigure $i -background \
                                    $vTcl(pr,menubgcolor)
                            }
                        }
                        -forground {
                            if {$val == ""} {
                                $w entryconfigure $i -forground \
                                    $vTcl(pr,menubgcolor)
                            }
                        }
                        -font {
                            if {$val == ""} {
                               $w entryconfigure $i -font $vTcl(pr,gui_font_menu)
                            }
                        }
                    }
                }
            }
        }
    }
    foreach list $opts {
        lassign $list opt x x def val
        set ::widgets::${w}::options($opt) $val
        #set ::widgets::${w}::defaults($opt) $def
        # New Switch to handle default as specified by user. Rozen - 11/10/12.
        # as well as default colors.
        switch -exact $opt {
            -buttonbackground -
            -entryactivecolor -
            -background {
                set ::widgets::${w}::defaults($opt) $vTcl(actual_gui_bg)
            }
            -foreground {
                set ::widgets::${w}::defaults($opt) $vTcl(actual_gui_fg)
            }
            default {
                set ::widgets::${w}::defaults($opt) $def
            }
        }
        if {[lsearch -exact $save_options $opt] >=0 } {
            set ::widgets::${w}::save($opt) 1
            continue
        }

        if {[info exists ::widgets::${w}::save($opt)]} { continue }
        if {$class == "Menu"} {   # Rozens kludge to save menu stuff.
            switch -exact -- $opt {
                -background -
                -forground -
                -activebackground -
                -activeforeground -
                -font {
                    set ::widgets::${w}::save($opt) 1
                }
            }
        } else {
            set ::widgets::${w}::save($opt) [expr ![vTcl:streq $def $val]]
        }
    }
    vTcl:widget:register_widget_custom $w
}
##
# Destroy all widgets that have not been registered. These will usually be ones
# that are created at run time or using tkcon.
##
proc vTcl:widget:remove_unregistered_widgets {{w .}} {
    set widgets [vTcl:list_widget_tree $w]
    foreach w $widgets {
        if {![catch {namespace children ::widgets} namespaces]} {
                if { [lsearch $namespaces ::widgets::${w}] <= -1 } {
                pack forget $w
                destroy $w
               }
        }
    }
}

###
## Register all unregistered widgets.  This is called when loading a project.
## If the project has widget registry information already stored, the namespace
## for each widget will already exist, and the widget will not be registered.
##
## If there is no registry, one will be created.  This lets us register old
## imported projects that don't contain saved registry information.
###

proc vTcl:widget:register_all_widgets {{w .}} {
    set widgets [vTcl:list_widget_tree $w]
    foreach w $widgets {
        vTcl:widget:register_widget $w
    }
}

namespace eval vTcl::widgets {

    proc saveOptions {w optionName} {
        namespace eval ::widgets::${w}::options {}
        namespace eval ::widgets::${w}::save    {}
        vTcl:WidgetVar $w options
        vTcl:WidgetVar $w save

        set value [$w cget $optionName]
        set options($optionName) $value
        set save($optionName) 1
    }

    ## ensures the list of suboptions are saved
    proc saveSubOptions {w args} {
        set nm ::widgets::${w}::subOptions
        namespace eval $nm {}
        foreach option $args {
            set ${nm}::save($option) 1
        }
    }

    ## actionProc takes as parameter the widget path and an additional param
    ##
    ## returnVal array is set with as index the widget path and as value the
    ## value returned by actionProc
    ##
    ## for example:
    ##    returnVal(.)  core
    ##    returnVal(.top32) core
    ##    returnVal(.top32.arrow28) bwidget
    ##    ...
    proc iterateCompleteWidgetTree {root actionProc actionParam returnVal} {
        upvar $returnVal _returnVal
        set children [vTcl:complete_widget_tree $root 0]
        foreach child $children {
            set _returnVal($child) [$actionProc $child $actionParam]
        }
    }

    proc getClasses {w args} {
        set c [vTcl:get_class $w]

        ## if this is a compound container with a megawidget inside,
        ## save the megawidget support procs into the project as well
        if {$c == "CompoundContainer" && [$w innerClass] == "MegaWidget"} {
            return [concat $c [usedClasses [$w innerWidget]]]
        } else {
            return $c
        }
    }

    proc usedClasses {root} {
        array set classArray {}
        iterateCompleteWidgetTree $root getClasses {} classArray

        set result ""
        foreach index [array names classArray] {
            set result [concat $result $classArray($index)]
        }

        return [lsort -unique $result]
    }

    proc getLibrary {w arg} {
        set c [vTcl:get_class $w]
        return $::classes($c,lib)
    }

    ## return the list of libraries used by a compound
    proc usedLibraries {root} {
        array set libraries {}
        iterateCompleteWidgetTree $root getLibrary {} libraries

        set result ""
        foreach index [array names libraries] {
            lappend result $libraries($index)
        }

        ## return a list without duplicates
        return [lsort -unique $result]
    }

    ## return the list of libraries that have been successfully loaded
    proc loadedLibraries {} {
        return $::vTcl(libs)
    }

    ## verify that the list of libraries passed as parameters are loaded
    ## returns the missing ones
    proc verifyLibraries {libraries} {
        set loaded [loadedLibraries]
        set result ""
        foreach library $libraries {
            if {[lsearch -exact $loaded $library] == -1} {
                lappend result $library
            }
        }
        return $result
    }

    ## asks a widget class if can insert and if so returns additional options
    proc queryInsertOptions {class addOptions refOptions} {
        upvar $refOptions options

        if {![info exists ::classes($class,queryInsertOptionsCmd)]} {
            ## yeah, we can insert, there is no restriction
            set options ""
            return 1
        }

        return [$::classes($class,queryInsertOptionsCmd) $addOptions options]
    }

    ## return the list of used images or fonts for this widget
    ## resourceType parameter needs to be "image" or "font"
    proc getResources {w resourceType} {
        set used {}
        set value {}

        ## 1. use defaut -image or -font option
        catch {set value [$w cget -$resourceType]}
        if {$value != ""} {
            lappend used $value
        }

        ## 2. use custom per class procedure to get used images or fonts
        set c [vTcl:get_class $w]
        set cmd get[string totitle $resourceType]sCmd
        if {[info exists ::classes($c,$cmd)]} {
            set used [concat $used [$::classes($c,$cmd) $w]]
        }

        ## 3. only return vTcl images and fonts objects
        set result {}
        foreach type {stock user} {
            foreach object $used {
                if {[lsearch [set ::vTcl(${resourceType}s,$type)] $object] > -1} {
                   lappend result $object
                }
            }
        } ; # foreach type ...

        return [lsort -unique $result]
    }

    ## return the list of images/font used by a compound
    ## resourceType parameter needs to be "image" or "font"
    proc usedResources {root resourceType} {
        array set resources {}
        iterateCompleteWidgetTree $root getResources $resourceType resources

        set result ""
        foreach index [array names resources] {
            if {![lempty $resources($index)]} {
                set result [concat $result $resources($index)]
            }
        }

        ## return a list without duplicates
        return [lsort -unique $result]
    }
}
