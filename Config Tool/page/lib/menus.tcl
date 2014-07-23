#############################################################################
# $Id: menus.tcl,v 1.3 2012/01/22 03:13:43 rozen Exp rozen $
#
# menus.tcl procedures to edit application menus
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

# Rozen. This seems stuff for user definition of menues.

# I had a bit of an experimental hassle to get it to work at all. I
# found that to make a menu for the top level window one needed to add
# not commands to the menu but cascades then one could fill out those
# cascades like File, Edit, View, etc. with commands or cascaded
# menues.  Damn lack of documentation.

# The menu stuff starts with vTcl:edit_target_menu in lib_core.tcl line 227.

# When we click on an item in the listbox of the menu editor we jump
# to ::menu_edit::click_listbox, about line 850 in this module.
# ::menu_edit::show_menu about line 560 - where we start when a line
# in the editor is selected

# fillProperties about line 700
# initBoxes about 567
# configCmd

# When we start the menu edit it starts with edit_target_menu line 227
# in lib_core.tcl.k

# new_item  where we add a new_iterm
# set_menu_item_defaults


# nameapace ::vTcl::ui::attributes in misc.tcl

namespace eval ::menu_edit {

    # this contains a list of currently open menu editors
    variable menu_edit_windows ""

    proc {::menu_edit::delete_item} {top} {
        global widget

        set ::${top}::current_menu ""
        set ::${top}::current_index ""

        # this proc deletes the currently selected menu item

        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set listboxitems [set ::${top}::listboxitems]

        set reference [lindex $listboxitems $index]

        set menu [lindex $reference end-1]
        set pos  [lindex $reference end]

        if {$pos != -1} {
            set mtype [$menu type $pos]
            if {$mtype == "cascade"} {
                set submenu [$menu entrycget $pos -menu]
                ::menu_edit::delete_menu_recurse $submenu
            }

            $menu delete $pos
            vTcl:init_wtree
        }

        ::menu_edit::fill_menu_list $top [set ::${top}::menu]
        click_listbox $top
    }

    proc {::menu_edit::delete_menu_recurse} {menu} {
        global widget vTcl
        # unregister
        catch {namespace delete ::widgets::$menu} error

        set last [$menu index end]
        while {$last != "none"} {

            set mtype [$menu type $last]

            if {$mtype == "cascade"} {
                set submenu [$menu entrycget $last -menu]
                ::menu_edit::delete_menu_recurse $submenu
            }

            if {$mtype == "tearoff"} {
                $menu configure -tearoff 0
            } else {
                $menu delete $last
            }

            set last [$menu index end]
        }

        destroy $menu
    }

    proc {::menu_edit::enable_editor} {top enable} {

        global widget

        set ctrls "$top.NewMenu      $top.DeleteMenu
                   $top.MoveMenuUp   $top.MoveMenuDown"

        switch $enable {
            0 - false - no {
                set ::${top}::backup_bindings [bindtags $widget($top,MenuListbox)]
                bindtags $widget($top,MenuListbox) dummy
                bindtags $widget($top,NewMenu)     dummy
                $top.MenuListbox configure -background gray

                foreach ctrl $ctrls {
                    set ::${top}::$ctrl.state      [$ctrl cget -state]
                    set ::${top}::$ctrl.background [$ctrl cget -background]

                    $ctrl configure -state disabled
                }
                enableProperties $top 0
            }
            1 - true - yes {
                foreach ctrl $ctrls {
                    if {[info exists ::${top}::$ctrl.state]} {
                        $ctrl configure -state      [set ::${top}::$ctrl.state] \
                                     -background [set ::${top}::$ctrl.background]
                    }
                }

                if {[info exists ::${top}::backup_bindings]} {
                    bindtags $widget($top,MenuListbox) \
                        [set ::${top}::backup_bindings]
                }
                bindtags $widget($top,NewMenu) ""
                $top.MenuListbox configure -background white
                enableProperties $top 1
                ::menu_edit::click_listbox $top
            }
        }
    }

    proc {::menu_edit::enable_all_editors} {enable} {

        variable menu_edit_windows

        set wnds $menu_edit_windows

        foreach wnd $wnds {
            ::menu_edit::enable_editor $wnd $enable
        }
    }

    proc {::menu_edit::set_uistate} {top} {
        foreach name [array names ::${top}::uistate] {
            if {$name != "Tearoff"} {
                $top.$name configure -state [set ::${top}::uistate($name)]
            }
        }
    }

    proc {::menu_edit::enable_toolbar_buttons} {top} {
        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index == "" || $index == 0} {
            array set ::${top}::uistate {
                DeleteMenu disabled  MoveMenuUp disabled MoveMenuDown disabled
                Tearoff disabled
            }
            ::menu_edit::set_uistate $top
            return
        }

        array set ::${top}::uistate { DeleteMenu normal Tearoff disabled }

        set m ""
        set i ""

        ::menu_edit::get_menu_index $top $index m i
        set j $i
        if {[$m cget -tearoff] == 1 && $i == 1} {
           set j [expr $i -1]
        }

