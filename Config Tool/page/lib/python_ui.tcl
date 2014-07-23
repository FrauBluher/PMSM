# -*- tcl -*-
# Time-stamp: 2012-12-17 23:00:07 rozen>

# Python_ui.tcl - procedures for generating Python User Interfaces
#
# This program was written by Don Rozenberg and is based on java_ui.tcl
# written by Constantin Teodorescu.
#
# The original copyright notice is attached and this program is released
# under the terms of that copyright.
#
# Copyright (C) 1996-1997 Constantin Teodorescu
# Copyright (C) 2013 Donald Rozenberg
#
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

# vTcl:python_quick_run
# vTcl:python_parse_menu
# vTcl:Window.vTcl.py_console
# vTcl:python_configure_widget
# vTcl:relative_placement
# vTcl:python_source_widget    Switch for generating code for each widget class
# vTcl:python_menu_options
# vTcl:python_process_menu
# vTcl:python_menu_options
# vTcl:generate_python           Top of the python generation.
# vTcl:generate_python_UI
# vTcl:style_code
# vTcl:get_top_level_configuration
# vTcl:python_menu_font
# vTcl:save_python_code

#  To  add a special attribute:
#      1. Add the attribute to global.tcl or lib_tix to put it in
#          vTcl(opt,list)
#      2. Add a new case to vTcl:update_widget_info
#      3. Add code to case of  vTcl:python_source_widget to handle
#             the special attributes.

#  Menu stuff starts 1900.

proc lambda {{p1 ""} {p2 ""} {p3 ""} {p4 ""} {p5 ""} {p6 ""} {p7 ""} {p8 ""}} {
    # This is a null proc to facilitate certain bindings.
    # If the user binds a command to a window event it may be executed when
    # the tcl file is sourced.  Since the command will attempt to execute a
    # Python lambda function, an error message will occur.  By having this null
    # procedure, the error message is avoided.
}

proc vTcl:generate_python_UI {} {
    global vTcl env
    # Code Generation starts here.  Creates the Python Console and
    # calls vTcl:generate_python for actual code generation.
    set vTcl(rework) 1                 ;# for debuging rework second version.
    set window $vTcl(tops)
    if {$window == ""} {
        # There is nothing to save.
        tk_dialog .foo Error "There is no GUI to process." error 0 "OK"
        return
    }

    #$top.butframe.but33 configure -command "vTcl:python_save_py_file"
    if {![info exists vTcl($window,x)]} {
        vTcl:active_widget $window
    }
#     if {![info exists vTcl($window,x)]} {
#         #bell
#         tk_messageBox -title Error -message "Please first select toplevel window"
#             return
#         } else {
#             set window $vTcl(tops)
#         }
#     set cite 0
#     while {1} {
#         incr cite
#         if {$cite>10} {break}
#         if {[llength [split $window .]]==2} { break}
#         set window [winfo parent $window]`
#     }
#    set window $vTcl(top_widget)
#    set vTcl(py_window) $window
    set vTcl(py_title) [wm title $window]
    set vTcl(py_classname) [string map { " " _ } $vTcl(py_title) ]
    vTcl:Window.vTcl.py_console
    update
    #.vTcl.py_console.f3.t delete 1.0 end
    #.vTcl.py_console.f5.t delete 1.0 end
    #.vTcl.py_console.pane.text1.text1 subwidget text delete 1.0 end
    #.vTcl.py_console.pane.text2.text2 subwidget text delete 1.0 end
    $vTcl(source_window) delete 1.0 end
    $vTcl(output_window) delete 1.0 end

    if {$vTcl(project,file) == ""} {
        vTcl:save
    }
    vTcl:generate_python $window
    set vTcl(python_module) "GUI"
    #.vTcl.py_console edit modified 0
    $vTcl(code_window) edit modified 0
    vTcl:save_GUI_file
}

proc vTcl:generate_python {window} {
    # This is the top of the python generation. Called from
    # vTcl:generate_python_UI.
    global vTcl
    global style_code
    #set vTcl(menubutton_list) {}
    set vTcl(add_helper_code) 0
    set vTcl(helper_list) {}
    set vTcl(toplevel_menu_header) ""
    set vTcl(Tree_cnt) 0
#    set window $vTcl(py_window)
    set vTcl(slash_pos_list) 0
    set vTcl(pw_cnt) 0
    set vTcl(menu_names) []
    set vTcl(menu_image_count) 0
    set vTcl(using_ttk) 0
    set vTcl(import_module) 0
    vTcl:set_timestamp
    set vTcl(gui_py_change_time) [clock milliseconds]
    # The following loop gets rid of all the fonts that were defined
    # in the last call to generate python.  In short, it is one of the
    # things necessary to let one generate python multiple times within
    # PAGE.
    foreach index [array names vTcl fonts_defined,*] {
        unset vTcl($index)
    }

    #set vTcl(fonts_defined,gui_font_dft) 1

    set vTcl(fonts_defined,$vTcl(actual_gui_font_dft_name)) 1
    set vTcl(fonts_defined,$vTcl(actual_gui_font_text_name)) 1
    set vTcl(fonts_defined,$vTcl(actual_gui_font_fixed_name)) 1
    set vTcl(fonts_used) []
    set bg $vTcl(actual_gui_bg)
    set vTcl(bgcolor) $bg
    set fg $vTcl(actual_gui_fg)
    set vTcl(fgcolor) $fg
    lappend vTcl(alias_names) 1
    unset vTcl(alias_names)
    if {[info exists style_code]} {
        unset style_code
    }
    lappend vTcl(alias_names) 1
    # Get window geometry
    foreach {W H X Y} [split [winfo geometry $window] "x+"] {}
    set resizable [wm resizable $window]
    if {([lindex $resizable 0]=="0") || ([lindex $resizable 1]=="0")} {
        set resizable false
    } else {
        set resizable true
    }
    set classname $vTcl(py_classname)
    set title $vTcl(py_title)
    set constructor_arguments ""
    set constructor_super ""
    set main_args ""
    set main ""
    set onWindowClose "this.setVisible(false); this.dispose();"
    #    set lwin $vTcl(py_window)
    set geom [winfo geometry $window]
    set geom ""
    append geom $W "x" $H "+" $vTcl($window,x) "+" $vTcl($window,y)
    set main "\nif __name__ == '__main__':\n"
    append main "$vTcl(tab)vp_start_gui()\n"
    #append main "$vTcl(tab)create_$classname ()\n"
    set onWindowClose "sys.exit()"

    set vTcl(py_vars) {}
    set vTcl(py_initfunc) {}
    set vTcl(py_funcdef) {}
    set vTcl(py_action) {}
    set vTcl(py_has_menus) 0
    set vTcl(global_variable) 0
    set vTcl(g_v_list) {}
    set vTcl(l_v_list) {}
    set vTcl(funct_list) {}
    set vTcl(functions) ""
    set vTcl(class_functions) ""
    set vTcl(proc_list) {}
    #    set vTcl(output_adjust_sash) 0   ;# temporary
    foreach bg [array names vTcl py_btngroup,*] {
        unset vTcl($bg)
    }

    set vTcl(import_module) "[file rootname $vTcl(project,file)]_support.py"
    vTcl:get_import_name
    vTcl:py_source_frame $window   ""  "" ;# generates code for all the widgets.
    #vTcl:py_process_menubutton_list

    vTcl:get_top_level_configuration $window
    set my_procs ""
    set class_procs "\n"
    # if {$vTcl(global_variable)} {
    #     set set_vars [vTcl:py_build_set_Tk_var $vTcl(g_v_list)]
    # } else {
    #     set set_vars ""
    # }
    set set_vars ""
    set start_up_proc [vTcl:python_gui_startup $geom $title $classname]

    #set my_procs "def init():\n    pass\n"

    # Separate the proc's into those that go inside the class definition
    # from those that go outside.  Skip any without the 'py:' prefix.

    # The next loop and the call to create_functions generate the code
    # for the functions needed to make code executable.  They fall
    # into two cases, those which the user specified using the function
    # editor and those which PAGE detected from bindings or command
    # attributes. For the first case, all I do is to spit them out and
    # add their names to vTcl(proc_list) to preclude their being
    # generated twice. With the rest, I guess that I will have to
    # analyze the argument lists to generate parameter lists.

    # This deals with the proc which were generated with the Function
    # Editor.
    set init_found 0
    foreach i  [lsort $vTcl(procs)] {
        if {[string first "py:" $i] == -1} {
            continue
        }
        if {$i == "main"} {
            continue
        }
        if {$i == "vp_start_gui"} {
            continue
        }
        if {$i == "append_python_attributes"} {
            continue
        }
        if {$i == "py:init"} {
            set init_found 1
        }
        if {![regexp -nocase {vtcl} $i]} {
            # I just want the name so I pick up between the "def " and
            # the parameter list.
            set last [string first "(" $new_proc]
            set nn [string range $new_proc 4 [expr $last - 1]]
            set nn [string trim $nn]
            lappend vTcl(proc_list) $nn
            set p1 $last
            set p2 [string first ")" $new_proc]
            set parm_list [string range $new_proc [expr $p1 + 1] [expr $p2 - 1]]
            set type "global"
            if {$parm_list == "self"} {set type "class"}
            if {[string first "self," $parm_list] > -1} {set type "class"}
            if {$type == "global"} {
                # Global proc
                set new_proc [vTcl:python_subst_tabs $new_proc]
                set new_proc [vTcl:python_delete_lambda $new_proc]
                #set my_procs "$my_procs$new_proc\n"
                append my_procs "$new_proc\n"
            } else {
                # class procs
                set new_proc [vTcl:python_delete_lambda $new_proc]
                set new_proc [vTcl:python_subst_tabs $new_proc]
                set new_proc [vTcl:python_delete_leading_tabs $new_proc]
                set new_proc [vTcl:python_indent_lines $new_proc]
                #set class_procs "$class_procs$new_proc\n"
                append class_procs "$new_proc\n"
            }
        }
    }
    if {$init_found == 0} {
        if {$vTcl(import_module) == ""} {
            append my_procs "def init():\n    pass\n"
        }
    }
    # Auto-create import statments for support modules. NEEDS WORK 11/5/13
    foreach m $vTcl(funct_list) {
    }
    # Auto-create procs from vTcl(funct_list)
    vTcl:create_functions

    # Now I build the balloon stuff.
    # For time being I'm not supporting balloon creation.
    #set balloon_code [vTcl:create_balloon_code $vTcl(tops)]
    set balloon_code ""

    # Finally the ttk helper functions.
    if {$vTcl(add_helper_code)} {
        set ttk_helper [create_ttk_helper]
    } else {
        set ttk_helper ""
    }
    set source \
"#! /usr/bin/env python
#
# GUI module generated by PAGE version $vTcl(version)
# In conjunction with Tcl version $vTcl(tcl_version)
#    $vTcl(timestamp)
import sys

try:
    from Tkinter import *
except ImportError:
    from tkinter import *

try:
    import ttk
    py3 = 0
except ImportError:
    import tkinter.ttk as ttk
    py3 = 1"
    if {$vTcl(global_string) != ""} {
        append source \
"
$vTcl(global_string)
"
    }
    if {$start_up_proc != ""} {
        append source \
"
$start_up_proc
"
    }
    if {$set_vars != ""} {
        append source \
"
$set_vars
"
    }
    if {$my_procs != ""} {
        append source \
"
$my_procs
"
    }
    if {$vTcl(functions) != ""} {
    append source \
"
$vTcl(functions)
"
    }
    append source \
"
class $classname:
    def __init__(self, master=None):
$vTcl(toplevel_config)
$vTcl(py_initfunc)"
    if {$vTcl(class_functions) != ""} {
        append source \
"
$vTcl(class_functions)"
    }
# set source "$source
# $balloon_code
# $class_procs
# $ttk_helper
# $main
# "
    if {$balloon_code != ""} {
    append source \
"
$balloon_code
"
    }
    if {$class_procs != ""} {
    append source \
"
$class_procs
"
    }
    if {$ttk_helper != ""} {
    append source \
"$ttk_helper"
    }
    append source \
"
$main
"
    $vTcl(source_window)  delete 1.0 end
    $vTcl(source_window)  insert end $source
    set vTcl(py_source) $source
    vTcl:colorize_python
    set filename "[file rootname $vTcl(project,file)].py"
    set top .vTcl.py_console
    wm title $top "Python Console - $filename"
    update
    return
}

proc vTcl:create_functions {{gen gui}} {
    # Generate functions contained in vTcl(funct_list).
    # Called from vTcl:generate_python near line 270
    #if {$gen == "gui"} return
    global vTcl
    set vTcl(functions) ""
    set mod ""
    set name_list {}
    if {! [info exists vTcl(funct_list)]} {
        # Empty list
        return
    }
    set functions_generated {}
    #set vTcl(funct_list) [vTcl:lrmdups $vTcl(funct_list)]
    foreach fun [lsort $vTcl(funct_list)] {
        # separate name and argument list.
        set spot [string first "(" $fun]
        if {$spot > -1} {
            set name [string range $fun 0 [expr $spot - 1]]
            set arg_list [string range $fun $spot end]
        } else {
            set name $fun
            set arg_list ""
        }
        # see if in vTcl(proc_list).
        set fun [vTcl:python_delete_lambda $name]
        if {[lsearch -exact $vTcl(proc_list) $name] > -1} {continue}
        # see if we have already generated the function.
        if {[lsearch -exact $name_list $fun] > -1} {continue}
        if {[string first "self." $name] > -1} {
            # class method skip in support module
            if {$gen == "import"} continue
            # Remove leading "self."
            set cfun [string range $fun 5 end]
            set parms [prepare_parameter_list $arg_list "class"]
            append vTcl(class_functions) \
"
    def $cfun$parms:
            print ('self.$cfun')
            sys.stdout.flush()
"
        } elseif { [string first "." $name] > -1} {
            # Name refers to an imported module.
            continue
            set spot [string first "." $name]
            set mod [string range $name 0 $spot]
            set ifun [string range $name [expr $spot + 1] end]
            set parms [prepare_parameter_list $arg_list "global"]
            if {$gen == ""} {
                append vTcl(functions) \
"
def $ifun$parms:
        print ('$fun')
        sys.stdout.flush()
"
            }
        } else {
            if {$gen == "gui"} continue
            # It's a global function.
            # global function
            set mod $vTcl(import_name).
            set parms [prepare_parameter_list $arg_list "global"]
            # Adding the print statement and flush function below to
            # aid in verifying a GUI design.
            append vTcl(functions) \
"
def $fun$parms:
        print ('$mod$fun')
        sys.stdout.flush()
"
            set mod ""
        }

   lappend name_list $fun
    }

}

