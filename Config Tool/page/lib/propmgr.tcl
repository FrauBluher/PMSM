##############################################################################
# $Id: propmgr.tcl,v 1.2 2012/01/22 03:14:34 rozen Exp rozen $
#
# propmgr.tcl - procedures used by the widget properties manager
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

# vTcl:prop:new_attr

## for Tcl/Tk 8.4
if {![llength [info commands tkMbPost]]} {
    ::tk::unsupported::ExposePrivateCommand tkMbPost
}

proc vTcl:show_propmgr {} {
    vTclWindow.vTcl.ae
}

proc vTcl:grid:height {parent {col 0}} {
    update idletasks
    set h 0
    set s [grid slaves $parent -column $col]
    foreach i $s {
        incr h [winfo height $i]
    }
    return $h
}

proc vTcl:grid:width {parent {row 0}} {
    update idletasks
    set w 0
    set s [grid slaves $parent -row $row]
    foreach i $s {
        incr w [winfo width $i]
    }
    return $w
}

proc vTcl:prop:set_visible {which {on ""}} {
    global vTcl
    set var ${which}_on
    switch $which {
        info {
            set f $vTcl(gui,ae,canvas).f1
            set name "Widget"
        }
        attr {
            set f $vTcl(gui,ae,canvas).f2
            set name "Attributes"
        }
        geom {
            set f $vTcl(gui,ae,canvas).f3
            set name "Geometry"
        }
        default {
            return
        }
    }
    if {$on == ""} {
        set on [expr - $vTcl(pr,$var)]
    }
    if {$on == 1} {
        pack $f.f -side top -expand 1 -fill both
        $f.l conf -text "$name (-)"
        set vTcl(pr,$var) 1
    } else {
        pack forget $f.f
        $f.l conf -text "$name (+)"
        set vTcl(pr,$var) -1
    }
    update idletasks
    vTcl:prop:recalc_canvas
}

proc vTclWindow.vTcl.ae {args} {
    # Build the Attribute Editor window. Rozen
    global vTcl tcl_platform

    set ae $vTcl(gui,ae)
    if {[winfo exists $ae]} {wm deiconify $ae; return}

    toplevel $ae -class vTcl
    wm withdraw $ae
    wm transient $ae .vTcl
    wm title $ae "Attribute Editor"
    wm geometry $ae 206x325
    wm resizable $ae 1 1
    wm transient $vTcl(gui,ae) .vTcl
    wm overrideredirect $ae 0

    if {$tcl_platform(platform) == "windows"} {
    set scrincr 25
    } else {
    set scrincr 20
    }

    set vTcl(gui,ae,canvas) [ScrolledWindow $ae.sw].c
    set c $vTcl(gui,ae,canvas)

    canvas $c -highlightthickness 0 -yscrollincrement $scrincr

    pack $ae.sw -expand 1 -fill both
    #pack $c    ;# Rozen didn't know any better.  BWidget

    $ae.sw setwidget $c

    set f1 $c.f1; frame $f1       ; # Widget Info
        $c create window 0 0 -window $f1 -anchor nw -tag info
    set f2 $c.f2; frame $f2       ; # Widget Attributes
        $c create window 0 0 -window $f2 -anchor nw -tag attr
    set f3 $c.f3; frame $f3       ; # Widget Geometry
        $c create window 0 0 -window $f3 -anchor nw -tag geom

    label $f1.l -text "Widget"     -relief raised -bg #aaaaaa -bd 1 -width 30 \
        -anchor center  -fg black
        pack $f1.l -side top -fill x
    label $f2.l -text "Attributes" -relief raised -bg #aaaaaa -bd 1 -width 30 \
        -anchor center  -fg black
        pack $f2.l -side top -fill x
    label $f3.l -text "Geometry"   -relief raised -bg #aaaaaa -bd 1 -width 30 \
        -anchor center  -fg black
        pack $f3.l -side top -fill x

    bind $f1.l <ButtonPress> {vTcl:prop:set_visible info}
    bind $f2.l <ButtonPress> {vTcl:prop:set_visible attr}
    bind $f3.l <ButtonPress> {vTcl:prop:set_visible geom}

    set w $f1.f
    frame $w; pack $w -side top -expand 1 -fill both
    # In the following labels I changed the disabled colors.
    label $w.ln -text "Widget" -width 11 -anchor w
        vTcl:entry $w.en -width 12 -textvariable vTcl(w,widget) \
        -relief sunken \
        -state disabled -disabledbackground $vTcl(pr,disablebg) \
        -disabledforeground $vTcl(pr,disablefg)
    label $w.lc -text "Class"  -width 11 -anchor w

        vTcl:entry $w.ec -width 12 -textvariable vTcl(w,class) \
        -relief sunken \
        -state disabled -disabledbackground $vTcl(pr,disablebg) \
        -disabledforeground $vTcl(pr,disablefg)
    label $w.lm -text "Manager" -width 11 -anchor w
        vTcl:entry $w.em -width 12 -textvariable vTcl(w,manager) \
        -relief sunken \
        -state disabled -disabledbackground $vTcl(pr,disablebg) \
        -disabledforeground $vTcl(pr,disablefg)
    label $w.la -text "Alias"  -width 11 -anchor w
    vTcl:entry $w.ea -width 12 -textvariable vTcl(w,alias) \
        -relief sunken
    bind $w.ea <KeyRelease-Return> "
        ::vTcl::properties::setAlias \$::vTcl(w,widget) ::vTcl(w,alias) $w.ea"
    bind $w.ea <FocusOut> "
        ::vTcl::properties::setAlias \$::vTcl(w,widget) ::vTcl(w,alias) $w.ea"
    label $w.li -text "Insert Point" -width 11 -anchor w
        vTcl:entry $w.ei -width 12 -textvariable vTcl(w,insert) \
        -relief sunken \
        -state disabled -disabledbackground $vTcl(pr,disablebg) \
        -disabledforeground $vTcl(pr,disablefg)

    grid columnconf $w 1 -weight 1

    grid $w.ln $w.en -padx 0 -pady 1 -sticky news
    grid $w.lc $w.ec -padx 0 -pady 1 -sticky news
    grid $w.lm $w.em -padx 0 -pady 1 -sticky news
    grid $w.la $w.ea -padx 0 -pady 1 -sticky news
    grid $w.li $w.ei -padx 0 -pady 1 -sticky news

    ttk::style configure PyConsole.TSizegrip \
        -background $vTcl(pr,bgcolor) ;# 11/22/12
#    pack [ttk::sizegrip $c.f3.sz -style "PyConsole.TSizegrip"] \
        -side right -anchor se
#    grid [ttk::sizegrip $ae.sz -style "PyConsole.TSizegrip"] \
        -column 999 -row 999 -sticky se ;#   11/27/12
    # 6/9/09

    set w $f2.f
    frame $w; pack $w -side top -expand 1 -fill both

    set w $f3.f
    frame $w; pack $w -side top -expand 1 -fill both

    vTcl:prop:set_visible info $vTcl(pr,info_on)
    vTcl:prop:set_visible attr $vTcl(pr,attr_on)
    vTcl:prop:set_visible geom $vTcl(pr,geom_on)
    if { $vTcl(w,widget) != "" } {
        vTcl:prop:update_attr
    }
    vTcl:setup_vTcl:bind $vTcl(gui,ae)
    if {$tcl_platform(platform) == "macintosh"} {
        set w [expr [winfo vrootwidth .] - 206]
        wm geometry $vTcl(gui,ae) 200x300+$w+20
    }
    catch {wm geometry .vTcl.ae $vTcl(geometry,.vTcl.ae)}
    update idletasks
    vTcl:prop:recalc_canvas
    vTcl:BindHelp $ae PropManager
    wm deiconify $ae
}