        if {$j == 0} {
            array set ::${top}::uistate { MoveMenuUp disabled }
        } else {
            array set ::${top}::uistate { MoveMenuUp normal }
        }

        if {$i < [$m index end]} {
            array set ::${top}::uistate { MoveMenuDown normal }
        } else {
            array set ::${top}::uistate { MoveMenuDown disabled }
        }

        if {[$m type $i] == "cascade"} {
            array set ::${top}::uistate { Tearoff normal }
        }

        ::menu_edit::set_uistate $top
    }

    proc {::menu_edit::fill_command} {top command} {
        global widget

        ## if the command is in the form "vTcl:DoCmdOption target cmd",
        ## then extracts the command, otherwise use the command as is
        if {[regexp {vTcl:DoCmdOption [^ ]+ (.*)} $command matchAll realCmd]} {
            lassign $command dummy1 dummy2 command
        }

        $top.MenuText delete 0.0 end
        $top.MenuText insert end $command

        vTcl:syntax_color $widget($top,MenuText)
    }

    proc {::menu_edit::fill_menu} {top m {level 0} {path {}}} {

        set size [$m index end]

        if {$path == ""} {
            set path $m
        } else {
            lappend path $m
        }

        if {$size == "none"} {return}

        for {set i 0} {$i <= $size} {incr i} {
            set mtype [$m type $i]
            if {$mtype == "tearoff"} continue

            lappend ::${top}::listboxitems [concat $path $i]

            set indent "    "
            for {set j 0} {$j < $level} {incr j} {
                append indent "    "
            }

            switch -exact $mtype {
                "cascade" {
                    set tearoff ""
                    set mlabel [$m entrycget $i -label]
                    set maccel [$m entrycget $i -accel]
                    set submenu [$m entrycget $i -menu]
                    if {$submenu != ""} {
                        if {[$submenu cget -tearoff] == 1} {
                            set tearoff " ---X---"}}
                    if {$maccel != ""} {
                        $top.MenuListbox insert end \
                            "$indent${mlabel}   ($maccel)$tearoff"
                    } else {
                        $top.MenuListbox insert end "$indent${mlabel}$tearoff"
                    }
                    if {$submenu != ""} {
                        ::menu_edit::fill_menu \
                            $top $submenu [expr $level + 1] [concat $path $i]
                    }
                }
                "command" {
                    set mlabel   [$m entrycget $i -label]
                    set maccel   [$m entrycget $i -accel]

                    if {$maccel != ""} {
                        $top.MenuListbox insert end \
                            "$indent${mlabel}   ($maccel)"
                    } else {
                        $top.MenuListbox insert end \
                            "$indent${mlabel}"
                    }
                }
                "separator" {
                    $top.MenuListbox insert end "$indent<separator>"
                }
                "radiobutton" -
                "checkbutton" {
                    set mlabel [$m entrycget $i -label]
                    set maccel [$m entrycget $i -accel]
                    if {$mtype == "radiobutton"} {
                        set prefix "o "
                    } else {
                        set prefix "x "}
                    if {$maccel != ""} {
                        $top.MenuListbox insert end \
                            "$indent$prefix${mlabel}   ($maccel)"
                    } else {
                        $top.MenuListbox insert end \
                            "$indent$prefix${mlabel}"
                    }
                }
            }
        }
    }

    proc {::menu_edit::fill_menu_list} {top m} {
        global widget
        # let's try to save the context
        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]
        if {$index == ""} {
            set index [set ::${top}::listbox_index]
        }

        set yview [lindex [$top.MenuListbox yview] 0]

        set ::${top}::listboxitems ""
        $top.MenuListbox delete 0 end

        # Rozen. Here we put in the first item <menu> at the top of
        # the box. We give it index of -1 which has effects when we hit it again/
        lappend ::${top}::listboxitems [list $m -1]
        $top.MenuListbox insert end "<Menu>"

        ::menu_edit::fill_menu $top $m
        set ::${top}::menu $m

        if {$index != ""} {
            $top.MenuListbox selection clear 0 end
            $top.MenuListbox selection set $index
        }

        $top.MenuListbox yview moveto $yview
    }

    proc {::menu_edit::get_menu_index} {top index ref_m ref_i} {
        upvar $ref_m m
        upvar $ref_i i

        set reference [set ::${top}::listboxitems]
        set reference [lindex $reference $index]
        set m [lindex $reference end-1]
        set i [lindex $reference end]
    }

    proc {::menu_edit::move_item} {top direction} {
        set indices [$top.MenuListbox curselection]
        set index   [lindex $indices 0]

        if {$index == ""} return

        set m ""
        set i ""

        ::menu_edit::get_menu_index $top $index m i

        # what is the new index ?
        switch $direction {
            up {
                set new_i [expr $i - 1]
            }
            down {
                set new_i [expr $i + 1]
            }
        }

        # let's save the old menu
        set old_config [$m entryconfigure $i]
        set mtype      [$m type $i]

        set optval ""

        # build a list of option/value pairs
        foreach option $old_config {
            lappend optval [list [lindex $option 0] [lindex $option 4]]
        }

        # delete the old menu
        $m delete $i

        # insert menu at the new place
        eval $m insert $new_i $mtype [join $optval]

        ::menu_edit::fill_menu_list $top [set ::${top}::menu]

        # let's select the same menu at its new location
        set size [$top.MenuListbox index end]

        for {set ii 0} {$ii < $size} {incr ii} {

            set mm ""
            set mi ""

            ::menu_edit::get_menu_index $top $ii mm mi
            if {$mm == $m && $new_i == $mi} {
                $top.MenuListbox selection clear 0 end
                $top.MenuListbox selection set $ii
                $top.MenuListbox activate $ii
                ::menu_edit::show_menu $top $ii
                break
            }
        }
    }

    proc {::menu_edit::new_item} {top type} {
        global widget
        global vTcl
        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set listboxitems [set ::${top}::listboxitems]
        set reference [lindex $listboxitems $index]
        set menu [lindex $reference end-1]
        set pos  [lindex $reference end]

        if {$pos != -1} {
            set mtype [$menu type $pos]
            if {$mtype == "cascade"} {
                set menu [$menu entrycget $pos -menu]
            }
        }
        switch $type {
            "cascade" {
                set nmenu [vTcl:new_widget_name menu $menu]
                set vTcl($nmenu,font) ""
                menu $nmenu -tearoff 0
                vTcl:widget:register_widget $nmenu -tearoff
                vTcl:setup_vTcl:bind $nmenu


                $menu add $type -label "NewCascade" -menu $nmenu \
                      -activebackground $vTcl(analog_color_m) \
                      -activeforeground $vTcl(active_fg) \
                      -background $vTcl(actual_gui_menu_bg) \
                      -foreground $vTcl(actual_gui_menu_fg)  \
                      -font $vTcl(actual_gui_font_menu_name)

                vTcl:init_wtree
                vTcl:active_widget $nmenu
                vTcl::widgets::saveSubOptions $nmenu -label -menu \
                          -activebackground -activeforeground  -background \
                          -foreground -font
            }
            "command" {
                $menu add $type -label "NewCommand"  \
                    -command "TODO"  ;# Rozen : Your menu handler here"
                # The command below lists the options we want to save.
                # Since I have put in the special options I want to make
                # sure that they are saved. Rozen
                vTcl::widgets::saveSubOptions $menu -label -command -font\
                   -foreground -background -activeforeground -activebackground
                ::menu_edit::set_menu_item_defaults $menu last   ;# Rozen
            }
            "radiobutton" {
                set toplevel [findToplevel $menu]
                $menu add $type -label "NewRadio"  \
                    -command "TODO"  ;# Rozen : Your menu handler here" \
                    -variable ::${toplevel}::menuSelectedButton
                vTcl::widgets::saveSubOptions $menu -label -command -variable \
                        -font -foreground -background -activeforeground \
                     -activebackground -tearoff# set_menu_item_defaults
                ::menu_edit::set_menu_item_defaults $menu last   ;# Rozen
            }
            "checkbutton" {
                set num 1
                set toplevel [findToplevel $menu]
                while {[info exists ::${toplevel}::check${num}]} {incr num}
                $menu add $type -label "NewCheck"  \
                    -command "TODO"  ;# Rozen : Your menu handler here" \
                    -variable ::${toplevel}::check${num}
                set ::${toplevel}::check${num} 1
                 vTcl::widgets::saveSubOptions $menu -label -command -variable \
                        -font -foreground -background -activeforeground \
                     -activebackground
                ::menu_edit::set_menu_item_defaults $menu last   ;# Rozen
            }
            "separator" {
                $menu add $type
                vTcl::widgets::saveSubOptions $menu -background -foreground
                # Line below because separator has no attributes of
                # font, active forground, active background or even
                # forground.
                vTcl:prop:default_opt $menu -background vTcl(w,opt,-background) \
                        $vTcl(actual_gui_menu_bg) last 1
            }
        }

        ::menu_edit::fill_menu_list $top [set ::${top}::menu]
    }

    proc set_menu_item_defaults {menu {index {}}} {
        # Added by Rozen.  Since I have added preferences for
        # background foreground and fonts formenus I have to pass not
        # the standard defaults but the ones that I have defined.
        # vTcl:prop:default_opt is in propmgr.tcl.
        global vTcl
        foreach def {-activebackground -activeforeground
                     -background -foreground -font} {
            switch -exact -- $def {
                -background {
                    vTcl:prop:default_opt $menu $def vTcl(w,opt,$def) \
                        $vTcl(actual_gui_menu_bg) $index 1
                }
                -foreground {
                    vTcl:prop:default_opt $menu $def vTcl(w,opt,$def)\
                        $vTcl(actual_gui_menu_fg) $index 1
                }
                -font {
                    vTcl:prop:default_opt $menu $def vTcl(w,opt,$def) \
                        $vTcl(actual_gui_font_menu_name) $index 1   ;# Rozen
                }
                -activebackground {
                    vTcl:prop:default_opt $menu $def vTcl(w,opt,$def)\
                        $vTcl(analog_color_m) $index 1
                }
            }
                # Because I do not specify defaults for active fore
                # and back grounds.
                # default {
                #     vTcl:prop:default_opt $menu $def vTcl(w,opt,$def) "" $index
                # }
        }
    }

    proc findToplevel {menu} {
        set toplevel [winfo toplevel $menu]
        while {[winfo class $toplevel] != "Toplevel"} {
            set toplevel [winfo parent $toplevel]}
        return $toplevel
    }

    proc {::menu_edit::post_context_new_menu} {top X Y} {
        global widget

        tk_popup $widget($top,NewMenuContextPopup) $X $Y
    }


    proc {::menu_edit::post_new_menu} {top} {
        global widget

        set x [winfo rootx  $widget($top,NewMenu)]
        set y [winfo rooty  $widget($top,NewMenu)]
        set h [winfo height $widget($top,NewMenu)]

        tk_popup $widget($top,NewMenuToolbarPopup)  $x [expr $y + $h]
    }

    ## get initial values for the checkboxes
    proc initBoxes {top m} {
        variable target
        set nm ::widgets::${m}::subOptions
        namespace eval $nm {}

        ## first time ? if so, check values that are not the default
        if {![info exists ${nm}::save]} {
            ## how many subitems ?
            set size [$m index end]
            if {$size == "none"} {
                return
            }

            for {set i 0} {$i <= $size} {incr i} {
                set conf [$m entryconfigure $i]
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

    proc {::menu_edit::show_menu} {top index} {
        global widget
        set name ::${top}::listboxitems
        eval set reference $\{$name\}

        set reference [lindex $reference $index]
        set m [lindex $reference end-1]
        set i [lindex $reference end]
        if {$i == -1} {
            enableProperties $top 0
            set ::${top}::current_menu  $m
            set ::${top}::current_index $i
            ::menu_edit::enable_toolbar_buttons $top
            fillProperties $top $m -1         ;# Rozen Needs Work.
            return
        }

        set mtype  [$m type $i]

        set ::${top}::current_menu  $m
        set ::${top}::current_index $i
        set ::${top}::listbox_index $index

        initBoxes $top $m
        fillProperties $top $m $i

        ::menu_edit::enable_toolbar_buttons $top
    }

    proc setGetBox {top option {var {}}} {
        set m [set ::${top}::current_menu]
        set i [set ::${top}::current_index]
        if {$m == "" || $i == ""} {return}

        set nm ::widgets::${m}::subOptions
        if {$var != ""} {
            set ${nm}::save($option) [set $var]
        } else {
            if {[info exists ${nm}::save($option)]} {
                return [set ${nm}::save($option)]
            } else {
                return 0
            }
        }
    }

    proc keyRelease {top option var boxvar} {
        set m [set ::${top}::current_menu]
        set i [set ::${top}::current_index]
        if {$m == "" || $i == ""} {return}
        if {$i == -1} return        ;# Rozen Again, allow change to <Menu>
        set conf [$m entryconfigure $i $option]
        set default [lindex $conf 3]
        set value [set $var]
        if {$value != $default} {
          set $boxvar 1
            setGetBox $top $option $boxvar
        }
    }

    proc discoverOptions {} {
        menu .m -tearoff 0
        .m add cascade -menu ".m.cascade" -label "test"
        menu .m.cascade -tearoff 0
        set options [.m entryconfigure 0]

        .m.cascade add command -label "command"
        set options [concat $options [.m.cascade entryconfigure 0]]

        .m.cascade add radiobutton -label "command"
        set options [concat $options [.m.cascade entryconfigure 1]]

        .m.cascade add checkbutton -label "command"
        set options [concat $options [.m.cascade entryconfigure 2]]

        .m.cascade add separator
        set options [concat $options [.m.cascade entryconfigure 3]]

        destroy .m.cascade
        destroy .m

        set optionsList ""
        foreach option $options {
            lappend optionsList [lindex $option 0]
        }
        return [lsort -unique $optionsList]
    }

    proc checkAttribute {m option checkVar} {
        set nm ::widgets::${m}::subOptions
        if {[info exists ${nm}::save($option)]} {
            set $checkVar [set ${nm}::save($option)]
        } else {
            set $checkVar 0
        }
    }

    proc update_default_properties {menu index option value} {
        # Rozen. This routine sets the value into the option field of
        # the ithth element of the menu. It seems that when the menu
        # item is created the defaults and value are not set by the
        # interpreter.  I think that I need to do that in order to get
        # anything different from Tk default colors and font.
        if {$index > -1} {
            $menu entryconfigure $index $option $value
        }
    }

    # namespace  ::vTcl::ui::attributes  in misc.tcl

    proc fillProperties {top m i} {
        # Rozen. This appears to turn on the ones which are approriate
        # for the menu type.

        # Rozen.  Since I want menu items to show up with default
        # colors and fonts specified in the preferences, I had to hack
        # this up with several special cases. See below at the switch
        # which I use to tranfer default values into values actually
        # to be used.
        global vTcl
        upvar ::${top}::enableData enableData
        upvar ::${top}::allOptions allOptions
        if {$i == -1} {   # So that we can change menu properties. Rozen
            set properties [$m configure]
        } else {
            set properties [$m entryconfigure $i]
        }
        set currentOptions ""
        foreach property $properties {
            set option [lindex $property 0]

            set value  [lindex $property 4]
            switch -exact -- $option {   # Added by Rozen
                -background {
                    if {$value == ""} {
                        set value  $vTcl(pr,menubgcolor)
                        update_default_properties $m $i $option $value
                    }
                }
                -foreground {
                    if {$value == ""} {
                        set value  $vTcl(pr,menufgcolor)
                        update_default_properties $m $i $option $value
                    }
                }
                 -font {
                    if {$value == ""} {
                        set value  $vTcl(pr,gui_font_menu)
                        update_default_properties $m $i $option $value
                    }
                 }
                 -activebackground {
                    if {$value == ""} {
                        set value $vTcl(pr,activebackground)
                        update_default_properties $m $i $option $value
                    }
                 }
                 -activeforeground {
                    if {$value == ""} {
                        set value  $vTcl(pr,activeforeground)
                        update_default_properties $m $i $option $value
                    }
                }
            }

            set variable ::${top}::optionsValues($option)
            set $variable $value
            lappend currentOptions $option
        }
        foreach option $allOptions($top) {
            set variable ::${top}::optionsValues($option)
            set f [$top.MenuCanvas].f.$option
            # first uncheck the box, then check it if needed
            set checkVar [::vTcl::ui::attributes::getCheckVariable $f $option]
            set $checkVar 0

            # enable/disable option if it does/does not apply to subitem
            if {[lsearch -exact $currentOptions $option] == -1} {
              ::vTcl::ui::attributes::enableAttribute $enableData($top,$option) 0
            } else {
              ::vTcl::ui::attributes::enableAttribute $enableData($top,$option) 1
                checkAttribute $m $option $checkVar
            }
        }

        ## make sure the -command option substitutes %widget and %top with the
        ## correct value
        set f [$top.MenuCanvas].f.-command
        ::vTcl::ui::attributes::setCommandTarget $f -command $m
    }

    proc enableProperties {top enable} {
        upvar ::${top}::enableData enableData
        upvar ::${top}::allOptions allOptions

        foreach option $allOptions($top) {
        ::vTcl::ui::attributes::enableAttribute $enableData($top,$option) $enable
        }
    }

    proc configCmd {top option variable} {
        set m [set ::${top}::current_menu]
        set i [set ::${top}::current_index]
        if {$m == "" || $i == ""} {return}
        if {$i == -1} {  # Rozen to allow setting of <menu> options.
            $m configure $option [set $variable]
            return
        }

        set v [set $variable]
        $m entryconfigure $i $option $v
        if {$option == "-label" || $option == "-accelerator"} {
            ::menu_edit::fill_menu_list $top [set ::${top}::menu]
        }
    }

    proc initProperties {top m} {
        # Rozen. When the menu editor is started this routine fills in
        # the right hand column with the list of properties but they
        # are not enabled. (I think.)
        upvar ::${top}::enableData enableData
        upvar ::${top}::allOptions allOptions
     set options [discoverOptions]
        set allOptions($top) $options

        set target($top) $m

        foreach option $options {
            set variable ::${top}::optionsValues($option)
            set $variable ""
            set f [$top.MenuCanvas].f.$option
            if {[winfo exists $f]} {destroy $f}
            frame $f
            set config_cmd "::menu_edit::configCmd $top $option $variable"
            set enableData($top,$option) \
                [::vTcl::ui::attributes::newAttribute  $target($top) $f \
                 $option $variable $config_cmd  \
                 "::menu_edit::setGetBox $top"  \
                 "::menu_edit::keyRelease $top"]
            pack $f -side top -fill x -expand 0
            ::vTcl::ui::attributes::enableAttribute $enableData($top,$option) 0
        }

        ## calculate the scrolling region
        update idletasks
        set w [winfo width  [$top.MenuCanvas].f]
        set h [winfo height [$top.MenuCanvas].f]
        ${top}.MenuCanvas configure -scrollregion [list 0 0 $w $h]
    }

    proc {::menu_edit::toggle_tearoff} {top} {
        set indices [$top.MenuListbox curselection]
        set index   [lindex $indices 0]

        if {$index == ""} return

        set m ""
        set i ""

        ::menu_edit::get_menu_index $top $index m i

        set mtype [$m type $i]
        if {$mtype != "cascade"} return

        set submenu [$m entrycget $i -menu]
        if {$submenu == ""} return

        set tearoff [$submenu cget -tearoff]
        set tearoff [expr 1-$tearoff]
        $submenu configure -tearoff $tearoff

        ::menu_edit::fill_menu_list $top [set ::${top}::menu]
        ::menu_edit::show_menu $top $index
    }

    proc {::menu_edit::update_current} {top} {
        ::vTcl::ui::attributes::setPending  ;# Bottom of misc.tcl.
    }

    proc {::menu_edit::close_all_editors} {} {

        variable menu_edit_windows

        set wnds $menu_edit_windows

        foreach wnd $wnds {
            destroy $wnd
        }

        set menu_edit_windows ""
    }

    proc {::menu_edit::browse_image} {top} {
        set image [set ::${top}::entry_image]
        set r [vTcl:prompt_user_image2 $image]
        set ::${top}::entry_image $r
    }

    proc {::menu_edit::browse_font} {top} {
        set font [set ::${top}::entry_font]
        set r [vTcl:font:prompt_noborder_fontlist $font]

        if {$r != ""} {
            set ::${top}::entry_font $r
        }
    }

    proc {::menu_edit::click_listbox} {top} {
        # This is where we start when the listbox is clicked. Rozen
        ::menu_edit::update_current $top

        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index != ""} {
            ::menu_edit::show_menu $top $index
        }
    }

    proc {::menu_edit::ask_delete_menu} {top} {

        if {[::vTcl::MessageBox -message {Delete menu ?} \
                           -title {Menu Editor} -type yesno] == "yes"} {
            ::menu_edit::delete_item $top
        }
    }

    proc {::menu_edit::includes_menu} {top m} {

        # is it the root menu?
        if {[set ::${top}::menu] == $m} {
            return 0}

        set size [$top.MenuListbox index end]

        for {set i 0} {$i < $size} {incr i} {

            set mm ""
            set mi ""

            ::menu_edit::get_menu_index $top $i mm mi

            if {$mm != "" && $mi != -1 &&
                [$mm type $mi] == "cascade" &&
                [$mm entrycget $mi -menu] == $m} then {
                return $i
            }
        }

        # oh well
        return -1
    }

    ## check if the menu to edit is a submenu in an already open
    ## menu editor, and if so, open that menu editor
    proc {::menu_edit::open_existing_editor} {m} {

        # let's check each menu editor
        variable menu_edit_windows

        foreach top $menu_edit_windows {

            set index [::menu_edit::includes_menu $top $m]

            if {$index != -1} {
                Window show $top
                raise $top
                $top.MenuListbox selection clear 0 end
                $top.MenuListbox selection set $index
                $top.MenuListbox activate $index
                ::menu_edit::show_menu $top $index
                return 1
            }
        }

        return 0
    }

    proc {::menu_edit::is_open_existing_editor} {m} {
        # let's check each menu editor
        variable menu_edit_windows

        foreach top $menu_edit_windows {

            if {[::menu_edit::includes_menu $top $m] != -1} then {
                return $top
            }
        }

        return ""
    }

    ## refreshes the menu editor
    proc {::menu_edit::refreshes_existing_editor} {top} {

        ::menu_edit::fill_menu_list $top [set ::${top}::menu]

        $top.MenuListbox selection clear 0 end
        $top.MenuListbox selection set 0
        $top.MenuListbox activate 0
        ::menu_edit::show_menu $top 0
    }

    ## finds the root menu of the given menu
    proc {::menu_edit::find_root_menu} {m} {

        # go up until we find something that is not a menu
        set parent $m
        set lastparent $m

        while {[vTcl:get_class $parent] == "Menu"} {
            set lastparent $parent

            set items [split $parent .]
            set parent [join [lrange $items 0 [expr [llength $items] - 2] ] . ]
        }

        return $lastparent
    }

} ; # namespace eval

proc vTclWindow.vTclMenuEdit {base menu} {
    ##################################
    # OPEN EXISTING EDITOR IF POSSIBLE
    ##################################
    if {[::menu_edit::open_existing_editor $menu]} then {
        return }

    # always open a menu editor with root menu
    set original_menu $menu
    set menu [::menu_edit::find_root_menu $menu]

    global widget vTcl

    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    namespace eval $base {
        variable listboxitems  ""
        variable current_menu  ""
        variable current_index ""
        variable listbox_index ""
        variable enableData
        variable allOptions
        array set enableData {}
        array set allOptions {}
    }

    ###################
    # DEFINING ALIASES
    ###################
    vTcl:DefineAlias $base.cpd24.01.cpd25.01 MenuListbox vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd24.01.cpd25.01.m24 NewMenuToolbarPopup vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.cpd24.01.cpd25.01.m25 NewMenuContextPopup vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra21.but21 NewMenu vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra21.but22 DeleteMenu vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra21.but23 MoveMenuUp vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra21.but24 MoveMenuDown vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra21.but22 MenuOK vTcl:WidgetProc $base 1

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel -menu $base.m22
    wm overrideredirect $base 0
    wm focusmodel $base passive
    #wm geometry $base 550x450+323+138
    wm geometry $base 700x450+600+300
    wm withdraw $base
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm resizable $base 1 1
    wm title $base "Menu Editor"
    wm transient $base .vTcl

    menu $base.m22 -tearoff 0 -relief flat
    $base.m22 add cascade \
        -menu "$base.m22.men23" -label Insert
    $base.m22 add cascade \
        -menu "$base.m22.men24" -label Delete
    $base.m22 add cascade \
        -menu "$base.m22.men36" -label Move
    menu $base.m22.men23 -tearoff 0
    $base.m22.men23 add command \
        -command "::menu_edit::new_item $base command" \
        -label {New command}
    $base.m22.men23 add command \
        -command "::menu_edit::new_item $base cascade" \
        -label {New cascade}
    $base.m22.men23 add command \
        -command "::menu_edit::new_item $base separator" \
        -label {New separator}
    $base.m22.men23 add command \
        -command "::menu_edit::new_item $base radiobutton" \
        -label {New radio}
    $base.m22.men23 add command \
        -command "::menu_edit::new_item $base checkbutton" \
        -label {New check}
    menu $base.m22.men24 -tearoff 0  \
        -postcommand "$base.m22.men24 entryconfigure 0 -state \
            \[set ::${base}::uistate(DeleteMenu)\]"
    $base.m22.men24 add command \
        -command "::menu_edit::ask_delete_menu $base" \
        -label {Delete selected item.}
    menu $base.m22.men36 -tearoff 0 \
        -postcommand "$base.m22.men36 entryconfigure 0 -state \
            \[set ::${base}::uistate(MoveMenuUp)\]
            $base.m22.men36 entryconfigure 1 -state \
            \[set ::${base}::uistate(MoveMenuDown)\]"
    $base.m22.men36 add command \
        -command "::menu_edit::move_item $base up" \
        -label Up
    $base.m22.men36 add command \
        -command "::menu_edit::move_item $base down" \
        -label Down

    frame $base.fra21 \
        -borderwidth 2 -height 75 -width 125
    # Button but32 is the OK button with the check
    ::vTcl::OkButton $base.fra21.but32 \
    -command "::menu_edit::update_current $base; destroy $base"
    frame $base.cpd24 \
        -background #000000 -height 100 -width 200
    frame $base.cpd24.01 \
        -background #9900991B99FE
    vTcl:toolbar_label $base.fra21.but21 \
        -image [vTcl:image:get_image "add.gif"]
    bind $base.fra21.but21 <ButtonPress-1> {
        ::menu_edit::post_new_menu [winfo toplevel %W]
    }
    ::vTcl::CancelButton $base.fra21.but22 \
        -command "::menu_edit::ask_delete_menu $base"
    vTcl:toolbar_button $base.fra21.but23 \
        -command "::menu_edit::move_item $base up" -image up
    vTcl:toolbar_button $base.fra21.but24 \
        -command "::menu_edit::move_item $base down" -image down

    ScrolledWindow $base.cpd24.01.cpd25
    listbox $base.cpd24.01.cpd25.01 -background white -foreground black ;# Rozen
    $base.cpd24.01.cpd25 setwidget $base.cpd24.01.cpd25.01

    bindtags $base.cpd24.01.cpd25.01 \
        "Listbox $base.cpd24.01.cpd25.01 $base all"
    bind $base.cpd24.01.cpd25.01 <Button-1> {
        focus %W
    }
    bind $base.cpd24.01.cpd25.01 <<ListboxSelect>> {
        # This is where we go when we click on a line in the listbox. Rozen
        ::menu_edit::click_listbox [winfo toplevel %W]
        after idle {focus %W}
    }
    bind $base.cpd24.01.cpd25.01 <ButtonRelease-3> {
        ::menu_edit::update_current [winfo toplevel %W]

        set index [%W index @%x,%y]
        %W selection clear 0 end
        %W selection set $index
        %W activate $index

        if {$index != ""} {
            ::menu_edit::show_menu [winfo toplevel %W] $index
        }

        ::menu_edit::post_context_new_menu [winfo toplevel %W] %X %Y
    }
    menu $base.cpd24.01.cpd25.01.m24 \
        -activeborderwidth 1 -tearoff 0
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} -command "::menu_edit::new_item $base command" \
        -label {New command}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} -command "::menu_edit::new_item $base cascade" \
        -label {New cascade}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} -command "::menu_edit::new_item $base separator" \
        -label {New separator}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base radiobutton" \
        -label {New radio}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base checkbutton" \
        -label {New check}
    menu $base.cpd24.01.cpd25.01.m25 \
        -activeborderwidth 1 -tearoff 0 \
        -postcommand "$base.cpd24.01.cpd25.01.m25 entryconfigure 8 -state \
            \[set ::${base}::uistate(Tearoff)\]"
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::new_item $base command" \
        -label {New command}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::new_item $base cascade" \
        -label {New cascade}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::new_item $base separator" \
        -label {New separator}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base radiobutton" \
        -label {New radio}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base checkbutton" \
        -label {New check}
    $base.cpd24.01.cpd25.01.m25 add separator
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} \
        -command "::menu_edit::ask_delete_menu $base" \
        -label Delete...
    $base.cpd24.01.cpd25.01.m25 add separator
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::toggle_tearoff $base" \
        -label Tearoff
    frame $base.cpd24.02

    # This is the window that has the attributes. It is on the right
    # hand side of the editor. The color plum was used so that I could
    # find it.
    ScrolledWindow $base.cpd24.02.scr84  ;# -background plum