proc split_long_font_string {str} {
    global vTcl
    if {[lsearch $vTcl(standard_fonts) $str] > -1} {
        return "$str\n"
    }
    set font_stmt $str
    set len [string length $font_stmt]
    set brk [string wordstart $font_stmt 70]
    set pre_char [string index $font_stmt [expr $brk - 1]]
    if {$pre_char == "-"} {
        set brk [expr $brk - 1]
    }
    set part1 [string range $font_stmt 0 [expr $brk - 1]]
    set part2 [string range $font_stmt [expr $brk] end]
    set ret "$part1 \" + \\\n$vTcl(tab2)$vTcl(tab)\"$part2\n"
    return $ret
}

proc color_value {color} {
    if {[string first "#" $color] > -1} {
        return $color
    } else {
        return [::colorDlg::colorToPoundRgb $color]
    }
}

proc color_comment {color} {
    if {[string first "#" $color] > -1} {
        lassign [FindClosestNamedColor $color] name dist
        if {$dist == 0} {
            return "# X11 color: '$name'"
        } else {
            return "# Closest X11 color: '$name'"
        }
    } else {
        return "# X11 color: [::colorDlg::colorToHex $color]"
    }
}

proc check_default_font {font} {
    # Determine if font is one of the standard fonts, if so just
    # return the font name in quotes.  Oct 2013
    global vTcl
    if {$font in $vTcl(standard_fonts)} {
        return "\"$font\""
    } else {
        return $font
    }
    # if {[string range $font 0 1] == "Tk"} {
    #     return "\"$font\""
    # } else {
    #     return $font
    # }
}

proc vTcl:get_top_level_configuration {window} {
    # Get configure information for the top level window.
    global vTcl
    set vTcl(toplevel_config) ""
    # First put out the color definitions.

    append vTcl(toplevel_config) \
      "$vTcl(tab2)_bgcolor = '$vTcl(actual_gui_bg)' \
                       [color_comment $vTcl(actual_gui_bg)]\n"
        #"$vTcl(tab2)_bgcolor = '$vTcl(bgcolor)'\n"
    append vTcl(toplevel_config) \
      "$vTcl(tab2)_fgcolor = '$vTcl(actual_gui_fg)' \
                       [color_comment $vTcl(actual_gui_fg)]\n"

    vTcl:comp_color        ;# Puts out stmt for complement color.
    vTcl:analog_colors     ;# Puts out stmts for analog colors.
    if {[::colorDlg::dark_color $vTcl(pr,guicomplement_color)]} {
        set comp_fg "white"
    } else {

        set comp_fg "black"
    }


    # Put out the fonts actually used.
    set putout []
    foreach f [lsort -unique $vTcl(fonts_used)] {
        if {[string range $f 0 1] == "Tk"} {
            # If f is a default font then do nothing.
            continue
        }
        if {[catch {
            set font_cfg [font configure $f]}]} {
            # font configure failed.
            set font_cfg "TkDefaultFont"
        }
        #set font_string [vTcl:python_menu_font $font_cfg]
        append vTcl(toplevel_config) \
              [split_long_font_string "$vTcl(tab2)$f = \"$font_cfg\""]
                 #"$vTcl(tab2)$f = $font_string\n"
        lappend putout $f
    }

    if {$vTcl(using_ttk)} {
        append vTcl(toplevel_config) \
            "$vTcl(tab2)self.style = ttk.Style()\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)if sys.platform == \"win32\":\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)$vTcl(tab)self.style.theme_use('winnative')\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)self.style.configure('.',background=_bgcolor)\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)self.style.configure('.',foreground=_fgcolor)\n"
        if {[lsearch $vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)] > -1} {
          append vTcl(toplevel_config) \
              "$vTcl(tab2)self.style.configure('.',font=[check_default_font \
                            $vTcl(actual_gui_font_dft_name)])\n"
#          "$vTcl(tab2)self.style.configure('.',font=$vTcl(actual_gui_font_dft_name))\n"
#            "$vTcl(tab2)self.style.configure('.',font=gui_font_dft)\n"
        }
       append vTcl(toplevel_config) \
          "$vTcl(tab2)self.style.map('.',background=\n"
       append vTcl(toplevel_config) \
    "$vTcl(tab2)$vTcl(tab)\[('selected', _compcolor), ('active',_ana2color)\])\n"
        if {[::colorDlg::dark_color $vTcl(pr,guianalog_color_m)]} {
            append vTcl(toplevel_config) \
          "$vTcl(tab2)self.style.map('.',foreground=\n"
            append vTcl(toplevel_config) \
    "$vTcl(tab2)$vTcl(tab)\[('selected', '$comp_fg'), ('active','white')\])\n"
        }
     }
    # Obtain a list of all attributes of the top level window.

    set opt [$window configure]
    # Above returns a list of lists. The values are:
    #              argvName,  dbName,  dbClass,  defValue, and current value
    foreach op $opt {
        foreach {o x y d v} $op {}
        set v [string trim $v]
        if {$d == $v} continue   ;# If value == default value bail.
        set len [string length $o]
        set sub [string range $o 1 end]
         switch -exact -- $sub {
             padX -
             padY -
             dropdown -
             editable -
             orient -
             fancy {
             }
             menu {
             }
             background {
                 append vTcl(toplevel_config) \
                     "$vTcl(tab2)master.configure($sub=_bgcolor)\n"
             }
             default {
                 append vTcl(toplevel_config) \
                     "$vTcl(tab2)master.configure($sub=\"$v\")\n"
             }
        }
    }
}

proc prepare_parameter_list {arg_list type} {
    # Auto gen the parameter list.  We can't just use the parameter
    # given in the command clause because they may be constants.
    if {[string length $arg_list] == 0} { # Rozen change 2 into 0
        if {$type == "class"} {
            return "(self)"
        } else {
            return "()"
        }
    }
    set args "("            ;# Open the parenthesized list.
    if {$type == "class"} {
        append args "self,"
    }
    set argl [split $arg_list "(,)"]  ;# Get a list of the arguments
    set zlist [lrange $argl 1 end-1]  ;# Throw out the "(" and ")" list elements
    set c 1
    foreach z $zlist {
        append args p$c ","
        incr c
    }
    set args [string range $args 0 end-1]  ;# Get rid of last ","
    append args ")"                        ;# Close the parenthesized list.
    return $args
}

proc create_ttk_helper {} {
    global vTcl
    set ttk_helper \
"
# The following code is added to facilitate the Scrolled widgets you specified.
class AutoScroll(object):
    '''Configure the scrollbars for a widget.'''

    def __init__(self, master):
        #  Rozen. Added the try-except clauses so that this class
        #  could be used for scrolled entry widget for which vertical
        #  scrolling is not supported. 5/7/14.
        try:
            vsb = ttk.Scrollbar(master, orient='vertical', command=self.yview)
        except:
            pass
        hsb = ttk.Scrollbar(master, orient='horizontal', command=self.xview)

        #self.configure(yscrollcommand=self._autoscroll(vsb),
        #    xscrollcommand=self._autoscroll(hsb))
        try:
            self.configure(yscrollcommand=self._autoscroll(vsb))
        except:
            pass
        self.configure(xscrollcommand=self._autoscroll(hsb))

        self.grid(column=0, row=0, sticky='nsew')
        try:
            vsb.grid(column=1, row=0, sticky='ns')
        except:
            pass
        hsb.grid(column=0, row=1, sticky='ew')

        master.grid_columnconfigure(0, weight=1)
        master.grid_rowconfigure(0, weight=1)

        # Copy geometry methods of master  (took from ScrolledText.py)
        if py3:
            methods = Pack.__dict__.keys() | Grid.__dict__.keys() \\
                  | Place.__dict__.keys()
        else:
            methods = Pack.__dict__.keys() + Grid.__dict__.keys() \\
                  + Place.__dict__.keys()

        for meth in methods:
            if meth\[0\] != '_' and meth not in ('config', 'configure'):
                setattr(self, meth, getattr(master, meth))

    @staticmethod
    def _autoscroll(sbar):
        '''Hide and show scrollbar as needed.'''
        def wrapped(first, last):
            first, last = float(first), float(last)
            if first <= 0 and last >= 1:
                sbar.grid_remove()
            else:
                sbar.grid()
            sbar.set(first, last)
        return wrapped

    def __str__(self):
        return str(self.master)

def _create_container(func):
    '''Creates a ttk Frame with a given master, and use this new frame to
    place the scrollbars and the widget.'''
    def wrapped(cls, master, **kw):
        container = ttk.Frame(master)
        return func(cls, container, **kw)
    return wrapped"

    if {[lsearch $vTcl(helper_list) Scrolledtext] > -1} {
        append ttk_helper \
"

class ScrolledText(AutoScroll, Text):
    '''A standard Tkinter Text widget with scrollbars that will
    automatically show/hide as needed.'''
    @_create_container
    def __init__(self, master, **kw):
        Text.__init__(self, master, **kw)
        AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledlistbox] > -1} {
        append ttk_helper \
"

class ScrolledListBox(AutoScroll, Listbox):
    '''A standard Tkinter Text widget with scrollbars that will
    automatically show/hide as needed.'''
    @_create_container
    def __init__(self, master, **kw):
        Listbox.__init__(self, master, **kw)
        AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledentry] > -1} {
        append ttk_helper \
"

class ScrolledEntry(AutoScroll, Entry):
    '''A standard Tkinter Entry widget with a horizontal scrollbar
    that will automatically show/hide as needed.'''
    @_create_container
    def __init__(self, master, **kw):
        Entry.__init__(self, master, **kw)
        AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledcombo] > -1} {
        append ttk_helper \
"

class ScrolledCombo(AutoScroll, ttk.Combobox):
    '''A ttk Combobox with a horizontal scrollbar that will
    automatically show/hide as needed.'''
    @_create_container
    def __init__(self, master, **kw):
        ttk.Combobox.__init__(self, master, **kw)
        AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledtreeview] > -1} {
        append ttk_helper \
"

class ScrolledTreeView(AutoScroll, ttk.Treeview):
    '''A standard ttk Treeview widget with scrollbars that will
    automatically show/hide as needed.'''
    @_create_container
    def __init__(self, master, **kw):
        ttk.Treeview.__init__(self, master, **kw)
        AutoScroll.__init__(self, master)
"
    }
    return $ttk_helper
}

proc vTcl:py_build_set_Tk_var {var_list {new yes}} {
    # Build the function which will initialize the Tkinter variables.
    #if {$gen == "gui"} return
    global vTcl
dargs
    if {$new == "yes"} {
        append ret \
"def set_Tk_var():
    # These are Tk variables used passed to Tkinter and must be
    # defined before the widgets using them are created."
    }
    set vars {}
    foreach {v m} $var_list {
        set vv $v
        set i [string first . $v]
        if {$i > -1} {
            set v [string range $v  [expr $i + 1] end]
        }
        if {[lsearch -exact $vars $v] == -1} {
            #if {[string first "." $v] > -1 && $gui == "gui"} { return }
            if {$new == "yes"} {
                append ret \
"
    global $v
    $v = ${m}()
"
            } else {
                append ret \
"    global $v
    $v = ${m}()
"
            }
        lappend vars $v

        }
    }
#    append ret "# End of Tk variables\n"
    return $ret
}


proc vTcl:colorize_python {} {
    global vTcl
    vTcl:syntax_color $vTcl(source_window)
}

proc vTcl:save_python_code {} {
    global vTcl
    # We come here when the user hits the save button on the Python
    # Console. From here we either save the GUI module or the support
    # module depending on the value of vTcl(python_module) which was
    # set in either vTcl:generate_python_UI or
    # vTcl:generate_python_support.
    if {$vTcl(python_module) == "Support"} {
         vTcl:save_support_file
    }
    if {$vTcl(python_module) == "GUI"} {
         vTcl:save_GUI_file
    }
}

proc vTcl:save_GUI_file {} {
    global vTcl
    # First we make a backup copy of any existing Python file popping
    # it onto a stack of backup files and then we write the new
    # version.  This saves up to five versions.

    # If the module most recently generated is the support module, it
    # was saved as part of the generation so there is nothing to do
    # here.
    if {$vTcl(python_module) == "Support"} return
    set filename "[file rootname $vTcl(project,file)].py"
    vTcl:save_python_file $filename
    return 0
}