proc vTcl:prop:recalc_canvas {} {
    global vTcl

    set ae $vTcl(gui,ae)
    set c  $vTcl(gui,ae,canvas)
    if {![winfo exists $ae]} { return }

    set f1 $c.f1                              ; # Widget Info Frame
    set f2 $c.f2                              ; # Widget Attribute Frame
    set f3 $c.f3                              ; # Widget Geometry Frame

    $c coords attr 0 [winfo height $f1]
    $c coords geom 0 [expr [winfo height $f1] + [winfo height $f2]]

    set w [vTcl:util:greatest_of "[winfo width $f1] \
                                  [winfo width $f2] \
                                  [winfo width $f3]" ]
    set h [expr [winfo height $f1] + \
                [winfo height $f2] + \
                [winfo height $f3] ]
    $c configure -scrollregion "0 0 $w $h"
    wm minsize .vTcl.ae $w 200

    set vTcl(propmgr,frame,$f1) 0
    lassign [vTcl:split_geom [winfo geometry $f1]] w h
    set vTcl(propmgr,frame,$f2) $h
    lassign [vTcl:split_geom [winfo geometry $f2]] w h2
    set vTcl(propmgr,frame,$f3) [expr $h + $h2]
}

proc vTcl:key_release_cmd {k config_cmd target option variable args} {
    global vTcl
    ## Don't change if the user presses a directional key.
    # Rozen.  I removed the following "if" because leaving it there
    # goofed up stuff when changing a button text to "process". I
    # really don't understand why.
    #if {$k < 37 || $k > 40} {
        set value [set $variable]
        set ::vTcl::config($target) [list $config_cmd $target $option \
                                         $variable $value $args]

        ## Geometry options do not have checkboxes to save/not save
        if {$config_cmd != "vTcl:prop:geom_config_mgr"} {
            vTcl:prop:save_opt $target $option $variable
        }
    #}
}

proc vTcl:focus_out_cmd {} {
    global vTcl
    set names [array names ::vTcl::config]

    foreach w $names {
        if {![winfo exists $w]} {
            continue
        }
        catch {
            lassign $::vTcl::config($w) config_cmd target option \
                variable value args
            $config_cmd $target $option $variable $value $args
        }
        unset ::vTcl::config($w)
    }

    vTcl:place_handles $::vTcl(w,widget)
}

proc vTcl:prop:config_cmd {target option variable value args} {
    global vTcl
    if {$option == "-image"} {
        set x [set $variable]
        if {[file exists $x]} {
            # The value of $variablew is a file presumably a gif or ppm.
            set new_value [vTcl:image:create_new_image $x]
            set $variable $new_value
            set y [set $variable]
        }
    }
    if {$value == ""} {
        $target configure $option [set $variable]
        vTcl:prop:save_opt $target $option $variable
        vTcl:place_handles $target
    } else {
        $target configure $option $value
        vTcl:prop:save_opt_value $target $option $value $target configure $option
    }
}