#    canvas $base.cpd24.02.scr84._grid.f.can85 \
#        -highlightthickness 0 -yscrollincrement 20 -closeenough 1.0
#dmsg 4.0.1
#    vTcl:DefineAlias "$base.cpd24.02.scr84._grid.f.can85" "MenuCanvas" vTcl:WidgetProc $base 1
#    $base.cpd24.02.scr84 setwidget $base.cpd24.02.scr84._grid.f.can85
    canvas $base.cpd24.02.scr84.can85 \
        -highlightthickness 0 -yscrollincrement 20 -closeenough 1.0
    vTcl:DefineAlias "$base.cpd24.02.scr84.can85" "MenuCanvas" vTcl:WidgetProc $base 1
    $base.cpd24.02.scr84 setwidget $base.cpd24.02.scr84.can85

    frame $base.cpd24.03 \
        -background #ff0000 -borderwidth 2 -relief raised
    bind $base.cpd24.03 <B1-Motion> {
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
    pack $base.fra21 \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.fra21.but32 \
        -in $base.fra21 -anchor center -expand 0 -fill none -side right
    pack $base.cpd24 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd24.01 \
        -x 0 -y 0 -width -1 -relwidth 0.6 -relheight 1 -anchor nw \
        -bordermode ignore
    pack $base.fra21.but21 \
        -in $base.fra21 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra21.but22 \
        -in $base.fra21 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra21.but23 \
        -in $base.fra21 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra21.but24 \
        -in $base.fra21 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd24.01.cpd25 \
        -in $base.cpd24.01 -anchor center -expand 1 -fill both -side top
    #pack $base.cpd24.01.cpd25.01        Rozen BWidget
    place $base.cpd24.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.4 -relheight 1 -anchor ne \
        -bordermode ignore
    pack $base.cpd24.02.scr84 \
        -in $base.cpd24.02 -anchor center -expand 1 -fill both -side top
    place $base.cpd24.03 \
        -x 0 -relx 0.6 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore

    pack [ttk::sizegrip $base.cpd24.sz -style "PyConsole.TSizegrip"] \
        -side right -anchor se

    vTcl:set_balloon $widget($base,NewMenu) \
        "Create a new menu item or a new submenu"
    vTcl:set_balloon $widget($base,DeleteMenu) \
        "Delete an existing menu item or submenu"
    vTcl:set_balloon $widget($base,MoveMenuUp) \
        "Move menu up"
    vTcl:set_balloon $widget($base,MoveMenuDown) \
        "Move menu down"

    frame [$base.MenuCanvas].f
    $base.MenuCanvas create window 0 0 -window [$base.MenuCanvas].f \
        -anchor nw -tag properties

    array set ::${base}::uistate {
        DeleteMenu disabled  MoveMenuUp disabled MoveMenuDown disabled
        Tearoff disabled
    }

    #############################
    # FILL IN MENU EDITOR `
    #############################

    # initializes menu editor
    ::menu_edit::initProperties $base $menu
    ::menu_edit::fill_menu_list $base $menu

    # keep a record of open menu editors
    lappend ::menu_edit::menu_edit_windows $base

    # initial selection
    set initial_index [::menu_edit::includes_menu $base $original_menu]
    if {$initial_index == -1} {
        set initial_index 0
    }

    $base.MenuListbox selection clear 0 end
    $base.MenuListbox selection set $initial_index
    $base.MenuListbox activate $initial_index
    ::menu_edit::click_listbox $base

    # when a menu editor is closed, should be removed from the list
    bind $base <Destroy> {

        set ::menu_edit::index \
            [lsearch -exact ${::menu_edit::menu_edit_windows} %W]

        if {${::menu_edit::index} != -1} {
            set ::menu_edit::menu_edit_windows \
                [lreplace ${::menu_edit::menu_edit_windows} \
                    ${::menu_edit::index} ${::menu_edit::index}]

            # clean up after ourselves
            namespace delete %W
        }
    }

    #######################
    # KEYBOARD ACCELERATORS
    #######################

    vTcl:setup_vTcl:bind $base

    # ok, let's add a special tag to override the <KeyPress-Delete> mechanism
    bindtags $widget($base,MenuListbox) \
        "_vTclMenuDelete [bindtags $widget($base,MenuListbox)]"

    bind _vTclMenuDelete <KeyPress-Delete> {

        ::menu_edit::ask_delete_menu [winfo toplevel %W]

        # we stop processing here so that Delete does not get processed
        # by further binding tags, which would have the quite undesirable
        # effect of deleting the current toplevel...

        break
    }

    wm deiconify $base
}