proc vTcl:py_source_frame {window prefix parentframe} {
    global vTcl
    # Starting entry for analyzing and creating the window.
    set class [$window cget -class]
    if {$class == "Toplevel"} {
        set menu [$window cget -menu]
        set vTcl(toplevel_menu) $menu
    }
    if {$prefix!=""} {
        set prefix $prefix\_
    }
    set vTcl(balloon_widgets) ""
    foreach widget [winfo children $window] { # Rozen
        #vTcl:python_source_widget $widget $prefix $parentframe
        vTcl:python_source_widget $widget $prefix $window
    }
}

proc vTcl:py_get_command_parameters {cmdpar} {
    # Confusing. Rozen
    global vTcl
    upvar cmdname lname
    upvar cmdbody lbody
    set lname {}
    set lbody {}
    catch {
        set lname $cmdpar
        if {$lname!=""} {
            foreach line [split $lname "\n"] {
                set line [string trim $line]
                if {[info procs $lname]!=""} {
                    set lbody [info body $lname]
                }
            }
        }
    }

}

proc vTcl:python_parse_menu {menubutton widname {suffix m}} {
    global vTcl
    foreach widget [winfo children $menubutton] {
        if {[winfo class $widget]=="Menu"} {
            set nritems [$widget index end]
            for {set i 0} {$i<=$nritems} {incr i} {
                switch [$widget type $i] {
                    command {
                        vTcl:py_get_command_parameters \
                                [$widget entrycget $i -command]
                        if {$cmdname==""} {
                            set cmdname "$widname\_$i\_click"
                        }
                        append vTcl(py_initfunc) \
                         "$vTcl(tab2)self.$widname\_m$suffix.add_command(label="
                        append vTcl(py_initfunc) \
                                "\"[$widget entrycget $i -label]\","
                        # added to add the accelerator capability.
                        if {[$widget entrycget $i -accel] != ""} {
                            append vTcl(py_initfunc) \
                                    "accel=\"[$widget entrycget $i -accel]\","
                        }
                        append vTcl(py_initfunc) \
                                "command=$cmdname,underline=0)\n"
                    set v $cmdname
                    if {[string first "(" $v] == -1} {
                        append v "()"
                    }
                    lappend vTcl(funct_list) $v
                    }
                    checkbutton { # Like to put in more options
                        vTcl:py_get_command_parameters \
                                [$widget entrycget $i -command]
                        if {$cmdname == ""} {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_checkbutton(label=\"[$widget entrycget $i -label]\""
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                   "accel=\"[$widget entrycget $i -accel]\""
                            }
                        } else {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_checkbutton(label=\"[$widget entrycget $i -label]\",command=$cmdname"
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                   ",accel=\"[$widget entrycget $i -accel]\""
                            }
                        }
                        append vTcl(py_initfunc) ")\n"
                    }
                    radiobutton { # Like to put in more options
                        vTcl:py_get_command_parameters \
                                [$widget entrycget $i -command]
                        if {$cmdname == ""} {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_radiobutton(label=\"[$widget entrycget $i -label]\""
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                    ",accel=\"[$widget entrycget $i -accel]\""
                            }
                        } else {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_radiobutton(label=\"[$widget entrycget $i -label]\",command=$cmdname"
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                    ",accel=\"[$widget entrycget $i -accel]\""
                            }                        }
                        append vTcl(py_initfunc) ")\n"
                    }
                    separator {
                        append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname\_m$suffix.add_separator()\n"
                    }
                    cascade {
                        set incsuffix ""
                        append incsuffix "m$suffix" "_cas$suffix"
                        append vTcl(py_initfunc) \
                                "$vTcl(tab2)self.$widname\_$incsuffix = "
                        append vTcl(py_initfunc) \
                                "Menu(self.$widname\_m$suffix)\n"
                        append vTcl(py_initfunc) \
                                "$vTcl(tab2)self.$widname\_m$suffix.add_cascade(label=\"[$widget entrycget $i -label]\","
                        if {[$widget entrycget $i -accel] != ""} {
                            append vTcl(py_initfunc) \
                                    "accel=\"[$widget entrycget $i -accel]\","
                        }
                        append vTcl(py_initfunc) \
                                "menu=self.$widname\_$incsuffix)\n"
                        set arg_suffix ""
                        append arg_suffix $suffix "_cas$suffix"
                        vTcl:python_parse_menu $widget $widname \
                                $arg_suffix
                    }
                }
            }
        }
    }
}

proc vTcl:python_parse_combo_menu {menubutton widname} {
    global vTcl
    global suffix
    foreach widget [winfo children $menubutton] {
        set suffix [expr $suffix + 1]
        if {[winfo class $widget]=="Menu"} {
            set nritems [$widget index last]
            for {set i 0} {$i<=$nritems} {incr i} {
                set suffix [expr $suffix + 1]
                if {[$widget type $i]=="command"} {
                    vTcl:py_get_command_parameters \
                            [$widget entrycget $i -command]
                    append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname\.add_command(\"z_$suffix\",label="
                    append vTcl(py_initfunc) \
                            "\"[$widget entrycget $i -label]\","
                   append vTcl(py_initfunc) \
                            "underline=0)\n"
                }
                if {[$widget type $i]=="separator"} {

                    append vTcl(py_initfunc) \
                            "$vTcl(tab)$vTcl(tab)self."
                    append vTcl(py_initfunc) \
                            "$widname\.add_separator(\"z_$suffix\")\n"
                }
            }
        }
    }
}

proc vTcl:python_quick_run {} {
    # Save the current content of source window then test if we have
    # both GUI and support modules saved and then execute the GUI
    # module.
    global vTcl
    global tcl_platform
    update
    vTcl:save_python_code
    update
    # Test to see that we have both a GUI module and a support module!
    set fg "[file rootname $vTcl(project,file)].py"
    set fs "[file rootname $vTcl(project,file)]_support.py"
    set nogui [expr ![file exists $fg]]
    set nosupp [expr ![file exists $fs]]
    # if {![info exists $fg]} {
    #     set nogui 1
    # }
    # if {![info exists $fs]} {
    #     set nosupp 1
    # }
    if {$nogui == 1} {
        # set choice [tk_messageBox -title Error -message \
        #     "No GUI module has been created and saved." \
        #     -icon warning \
        #     -type ok]
        set choice [tk_dialog .foo "ERROR" \
                        "No GUI module has been created and saved." \
                        questhead 0 "OK"]
        return
    }
    if {$nosupp == 1} {
        # set choice [tk_messageBox -title Error -message \
        #     "No support module has been created and saved." \
        #     -icon warning \
        #     -type ok]
        set choice [tk_dialog .foo "ERROR" \
                        "No support module has been created and saved." \
                        questhead 0 "OK"]
        return
    }
    # Test to see if the GUI python module has been generated after
    # the latest GUI change.
    if {$vTcl(gui_py_change_time) < $vTcl(gui_change_time)} {
        set question "GUI definition has been changes since GUI module created. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
                         questhead 0 "Cancel" "Proceed"]
        if {$choice == 0} return
    }
    # Test to see if support module needs updates.
    set window $vTcl(tops)
    vTcl:determine_updates $window
    if {([info exists vTcl(must_add_vars)]) || \
            ([info exists vTcl(must_add_procs)])} {
        # There are possible updates.
        set question "Support module missing available updates of functions or TK variables. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
             questhead 0 "Cancel" "Proceed"]
        if {$choice == 0} return
    }
    switch $tcl_platform(platform) {
        unix {
           vTcl:python_run_unix
        }
        default {
            vTcl:python_run
        }
    }

}

proc vTcl:python_run {} {
    global vTcl
    global tcl_platform
    set root_name [file rootname $vTcl(project,file)]
    set pc .vTcl.py_console
    $pc configure -cursor watch
    set pc_output $vTcl(output_window)
    $pc_output delete 1.0 end
    $pc_output insert end "Running $root_name.py ...\n"
    update
    file delete $root_name.output
    if { [catch {set res \
         "[exec python $root_name.py >>& $root_name.output]"} result]} {
        puts stderr $result
    } else {
    }
    #catch {set res \
            "[exec python $root_name.py >>& $root_name.output]"}
    if {[file exists $root_name.output] && [file size $root_name.output] > 0} {
        set fid [open $root_name.output r]
        while {![eof $fid]} {
            gets $fid line
            #$pc_output subwidget text insert end "$line\n"
            $pc_output insert end "$line\n"
        }
        close $fid
    } else {
        #$pc_output subwidget text insert end "No Output"
        $pc_output insert end "No Output"
    }
    $pc configure -cursor {}
    update
}

proc vTcl:python_run_unix {} {
    global tcl_platform
    # Executes the generated GUI code by opening a pipe to a python
    # process which executes the saved generated python GUI code.
    global vTcl
    set pc .vTcl.py_console
    $pc configure -cursor watch
    set pc_output $vTcl(output_window)
    $pc_output delete 1.0 end
    set root_name [file rootname $vTcl(project,file)]
    $pc_output insert end "Running $root_name.py ...\n"
    update
    #set cmd "python $root_name.py 2>&1"
    set cmd "python $root_name.py"
    # Start the pipe, vTcl(fifo), to the python interpret
    # runninng the GUI
    set vTcl(fifo) [open "|$cmd |& cat" {RDWR}]
    # Configure buffering and blocking of the pipe
    fconfigure $vTcl(fifo) -buffering line -blocking 0
    # Link files events, such as close and flush, to the proc
    # vTcl:read_fifo.
    fileevent $vTcl(fifo) readable vTcl:read_fifo
}
proc vTcl:python_run_both {pcommand} {
    global tcl_platform
    # Executes the generated GUI code by opening a pipe to a python
    # process which executes the saved generated python GUI code.
    # NEEDS WORK - doesn't look like I ever call this function.
    global vTcl
    set pc .vTcl.py_console
    $pc configure -cursor watch
    set pc_output $vTcl(output_window)
    $pc_output delete 1.0 end
    set root_name [file rootname $vTcl(project,file)]
    $pc_output insert end "Running $root_name.py ...\n"
    update
    #set cmd "python $root_name.py 2>&1"
    set cmd "python $root_name.py"
    # Start the pipe, vTcl(fifo), to the python interpreter process
    # runninng the GUI
    set vTcl(fifo) [open "|$cmd |& $pcommand" {RDWR}]
    # Configure buffering and blocking of the pipe
    fconfigure $vTcl(fifo) -buffering line -blocking 0
    # Link files events, such as close and flush, to the proc
    # vTcl:read_fifo.
    fileevent $vTcl(fifo) readable vTcl:read_fifo
}

proc vTcl:read_fifo {} {
    # Reads the output of the execution pipe whenever a file event
    # such as close or buffer flush occurs. Mated with
    # vTcl:python_run. It adds the line read to output window of the
    # py_console.
    global vTcl
    set pc_output $vTcl(output_window)
    if {[gets $vTcl(fifo) line] >= 0} {
        $pc_output insert end "$line\n"
    }
    if {[eof $vTcl(fifo)]} {
        close $vTcl(fifo)
        $pc_output insert end "Execution terminated.\n"
    }
    update
}