proc vTcl:prop:spec_config_cmd {target option variable value args} {
    global vTcl
    set cmd $args
    if {$value == ""} {
        $cmd $target [set $variable]
        vTcl:prop:save_opt $target $option $variable
        vTcl:place_handles $target
    } else {
        $cmd $target $value
        vTcl:prop:save_opt_value $target $option $value
    }
}

proc vTcl:prop:geom_config_mgr {target option variable value args} {
    global vTcl
    set mgr $args
    vTcl:setup_unbind_widget $target
    if {$value == ""} {
        $mgr configure $target $option [set $variable]
        vTcl:place_handles $target
    } else {
        $mgr configure $target $option $value
    }
    vTcl:setup_bind_widget $target
    ::vTcl::notify::publish geom_config_mgr $target $mgr $option
}

proc vTcl:prop:geom_config_cmd {target option variable value args} {
    global vTcl
    set cmd $args
    vTcl:setup_unbind_widget $target
    if {$value == ""} {
        $cmd $target $option [set $variable]
        vTcl:place_handles $target
    } else {
        $cmd $target $option $value
    }
    vTcl:setup_bind_widget $target
    ::vTcl::notify::publish geom_config_cmd $target $cmd $option
}

proc vTcl:prop:update_attr {} {
    # Called when widget is selected. $vTcl(options) is a list of all
    # attributes for all widgets.
    global vTcl options specialOpts
    set ae $vTcl(gui,ae)
    if {![winfo exists $ae]} {return}

    if {$vTcl(var_update) == "no"} {
        return
    }
    if {[vTcl:streq $vTcl(w,widget) "."]} {
        vTcl:prop:clear
        return
    }
    #
    # Update Widget Attributes
    #
    set fr $vTcl(gui,ae,canvas).f2.f
    set top $fr._$vTcl(w,class)
    update idletasks
    if {[winfo exists $top]} {
        if {$vTcl(w,class) != $vTcl(w,last_class)} {
            catch {pack forget $fr._$vTcl(w,last_class)}
            update
            pack $top -side left -fill both -expand 1
        }
        foreach i $vTcl(options) {
            set type $options($i,type)
            if {[info exists specialOpts($vTcl(w,class),$i,type)]} {
                set type $specialOpts($vTcl(w,class),$i,type)
            }
            if {$type == "synonym"} { continue }
            if {[lsearch $vTcl(w,optlist) $i] >= 0} {
                if {$type == "color"} {
                    set val $vTcl(w,opt,$i)
                    if {$val == ""} {
                        ## if empty color use default background
                        set val [lindex [$top.t${i}.f configure -bg] 3]
                    }
                    if {[string first "#" $val] >= -1} {
                        # Rozen Kludge in case color is in hex form.
                        set vTcl(tmp) $val
                        set val vTcl(tmp)
                    }
                    ::vTcl::ui::attributes::show_color $top.t${i}.f $val
                    #$top.t${i}.f configure -bg $val
                }
            }
        }
    } elseif [winfo exists $fr] {
        catch {pack forget $fr._$vTcl(w,last_class)}
        frame $top
        pack $top -side top -expand 1 -fill both
        grid columnconf $top 1 -weight 1
        set type ""
        # vTcl(opt,list) is  list of all possible attributes and it is
        # set statically in globals.tcl"
        # vTcl(w,optlist) is the list of options which are valid for the
        # window w. It is set in vTcl:update_widget_info in widget.tcl.
        # See vTcl:conf_to_pairs in widget.tcl.  Rozen
        foreach i $vTcl(options) {
            if {$options($i,type) == "synonym"} { continue }
            set newtype $options($i,title)
            if {$type != $newtype} {
                set type $newtype
            }
            if {[lsearch $vTcl(w,optlist) $i] < 0} { continue }
            if {$i == "-class"} { continue } ;# Rozen class already displayed.
            #if {$i == "-xscrollcommand"} { continue } ;# Rozen nothing 5/4/14
            #                                           # for user to do
            #if {$i == "-yscrollcommand"} { continue } ;# Same as above. 
            if {[string first scroll $i] > -1} {continue} ;# Nothing
                                                           # user can
                                                           # use Rozen 5/4/2014
            set variable "vTcl(w,opt,$i)"
            vTcl:prop:new_attr $top $i $variable vTcl:prop:config_cmd "" opt
        }

        ## special stuff to edit menu items (cascaded items)
        if {$vTcl(w,class) == "Menu"} {
            global dummy
            set dummy ""
            vTcl:prop:new_attr $top -menuspecial dummy "" "" opt ""
        }
        ## special options support
        if {[info exist ::classoption($vTcl(w,class))]} {
            foreach spec_opt $::classoption($vTcl(w,class)) {
                vTcl:prop:new_attr $top $spec_opt vTcl(w,opt,$spec_opt) \
                    vTcl:prop:spec_config_cmd $::configcmd($spec_opt,config) opt
            }
        }


            set mgr $vTcl(w,manager)
        catch {
            if {[lsearch -exact $vTcl(m,$mgr,extlist) "title"] > 0} {
                # I want to move the title attribute from geometry
                # section to attributer section. Rozen
                set j "title"
                set mgr $vTcl(w,manager)   ;# OK
                set variable "vTcl(w,$mgr,$j)"  ;# OK
                set cmd [lindex $vTcl(m,$mgr,$j) 4]  ;# OK
                #set config_cmd "$cmd \$vTcl(w,widget) $j \$$variable" ;#
                #set focus_out_cmd "vTcl:focus_out_geometry_cmd $j $cmd"
                if {$cmd == ""} {
                    vTcl:prop:new_attr $top $j $variable \
                        vTcl:prop:geom_config_mgr $mgr m,$mgr -geomOpt
                } else {
                    vTcl:prop:new_attr $top $j $variable \
                        vTcl:prop:geom_config_cmd $cmd m,$mgr -geomOpt
                }
            }
        }
    }
    if {$vTcl(w,manager) == ""} {
        update idletasks
        vTcl:prop:recalc_canvas
        return
    }

    #
    # Update Widget Geometry
    #
    set fr $vTcl(gui,ae,canvas).f3.f
    set top $fr._$vTcl(w,manager)
    set mgr $vTcl(w,manager)
    update idletasks
    if {[winfo exists $top]} {
        if {$vTcl(w,manager) != $vTcl(w,last_manager)} {
            catch {pack forget $fr._$vTcl(w,last_manager)}
            pack $top -side left -fill both -expand 1
        }
    } elseif [winfo exists $fr] {
        catch {pack forget $fr._$vTcl(w,last_manager)}
        frame $top
        pack $top -side top -expand 1 -fill both
        grid columnconf $top 1 -weight 1

    catch {
        foreach i "$vTcl(m,$mgr,list) $vTcl(m,$mgr,extlist)" {
            if {$i == "title"} continue   ;# Rozen
            set variable "vTcl(w,$mgr,$i)"
            set cmd [lindex $vTcl(m,$mgr,$i) 4]
            if {$cmd == ""} {
                vTcl:prop:new_attr $top $i $variable \
                    vTcl:prop:geom_config_mgr $mgr m,$mgr -geomOpt
            } else {
                vTcl:prop:new_attr $top $i $variable \
                    vTcl:prop:geom_config_cmd $cmd m,$mgr -geomOpt
            }
        }
    }   ;# End of catch.
    }

    if {$vTcl(w,manager) == "wm"} {
        # enable/disable position/size values depending on settings
        vTcl:wm:enable_geom
    }
    update idletasks
    vTcl:prop:recalc_canvas
    vTcl:prop:update_saves $vTcl(w,widget)
}

proc vTcl:prop:combo_update {w var args} {
    if {[winfo exists $w]} {
        set values [set ::$var]
        set index [lindex $values 0]
        $w configure -values [lrange $values 1 end]
        if {$index != -1} {
            $w setvalue @$index
        }
    }
}

proc vTcl:prop:combo_select {w option} {
    $::configcmd($option,select) $::vTcl(w,widget) [$w getvalue]
}

proc vTcl:prop:combo_edit {w option} {
    $::configcmd($option,edit) $::vTcl(w,widget) $::configcmd($option,editArg)
}

proc vTcl:prop:choice_update {w var args} {
    if {[winfo exists $w]} {
        set values [$w cget -values]
        set value  [set ::$var]
        set index [lsearch -exact $values $value]
        if {$index != -1} {
            $w setvalue @$index
        }
    }
}

proc vTcl:prop:choice_select {w var} {
    set index [$w getvalue]
    set values [$w cget -values]
    if {$index != -1} {
        set ::$var [lindex $values $index]
    }
}

proc vTcl:prop:color_update {w val} {
    if {$val == ""} {
        ## if empty color use default background
        set val [lindex [$w configure -bg] 3]
    }
    if {[::colorDlg::dark_color $val]} {
        set ell_image ellipseslight
    } else {
        set ell_image ellipsesdark
    }
    $w configure -bg $val -image $ell_image
}