proc vTcl:Window.vTcl.py_console {} {
    global vTcl
    set base .vTcl.py_console
    if {[winfo exists $base]} {
        wm deiconify $base; raise .vTcl.py_console
        return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background $vTcl(pr,bgcolor) ;# 11/22/12
    wm focusmodel $top passive
    wm geometry $top 800x1000+413+54; update
    wm maxsize $top 1905 1170
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "Python Console"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toolorplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ttk::style configure PyConsole.TLabelframe \
        -background $vTcl(pr,bgcolor) ;# 11/22/12
    ttk::style configure PyConsole.TLabelframe.Label \
        -foreground $vTcl(pr,fgcolor) \
        -background $vTcl(pr,bgcolor) ;# 11/22/12
    ttk::style configure PyConsole.TPanedwindow \
        -background $vTcl(pr,bgcolor) ;# 11/22/12
    ttk::style configure PyConsole.TSizegrip \
        -background $vTcl(pr,bgcolor) ;# 11/22/12

    ttk::style configure Horizontal.TScrollbar \
        -background $vTcl(pr,bgcolor)  -foreground $vTcl(pr,fgcolor)
    ttk::style configure Vertical.TScrollbar \
        -background $vTcl(pr,bgcolor) -foreground $vTcl(pr,fgcolor)

    #set analog_colors [::colorDlg::analogous_colors  $vTcl(pr,bgcolor)]
    #lassign $analog_colors ab_color_p ab_color_m



    # ttk::style configure TLabelframe \
    #
    # ttk::style configure TLabelframe.Label \
    #     -background $vTcl(pr,bgcolor) ;# 11/22/12
    # ttk::style configure TScrollbar \
    #     -background $vTcl(pr,bgcolor) ;# 11/22/12
    # ttk::style configure TPanedwindow \
    #     -background $vTcl(pr,bgcolor) ;# 11/22/12

    # ttk::style configure TSizegrip \
    #     -background $vTcl(pr,bgcolor) ;# 11/22/12

#    grid [ttk::sizegrip $top.sz -style "PyConsole.TSizegrip"] \
#        -column 999 -row 999 -sticky se ;#   11/27/12

    # 6/9/09
    ttk::panedwindow $top.tPa42 -orient vertical -style "troughcolorPyConsole.TPanedwindow"
    #ttk::panedwindow $top.tPa42 \
    #    -orient vertical -width 800 -height 900
    ttk::labelframe $top.tPa42.f1 \
        -style "PyConsole.TLabelframe" \
        -text {Generated Python} ;# -height 750

    $top.tPa42 add $top.tPa42.f1

    ttk::labelframe $top.tPa42.f2 \
        -style "PyConsole.TLabelframe" \
        -text {Execution Output} ;# -height 100
    $top.tPa42 add $top.tPa42.f2

    text $top.tPa42.f1.01  -background white -foreground black \
         -xscrollcommand "$top.tPa42.f1.02 set"\
         -yscrollcommand "$top.tPa42.f1.03 set" \
         -insertborderwidth 3

    set vTcl(code_window) $top.tPa42.f1.01
    ttk::scrollbar $top.tPa42.f1.02  -command "$top.tPa42.f1.01 xview" \
        -orient horizontal \
        -style TScrollbar
#-troughcolor green \
# -activebackground plum \
#        -background $vTcl(pr,bgcolor) ;# 11/22/12

    ttk::scrollbar $top.tPa42.f1.03  -command "$top.tPa42.f1.01 yview" \
        -style TScrollbar
#-troughcolor green \
# -activebackground plum \
#        -background $vTcl(pr,bgcolor) ;# 11/22/12

    grid $top.tPa42.f1.01  -in $top.tPa42.f1 -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -sticky nesw
    grid $top.tPa42.f1.02  -in $top.tPa42.f1 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $top.tPa42.f1.03  -in $top.tPa42.f1 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    # Rozen Added row, column config stuff so that it would resize properly.
    grid rowconfigure $top.tPa42.f1 0 -weight 1
    grid columnconfigure $top.tPa42.f1 0 -weight 1

    # Bindings for the mousewheel.
    bind $top.tPa42.f1.01 <Button-4> [list %W yview scroll -5 units]
    bind $top.tPa42.f1.01 <Button-5> [list %W yview scroll 5 units]

    text $top.tPa42.f2.01  -background white -foreground black \
         -xscrollcommand "$top.tPa42.f2.02 set"\
         -yscrollcommand "$top.tPa42.f2.03 set"

    ttk::scrollbar $top.tPa42.f2.02  -command "$top.tPa42.f2.01 xview" \
        -orient horizontal \
        -style TScrollbar
#-troughcolor green \
# -activebackground plum \
#        -background $vTcl(pr,bgcolor) ;# 11/22/12

    ttk::scrollbar $top.tPa42.f2.03  -command "$top.tPa42.f2.01 yview" \
        -style TScrollbar
#\
#-troughcolor green \
# -activebackground plum \
#        -background $vTcl(pr,bgcolor) ;# 11/22/12



    grid $top.tPa42.f2.01  -in  $top.tPa42.f2 -column 0 -row 0 -columnspan 1 \
         -rowspan 1 -sticky nesw
    grid $top.tPa42.f2.02  -in $top.tPa42.f2 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $top.tPa42.f2.03  -in $top.tPa42.f2 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    # Rozen Added row, column config stuff so that it would resize properly.
    grid rowconfigure $top.tPa42.f2 0 -weight 1
    grid columnconfigure $top.tPa42.f2 0 -weight 1

    # Bindings for the mousewheel.  Both of the following approaches work.
    bind $top.tPa42.f2.01 <Button-4> [list %W yview scroll -5 units]
    bind $top.tPa42.f2.01 <Button-5> [list %W yview scroll 5 units]

    # Hopefully this will help the mousewheel in Windows by setting the focus.
    bind $top.tPa42.f1.01 <Enter> {focus %W}
    bind $top.tPa42.f2.01 <Enter> {focus %W}

    frame $top.butframe  -height 40  ;#     # 6/9/09
    button $top.butframe.but33 \
        -text Save -command "vTcl:save_python_code" \
        -background $vTcl(pr,bgcolor) -foreground $vTcl(pr,fgcolor) ;# 11/22/12

    button  $top.butframe.but34 \
        -text Run -command "vTcl:python_quick_run" \
        -background $vTcl(pr,bgcolor) -foreground $vTcl(pr,fgcolor) \

    button  $top.butframe.but35 \
        -text Close -command "Window hide $base" \
        -background $vTcl(pr,bgcolor)  -foreground $vTcl(pr,fgcolor) ;# 11/22/12

    place $top.butframe.but33 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.06 -y 5
    place $top.butframe.but34 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.44 -y 5
    place $top.butframe.but35 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.8  -y 5
    place [ttk::sizegrip $top.sz -style "PyConsole.TSizegrip"] \
        -relx 1.0 -rely 1.0 -anchor se
#grid [ttk::sizegrip $top.butframe.sz] -column 999 -row 999 -sticky se
#pack [ttk::sizegrip $top.butframe.sz] -side right -anchor se
#place [ttk::sizegrip $top.butframe.sz] -in $top.butframe \
-anchor se



    ####################
    # SETTING GEOMETRY #
    ####################

    # Added 6/9/09
    grid $top.tPa42 -in $top -column 0 -row 0 -sticky news
    grid $top.butframe -in $top -column 0 -row 1 -sticky news
    grid rowconfigure $top 0 -weight 1
    grid columnconfigure $top 0 -weight 1

    # 6/9/09
    #pack $top.tPa42 -in $top -expand true -fill both -side top
    #pack $top.butframe -in $top  -fill x -side bottom

    # The purpose of the following is to overwrite the geometry stuff
    # above with the geometry which has been saved in the preferences.
    #puts " vTcl(geometry,.vTcl.py_console) = $vTcl(geometry,.vTcl.py_console)"
    catch {wm geometry .vTcl.py_console $vTcl(geometry,.vTcl.py_console)}

    set old_geometry [wm geometry .vTcl.py_console]
    set old_height [split $old_geometry "x+"]
    set old_height [lindex $old_height 1]
    set vTcl(old_height) old_height


    bind $base <Configure> {
        set new_geometry [wm geometry .vTcl.py_console]
        set new_height [split $new_geometry "x+"]
        set new_height [lindex $new_height 1]
        if {$new_height != $vTcl(old_height)} {
            set pos [expr int($new_height * 0.8)]
            set pos [min $pos [expr int($new_height) - 150]]
            .vTcl.py_console.tPa42 sashpos 0 $pos
        }
        set vTcl(old_height) $new_height
    }

    focus $top.butframe.but34     ;# Rozen 10/20/12
    update idletasks

    if {[info exists vTcl(sash)]} {
        $top.tPa42 sashpos 0 [expr int($vTcl(sash))]
    } else {
        set size [wm geometry $top]
        set size [split $size "x+"]
        set pos [lindex $size 1]
        set pos [expr int($pos * 0.8)]
        $top.tPa42 sashpos 0 $pos
    }

    vTcl:FireEvent $base <<Ready>>

    bind $base <Control-c> {vTcl:quit}
    bind $base <Control-q> {vTcl:quit}
    ;# Rozen 3/31/14
    bind $base <Control-p> {vTcl:generate_python_UI}
    bind $base <Control-i> {vTcl:generate_python_support}
    bind $base <Control-r> {vTcl:python_quick_run}


    set vTcl(source_window)   $top.tPa42.f1.01
    set vTcl(output_window)   $top.tPa42.f2.01
}


proc  vTcl:build_treeview_support {target widname cmdname widclass} {
    # This routine rounds out the support of the scrolledtreeview by
    # creating columns, and assigning them characteristics.
    global vTcl
    set cols [$target cget -columns]
    set column_names [concat "#0" $cols]
    foreach c $column_names {
            set heading($c) [$target heading $c]
            set column($c) [$target column $c]
    }
    foreach c $column_names {
        foreach {o v} $heading($c) {
            if {$v == ""} continue
            if {[string range $o 0 0] == "-"} {
                set sub [string range $o 1 end]
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.heading(\"$c\",$sub=\"$v\")\n"
        }
        foreach {o v} $column($c) {
            if {$v == ""} continue
            if {$o == "-id"} continue
            if {[string range $o 0 0] == "-"} {
                set sub [string range $o 1 end]
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.column(\"$c\",$sub=\"$v\")\n"
        }
    }
}

proc vTcl:prepend_import_name {cmd_exp} {
    global vTcl
    if {[string first "." $cmd_exp] > -1} {
        # String already is qualified with a module name, possibly "self".
        return $cmd_exp
    }
    # I assume that the $cmd_exp has already been trimmmed.
    if {[string first "lambda" $cmd_exp] == 0} {
        # Extract the non lambda part of the function name
        set index [string first ":" $cmd_exp]
        set exp [expr $index + 1]
        # r will be the non lambda part
        set r [string range $cmd_exp [expr $index + 1] end]
        set r [string trim $r]
        #set new_cmd [string replace $cmd_exp $exp $exp $vTcl(import_name).]
        set new_cmd [string replace $cmd_exp $exp end $vTcl(import_name).$r]
    } else {
        set new_cmd $vTcl(import_name).$cmd_exp
    }
    return $new_cmd
}

proc vTcl:python_configure_widget {widget widname cmdname \
                                       widclass {name ""} {menu_name ""}} {
    global vTcl
    global color
    # Obtains a list of all attributes of the widget, checks to see if
    # the current value differs from the default value.  If it does, then
    # puts adds the configuration statement for that value.
    set opt [$widget configure]
    # Is activeforeground in the list?
    set active_fg_there 0
    foreach op $opt {
        foreach {o x y d v} $op {}
        set v [string trim $v]
        if {$o == "-activeforeground"} {
            set active_fg_there 1
        }
    }

    # Above returns a list of lists. The values are:
    #              argvName,  dbName,  dbClass,  defValue, and current value
    if {$name == ""} {
        set name "self.$widname"
    }
    set class [vTcl:get_class $widget]
    foreach op $opt {
        foreach {o x y d v} $op {}
        set v [string trim $v]
        if {$d == $v} {
            continue   ;# If value == default value bail.
        }
        # The following is here because the TRadiobutton has a really
        # weird default value.
        if {$x == "variable"} {
            if {$v == ""} continue
        }
        set len [string length $o]
        set sub [string range $o 1 end]
        switch -exact -- $sub {
            padX -
            padY -
            dropdown -
            editable -
            height -
            fancy {
            }
            xscrollcommand -
            yscrollcommand {

                # There is a question here whether I really want
                # to support separate scrollbars.  I think that now
                # the answer is no.

            }
            textvariable {
                if {[string first self. $v] == 0} {
                    if {[lsearch -exact $vTcl(l_v_list) $v] == -1} {
                        # Class variable.
                        append vTcl(py_initfunc) \
                        "$vTcl(tab2)$v = StringVar()\n"
                        lappend vTcl(l_v_list) $v
                    }
                #} elseif {[string first . $v] >= 0} {
                #    # Variable in imported module
                #    set vTcl(supp_variables) 1
                } else {
                    # Global variable
                    if {[lsearch -exact $vTcl(g_v_list) $v] == -1} {
                        set vTcl(global_variable) 1
                        set l [list $v "StringVar"]
                       #lappend vTcl(g_v_list) $l
                        lappend vTcl(g_v_list) $v StringVar
                    }
                }
                #                    append vTcl(py_initfunc) \tMe36_m
                #append vTcl(py_initfunc) \
                #    "$vTcl(tab2)$self..configure($sub=$v)\n"
                set v [vTcl:prepend_import_name $v]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure($sub=$v)\n"
                #lappend  vTcl(g_v_list) $v $m  CHECK This OUT!! What is $m.
            }
            listvariable -
            variable {
                if {[string bytelength $v] == 0} {
                    vTcl:error "No variable specified for $widget"
                }
                if {[string first :: $v] != -1} {
                    vTcl:error "Illegal variable $v specified in $widget"
                }
                # First some code to see if class or global variable
                # is wanted, I will tell by checking if 'self.' is
                # part of the name.
                if {[string first self. $v] == 0} {
                    # Class variable.
                    if {[lsearch -exact $vTcl(l_v_list) $v] == -1} {
                        switch $widclass {
                            "Scrolledlistbox" -
                            "Checkbutton" -
                            "TCheckbutton" -
                            "Radiobutton" -
                            "TRadiobutton" {
                                append v
                                    "$vTcl(tab2)$v = StringVar()\n"
                            }
                            "TScale" -
                            "Scale" {
                                append vTcl(py_initfunc) \
                                    "$vTcl(tab2)$v = DoubleVar()\n"
                            }
                            "TProgressbar" {
                                append vTcl(py_initfunc) \
                                    "$vTcl(tab2)$v = IntVar()\n"
                            }
                        }
                        lappend vTcl(l_v_list) $v
                    }
                #} elseif {[string first . $v] >= 0} {
                #    # Variable in imported module
                #    set vTcl(supp_variables) 1
                } else {
                    # Global variable
                    if {[lsearch -exact $vTcl(g_v_list) $v] == -1} {
                        set vTcl(global_variable) 1
                        switch $widclass {
                            "Scrolledlistbox" -
                            "Checkbutton" -
                            "TCheckbutton" -
                            "Listbox" -
                            "Radiobutton" -
                            "TRadiobutton" {
                                set m StringVar
                            }
                            "TScale" -
                            "Scale" {
                                set m DoubleVar
                            }
                            "TProgressbar" {
                                set m IntVar
                            }
                        }
                        set l [list $v $m]
                        #lappend vTcl(g_v_list) $l
                        lappend vTcl(g_v_list) $v $m
                    }
                }
                set v [vTcl:prepend_import_name $v]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure($sub=$v)\n"
            }
            command {
                if {[string first xview $v] > -1} {
                    set blank_index [string first " " $v]
                    set nm [string range $v 1 [expr $blank_index-1]]
                    set nm_wid [vTcl:widget_2_widname $nm]
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=self.$nm_wid.xview)\n"
                } elseif {[string first yview $v] > -1} {
                    set blank_index [string first " " $v]
                    set nm [string range $v 1 [expr $blank_index-1]]
                    set nm_wid [vTcl:widget_2_widname $nm]
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=self.$nm_wid.yview)\n"
                } else {
                    set vv $v
                    #if {[string first "(" $vv] == -1} {
                        # If we don't have any parameters make an
                        # empty parameter list.
#NEEDS WORK Check to see if we need the next command
                        #append vv "()"
                    #}
                    set v [vTcl:prepend_import_name $v]
                    lappend vTcl(funct_list) $vv
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=$v)\n"
                }
            }
            opencmd -
            closecmd -
            browsecmd {
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            menu {
                #set menu $v
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$menu_name)\n"
            }
            image {
                # NEEDS WORK Consolidate (use  vTcl:python_create_image)
                set file_name $vTcl(imagefile,$v)
                set file_name [regsub [pwd]/ $file_name ""] ;# Try for
                                                             # relative
                                                             # path
                set image_name self._img$vTcl(image_count)
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$image_name = PhotoImage(file=\"$file_name\")\n"
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$image_name)\n"
                #append vTcl(py_initfunc) \
                     "$vTcl(tab2)$name.image = $image_name\n"
                incr vTcl(image_count)

            }
            values {
                # Used by Spinbox and Combobox.
                # Need to transform the list into python format.
                if {[info exists values_list]} {
                    unset values_list
                }
                append values_list "\["
                foreach value $v {
                    if {$value != ""} {
                        append values_list "'" $value "'" ","
                    }
                }
                append values_list "\]"

                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.value_list = $values_list\n"
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=self.value_list)\n"
            }
            font {
                # Here we have to look up the font and then issue the statements.
                # The first hing to do is remove any blanks in v.
                set v [vTcl:python_replace_blanks $v]
                set font_names [font names]

                if {[lsearch $font_names $v] == -1} {
                    if {[info exists vTcl(fonts_defined,$v)] == 0} {
                        if {[info exists vTcl(fonts,$v,font_descr)]} {
                            # If we have a font description, we use it.
                            set desc $vTcl(fonts,$v,font_descr)
                        } else {
                            # Otherwise we create it.
                            set desc [font actual $v]
                            set vTcl(fonts,$v,font_descr) $desc
                        }
                        append vTcl(py_initfunc) \
                            [split_long_font_string \
                                 "$vTcl(tab2)$v = \"$desc\""]
                        # Remember that we created it.
                        set vTcl(fonts_defined,$v) 1
                    }
                }

                set vv [check_default_font $v]   ;#  10-17-13
                append vTcl(py_initfunc) \
                             "$vTcl(tab2)$name.configure($sub=$vv)\n"
                # Remember that we used it.
                lappend vTcl(fonts_used) $v
            }
            class {}
            #height -
            width {
                # I don't want to configure the widget with height and
                # width because in some cases varues are interpreted
                # as character widths and in others in terms of
                # pixels.  Rather let us specify them in the call to
                # place where the values seem to be in units of
                # pixels.

                # It seem as though I do need this for Message
                # Widgets. 10/16/12
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            text {
                # I may have a problem with multiline text.
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=\'\'\'$v\'\'\')\n"
            }
            orient {
                if {$widclass != "TPanedwindow"} {
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                }
            }
            background {
                if {$v == $vTcl(bgcolor)} {
                    if {![info exists classes($class,ttkWidget)]} {
                        # The widget is not a ttkwidget
                        append vTcl(py_initfunc) \
                            "$vTcl(tab2)$name.configure($sub=_bgcolor)\n"
                    }
                } else {
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                }
            }
            activebackground {
                set active_bg $v
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                if {$active_fg_there == 1 &&
                    [::colorDlg::dark_color $active_bg]  == 1 } {
                    append vTcl(py_initfunc) \
                      "$vTcl(tab2)$name.configure(activeforeground=\"white\")\n"
                }
            }
            align -
            anchor -
            relief -
            state -
            orient -
            selectmode -
            style -
            wrap -
            justify {
                set v [string toupper $v]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            default {
                if {$sub == "from"} {
                    set sub "from_"
                }
                if {[info exists color($v)]} {
                    if {$d == $color($v)} {
                        # The color name corresponds to the Hexadecimal
                        # default. So bail
                        continue
                    }
                }
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
            }
        }
    }
}

proc vTcl:python_add_special_opt_to_optlist {option target} {
    global vTcl
    lappend vTcl(w,optlist) $option
    set vTcl(w,opt,$option) ""
    if {[info exists vTcl(w,opt,$option,$target)] != 0} {
        set vTcl(w,opt,$option) $vTcl(w,opt,$option,$target)
        if {[info exists vTcl(special_attributes)] == 0} {
            lappend vTcl(special_attributes) vTcl(w,opt,$option,$target)
        } else {
            if {[lsearch $vTcl(special_attributes) \
                    vTcl(w,opt,$option,$target)] == -1} {
                lappend vTcl(special_attributes) vTcl(w,opt,$option,$target)
            }
        }
    }
}

# Utility  Similar to vTcl:lib_tix:dump_subwidgets.
# Generate source code for the subwidgets of a megawidget.
proc vTcl:python_source_subwidgets {subwidget parentframe} {
    global vTcl
    # set widget_tree [vTcl:widget_tree $subwidget]
    # The above nets me all of the widgets in the subtree.
    # Things appeared at two levels in NoteBook pages, for instance.
    # However, if a subwidget is a container widget, I
    # expect it to handle its own subwidgets.  Therefore,
    # I do not want this procedure to look inside a
    # container subwidget.  I think I will try the following:
    set widget_tree [vTcl:get_children $subwidget]
    foreach i $widget_tree {
        set basename [vTcl:base_name $i]
        # don't try to source subwidget itself
        if {"$i" != "$subwidget"} {
            #set class [vTcl:get_class $i]
            #set pc [vTcl:get_class $parentframe]
            set pframe [ vTcl:widget_2_widname $subwidget] ;# New
            #vTcl:python_source_widget $i ""  $pframe
            vTcl:python_source_widget $i ""  $subwidget
        }
    }
    return
}

proc vTcl:split_line {str} {

    # An attempt to keep lines from wrapping, especially those with
    # relative placement.  If line is longer than max_l then back up
    # to last comma and see if it fits, etc.

    #return $str
    global vTcl
    set max_l 80
    set len [string length $str]
    if {$len <= $max_l} {
        return $str
    }
    set pieces [split $str ,]
    #set len_pieces [string length [lindex $str 0]]
    # Algorithm:
    # set chunk ""
    # while a chunk is left append chunk next piece.
    # If chunk shorter than max
    #   while another chunk will fit, add it.
    #   otherwise add the \n and add to output.
    #
    set ind 0
    set l_size [llength $pieces]
    set chunk ""
    while {$ind < $l_size} {

        if {$ind == 0} {
            append chunk [lindex $pieces $ind]
        } else {
            append chunk "," [lindex $pieces $ind]
        }
        incr ind
        while {$ind <= $l_size} {
            set l_chuck [string length $chunk]
            set l_next [string length [lindex $pieces $ind]]
            set t_len [expr $l_chuck + $l_next]
            if {$t_len > $max_l} {
                append output $chunk "\n"
                set chunk "$vTcl(tab2)$vTcl(tab2)"
                break
            } else {
                if {$ind == $l_size} {
                    append output $chunk
                } else {
                    append chunk "," [lindex $pieces $ind]
                }
                incr ind
            }
        }
    }
    return $output
}


proc vTcl:relative_placement {} {

    # Generates the place command for the widget based on whether or
    # not the relative flag is set. If set then the parameters relx,
    # rely, relwidth and relheight are set otherwise just x and
    # y. When I wrote this I expected to have a user option to turn it
    # on or off.

    # this could definitely be cleaned up by the removal of the global
    # rel and putting the stuff in vTcl.  May do that in the future.
    global vTcl
    global rel

    if {$vTcl(pr,relative_placement)} { ;# Most common case
        append str \
            "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx),rely=$rel(rely),"
            append str \
            "relheight=$rel(relh),relwidth=$rel(relw))\n"
        append vTcl(py_initfunc) [vTcl:split_line $str]
    } else {
        #append vTcl(py_initfunc) \
            "$vTcl(tab2)self.$rel(widname).place(x=$(x),y=$(y))\n"
            append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x),y=$rel(y),"
            append str \
            "height=$rel(h),width=$rel(w))\n"
        append vTcl(py_initfunc) [vTcl:split_line $str]
    }
}

proc vTcl:entry_placement {} {
    # For entry widgets, I don't want to constrain the height so that
    # therre will be room for scroll bars without eating into the
    # entry field itself.`
    global vTcl
    global rel

    if {$vTcl(pr,relative_placement)} { ;# Most common case
        append str \
           "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx),rely=$rel(rely),"
            append str \
            "relwidth=$rel(relw))\n"
        append vTcl(py_initfunc) [vTcl:split_line $str]
    } else {
        #append vTcl(py_initfunc) \
            "$vTcl(tab2)self.$rel(widname).place(x=$(x),y=$(y))\n"
            append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x),y=$rel(y),"
            append str \
            "width=$rel(w))\n"
        append vTcl(py_initfunc) [vTcl:split_line $str]
    }
}

proc vTcl:scale_placement {widget} {
    # For the placement of scales one wants relative placement and
    # relative widths for horizontal scales and relative height for
    # vertical ones.
    global vTcl
    global rel
    set o [$widget cget -orient]
    append str \
        "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx),rely=$rel(rely),"
    if {$o == "horizontal"} {
        append str \
            "relwidth=$rel(relw),relheight=0.0,height=$rel(h))\n"
    } else {
        append str \
            "relwidth=0.0,relheight=$rel(relh),width=$rel(w))\n"
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]

}

proc vTcl:fixed_placement {} {
    global vTcl
    global rel
    #append str \
        "$vTcl(tab2)self.$rel(widname).place(x=$rel(x),y=$rel(y))\n"
    append str \
        "$vTcl(tab2)self.$rel(widname).place(x=$rel(x),y=$rel(y),"
    append str \
        "height=$rel(h),width=$rel(w))\n"
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:relative_x_y {} {

    # Generates the place command for the widget based on whether or
    # not the relative flag is set. If set then the parameters relx,
    # rely, relwidth and relheight are set otherwise just x and
    # y. When I wrote this I expected to have a user option to turn it
    # on or off.  I have since decided not to make this an option.


    global vTcl
    global rel
    if {$rel(flag)==0} {
        #append vTcl(py_initfunc) \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x),y=$rel(y)\n"
        #append vTcl(py_initfunc) \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x),y=$rel(y)\n"
        append str \
            "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx),rely=$rel(rely),"
            append str \
            "height=$rel(h),width=$rel(w))\n"
        append vTcl(py_initfunc) [vTcl:split_line $str]
        return
    }
    append str \
        "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx),rely=$rel(rely),"
    append str \
            "height=$rel(h),width=$rel(w))\n"
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:comp_color {} {
    global vTcl
    if {![info exists style_code(compcolor)]} {
        set comp $vTcl(pr,guicomplement_color)
        append vTcl(toplevel_config) \
            "$vTcl(tab2)_compcolor = '$comp' [color_comment $comp]\n"
        set style_code(compcolor) 1
    }
}

proc vTcl:analog_colors {} {
    global vTcl
    if {![info exists style_code(anacolors)]} {
        set ap $vTcl(pr,guianalog_color_p)
        set am $vTcl(pr,guianalog_color_m)
        append vTcl(toplevel_config) \
            "$vTcl(tab2)_ana1color = '$ap' [color_comment $ap] \n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)_ana2color = '$am' [color_comment $am] \n"
        set style_code(anacolors) 1
    }
}

proc vTcl:style_code {widclass} {

    global vTcl
    global style_code
    if {[info exists style_code($widclass)]} return
    if {$widclass == "Text"} return
    # if {![info exists style_code(colors)]} {
    #     # Define background and foreground colors
    #     set bg $vTcl(pr,guibgcolor)
    #     set fg $vTcl(pr,guifgcolor)
    #     append vTcl(py_initfunc) \
    #        "$vTcl(tab2)_bgcolor = '$bg'\n"
    #     append vTcl(py_initfunc) \
    #        "$vTcl(tab2)_fgcolor = '$fg'\n"
    #     set style_code(colors) 1
    # }
    if {[string index $widclass 0] == T ||
        $widclass == "Heading" || $widclass == "Scrolledtreeview"} {
        switch $widclass {
            Heading {
                append vTcl(py_initfunc) \
        "$vTcl(tab2)self.style.configure('$widclass',background=_compcolor)\n"
            }
            TSizegrip {
                append vTcl(py_initfunc) \
         "$vTcl(tab2)self.style.configure('$widclass',background=_bgcolor)\n"
            }
            TNotebook.Tab {
                append vTcl(py_initfunc) \
          "$vTcl(tab2)self.style.configure('$widclass',background=_bgcolor)\n"
                append vTcl(py_initfunc) \
          "$vTcl(tab2)self.style.configure('$widclass',foreground=_fgcolor)\n"
                append vTcl(py_initfunc) \
          "$vTcl(tab2)self.style.map('$widclass',background=\n"
                append vTcl(py_initfunc) \
                 "$vTcl(tab2)$vTcl(tab)\[('selected', _compcolor), ('active',_ana2color)\])\n"
            }
            Scrolledtreeview {
                append vTcl(py_initfunc) \
          "$vTcl(tab2)self.style.configure('Treeview.Heading', \
              font=[check_default_font $vTcl(actual_gui_font_dft_name)])\n"
#          "$vTcl(tab2)self.style.configure('Treeview.Heading',font=$vTcl(actual_gui_font_dft_name))\n"
            }
            TCheckbutton -
            TRadiobutton {
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.style.map('$widclass',background=\n"
                append vTcl(py_initfunc) \
                 "$vTcl(tab2)$vTcl(tab)\[('selected', _bgcolor), ('active',_ana2color)\])\n"
            }
        }
          #   default {
          #       append vTcl(py_initfunc) \
          # "$vTcl(tab2)self.style.configure('$widclass',background=_bgcolor)\n"
          #   }

        # if {$widclass != "TSizegrip"} {
        #     append vTcl(py_initfunc) \
        #         "$vTcl(tab2)style.configure('$widclass',foreground=_fgcolor)\n"
        # }
        set style_code($widclass) 1
    }
}

proc vTcl:python_source_widget {target prefix parentframe} {
    global vTcl widget
    global suffix
    global rel
    # Get target name and class
    set suffix 0
    set widclass [winfo class $target]

    set widname [vTcl:widget_2_widname $target]
    if {[string first "vTH_" $target]>-1} {
        return
    }
    if {[winfo class $target]=="Menubutton"} {
        set menu_y_shift 24
    } else {
        set menu_y_shift 0
    }
    foreach {w h x y} [split [winfo geometry $target] "x+"] {}
    set rectangle "$x, [expr {$y-$menu_y_shift}], $w, $h"

    set cmdbody {}
    set cmdname {}
    set vTcl(gen_name) {}
    catch {
        vTcl:py_get_command_parameters [$target cget -command]
    }
    set parentclass [winfo class $parentframe]
    if {$parentclass == "Toplevel"} {     # Rozen
        set pframe "master"
    } else {
        set parentf [vTcl:widget_2_widname $parentframe]
        set pframe "self.$parentf"
    }
    # Split the target geometry into w, h, x, y
    foreach {w h x y} [split [winfo geometry $target] "x+"] {}
    # Following makes sure that placement stays on units of 5 pixels.
    # Otherwise we end up with some things creeping across the window
    # when doing rework.
    set x [expr $x - [expr $x % 5]]
    set y [expr $y - [expr $x % 5]]
    # relative placement
    set rel(flag) 1
    set rel(rel_width) 1
    set parent_window [winfo parent $target]
    set parent_geometry [winfo geometry $parent_window]
    # Test whether parent geometry is "bad" and if the parent window
    # is in notebook

    if {$parent_geometry=="1x1+0+0"} {
        if {[string first pg $parent_window ] > -1} {
            foreach {W H X Y} [split $rel(geometry) "x+"] {}
        }
    } else {
        # Split parent geometry into W, H, X, Y.
        foreach {W H X Y} [split [winfo geometry $parent_window] "x+"] {}
    }

    set rel(x) $x
    set rel(y) $y
    set rel(h) $h
    set rel(w) $w
    set relx [expr $x / $W.0]
    set rel(relx) [expr {round($relx*100)/100.0}]
    set rely [expr $y / $H.0]
    set rel(rely) [expr {round($rely*100)/100.0}]
    set relw [expr $w / $W.0]
    set rel(relw) [expr {round($relw*100)/100.0}]
    set relh [expr $h / $H.0]
    set rel(relh) [expr {round($relh*100)/100.0}]
    set rel(widname) $widname
    set rel(pframe) $pframe

    set vTcl(py_initfunc) "$vTcl(py_initfunc)\n"
    set vTcl(image_count) 1
    # Following line puts out the required style code for ttk widgets.
    #append py_initfunc [vTcl:style_code $widclass]
    if {([string index $widclass 0] == "T" ||
         [string first  "Scroll" $widclass] > -1)  && $widclass != "Text"} {
        set vTcl(using_ttk) 1
    }
    switch $widclass {
        Label {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Label ($pframe)\n"
            vTcl:relative_x_y   ;# Don't want labels stretchable.
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            vTcl:python_configure_widget $target $widname "" $widclass
        }
        Entry {
            vTcl:py_get_command_parameters [$target cget -textvar]
            if {$cmdname == ""} {
                set cmdname "$widname\_hit_enter"
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Entry ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname "" $widclass
        }
        Button {
            set im [$target cget -image]
            set hi [$target cget -height]
            set wi [$target cget -width]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Button ($pframe)\n"
            vTcl:relative_x_y   ;# Don't want buttons stretchable.
             if {$cmdname==""} {
                set cmdname "$widname\_click()"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Scale {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Scale ($pframe)\n"
            #vTcl:relative_placement
            vTcl:scale_placement $target
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Scrollbar { # Since I am using the Tix widgets I am not too interested
                    # in scrollbars, so I haven't checked them out.
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Scrollbar ($pframe)\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.place(in_=$pframe,x=$x,y=$y)\n"
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Frame {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Frame ($pframe)\n"
            vTcl:relative_placement
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            if {$bdt == "none"} {
                set vTcl(py_initfunc) "$vTcl(py_initfunc)$vTcl(tab)"

                    "$widname.setBorder(new EmptyBorder(0,0,0,0))\n"
            } else {
                switch [$target cget -relief] {
                    raised {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=RAISED)\n" }
                    sunken {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=SUNKEN)\n" }
                    groove {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=GROOVE)\n" }
                    ridge {
                      append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname.configure(relief=RIDGE)\n" }
                }

            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
        }
        Text {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Text ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_load_cmd $target $widname
        }
       Message {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Message ($pframe)\n"
            vTcl:relative_placement
            #vTcl:fixed_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_load_cmd $target $widname
        }
        Listbox {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Listbox ($pframe)\n"
            vTcl:relative_placement
            if {$cmdname==""} {
                set cmdname "$widname\_state_changed"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_load_cmd $target $widname

        }
        Radiobutton {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Radiobutton ($pframe)\n"
            vTcl:relative_placement
            if {$cmdname==""} {
                set cmdname "$widname\_click"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
# NEEDS WORK because I don't know what the following is for.
            set rbvar [$target cget -variable]
            if {![info exists vTcl(py_btngroup,$rbvar)]} {
                set vTcl(py_btngroup,$rbvar) 1
            }
        }
        Checkbutton {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Checkbutton ($pframe)\n"
            vTcl:relative_placement
            if {$cmdname==""} {
                set cmdname "$widname\_state_changed"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Menubutton {
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = Menubutton($pframe)\n"
            vTcl:relative_placement
            set menu [$target cget -menu]
            set menu_name [vTcl:widget_2_widname $menu]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$menu_name = Menu(self.$widname)\n"
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_process_menu $menu $widname
        }
        Canvas {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = Canvas ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Spinbox {
            set from [ $target cget -from ]
            set to [$target cget -to]
            append vTcl(py_initfunc) \
            "$vTcl(tab2)self.$widname = Spinbox ($pframe,from_=$from,to=$to)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        TButton {
            #set image_file [vTcl:look_for_image $widget]
            append vTcl(py_initfunc) \
                 "$vTcl(tab2)self.$widname = ttk.Button ($pframe)\n"
            vTcl:relative_x_y  ;# Don't want buttons stretchable.
            if {$cmdname==""} {
                set cmdname "$widname\_click()"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TEntry {
            vTcl:py_get_command_parameters [$target cget -textvar]
            if {$cmdname == ""} {
                set cmdname "$widname\_hit_enter"
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Entry ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname "" $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TFrame {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Frame ($pframe)\n"
            vTcl:relative_placement
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            if {$bdt == "none"} {
                set vTcl(py_initfunc) "$vTcl(py_initfunc)$vTcl(tab)"

                    "$widname.setBorder(new EmptyBorder(0,0,0,0))\n"
            } else {
                switch [$target cget -relief] {
                    raised {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=RAISED)\n" }
                    sunken {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=SUNKEN)\n" }
                    groove {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=GROOVE)\n" }
                    ridge {
                      append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname.configure(relief=RIDGE)\n" }
                }

            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TLabel {
            # Don't forget to discuss the strange behavior of no width
            # upon creation.
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Label ($pframe)\n"
            vTcl:relative_x_y   ;# Don't want labels stretchable.
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            vTcl:python_configure_widget $target $widname "" $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TLabelframe {
           append py_initfunc [vTcl:style_code "TLabelframe.Label"]
           append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Labelframe ($pframe)\n"
            vTcl:relative_placement
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            if {$bdt == "none"} {
                set vTcl(py_initfunc) "$vTcl(py_initfunc)$vTcl(tab)"
                    "$widname.setBorder(new EmptyBorder(0,0,0,0))\n"
            } else {
                switch [$target cget -relief] {
                    raised {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=RAISED)\n" }
                    sunken {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=SUNKEN)\n" }
                    groove {
                      append vTcl(py_initfunc) \
                       "$vTcl(tab2)self.$widname.configure(relief=GROOVE)\n" }
                    ridge {
                      append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname.configure(relief=RIDGE)\n" }
                }
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            #vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $parentframe
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TNotebook {
            #append py_initfunc [vTcl:comp_color]
            #append py_initfunc [vTcl:analog_colors]
            append py_initfunc [vTcl:style_code "TNotebook.Tab"]
            append py_initfunc [vTcl:style_code "TFrame"]
            #append vTcl(py_initfunc) \
               "$vTcl(tab2)self.style.map('TNotebook.Tab', background=\[ \n"
            #append vTcl(py_initfunc) \
       "$vTcl(tab2)$vTcl(tab)('active', $_compcolor),"
            #append vTcl(py_initfunc) \
       "$vTcl(tab2)$vTcl(tab)('selected', _compcolor)\])\n"

            # append vTcl(py_initfunc) \
            #    "$vTcl(tab2)self.style.map('TNotebook.Tab', foreground=\[ \n"
            # append vTcl(py_initfunc) \
            #    "$vTcl(tab2)self.style.map('TNotebook.Tab', foreground=\[ \n"

            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = ttk.Notebook($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname ""  \
                [winfo class $target]
            # Lets try to put out options for the nbframe subwidget
            set pages [$target tabs]
            set i 0
            foreach p  $pages {
                # Create the frame.
                set sub_name [join [concat $widname "_pg" $i] ""]
                vTcl:python_alias $sub_name $p   ;# Rozen new
                append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$sub_name = ttk.Frame(self.$widname)\n"
                append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.add(self.$sub_name, padding=3)\n"
                set options [vTcl:python_nb_tab_configure $target $p]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.tab($i, $options)\n"
                incr i
            }
            # Now get the widgets inside each page.

            # Since the pg returns a geometry of 1x1+0+0 we pick up
            # the geometry of the parent.  Definitely a kludge.
            set rel(geometry) [winfo geometry [winfo parent $p]]
            foreach p  $pages {
                vTcl:python_source_subwidgets $p $p
            }
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        Scrolledtext {
            set config [$target configure]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            #append vTcl(py_initfunc) \
                "$vTcl(tab2)root.option_add('*scrollbar*background', '$vTcl(actual_gui_bg)')\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledText ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledtext
        }
        Scrolledentry {
            set config [$target configure]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            #append vTcl(py_initfunc) \
                "$vTcl(tab2)root.option_add('*scrollbar*background', '$vTcl(actual_gui_bg)')\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledEntry ($pframe)\n"
            vTcl:entry_placement
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledentry
        }
        Scrolledcombo {
            set config [$target configure]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            #append vTcl(py_initfunc) \
                "$vTcl(tab2)root.option_add('*scrollbar*background', '$vTcl(actual_gui_bg)')\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledCombo ($pframe)\n"
            vTcl:entry_placement
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledcombo
        }
        TProgressbar {
            set config [$target configure]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Progressbar ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass

        }
        TMenubutton {
            append vTcl(py_initfunc) \
               "$vTcl(tab2)self.$widname = ttk.Menubutton($pframe)\n"
#            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.place(in_=$pframe,x=$x,y=$y)\n"
            vTcl:relative_placement
            set menu [$target cget -menu]
            set menu_name [vTcl:widget_2_widname $menu]
            set menu_name [vTcl:python_unique_menu_name menu]
            append vTcl(py_initfunc) \
               "$vTcl(tab2)self.$menu_name = Menu(self.$widname,tearoff=0)\n"
            vTcl:python_configure_widget $target $widname $cmdname \
                      $widclass "" "self.$menu_name"
            vTcl:python_process_menu $menu $widname $menu_name
            #append vTcl(py_initfunc) \
            #   "$vTcl(tab2)self.$widname.config(menu=$lablab)\n"
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        Scrolledlistbox {
            append py_initfunc [vTcl:style_code "TScrollbar"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledListBox($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledlistbox
        }
        Scrolledtreeview {
            #append py_initfunc [vTcl:comp_color]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            append py_initfunc [vTcl:style_code "Scrolledtreeview"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledTreeView ($pframe)\n"
            append py_initfunc [vTcl:style_code "TScrollbar"]
            vTcl:relative_placement
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            vTcl:build_treeview_support $target.01 $widname $cmdname $widclass
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledtreeview
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TCheckbutton {
            append py_initfunc [vTcl:style_code "TCheckbutton"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Checkbutton ($pframe)\n"
            vTcl:relative_placement
            if {$cmdname==""} {
                set cmdname "$widname\_state_changed"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
                           # $('<Map>', self.__adjust_sash)widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TCombobox {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Combobox ($pframe)\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TRadiobutton {
            append py_initfunc [vTcl:style_code "TRadiobutton"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Radiobutton ($pframe)\n"
            vTcl:relative_placement
            if {$cmdname==""} {
                set cmdname "$widname\_click"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
# NEEDS WORK because I don't know what the following is for.
            set rbvar [$target cget -variable]
            if {![info exists vTcl(py_btngroup,$rbvar)]} {
                set vTcl(py_btngroup,$rbvar) 1
            }
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TScale {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Scale ($pframe)\n"
            #vTcl:relative_placement
            vTcl:scale_placement $target
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TSizegrip {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Sizegrip($pframe)\n"
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.place(anchor=SE,relx=1.0,rely=1.0)\n"
        }
        TPanedwindow {
            #append py_initfunc [vTcl:style_code "TLabelframe"]

            #append py_initfunc [vTcl:style_code "TLabelframe.Label"]
            set orient [$target cget -orient]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Panedwindow ($pframe, orient=\"$orient\")\n"
            vTcl:relative_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            # Add the panes.  The panes are added so that each pane
            # shares the same space.
            set panes [$target panes]
            set no_panes [llength $panes]
            set cnt 0
            foreach p $panes {
                incr cnt
                set text [$p cget -text]
                set sub_name [join [concat $widname "_f" $cnt] ""]
                vTcl:python_alias $sub_name $p   ;# Rozen new
                if {$orient == "horizontal"} {
                    set w [$p cget -width]
                    if {$cnt < $no_panes} {
                        set width_clause "width=$w, "
                    } else {
                        set width_clause ""
                    }
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.${widname}_f$cnt = ttk.Labelframe(${width_clause}text='$text')\n"
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add(self.${widname}_f$cnt)\n"
                } else {
                    # vertical
                    set h [$p cget -height]
                    if {$cnt < $no_panes} {
                        set height_clause "height=$h, "
                    } else {
                        set height_clause ""
                    }
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.${widname}_f$cnt = ttk.Labelframe(${height_clause}text='$text')\n"
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add(self.${widname}_f$cnt)\n"
                }
            }

        update idletasks
        set pos "pos = \["
        for {set i 0;set p [expr [llength $panes]-1]} {$i < $p} {incr i} {
            set coord [$target sashpos $i]
            append pos $coord ","
        }
        append pos "\]"

#     This is the sort of code I want. It is from Guilherme Polo's Theming.py
#         self.__funcid = paned.bind('<Map>', self.__adjust_sash)

#     def __adjust_sash(self, event):
#         """Adjust the initial sash position between the top frame and the
#         bottom frame."""
#         height = self.master.geometry().split('x')[1].split('+')[0]
#         paned = event.widget
#         paned.sashpos(0, int(height) - 180)
#         paned.unbind('<Map>', self.__funcid)
#         del self.__funcidTcl(pr,menubgcolor
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.__funcid$vTcl(pw_cnt) = self.$widname.bind('<Map>', self.__adjust_sash$vTcl(pw_cnt))\n"

            append vTcl(class_functions) \
"
    def __adjust_sash$vTcl(pw_cnt)(self, event):
        paned = event.widget
        $pos
        i = 0
        for sash in pos:
            paned.sashpos(i, sash)
            i += 1
        paned.unbind('<map>', self.__funcid$vTcl(pw_cnt))
        del self.__funcid$vTcl(pw_cnt)
"
            incr vTcl(pw_cnt)

            # Generate code for each of the subwidgets.
            foreach p $panes {
                #set child [winfo children $p]
                vTcl:python_source_subwidgets $p $p
            }

            #vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
         }
         Menu {
            if {$target == $vTcl(toplevel_menu)} {
                # First step is to put out the proper toplevel menus headers.
                # But only do once.
                set menu_config [$target configure]
                #set menu_font [$target cget -font] In the line below
                # I want the top level to have the font specified in
                # the preferences.  Since this is a menubar and there
                # will only be one menubar per toplevel window, I will
                # change the widname to "menubar".
                set readable_name menubar
                if {$vTcl(toplevel_menu_header) == "" } {
                    #set f_s [vTcl:python_menu_font $vTcl(pr,gui_font_menu)]
                    set f_s [vTcl:python_menu_font \
                                 $vTcl(actual_gui_font_menu_name)]
                    lappend vTcl(fonts_used) $vTcl(actual_gui_font_menu_name)
                    if {$f_s == "font=()"} {
                        # For readability I am explicitly saying that I
                        # will specify the use of TkMenuFont.
                        set f_s "font=\"TkMenuFont\""
                        #set f_s ""
                    }
                    if {$f_s != ""} {
                        set f_s ",$f_s"
                    }
                    set menu_bg [$target cget -background]
                    # set bg_s ""
                    # if { $vTcl(pr,menubgcolor) != $vTcl(pr,bgcolor)} {
                    #     append bg_s ",background=\'" $vTcl(pr,menubgcolor) "\'"
                    # }
                    set bg_s ""
                    if {[::colorDlg::compare_colors $menu_bg \
                             $vTcl(actual_gui_bg)]} {
                        append bg_s ",bg=_bgcolor"
                    } else {
                        append bg_s ",bg=\'" $menu_bg "\'"
                    }
                    # set fg_s ""
                    # if { $vTcl(pr,menufgcolor) != "#000000"} {
                    #     append fg_s ",fg=\'" $vTcl(pr,menufgcolor) "\'"
                    # }
                    set menu_fg [$target cget -foreground]
                    set fg_s ""
                    if {[::colorDlg::compare_colors $menu_fg \
                             $vTcl(actual_gui_fg)]} {
                        append fg_s ",fg=_fgcolor"
                    } else {
                        append fg_s ",fg=\'" $menu_fg "\'"
                    }
#NEEDS WORK for activebackground.
                    append vTcl(py_initfunc) \
                 "$vTcl(tab2)self.$readable_name = Menu(master$f_s$bg_s$fg_s)\n"
                    append vTcl(py_initfunc) \
                   "$vTcl(tab2)master.configure(menu = self.$readable_name)\n"
                           #"$vTcl(tab2)master\[\'menu\'\] = self.$widname\n"
                    set vTcl(toplevel_menu_header) 1
                    append vTcl(py_initfunc) "\n"
                }
                vTcl:python_process_menu $target $widname $readable_name
            }
        }
        default {
            puts "Unknown widget class encountered: $widclass"
       }
    }

    # Here is were I put in the bindings.
    append vTcl(py_initfunc) [vTcl:python_dump_bind $target $widname]
}

proc vTcl:python_menu_font {font} {

    # Change something like
 #-family Purisa -size 14 -weight normal -slant roman -underline 0 -overstrike 0
    # into ,font=('Purisa',14,'normal','roman',)
    # Badly named becaues I use it whenever I want to reformat a font descrition.
    global vTcl
    set font_string ""
    # I want to see if font is a font name.  I will assume that if the
    # font name does not contain the string "family"we have then it is a font
    # name.
    if {[string index $font 0] == "T"} {
        if {$font in $vTcl(standard_fonts)} {
            if {$font == "TkMenuFont"} {
                return ""
            } else {
                return "font=\"TkMenuFont\""
            }
        } else {
            return "font=\"TkMenuFont\""
        }
    }
    if {[string first "-family" $font] == -1} {
        # I think that we have a font name.
        lappend vTcl(fonts_used) $font
        return "font=$font"
    }
    if {$font == "" } {
        # I don't think that I hit this batch of code.
        set font vTcl(pr,gui_font_menu)
        #set font TkMenuFont
    }
    if {$font != ""} {
             set font_string "font=("
             # Reformat font sting for python
             foreach {prop value} $font {
                 switch $prop {
                     "-family" -
                     "-weight" -
                     "-slant" {
                         append font_string "'" $value "',"
                     }
                     "-size" {
                         append font_string $value ","
                     }
                     "-underline" {
                         if {$value == 1} {
                             append font_string "'underl<Menu>ine',"
                         }
                     }
                     "-overstrike" {
                         if {$value == 1} {
                             append font_string "'overstrike',"
                         }
                     }
                 }
             }
             append font_string ")"
         }
         return $font_string
}

proc vTcl:python_menu_options { opts {index {}} {menu_name {}} {image_name {}}} {
    # Each time vTcl:python_process_menu processes a menu entry this
    # routine is called to create a python string which will add the
    # non default option values. It is passed the list of option lists.
    # The opton list items looks like {-underline {} {} -1 -1}
    global vTcl
    set option_string ""
    # Now I will handle the configuration options: Added 12/24/11
    foreach op $opts {
        foreach {o x y d v} $op {
            # o - option
            # d - default
            # v - value
        }
        set v [string trim $v]
        if {$d == $v} continue   ;# If value == default value bail.
        set oa [string range $o 1 end]
        switch -exact -- $o {
            -font {
                set font_string [vTcl:python_menu_font $v]
                #append option_string [string range $font_string 1 end] ","
                if {$font_string != ""} {
                    append option_string \
                        "$vTcl(tab2)$vTcl(tab2)$font_string,\n"
                }
            }
            -menu {
                set z ''
                # Do nothing
                #append option_string "$oa=self.$menu_name,\n"
            }
            -accelerator -
            -activebackground -
            -activeforeground -
            -background -
            -compound -
            -foreground -
            -label -
            -selectcolor -
            -value {
                    append option_string \
                    "$vTcl(tab2)$vTcl(tab2)$oa=\"$v\",\n"
            }
            -command {
                #set v $cmdname
                #if {[string first "(" $v] == -1} {
                #        append v "()"
                #}
                lappend vTcl(funct_list) $v
                set v [vTcl:prepend_import_name $v]
                append option_string \
                     "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }
            -image {
                append option_string \
                     "$vTcl(tab2)$vTcl(tab2)$oa=$image_name,\n"
             }
            -variable {
                # The big deal here is to besure that the global
                # variable is created $v is the variable name. Check
                # to see if it begins with "self." to tell if it is a
                # local rather than a global.
                if {[string first self. $v] == 0} {
                    if {[lsearch -exact $vTcl(l_v_list) $v] == -1} {
                        set vv  "$vTcl(tab2)$v = StringVar()\n"
                        lappend vTcl(l_v_list) $vv
                    }

                #} elseif {[string first . $v] >= 0} {
                #    # Variable in imported module
                #    set vTcl(supp_variables) 1
                } else {
                    # Global variable
                    if {[lsearch -exact $vTcl(g_v_list) $v] == -1} {
                        set vTcl(global_variable) 1
                        set m StringVar
                         set l [list $v $m]
                        #lappend vTcl(g_v_list) $l
                        lappend vTcl(g_v_list) $v $m
                    }
                }
                set v [vTcl:prepend_import_name $v]
                append option_string "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }    ;# End of value and variable.
            -state -
            -relief {
                set v [string toupper $v]
                append option_string "$vTcl(tab2)$vTcl(tab2)$aoa=$v,\n"
            }
            default {
                append option_string "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }
        } ;# End of Switch
    }  ;# End of loop over opts
    # Remove last ',\n' from opt_string
    set option_string [string range $option_string 0 end-2]
    return $option_string
}

proc vTcl:python_unique_menu_name {name} {
    # Sees if name is in vTcl(menu_names) and if so generates an
    # integer when when appended to the name is unique in the
    # list. The last step is to add the new name to the list.
    global vTcl
    set final_name $name
    while {[lsearch -exact $vTcl(menu_names) $final_name] > -1} {
        incr i
        append final_name $i
    }
    lappend vTcl(menu_names) $final_name
    return $final_name
}

proc vTcl:python_create_image {target index} {
    # Looks up file name, converts it to a relative file name, and
    # generates an image name which it uses to generate a line of code
    # required by Python to create an reference. I do not have to
    # return the name because it will be used when processsing the
    # option list before another will be generated. This was birriwed
    # from vTcl:python_configure_widget.

    # NEEDS WORK: Should not have the same code in two places; will
    # consolidate. Add a parameter to increment.
    global vTcl
    # See if menu entry has an image.
    set image  [$target entrycget $index -image]
    if {$image == ""} return ""
    set file_name $vTcl(imagefile,$image)  ;# Fetch file name coupled to image.
    set file_name [regsub [pwd]/ $file_name ""] ;# Try for relative path
    set image_name self._img$vTcl(menu_image_count)
    append vTcl(py_initfunc) \
        "$vTcl(tab2)$image_name = PhotoImage(file=\"$file_name\")\n"
    incr vTcl(menu_image_count)
    return $image_name
}

proc vTcl:python_replace_blanks {str} {
    # Replace all blanks in str with "_" and write to
    # no_blanks. Return no_blanks. Before starting we remove beginning
    # and trainling white space.
    set str [string trim $str]
    regsub -all {\s+}  $str "_" no_blanks
    return $no_blanks
}

proc vTcl:python_process_menu {target widname {readable_name {}}} {
    # This is a recursive proc to translate the menu stuff in
    # python. When we get to a menu item which is a cascade we so that
    # item and then recurse into the new cascade menu. It calls
    # vTcl:python_create_image to determine if the item contains an
    # image and to generate the needed extra reference to the
    # PhotoImage object (see
    # http://effbot.org/tkinterbook/photoimage.htm for an example.)
    # and then calls vTcl:python_menu_options to process the options
    # for the menu entry.
    global vTcl
    if {[string first .# $target] >= 0} {return}
    set entries [$target index end]
    if {$entries == "none"} {return}
    set result ""
    if {$readable_name == ""} {
        set widname [vTcl:widget_2_widname $target]
    } else {
        set widname $readable_name
    }
    for {set i 0} {$i<=$entries} {incr i} {
        set type [$target type $i]
        if {$target == $vTcl(toplevel_menu)} {
            if {$type == "tearoff"} {
                # tearoff at toplevel doesn't really mean anything,
                # but let the user specify it anyway.
                continue

            }
        }
        set opts [$target entryconfigure $i]
        set lab_name {}
        switch $type {
            cascade {
                set lab [$target entrycget $i -label] ;# Get label
                set lab_lower [string tolower $lab]
                # replace blanks in lab_lower with "_" and write it
                # out in variable 'no_blanks'
                set no_blanks [vTcl:python_replace_blanks $lab_lower]
                #regsub -all {\s+}  $lab_lower "_" no_blanks
                set lab_name [vTcl:python_unique_menu_name $no_blanks]
                set child [$target entrycget $i -menu]
                set widname_child [vTcl:widget_2_widname $child]
                set tearoff [$child cget -tearoff]
                if {$tearoff} {
                    set tearoff ",tearoff=1"
                } else {
                    set tearoff ",tearoff=0"
                }

                append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$lab_name = Menu(master$tearoff)\n"

                    # Generate the line of code which creates the
                    # required reference.
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$readable_name.add_cascade("

                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]

                append vTcl(py_initfunc) \
                        "menu=self.$lab_name,\n"
                append vTcl(py_initfunc) $op_str ")\n"
                vTcl:python_process_menu $child $lab_name $lab_name
            }
            command {
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add_command(\n"
                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]
                append vTcl(py_initfunc) $op_str ")\n"
            }
            separator {
                set image_name ""
                append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname.add_separator(\n"
                set op_str [vTcl:python_menu_options $opts]
                append vTcl(py_initfunc) $op_str ")\n"
            }
            checkbutton {
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.add_checkbutton(\n"
                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]
                append vTcl(py_initfunc) $op_str ")\n"
            }
            radiobutton {
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                            "$vTcl(tab2)self.$widname.add_radiobutton(\n"
                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]
                append vTcl(py_initfunc) $op_str ")\n"
            }

        }   ;# End of Switch
    }
    return $lab_name
}


proc vTcl:python_get_inner_frame {target} {
    global vTcl
    set output ""
    set pieces [split $target .]
    set max 0
    for {set i 1} {$i <= [llength $pieces]} {incr i} {
        set can [lindex $pieces $i]
        if {[string first "tix" $can] != -1} {
            set max $i
        }
    }
    if {$max > 2} {
        append f_name [lindex $pieces 2] "_" [lindex $pieces $max]
    } else {dp
        set f_name [lindex $pieces 2]
    }
     return f_name
}

proc vTcl:find_attribute {widget attribute} {
    global vTcl
    set config [$widget configure]
    foreach c  $config {
        if {[lindex $c 0] == $attribute} {
            return [lindex $c 4]
        }
    }
}

proc vTcl:python_process_me {command widget widname} {
    global vTcl
    set i [string first "%me" $vTcl($widget,$command)]
    set x $vTcl($widget,$command)
    set ind [string first "self." $widname]
    if {$ind > -1} {
        set widname [string range $widname 5 end]
    }
    if {$i > -1} {
        set head [string range $x 0  [expr $i - 1]]
        set tail [string range $x [expr $i + 3] end]
        set x $head
        append x "self.$widname"
        append x $tail
    }
    return $x
}

proc vTcl:python_load_cmd  {widget widname} {
    global vTcl
    if {[info exists vTcl($widget,-loadcommand)]} {
        set x [vTcl:python_process_me "-loadcommand" $widget $widname]
        append vTcl(py_initfunc) "$vTcl(tab2)$x\(self.$widname\)\n"
    }
}

proc vTcl:python_delete_leading_tabs {proc} {
    set p $proc
    set spaces ""
    while {[string first "\n" $p] == 0} {
        set p [string range $p 1 end]
        set spaces 1
    }
    while {[string first " " $p] == 0} {
        set p [string range $p 1 end]
        set spaces 1
    }
    while {[string first "\t" $p] == 0} {
        set p [string range $p 1 end]
        set spaces 1
    }
    if {$spaces == ""} {
        return $proc
    }
    return $p
}

proc vTcl:python_delete_lambda {proc} {
    set p $proc
    set p [regsub "lambda.*:" $p ""]
    set p [string trim $p]
    return $p
}

proc vTcl:python_indent_lines {proc} {
    global vTcl
global log
    set p $proc
    set rem  ""
    set tail $proc
    set lines ""
    while {[string first "\n" $tail] > -1} {
        set i [string first "\n" $tail]
        set head [string range $tail 0 $i]
        set tail [string range $tail [expr $i + 1] end]
        append rem $vTcl(tab) $head
        set lines 1
    }
    if {$lines == ""} {
        return proc
    }
    return $rem
}

proc vTcl:python_subst_tabs {proc} {
    global vTcl
    set p $proc
    set res ""
    set tabs ""
    while {[string first "\t" $p] > -1} {
        set i [string first "\t" $p]
        set head [string range $p 0 $i]
        set tail [string range $p [expr $i + 1] end]
        append p $head $vTcl(tab) $tail
        set tabs 1
    }
    if {$tabs == ""} {
        return $proc
    }
    return $p
}

proc vTcl:python_print_proc {proc} {
    set p $proc
    set i [string first "\t" $p]
    puts $p
}

proc vTcl:python_gui_startup {geom title classname} {
    global vTcl
    if {$vTcl(import_module) != ""} {
        append start_gui \
"
import $vTcl(import_name)
"
    }
    append start_gui \
"
def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = Tk()
    root.title('$classname')
    root.geometry('$geom')"
    if {$vTcl(global_variable)} {
        append start_gui \
"
    $vTcl(import_name).set_Tk_var()"
    }
    append start_gui \
"
    w = $classname (root)
"
    if {$vTcl(import_module) == "" } {
        append start_gui \
"
    init()
    root.mainloop()"
    } else {
        append start_gui \
"    $vTcl(import_name).init(root, w)
    root.mainloop()
"
    }
    append start_gui \
"
w = None
def create_$classname (root, param=None):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt
    rt = root
    w = Toplevel (root)
    w.title('$classname')
    w.geometry('$geom')"

if {$vTcl(global_variable)} {
        append start_gui \
"
    $vTcl(import_name).set_Tk_var()"
    }
    append start_gui \
"
    w_win = $classname (w)"
    if {$vTcl(import_module) == "" } {
        append start_gui \
"
    init()
    return w_win"
    } else {
        append start_gui \
"
    $vTcl(import_name).init(w, w_win, param)
    return w_win
"
    }
    append start_gui \
"
def destroy_$classname ():
    global w
    w.destroy()
    w = None
"

    return $start_gui
}

proc  vTcl:get_subwidget_options {widget hlist} {
    # This Proc puts options of the subwidget into the -options
    # string of the widget creation.  I think that I could have
    #used this in more places.
    global vTcl
    set w [$widget subwidget $hlist]
    set config [$w config]
    # The following loop was borrowed from vTcl:python_configure_widget
    # It needs to be modified to return not a configure call but a
    # list for -options.
    set options ""
    foreach c  $config {
        if {[llength $c] == 5 &&
            [string first "Cmd" [lindex $c 1]] ==  -1 &&
            [string first "command" [lindex $c 1]] ==  -1 &&
            [string first "Command" [lindex $c 1]] ==  -1 } {
            if {[lindex $c 3] != [lindex $c 4]} {
                set str [lindex $c 0]
                # get rid of the - sign.
                set len [string length $str]
                set sub [string range $str 1 [expr $len -1]]
                append options \
              "\\\n$vTcl(tab2)$vTcl(tab2)$hlist.[lindex $c 1] \"[lindex $c 4]\""
            }
        }
    }
    return $options
}

proc vTcl:python_nb_tab_configure {target tab} {
    # Ttk version of program to handle the setting of options for
    # tTnotebook.
    set output ""
    set tab_options [$target tab $tab]
    foreach {opt val} $tab_options {
        set str [lindex $opt]
        # get rid of the - sign.
        set len [string length $str]
        set sub [string range $str 1 [expr $len -1]]
        switch $sub {
            underline -
            text {
                append output "$sub=\"$val\","
            }
        }
    }
    return $output
}

proc vTcl:python_nb_page_configure {p widget widname name} {
    # Configures the option of the pageframe widget (TixNotebook)
    global vTcl
    set output ""
    set config [$widget pageconfigure $p]
    foreach c  $config {
        if {[llength $c] == 5 && [string first "cmd" [lindex $c 1]] ==  -1 } {
            if {[lindex $c 3] != [lindex $c 4]} {
                set str [lindex $c 0]
                # get rid of the - sign.
                set len [string length $str]
                set sub [string range $str 1 [expr $len -1]]
                append output \
                     ",$sub=\"[lindex $c 4]\""
            }
        }
    }
    return $output
}

proc vTcl:create_balloon_code {window} {
    # Generates a code string containing any of the balloon
    # code needed.
    global vTcl
    set balloon_widgets [vTcl:find_widgets_with_balloon_msg $window]
    set balloon_code ""
    if {[llength $balloon_widgets] > 0} {
        append balloon_code \
           "$vTcl(tab2)self.balloon = Tix.Balloon(master)\n"
        foreach w $balloon_widgets {
            set widname [vTcl:widget_2_widname $w]
            append balloon_code \
         "$vTcl(tab2)self.balloon.bind_widget(self.$widname,"\
         "balloonmsg=\"$vTcl($w,balloon_msg)\")\n"
        }
        append balloon_code \
           "$vTcl(tab2)self.balloon.configure(bg='blue', borderwidth=3)"
    }
    return $balloon_code
}

proc vTcl:widget_2_widname {target} {
    # See if there is an alias defined, if so return it.  Otherwise,
    # transform the widget name by replacing the periods with '_'.
    # Originally, it was written assuming that the first character was
    # "." but it maybe something like $top which would throw off the
    # the indices 2 and 3 below.

    global vTcl widget
    # in case target is an alias, then just return it!
    if {[lsearch -exact $vTcl(alias_names) $target] > -1} {
        return $target
    }
    if {[catch {set alias $widget(rev,$target)}]} {
        # This is the otherwise path: no alias
        set pieces [split $target ".$"]
        set no [llength $pieces]
        set first [lindex $pieces 2]
        set sublist [lrange $pieces 3 end]
        set widname $first
        # What I am doing is risky. NEEDS WORK
        foreach p $sublist {
            set p_trim [string trim $p \"]
            append widname "_" $p_trim
        }
    } else {
        # Work on the alias rather than the target value. Replace
        # blanks with '_' in the alias.
        set pieces [split $alias]
        set widname [lindex $pieces 0]
        if {[llength $pieces] > 1} {
            set sublist [lrange $pieces 1 end]
            foreach p $sublist {
                set p_trim [string trim $p]
                append widname "_" $p_trim
            }
        }
        lappend vTcl(alias_names) $widname
    }
    return $widname
}

proc vTcl:python_set_alias {target name} {
    # Sees if an alias exists and if so put out an assignment in the
    #  wrong place.  This needs to be fixed.  NEEDS WORK
    global vTcl widget
    if {[catch {set alias $widget(rev,$target)}]} {
        return
    } else {
        # Don't put out this statement, Try a comment instead.
        append vTcl(py_initfunc) \
                "$vTcl(tab2)$alias = $name  \# alias $target\n"
    }
}


proc vTcl:python_alias {alias target} {
    # Update the current value of alias when the
    # alias field in the attribute editor is changed.
    # Never called ??
    global vTcl widget
    catch {
        unset widget($was)
        unset widget(rev,$target)
    }
    if {$alias != ""} {
        set widget($alias) $target
        set widget(rev,$target) $alias
    }
}

proc vTcl:python_dump_bind {target widname} {
    # This is a take off from vTcl:dump_widget_bind
    global vTcl

    set class [vTcl:get_class $target]
    set needle [string first "Scrolled" $class]
    if {$needle > -1}  {
        set result [vTcl:python_dump_bind $target.01 $widname]
        return $result
    }
    set result ""
    if {[catch {bindtags $target \{$vTcl(bindtags,$target)\}}]} {
        return ""
    }
    set bindlist [lsort [bind $target]]
    foreach i $bindlist {
        set command [bind $target $i]
        set command [string trim $command]
        if {[regexp "lambda.*:(.*)" $command match name]} {
            # We have a lambda function so there separate out the
            # callback name and add to the function list to be
            # created.
            set name [string trim $name]
            lappend vTcl(funct_list) $name
        } else {
            # If I got here then the command is not a lambda function
            # but rather a function name is added it to the list of
            # functions to generate. However one still need to have at
            # least one parameter which is the event.  If there were
            # more parameters then we would have been in the lambda
            # brach above where there would have been the event
            # variable.
            set name [string trim $command]
            append name "(e)"
            lappend vTcl(funct_list) $name
        }
        if {"$vTcl(bind,ignore)" == "" ||
               ![regexp "^($vTcl(bind,ignore))" $command] } {
            if { ![regexp "focus" $command] } { # This if is another of
                                                # those tix hacks._e,

set command [vTcl:prepend_import_name $command]
                append result \
                        "$vTcl(tab2)self.$widname.bind('$i',$command)\n"
            }
        }
    }
    bindtags $target vTcl(b)
    return $result
}

proc x_compare {a b} {
    set alast [lindex $a end]
    set blast [lindex $b end]
    if {$alast <= $blast} {
        return -1
    } else {
        return 1
    }
}

proc vTcl:python_process_menubutton {menubutton widname} {

}

proc vTcl:sort_menubuttons {} {
    global vTcl
    set sort_list {}
    foreach i $vTcl(menubutton_list) {
        set x [winfo x $i]
        set item [list $i $x]
        lappend sort_list $item
    }
    set new [lsort -command x_compare $sort_list]
    return $new
}

# For debugging purposes.
proc printenv { args } {
    global env
    set maxl 0
    if {[llength $args] == 0} {
        set args [lsort [array names env]]
    }
    foreach x $args {
        if {[string length $x] > $maxl} {
            set maxl [string length $x]
        }
    }
    incr maxl 2
    foreach x $args {
        puts stdout [format "%*s = %s" $maxl $x $env($x)]
    }
}