proc vTcl:prop:new_attr {top option variable config_cmd \
                             config_args prefix {isGeomOpt ""}} {
    # Rozen removed $variable This routine creates the right hand side
    # of the Attribute editor. One attribute at a time.
    global vTcl options specialOpts propmgrLabels
    if {$option == "values"} {
    }
    set base $top.t${option}
    # Hack for Tcl/Tk 8.5
    # Tristan 2008-05-13
    foreach v {vTcl $variable options specialOpts propmgrLabels} {
        upvar #0 $v $v
    }

    set base $top.t${option}

    # Hack for Tix
    if {[winfo exists $top.$option]} { return }

    if {![lempty $isGeomOpt]} {
        set isGeomOpt 1
    } else {
        set isGeomOpt 0
    }

    if {$prefix == "opt"} {
        if {[info exists specialOpts($vTcl(w,class),$option,type)]} {
            set text    $specialOpts($vTcl(w,class),$option,text)
            set type    $specialOpts($vTcl(w,class),$option,type)
            set choices $specialOpts($vTcl(w,class),$option,choices)
        } else {
            set text    $options($option,text)
            set type    $options($option,type)
            set choices $options($option,choices)
        }
    } else {
        set text    [lindex $vTcl($prefix,$option) 0]
        set type    [lindex $vTcl($prefix,$option) 2]
        set choices [lindex $vTcl($prefix,$option) 3]
    }
    if {[vTcl:streq $type "relief"]} {
        set type    choice
        set choices $vTcl(reliefs)
    }

    set label $top.$option
    label $label -text $text -anchor w -width 11 -fg black \
        -relief $vTcl(pr,proprelief) \
           -foreground $vTcl(pr,fgcolor)  ;# Rozen

    set focusControl $base
    # The option spec "-insertborderwidth 3" below makes cursor
    # visible when bg is dark.
    switch $type {
        boolean {
            frame $base
            vTcl:boolean_radio ${base}.y \
                -variable $variable -value 1 -text "Yes" -relief sunken  \
                -command "$config_cmd \$vTcl(w,widget) $option $variable {} $config_args" -padx 0 -pady 1
            vTcl:boolean_radio ${base}.n \
                -variable $variable -value 0 -text "No" -relief sunken  \
                -command "$config_cmd \$vTcl(w,widget) $option $variable {} $config_args" -padx 0 -pady 1
            pack ${base}.y ${base}.n -side left -expand 1 -fill both
        }
        combobox {
            frame $base
            ComboBox ${base}.c -width 8 -editable 0 \
                -modifycmd "vTcl:prop:combo_select ${base}.c $option"
            button ${base}.b -image ellipses -width 12 -padx 0 -pady 1 \
                -command "vTcl:prop:combo_edit ${base}.c $option"
            pack ${base}.c -side left -fill x -expand 1
            pack ${base}.b -side right -fill none -expand 0
            set focusControl ${base}.c
            if {[trace vinfo ::$variable] == ""} {
                trace variable ::$variable w \
                    "vTcl:prop:combo_update ${base}.c $variable"
            } else {
                vTcl:prop:combo_update ${base}.c $variable
            }
        }
        choice {
            ComboBox ${base} -editable 0 -width 12 -values $choices \
                -modifycmd "vTcl:prop:choice_select ${base} $variable
              $config_cmd \$vTcl(w,widget) $option $variable {} $config_args"
            trace variable ::$variable w "vTcl:prop:choice_update ${base} $variable"
            vTcl:prop:choice_update ${base} $variable
        }
        menu {
            button $base \
                -text "<click to edit>" -relief sunken  -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
            focus $base
            vTcl:propmgr:select_attr $top $option
                    set current \$vTcl(w,widget)
                    vTcl:edit_target_menu \$current
                    set $variable \[\$current cget -menu\]
                    vTcl:prop:save_opt \$current $option $variable
                " -anchor w
        }
        menuspecial {
            button $base \
                -text "<click to edit>" -relief sunken  -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
            vTcl:propmgr:select_attr $top $option
                    set current \$vTcl(w,widget)
                    vTcl:edit_menu \$current
                    vTcl:prop:save_opt \$current $option $variable
                " -anchor w
        }
        color {
            frame $base
            vTcl:entry ${base}.l -relief sunken  \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black -insertborderwidth 3
            bind ${base}.l <KeyRelease-Return> \
                "$config_cmd \$vTcl(w,widget) $option $variable {} $config_args
                 ${base}.f conf -bg \$$variable"
            button ${base}.f \
                -image ellipses  -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
            vTcl:propmgr:select_attr $top $option
            vTcl:show_color $top.t${option}.f $option $variable ${base}.f
            vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
        "
            vTcl:prop:color_update ${base}.f [set $variable]
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
            set focusControl ${base}.l
        }
        command {
            frame $base
            vTcl:entry ${base}.l -relief sunken  \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black  -insertborderwidth 3
# Removed by Rozen
#             button ${base}.f \
#                 -image ellipses  -width 12 \
#                 -highlightthickness 1 -fg black -padx 0 -pady 1 \
#                 -command "
#             vTcl:propmgr:select_attr $top $option
#             vTcl:set_command \$vTcl(w,widget) $option $variable
#         "
            pack ${base}.l -side left -expand 1 -fill x
#            pack ${base}.f -side right -fill y -pady 1 -padx 1
        set focusControl ${base}.l
        }
        font {
            frame $base
            vTcl:entry ${base}.l -relief sunken  \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black  -insertborderwidth 3
            button ${base}.f \
                -image ellipses  -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
        vTcl:propmgr:select_attr $top $option
        vTcl:font:prompt_user_font \$vTcl(w,widget) $option
        vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
        "
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
            ::vTcl::ui::attributes::show_color ${base}.f \
                vTcl(pr,bgcolor) ;# Rozen 2-3-13
            set focusControl ${base}.l
        }
        image {
            frame $base
            vTcl:entry ${base}.l -relief sunken  \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black  -insertborderwidth 3
            button ${base}.f \
                -image ellipses  -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
        vTcl:propmgr:select_attr $top $option
        vTcl:prompt_user_image \$vTcl(w,widget) $option
        vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
        "
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
        set focusControl ${base}.l
        }
        default {
            vTcl:entry $base \
                -textvariable $variable -width 12 -highlightthickness 1 \
                     -foreground black        ;# Rozen 2-3-13
        }
    }

    ## Append the label to the list for this widget and add the focusControl
    ## to the lookup table.  This is used when scrolling through the property
    ## manager with the directional keys.  We don't want to append geometry
    ## options, we just handle them later.
    set c [vTcl:get_class $vTcl(w,widget)]
    if {!$isGeomOpt} {
        lappend vTcl(propmgr,labels,$c) $label
    } else {
        lappend vTcl(propmgr,labels,$vTcl(w,manager)) $label
    }
    set propmgrLabels($label) $focusControl

    ## If they click the label, select the focus control.
    bind $label <Button-1> "focus $focusControl"
    bind $label <Enter> "
    if {\[vTcl:streq \[$label cget -relief] $vTcl(pr,proprelief)]} {
        $label configure -relief raised
    }
    "
    bind $label <Leave> "
    if {\[vTcl:streq \[$label cget -relief] raised]} {
        $label configure -relief $vTcl(pr,proprelief)
    }
    "

    ## If they right-click the label, show the context menu. No right-click for
    ## geometry options is currently provided.
    if {!$isGeomOpt} {
        bind $label <ButtonRelease-3> \
        "vTcl:propmgr:show_rightclick_menu $vTcl(gui,ae) $option $variable %X %Y"
    }

    bind after_$focusControl <FocusIn>    \
        "vTcl:propmgr:select_attr $top $option"
    bind after_$focusControl <FocusOut>   \
        vTcl:focus_out_cmd
    bind $focusControl <MouseWheel> \
        "vTcl:propmgr:scrollWheelMouse %D $label"
    bind after_$focusControl <KeyRelease> \
        "vTcl:key_release_cmd %k $config_cmd \$vTcl(w,widget) $option $variable $config_args"
    bind after_$focusControl <KeyRelease-Return> \
        "$config_cmd \$vTcl(w,widget) $option $variable {} $config_args"
    bind after_$focusControl <Key-Up> \
        "vTcl:propmgr:focusPrev $label"
    bind after_$focusControl <Key-Down> \
        "vTcl:propmgr:focusNext $label"
    bindtags $focusControl "[bindtags $focusControl] after_$focusControl"

    if {[vTcl:streq $prefix "opt"]} {
    set saveCheck [checkbutton ${base}_save -pady 0]
    vTcl:set_balloon $saveCheck "Check to save option"
    grid $top.$option $base $saveCheck -sticky news
    } else {
    grid $top.$option $base -sticky news
    global tcl_platform
    ## If we're on windows, we need geometry labels to be padded a little
    ## to match the rest of the labels in the options.
    if {$tcl_platform(platform) == "windows"} {
        $label configure -pady 4
    }
    }
}

proc vTcl:prop:enable_manager_entry {option state} {
    global vTcl

    if {![winfo exists $vTcl(gui,ae)]} return

    set fr $vTcl(gui,ae,canvas).f3.f
    set top $fr._$vTcl(w,manager)

    set base $top.t${option}

    array set background [list normal $vTcl(pr,entrybgcolor) disabled gray]

    ## makes sure the property entry does exist
    if {[winfo exists $base]} {
        $base configure -state $state -bg $background($state)
    }
}

proc vTcl:prop:clear {} {
    global vTcl

    if {![winfo exists $vTcl(gui,ae)]} return

    vTcl:propmgr:deselect_attr

    if {![winfo exists $vTcl(gui,ae,canvas)]} {
        frame $vTcl(gui,ae,canvas)
        pack $vTcl(gui,ae,canvas)
    }
    foreach fr {f2 f3} {
        set fr $vTcl(gui,ae,canvas).$fr
        if {![winfo exists $fr]} {
            frame $fr
            pack $fr -side top -expand 1 -fill both
        }
    }

    ## Destroy and rebuild the Attributes frame
    set fr $vTcl(gui,ae,canvas).f2.f
    catch {destroy $fr}
    frame $fr; pack $fr -side top -expand 1 -fill both

    ## Destroy and rebuild the Geometry frame
    set fr $vTcl(gui,ae,canvas).f3.f
    catch {destroy $fr}
    frame $fr; pack $fr -side top -expand 1 -fill both

    set vTcl(w,widget)  {}
    set vTcl(w,insert)  {}
    set vTcl(w,class)   {}
    set vTcl(w,alias)   {}
    set vTcl(w,manager) {}

    update
    vTcl:prop:recalc_canvas
}

###
## Update all the option save checkboxes in the property manager.
###
proc vTcl:prop:update_saves {w} {
    global vTcl
    set c $vTcl(gui,ae,canvas)
    set class [vTcl:get_class $w]
    ## special options support
    set spec_opts ""
    if {[info exist ::classoption($class)]} {
        set spec_opts $::classoption($class)
    }
    foreach opt [concat $vTcl(w,optlist) $spec_opts] {
        set check $c.f2.f._$class.t${opt}_save
        if {![winfo exists $check]} { continue }
        $check configure -variable ::widgets::${w}::save($opt)
    }
}

###
## Update the checkbox for an option in the property manager.
##
## If the option becomes the default option, we uncheck the checkbox.
## This will save on space because we're not storing options we don't need to.
###
proc vTcl:prop:save_opt {w opt varName} {
    if {[vTcl:streq $w "."]} { return }

    upvar #0 $varName var
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save
    if {![info exists options($opt)]} { return }
    if {[vTcl:streq $options($opt) $var]} { return }

    set options($opt) $var

    if {$options($opt) == $defaults($opt)} {
    set save($opt) 0
    } else {
    set save($opt) 1
    }
    ::vTcl::change
}

proc vTcl:prop:save_opt_value {w opt value} {
    if {[vTcl:streq $w "."]} { return }
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save
    if {![info exists options($opt)]} { return }
    if {[vTcl:streq $options($opt) $value]} { return }

    set options($opt) $value

    if {$options($opt) == $defaults($opt)} {
    set save($opt) 0
    } else {
    set save($opt) 1
    }
    ::vTcl::change
}

proc vTcl:propmgr:select_attr {top opt} {
    global vTcl
    vTcl:propmgr:deselect_attr
    $top.$opt configure -relief sunken
    set vTcl(propmgr,lastAttr) [list $top $opt]
    set vTcl(propmgr,opt) $opt
}

proc vTcl:propmgr:deselect_attr {} {
    global vTcl
    if {![info exists vTcl(propmgr,lastAttr)]} { return }
    [join $vTcl(propmgr,lastAttr) .] configure -relief $vTcl(pr,proprelief)
    unset vTcl(propmgr,lastAttr)
}

proc vTcl:propmgr:focusOnLabel {w dir} {
    global vTcl propmgrLabels

    set m $vTcl(w,manager)
    set c [vTcl:get_class $vTcl(w,widget)]
    set list [concat $vTcl(propmgr,labels,$c) $vTcl(propmgr,labels,$m)]

    set ind [lsearch $list $w]
    incr ind $dir

    if {$ind < 0} { return }

    set next [lindex $list $ind]

    if {[lempty $next]} { return }

    ## We want to set the focus to the focusControl, but we want the canvas
    ## to scroll to the label of the focusControl.
    focus $propmgrLabels($next)

    vTcl:propmgr:scrollToLabel $vTcl(gui,ae,canvas) $next $dir
}

proc vTcl:propmgr:focusPrev {w} {
    vTcl:propmgr:focusOnLabel $w -1
}

proc vTcl:propmgr:focusNext {w} {
    vTcl:propmgr:focusOnLabel $w 1
}

proc vTcl:propmgr:scrollToLabel {c w units} {
    global vTcl
    set split [split $w .]
    set split [lrange $split 0 5]
    set frame [join $split .]

    if {$units > 0} {
    set offset [expr 2 * [winfo height $w]]
    } else {
    set offset [winfo height $w]
    }
    lassign [$c cget -scrollregion] foo foo cx cy
    lassign [vTcl:split_geom [winfo geometry $w]] foo foo ix iy
    set yt [expr $iy.0 + $vTcl(propmgr,frame,$frame) + $offset]
    lassign [$c yview] topY botY
    set topY [expr $topY * $cy]
    set botY [expr $botY * $cy]

    ## If the total new height is lower than the current view, scroll up.
    ## If the total new height is higher than the current view, scroll down.
    if {$yt < $topY || $yt > $botY} {
    $c yview scroll $units units
    }
}

proc vTcl:propmgr:show_rightclick_menu {base option variable X Y} {

    if {![winfo exists $base.menu_rightclk]} {

        menu $base.menu_rightclk -tearoff 0

        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men22" -accelerator {} -command {} -font {} \
                -label {Reset to default}

        $base.menu_rightclk add separator

        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men24" -accelerator {} -command {} -font {} \
                -label {Do not save option for}

        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men25" -accelerator {} -command {} -font {} \
                -label {Save option for}

        $base.menu_rightclk add separator

        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men26" -accelerator {} -command {} -font {} \
                -label {Apply to}

        menu $base.menu_rightclk.men24 -tearoff 0

        $base.menu_rightclk.men24 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            subwidgets vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {Same Class Subwidgets}

        $base.menu_rightclk.men24 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            frame vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {All Same Class Widgets in same Parent}

        $base.menu_rightclk.men24 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            toplevel vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {All Same Class Widgets in toplevel}

    $base.menu_rightclk.men24 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            all vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {All Same Class Widgets in this project}

        menu $base.menu_rightclk.men25 -tearoff 0

        $base.menu_rightclk.men25 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            subwidgets vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {Same Class Subwidgets}

        $base.menu_rightclk.men25 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            frame vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {All Same Class Widgets in same Parent}

        $base.menu_rightclk.men25 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            toplevel vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {All Same Class Widgets in toplevel}
        $base.menu_rightclk.men25 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            all vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {All Same Class Widgets in this project}

        menu $base.menu_rightclk.men26 -tearoff 0

        $base.menu_rightclk.men26 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            subwidgets vTcl:prop:set_opt \
                        [set $::vTcl::_rclick_variable]} \
                -label {Same Class Subwidgets}

        $base.menu_rightclk.men26 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            frame vTcl:prop:set_opt \
                        [set $::vTcl::_rclick_variable]} \
                -label {All Same Class Widgets in same Parent}

        $base.menu_rightclk.men26 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            toplevel vTcl:prop:set_opt \
                        [set $::vTcl::_rclick_variable]} \
                -label {All Same Class Widgets in toplevel}

        $base.menu_rightclk.men26 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            all vTcl:prop:set_opt \
                        [set $::vTcl::_rclick_variable]} \
                -label {All Same Class Widgets in this project}

        menu $base.menu_rightclk.men22 -tearoff 0

        $base.menu_rightclk.men22 add command \
                -accelerator {} \
        -command {vTcl:prop:default_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable} \
                -label {This Widget}

        $base.menu_rightclk.men22 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            subwidgets vTcl:prop:default_opt} \
                -label {Same Class Subwidgets}

        $base.menu_rightclk.men22 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            frame vTcl:prop:default_opt} \
                -label {All Same Class Widgets in same Parent}

        $base.menu_rightclk.men22 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            toplevel vTcl:prop:default_opt} \
                -label {All Same Class Widgets in toplevel}

        $base.menu_rightclk.men22 add command \
                -accelerator {} \
        -command {vTcl:prop:apply_opt $vTcl(w,widget) \
            $::vTcl::_rclick_option $::vTcl::_rclick_variable \
            all vTcl:prop:default_opt} \vTcl(w,class)
                -label {All Same Class Widgets in this project}
    }

    set ::vTcl::_rclick_option   $option
    set ::vTcl::_rclick_variable $variable

    tk_popup $base.menu_rightclk $X $Y
}

# This proc resets a given option to its default value
# The goal is to help making cross-platform applications easier by
# only saving options that are necessary

proc vTcl:prop:default_opt {
            w opt varName {user_param {}} {index {}} {force_save {}}} {
    # Rozen. I added the three parameters user_param, index, and
    # force_save as I was trying to get the menu stuff to work
    # correctly.  This all seems to have be required since I want to
    # be able to specify new defaults for menu colors and fonts. (Such
    # defaults are set by the user in the Preferences dialog using the
    # Fonts and Colors tabs.)  Since these defaults are not know to Tk
    # I have to force them. In those cases I call this routine from
    # ::menu_edit::set_menu_item_defaults in menus.tcl with the
    # 'user_param' set to the default that I want to use.  Since this
    # value has to into the configuration of the menu item, I pass the
    # non-blank 'index' argument.  Normally, when setting the default
    # one then does not need to set the value of the save variable
    # unless the user changes it.  However with the menu stuff Tk
    # would get the default wrong, so we always want to save it, so I
    # pass in the non-blank 'force_save'.

    # The strang variable defaults($opt) anr set in in
    # vTcl:widget:register_widget located in widget.tcl
    global vTcl
    upvar #0 $varName var
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save

    if {![info exists options($opt)]} { return }
    if {![info exists defaults($opt)]} { return }
    # only refresh the attribute editor if this is the
    # current widget, otherwise we'll get into trouble

    if {$w == $vTcl(w,widget)} {
        # Here is where tvar got changed.
        set var $defaults($opt)
    }
    if {$user_param != ""} { ;# Rozen
        set defaults($opt) $user_param
    }
    if {$index != ""} {          # Added by Rozen to set options of menu entries.
        $w entryconfigure $index $opt $defaults($opt)
    } else {
        $w configure $opt $defaults($opt)
    }
    set options($opt) $defaults($opt)
    if {$force_save != ""} {  ;# Rozen
        set save($opt) 1
    } else {
        set save($opt) 0
    }
    ::vTcl::change
}

# This proc applies an option to a widget

proc vTcl:prop:set_opt {w opt varName value} {

    global vTcl
    upvar #0 $varName var
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save
    if {![info exists options($opt)]} { return }
    if {![info exists defaults($opt)]} { return }
    $w configure $opt $value
    set options($opt) $value

    # only refresh the attribute editor if this is the
    # current widget, otherwise we'll get into trouble

    if {$w == $vTcl(w,widget)} {
    set var $value
    }

    if {$value == $defaults($opt)} {
    set save($opt) 0
    } else {
    set save($opt) 1
    }
}

proc vTcl:prop:save_or_unsave_opt {w opt varName save_or_not} {

    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w save

    if {![info exists options($opt)]} { return }

    set save($opt) $save_or_not
    ::vTcl::change
}

# Apply options settings to a range of widgets of the same
# class as w
#
# Parameters:
#   w         currently selected widget
#   opt       the option to change (eg. -background)
#   varName   name of variable for display in attributes editor
#   extent    which widgets to modify; can be one of
#         frame
#         apply to given widget and all in same parent
#             subwidgets
#                 apply to given widget and all its subwidgets
#             toplevel
#                 apply to all widgets in toplevel containing given widget
#             all
#                 apply to all widgets in the current project
#   action    name of proc to call for each widget
#             this callback proc should have the following parameters:
#                 w          widget to modify
#                 opt        option name (eg. -cursor)
#                 varName    name of variable in attributes editor
#                 user_param optional parameter
#   user_param
#             value of optional user parameter

proc vTcl:prop:apply_opt {w opt varName extent action {user_param {}}} {

    global vTcl

    # let's do it, but before that, we need to destroy the handles
    vTcl:destroy_handles

    set class [vTcl:get_class $w]

    switch $extent {
    subwidgets {
    # 0 because we don't want information for widget tree display
    set widgets [vTcl:complete_widget_tree $w 0]
    }
    toplevel {
    set top [winfo toplevel $w]
        set widgets [vTcl:complete_widget_tree $top 0]
    }
    all {
        set widgets [vTcl:complete_widget_tree . 0]
    }
    frame {
        set widgets [list]
        set man  [winfo manager $w]
        set par  [winfo parent $w]
        if {$man == "grid" || $man == "pack" || $man == "place"} {
            set widgets [$man slaves $par]
        }
    }
    }

    foreach widget $widgets {
        if {[vTcl:get_class $widget] == $class} {
        $action $widget $opt $varName $user_param
    }
    }

    # we are all set
    vTcl:create_handles $vTcl(w,widget)
}

proc vTcl:propmgr:scrollWheelMouse {delta label} {
    if {$delta > 0} {
    vTcl:propmgr:focusPrev $label
    } else {
    vTcl:propmgr:focusNext $label
    }
}

namespace eval ::vTcl::properties {

    proc setAlias {target aliasVar entryWidget} {
        if {![winfo exists $target]} return

        set alias [set $aliasVar]

        ## has the alias changed ? no, really, just asking
        if {[info exists ::widget(rev,$target)] &&
            $::widget(rev,$target) == $alias} {
            return
        }

        set valid [vTcl:valid_alias $target $alias]
        if {!$valid} {
            ## disable focusOut binding before showing message box
            set oldBind [bind $entryWidget <FocusOut>]

            ## now we can show the message box
            ::vTcl::MessageBox -message "Alias '$alias' already exists"

            ## restore focusOut binding after message box is dismissed
            bind $entryWidget <FocusOut> $oldBind
            return
        }

        ## user wants to unset alias?
        if {$alias == ""} {
            vTcl:unset_alias $target
        } else {
            vTcl:set_alias $target $alias
        }
    }
}

