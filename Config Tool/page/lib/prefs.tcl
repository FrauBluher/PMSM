##############################################################################
# $Id: prefs.tcl,v 1.5 2013/10/03 02:40:49 rozen Exp rozen $
#
# prefs.tcl - procedures for editing application preferences
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
# GNU General Public License for more details.t
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

##############################################################################
#

# vTcl:prefs:bgcolor             for setting color preferences.
# vTclWindow.vTcl.prefs          sort of main function.
# vTcl:save_prefs                where we actuall save the preferences.
# vTcl:prefs:bgcolor_get         where we invoke the color selector
# vTcl:prefs:guibgcolor_get      where we invoke the color selector
# vTcl:prefs:fonts               font stuff obviously
# vTcl:prefs:basics
# vTcl:prefs:grid
# vTcl:prefs:data_exchange
# vTcl:prefs:browse_font         where we invoke the font dialog

proc vTcl:prefs:uninit {base} {
    catch {destroy $base.tb}
}

proc vTcl:prefs:init {base} {
    global vTcl
    # this is to store all variables
    namespace eval prefs {
       variable balloon          ""
       variable getname          ""
       variable shortname        ""
       variable winfocus         ""
       variable autoplace        ""
       variable cmdalias         ""
       variable autoalias        ""
       variable multiplace       ""
       variable autoloadcomp     ""
       variable autoloadcompfile ""
       variable font_dft         "";# Rozen 11/6/12
       variable gui_font_dft     $vTcl(pr,gui_font_dft)    ;# Rozen 11/6/12
       variable gui_font_text    $vTcl(pr,gui_font_text)
       variable gui_font_fixed   $vTcl(pr,gui_font_fixed)
       variable font_fixed       ""
       variable gui_font_menu    $vTcl(pr,gui_font_menu)   ;# Rozen
       variable relative_placement ""  ;# Rozen
       variable manager          ""
       variable encase           ""
       variable projecttype      ""
       variable imageeditor      ""
       variable saveimagesinline ""
       variable projfile         ""
       variable saveasexecutable ""
       variable bgcolor          $vTcl(pr,bgcolor)
       variable fgcolor          $vTcl(pr,fgcolor)
       variable guibgcolor       $vTcl(pr,guibgcolor)
       variable guifgcolor       $vTcl(pr,guifgcolor)
       variable entrybgcolor     ""
       variable entryactivecolor ""
       variable guientrybgcolor     ""
       variable guientryactivecolor $vTcl(pr,gui_font_dft)

       variable listboxbgcolor   ""
       variable guilistboxbgcolor   ""
       variable treehighlight    ""
       variable texteditor       ""
       variable menubgcolor      ""     ;# Rozen
       variable menufgcolor      ""     ;# Rozen
       variable guicomplement_color ""
       variable guianalog_color_p   ""
       variable guianalog_color_m   ""
    }

    # This stuff creates a menu font like 'font10' and set it up to
    # use Things like vTcl(pr,font_dft) are actually lists and the
    # eval used in the set stmt below is there to expand the list into
    # an appropiate parameter string.
    foreach f [list font_dft font_fixed] {
        if {[string index $vTcl(pr,$f) 0] == T} {
            set prefs::$f $vTcl(pr,$f)
        } else {
            set prefs::$f [eval font create [font actual $vTcl(pr,$f)]]
        }
    }

    set prefs::gui_font_dft \
        [eval font create [font actual $vTcl(pr,gui_font_dft)]]  ;# Rozen
    set prefs::gui_font_fixed \
        [eval font create [font actual $vTcl(pr,gui_font_fixed)]]  ;# Rozen
    set prefs::gui_font_text\
        [eval font create [font actual $vTcl(pr,gui_font_text)]]  ;# Rozen

    set prefs::gui_font_menu\
        [eval font create [font actual $vTcl(pr,gui_font_menu)]]

    # set the variables for the dialog
    vTcl:prefs:data_exchange 0

    ## Destroy the notebook if already existing
    vTcl:prefs:uninit $base;# Rozen 11/6/12
    set tb [NoteBook $base.tb]
    pack $tb -fill both -expand 1
    vTcl:prefs:basics  [$tb insert end "Basics" -text "Basics"]
    #vTcl:prefs:project [$tb insert end "Project" -text "Project"] ;# Rozen
    vTcl:prefs:fonts   [$tb insert end "Fonts" -text "Fonts"]
    #vTcl:prefs:gui_fonts   [$tb insert end "GUI Fonts" -text "GUI Fonts"]
    vTcl:prefs:bgcolor [$tb insert end "Colors" -text "Colors"]
    #vTcl:prefs:images  [$tb insert end "Images" -text "Images"] ;# Rozen
    #vTcl:prefs:libs    [$tb insert end "Libraries" -text "Libraries"]
    #vTcl:prefs:external [$tb insert end "External" -text "External"] ;# Rozen
    #vTcl:prefs:grid    [$tb insert end "Grid" -text "Grid"]    ;# Rozen

    $tb raise Basics
    #$tb raise Fonts
}

proc vTclWindow.vTcl.prefs {{base ""}} {
    global widget
    # Rozen. The main preference window.
    if {$base == ""} {
        set base .vTcl.prefs
    }
    if {[winfo exists $base]} {
        wm deiconify $base -width  5
        return
    }

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm geometry $base +0+0
    wm withdraw $base
    ## measure text height then compute an approximate dialog height
    radiobutton $base.rb -text "Single line"
    place $base.rb -x 0 -y 0
    update
    # Rozen The constant below is an estimate of the number of lines
    # in the dialog box. I changed from 15 to 25 to accommodate the
    # widget color stuff. SIZE
    set height [expr ([winfo height $base.rb] + 1) * 25]
    destroy $base.rb
    ## end measurement
    #wm geometry   $base 400x$height
    wm geometry   $base 600x$height   ;# Rozen
    wm focusmodel $base passive
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "PAGE Preferences"  ;# Rozen
    wm protocol $base WM_DELETE_WINDOW "wm withdraw $base"
    bind $base <Key-Return> {
        vTcl:prefs:data_exchange 1; wm withdraw [winfo toplevel %W]
    }
    bind $base <Key-Escape> {
        wm withdraw [winfo toplevel %W]; vTcl:prefs:data_exchange 0
    }
    bind $base <<Show>> {
        ## make sure the dialog is up-to-date
        #vTcl:prefs:data_exchange 0
    }
    frame $base.fra19
    ::vTcl::OkButton $base.fra19.but20 \
     -command "vTcl:prefs:data_exchange 1; wm withdraw $base"
    ::vTcl::CancelButton $base.fra19.but21 \
     -command "vTcl:prefs:data_exchange 0; wm withdraw $base"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra19 \
        -in $base -anchor e -expand 0 -fill none -pady 5 -side top
    pack $base.fra19.but20 \
        -in $base.fra19 -side left
    pack $base.fra19.but21 \
        -in $base.fra19 -side left

    ###################
    # Balloon help
    ###################
    vTcl:set_balloon $base.fra19.but20 "Apply changes and close dialog"
    vTcl:set_balloon $base.fra19.but21 "Cancel changes and close dialog"

    vTcl:prefs:init $base
    vTcl:BindHelp $base Preferences

    update
    vTcl:center $base 400 $height
    wm deiconify $base
}

proc {vTcl:prefs:data_exchange} {save_and_validate} {
    global widget vTcl
    # Rozen, routine executed when either check or X buttons are
    # selected.

    # if save_and_validate is set to 0, values are transferred from
    # the preferences to the dialog (this is typically done when
    # initializing the dialog)   ;# Rozen
       variable relative_placement ""  ;#

    # if save_and_validate is set to 1, values are transferred from
    # the dialog to the preferences (this is typically done when the
    # user presses the OK button Rozen, I think that the preferences
    # should be save to disk as well, so I will change it to call
    # vTcl:save_prefs.

    vTcl:data_exchange_var vTcl(pr,balloon)          \
    prefs::balloon          $save_and_validate
    vTcl:data_exchange_var vTcl(pr,getname)          \
    prefs::getname          $save_and_validate
    vTcl:data_exchange_var vTcl(pr,shortname)        \
    prefs::shortname        $save_and_validate
    vTcl:data_exchange_var vTcl(pr,winfocus)         \
    prefs::winfocus         $save_and_validate
    vTcl:data_exchange_var vTcl(pr,autoplace)        \
    prefs::autoplace        $save_and_validate
    vTcl:data_exchange_var vTcl(pr,autoloadcomp)     \
    prefs::autoloadcomp     $save_and_validate
    vTcl:data_exchange_var vTcl(pr,autoloadcompfile) \
    prefs::autoloadcompfile $save_and_validate
    vTcl:data_exchange_var vTcl(pr,manager)          \
    prefs::manager          $save_and_validate
    vTcl:data_exchange_var vTcl(pr,encase)           \
    prefs::encase           $save_and_validate
    vTcl:data_exchange_var vTcl(pr,projecttype)      \
    prefs::projecttype      $save_and_validate
    vTcl:data_exchange_var vTcl(pr,imageeditor)      \
    prefs::imageeditor      $save_and_validate
    vTcl:data_exchange_var vTcl(pr,saveimagesinline) \
    prefs::saveimagesinline $save_and_validate
    vTcl:data_exchange_var vTcl(pr,cmdalias)         \
    prefs::cmdalias         $save_and_validate
    vTcl:data_exchange_var vTcl(pr,autoalias)        \
    prefs::autoalias        $save_and_validate
    vTcl:data_exchange_var vTcl(pr,multiplace)       \
    prefs::multiplace       $save_and_validate
    vTcl:data_exchange_var vTcl(pr,projfile)         \
        prefs::projfile         $save_and_validate
    vTcl:data_exchange_var vTcl(pr,saveasexecutable) \
        prefs::saveasexecutable $save_and_validate
    vTcl:data_exchange_var vTcl(pr,bgcolor)          \
        prefs::bgcolor $save_and_validate
    vTcl:data_exchange_var vTcl(pr,fgcolor)          \
        prefs::fgcolor $save_and_validate
    vTcl:data_exchange_var vTcl(pr,guibgcolor)          \
        prefs::guibgcolor $save_and_validate               ;# Rozen 11/10/12
    vTcl:data_exchange_var vTcl(pr,guifgcolor)          \
        prefs::guifgcolor $save_and_validate               ;# Rozen 11/10/12
    vTcl:data_exchange_var vTcl(pr,guicomplement_color)          \
        prefs::guicomplement_color $save_and_validate      ;# Rozen 11/10/12
    vTcl:data_exchange_var vTcl(pr,guianalog_color_p)          \
        prefs::guianalog_color_p $save_and_validate          ;# Rozen 11/10/12
    vTcl:data_exchange_var vTcl(pr,guianalog_color_m) \
        prefs::guianalog_color_m $save_and_validate
    vTcl:data_exchange_var vTcl(pr,entrybgcolor)     \
        prefs::entrybgcolor $save_and_validate
    vTcl:data_exchange_var vTcl(pr,entryactivecolor) \
        prefs::entryactivecolor $save_and_validate
    vTcl:data_exchange_var vTcl(pr,guientrybgcolor)     \
        prefs::guientrybgcolor $save_and_validate         ;# Rozen 11/6/12
    vTcl:data_exchange_var vTcl(pr,guientryactivecolor) \
        prefs::guientryactivecolor $save_and_validate     ;# Rozen 11/6/12
    vTcl:data_exchange_var vTcl(pr,listboxbgcolor)   \
        prefs::listboxbgcolor $save_and_validate
    vTcl:data_exchange_var vTcl(pr,guilistboxbgcolor)   \
        prefs::guilistboxbgcolor $save_and_validate          ;# Rozen 11/6/12
    vTcl:data_exchange_var vTcl(pr,treehighlight)    \
        prefs::treehighlight $save_and_validate
    vTcl:data_exchange_var vTcl(pr,texteditor)       \
        prefs::texteditor $save_and_validate
    vTcl:data_exchange_var vTcl(pr,relative_placement)       \
        prefs::relative_placement $save_and_validate    ;# Rozen
    vTcl:data_exchange_var vTcl(pr,menubgcolor)       \
        prefs::menubgcolor $save_and_validate    ;# Rozen
    vTcl:data_exchange_var vTcl(pr,menufgcolor)       \
        prefs::menufgcolor $save_and_validate    ;# Rozen

    if {$save_and_validate} {
        # We come here upon leaving and we also save any values we
        # changed by saving all of vTcl(pr,*).
        set vTcl(pr,font_dft)   [font configure $prefs::font_dft]
        set vTcl(font,$vTcl(pr,font_dft)) $prefs::font_dft
        set vTcl(pr,font_fixed) [font configure $prefs::font_fixed]
#NEEDS WORK next four stmts need to be changed to test whether the pref contains Tk...Font or not.
        if {[string index $prefs::gui_font_dft 0] == "T"} {
            set vTcl(pr,gui_font_dft) $prefs::gui_font_dft
        } else {
            set vTcl(pr,gui_font_dft) \
                [font configure $prefs::gui_font_dft]  ;# Rozen 12/14/12
        }
        set vTcl(pr,gui_font_fixed) \
            [font configure $prefs::gui_font_fixed]  ;# Rozen 12/14/12
        set vTcl(pr,gui_font_text) \
            [font configure $prefs::gui_font_text]  ;# Rozen 12/14/12

        set vTcl(pr,gui_font_menu) \
            [font configure $prefs::gui_font_menu]

        # So that I can start using the any new font specifications ritht away.
        set vTcl(actual_gui_font_dft_name) $prefs::gui_font_dft
        # set vTcl(actual_gui_font_text_name) $gt    ;# $vTcl(font,gui_font_text)
        # set vTcl(actual_gui_font_fixed_name) $gf   ;# $vTcl(font,gui_font_fixed)
        # set vTcl(actual_gui_font_menu_name) $gm   ;# $vTcl(font,gui_font_menu)
        vTcl:save_prefs      ;# Rozen Makes more sense to me to have it here.
    } else {
        # We enter here when we start prefs.
        # PAGE Defaults
        if {[string index $vTcl(pr,font_dft) 0] == "-"} {
            eval font configure $prefs::font_dft $vTcl(pr,font_dft)
        } else {
            eval font configure $prefs::font_dft \
                [font actual $vTcl(pr,font_dft)]
        }

        if {[string index $vTcl(pr,font_fixed) 0] == "-"} {
            eval font configure $prefs::font_fixed $vTcl(pr,font_fixed)
        } else {
            eval font configure $prefs::font_fixed \
                [font actual $vTcl(pr,font_fixed)]
        }
        # GUI Defaults
        if {[string index $vTcl(pr,gui_font_dft) 0] == "-"} {
            eval font configure $prefs::gui_font_dft $vTcl(pr,gui_font_dft)
        } else {
            # eval font configure $prefs::gui_font_dft \
            #     [font actual $vTcl(pr,gui_font_dft)]
            set prefs::gui_font_dft $vTcl(pr,gui_font_dft)
        }
        if {[string index $vTcl(pr,gui_font_fixed) 0] == "-"} {
            eval font configure $prefs::gui_font_fixed $vTcl(pr,gui_font_fixed)
        } else {
            eval font configure $prefs::gui_font_fixed \
                [font actual $vTcl(pr,gui_font_fixed)]
        }

        if {[string index $vTcl(pr,gui_font_text) 0] == "-"} {
            eval font configure $prefs::gui_font_text $vTcl(pr,gui_font_text)
        } else {
            eval font configure $prefs::gui_font_text \
                [font actual $vTcl(pr,gui_font_text)]
        }

        if {[string index $vTcl(pr,gui_font_menu) 0] != "T"} {
            eval font configure $prefs::gui_font_menu $vTcl(pr,gui_font_menu)
        } else {
            eval font configure $prefs::gui_font_menu \
                [font actual $vTcl(pr,gui_font_menu)]
        }
    }
}

proc {vTcl:prefs:basics} {tab} {

    #vTcl:formCompound:add $tab checkbutton \
        -text "Use balloon help" \
        -variable prefs::balloon
    #vTcl:formCompound:add $tab checkbutton \
        -text "Ask for widget name on insert" \
        -variable prefs::getname
    #vTcl:formCompound:add $tab checkbutton \
        -text "Short automatic widget names" \
        -variable prefs::shortname
    #vTcl:formCompound:add $tab checkbutton \
        -text "Window focus selects window" \
        -variable prefs::winfocus
    #vTcl:formCompound:add $tab checkbutton \
        -text "Auto place new widgets" \
        -variable prefs::autoplace
    #vTcl:formCompound:add $tab checkbutton \
        -text "Use widget command aliasing" \
        -variable prefs::cmdalias
    vTcl:formCompound:add $tab checkbutton \
        -text "Use auto-aliasing for new widgets" \
        -variable prefs::autoalias
    #vTcl:formCompound:add $tab checkbutton \
        -text "Use continuous widget placement" \
        -variable prefs::multiplace
    #vTcl:formCompound:add $tab checkbutton \
        -text "Save project info in project file" \
        -variable prefs::projfile
    vTcl:formCompound:add $tab checkbutton \
        -text "Generate Python with relative placement" \
        -variable prefs::relative_placement   ;# Rozen

    vTcl:prefs:grid $tab

# Rozenset vTcl(pr,bgcolor) ""

#     vTcl:formCompound:add $tab checkbutton \
#         -text "Auto load compounds from file:" \
#         -variable prefs::autoloadcomp

#     set form_entry [vTcl:formCompound:add $tab frame]
#     pack configure $form_entry -fill x

#     set entry [vTcl:formCompound:add $form_entry entry \
#         -textvariable prefs::autoloadcompfile]
#     pack configure $entry -fill x -padx 2 -side left -expand 1

#     set browse_file [vTcl:formCompound:add $form_entry ::vTcl::BrowseButton\
#         -command "vTcl:prefs:browse_file prefs::autoloadcompfile"]
#     pack configure $browse_file -side right
}

proc {vTcl:prefs:browse_file} {varname} {

    global widget tk_strictMotif

    eval set value $$varname
    set types {
        {{Tcl Files} *.tcl}
        {{All Files} * }
    }

    set tk_strictMotif 0
    set newfile [tk_getOpenFile -filetypes $types]
    set tk_strictMotif 1

    if {$newfile != ""} {
       set $varname $newfile
    }
}

proc {vTcl:prefs:browse_font} {fontname} {
    global widget
    set value [font configure $fontname]

    foreach {op v} $value {
        if {$op == "-size"} {
            if {$v < 0} {
                set v [string range $v 1 end]
            }
        }
        lappend new_value $op $v
    }
    set newfont [vTcl:font:prompt_user_font_2 $new_value]
    if {$newfont != ""} {
        eval font configure $fontname $newfont
    }
}
proc {vTcl:prefs:use_Tk_default_font} {fontname font} {
    # Stuff to return a name which is the TkFont name
    # Called from line 608 this file.
#        eval font configure $fontname $font
}

proc {vTcl:prefs:use_TkMenuFont} {fontname} {
    global widget
    set value [font configure "TkMenuFont"]

    foreach {op v} $value {
        if {$op == "-size"} {
            if {$v < 0} {
                set v [string range $v 1 end]
            }
        }
        lappend new_value $op $v
    }
    eval font configure $fontname $new_value
}

proc vTcl:prefs:change_font {font_input} {
    # Added to allow one to change from a Tk default font
    # specification to a new specification without changing the
    # default font itself. If the font specification is a default
    # font, it creates a new font like the default and then allows the
    # user to change that font. Rozen 10/7/13

    if {[string range [set $font_input] 0 1] == "Tk"} {
        set Tk_desc [font configure [set $font_input]]
        set font_name [vTcl:font:add_font $Tk_desc stock {} 0]
    } else {
        set font_name [set $font_input]
    }

    vTcl:prefs:browse_font $font_name
    set [set font_input]  $font_name
}

proc {vTcl:prefs:fonts} {tab} {
    global widget


    # "vTcl:prefs:browse_font variable" changes "variable" to be the
    # font_name of the font just created.  It will be something like
    # font10.

    set last  [vTcl:formCompound:add $tab  label \
      -text "PAGE default font" -background grey -relief raised \
                   -foreground white]
    pack configure $last -fill x

    set font_frame [vTcl:formCompound:add $tab frame]
    pack configure $font_frame -fill x
    set last [vTcl:formCompound:add $font_frame label \
        -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
        -justify left -font $prefs::font_dft]
    pack configure $last -side left
    set last [vTcl:formCompound:add $font_frame button \
        -text "Change ..." \
        -command "vTcl:prefs:browse_font $prefs::font_dft"]
    pack configure $last -side right

    vTcl:formCompound:add $tab  label -text ""


    # Rozen. I am still trying to figure if this is really usefull
    set last  [vTcl:formCompound:add $tab  label \
        -text "PAGE fixed width font" -background gray -relief raised \
                   -foreground white]
    pack configure $last -fill x

    set font_frame [vTcl:formCompound:add $tab frame]
    pack configure $font_frame -fill x
    set last [vTcl:formCompound:add $font_frame label \
        -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
        -justify left -font $prefs::font_fixed]
    pack configure $last -side left
    set last [vTcl:formCompound:add $font_frame button \
        -text "Change ..." \
        -command "vTcl:prefs:browse_font $prefs::font_fixed"]
    pack configure $last -side right
    vTcl:formCompound:add $tab  label -text ""

# Gui Default Font.
    set last  [vTcl:formCompound:add $tab  label \
        -text "GUI default font" -background grey -relief raised \
                   -foreground white]
    pack configure $last -fill x
    set font_frame [vTcl:formCompound:add $tab frame]
    pack configure $font_frame -fill x

    set default_font_label [vTcl:formCompound:add $font_frame label \
        -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
        -justify left -font $prefs::gui_font_dft]
    pack configure $default_font_label -side left

    # New 10/3/13
    # If we are changing the font and it was a Tk default font then
    # we should go back to a new font and not change the value of the T
    # font.
    set button_frame [vTcl:formCompound:add $font_frame frame]
    button $button_frame.change \
        -text "Change ..." \
        -command "vTcl:prefs:change_font prefs::gui_font_dft
                 $default_font_label configure -font \$prefs::gui_font_dft"
    pack configure $button_frame.change -side top

    button $button_frame.default \
        -text TkDefaultFont \
        -command "$default_font_label configure -font TkDefaultFont
                  set prefs::gui_font_dft TkDefaultFont"
    # The stuff immediately above gets the default font displayed in the
    # prefs font window.
    pack $button_frame.default -side right
    pack $button_frame -side right

    # Old Stuff 10/3/13
    # set last [vTcl:formCompound:add $font_frame button \black
    #     -text "Change ..." \
    #     -command "vTcl:prefs:browse_font $prefs::gui_font_dft"]
    # pack configure $last -side right

    # vTcl:formCompound:add $tab  label -text ""

# GUI Fixed Width Font
    set last  [vTcl:formCompound:add $tab  label \
        -text "GUI fixed width font" -background gray -relief raised \
                   -foreground white]
    pack configure $last -fill x
    set font_frame [vTcl:formCompound:add $tab frame]
    pack configure $font_frame -fill x
    set fixed_font_label [vTcl:formCompound:add $font_frame label \
        -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
        -justify left -font $prefs::gui_font_fixed]
    pack configure $fixed_font_label -side left
    # New 10-9-13
    set button_frame [vTcl:formCompound:add $font_frame frame]
    button $button_frame.change \
        -text "Change ..." \
        -command "vTcl:prefs:change_font prefs::gui_font_fixed
                 $fixed_font_label configure -font \$prefs::gui_font_fixed"
    pack configure $button_frame.change -side top

    button $button_frame.default \
        -text TkFixedFont \
        -command "$fixed_font_label configure -font TkFixedFont
                  set prefs::gui_font_fixed TkFixedFont"
    # The stuff immediately above gets the default font displayed in the
    # prefs font window.
    pack $button_frame.default -side right
    pack $button_frame -side right




    # Old stuff 10-9-13
    # set last [vTcl:formCompound:add $font_frame button \
    #     -text "Change ..." \
    #     -command "vTcl:prefs:browse_font $prefs::gui_font_fixed"]
    # pack configure $last -side right
    # vTcl:formCompound:add $tab  label -text ""

# GUI text font
    set last  [vTcl:formCompound:add $tab  label \
        -text "GUI text font" -background gray -relief raised \
                   -foreground white]
    pack configure $last -fill x

    set font_frame [vTcl:formCompound:add $tab frame]
    pack configure $font_frame -fill x
    set text_font_label [vTcl:formCompound:add $font_frame label \
        -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
        -justify left -font $prefs::gui_font_text]
    pack configure $text_font_label -side left
    # New 10-9-13
    set button_frame [vTcl:formCompound:add $font_frame frame]
    button $button_frame.change \
        -text "Change ..." \
        -command "vTcl:prefs:change_font prefs::gui_font_text
                 $text_font_label configure -font \$prefs::gui_font_text"
    pack configure $button_frame.change -side top

    button $button_frame.default \
        -text TkTextFont \
        -command "$text_font_label configure -font TkTextFont
                  set prefs::gui_font_text TkTextFont"
    # The stuff immediately above gets the default font displayed in the
    # prefs font window.
    pack $button_frame.default -side right
    pack $button_frame -side right

    # Old stuff 10-9-13
    # set last [vTcl:formCompound:add $font_frame button \
    #     -text "Change ..." \
    #     -command "vTcl:prefs:browse_font $prefs::gui_font_text"]
    # pack configure $last -side right
    # vTcl:formCompound:add $tab  label -text ""

# GUI Menu Font
    # Rozen. I want to be able to set the menu font.
    set last  [vTcl:formCompound:add $tab  label \
        -text "GUI Menu font" -background grey -relief raised \
                   -foreground white]
    pack configure $last -fill x

    set font_frame [vTcl:formCompound:add $tab frame]
    pack configure $font_frame -fill x

    set menu_font_label [vTcl:formCompound:add $font_frame label \
        -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
        -justify left -font $prefs::gui_font_menu]
    pack configure $menu_font_label -side left

    # Rozen Trying to get a frame for the buttons on the right.  New Stuff 9-1-13
    # This sort of works but I would like to have the two buttons in the
    # row above.  NEEDS WORK
    # tab us set in line 117.
    set button_frame [vTcl:formCompound:add $font_frame frame]
    button $button_frame.change \
        -text "Change ..." \
        -command "vTcl:prefs:browse_font $prefs::gui_font_menu
                  $menu_font_label configure -font \$prefs::gui_font_menu"
    pack configure $button_frame.change -side top

    button $button_frame.default \
        -text TkMenuFont \
        -command "$menu_font_label configure -font TkMenuFont
                  set vTcl(actual_gui_font_menu_name) TkMenuFont"
    # The stuff immediately above gets the default font displayed in the
    # prefs font window.
    pack $button_frame.default -side right
    pack $button_frame -side right
    #pack configure $last -side bottom
    #pack configure $last -fill x
    # End New stuff

    # Next four lines original
    # set last [vTcl:formCompound:add $font_frame button \
    #     -text "Change ..." \
    #     -command "vTcl:prefs:browse_font $prefs::gui_font_menu"]
    # pack configure $last -side right     new_value


    # My attempt to add button for specifying TkMenuFont   NEEDS WORK
    # set last [vTcl:formCompound:add $font_frame button \
    #     -text "TkMenuFont" \
    #     -command "vTcl:prefs:use_TkMenuFont $prefs::gui_font_menu"]
    # pack configure $last -side right   ;# puts button bottom   next to change button.

    # More new stuff
# Try again later.   NEEDS WORK!!!!
#    set last [vTcl:formCompound:add $button_frame button \
#        -text "TkMenuFont" \
#        -command "vTcl:prefs:use_Tk_default_font prefs::gui_font_menu \
#             \"TkMenuFont\""]
#    pack configure $last -side right   ;# puts button next to change button.

#        -command "vTcl:prefs:use_TkMenuFont $prefs::gui_font_menu"] # Works
    # End new stuff
    # pack configure $last -fill x
}

proc {vTcl:prefs:gui_fonts} {tab} {

    # global widget

    # set last  [vTcl:formCompound:add $tab  label \
    #     -text "Dialog font" -background gray -relief raised]
    # pack configure $last -fill x

    # set font_frame [vTcl:formCompound:add $tab frame]
    # pack configure $font_frame -fill x
    # set last [vTcl:formCompound:add $font_frame label \
    #     -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
    #     -justify left -font $prefs::font_dft]
    # pack configure $last -side left
    # set last [vTcl:formCompound:add $font_frame button \
    #     -text "Change..." \
    #     -command "vTcl:prefs:browse_font $prefs::font_dft"]
    # pack configure $last -side right

    # vTcl:formCompound:add $tab  label -text ""

    # set last  [vTcl:formCompound:add $tab  label \
    #     -text "Fixed width font" -background gray -relief raised]
    # pack configure $last -fill x

    # set font_frame [vTcl:formCompound:add $tab frame]
    # pack configure $font_frame -fill x
    # set last [vTcl:formCompound:add $font_frame label \
    #     -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
    #     -justify left -font $prefs::font_fixed]
    # pack configure $last -side left
    # set last [vTcl:formCompound:add $font_frame button \
    #     -text "Change..." \
    #     -command "vTcl:prefs:browse_font $prefs::font_fixed"]
    # pack configure $last -side right
    # vTcl:formCompound:add $tab  label -text ""
    # # Rozen. I want to be able to set the menu font.
    # set last  [vTcl:formCompound:add $tab  label \
    #     -text "Menu font" -background gray -relief raised]
    # pack configure $last -fill x

#     set font_frame [vTcl:formCompound:add $tab frame]
#     pack configure $font_frame -fill x
#     set last [vTcl:formCompound:add $font_frame label \
#         -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
#         -justify left -font $prefs::gui_font_menu]
#     pack configure $last -side left
#     set last [vTcl:formCompound:add $font_frame button \
#         -text "Change..." \
#         -command "vTcl:prefs:browse_font $prefs::gui_font_menu"]
#     pack configure $last -side right
#     # My attempt to add button for specifying TkMenuFont
#     # set last [vTcl:formCompound:add $font_frame button \
#     #     -text "TkMenuFont" \
#     #     -command "vTcl:prefs:use_TkMenuFont $prefs::gui_font_menu"]
#     # pack configure $last -side right
 }

proc vTcl:prefs:bgcolor_get {w} {
    if {[string equal $::prefs::bgcolor ""]} {
        set initial "#d9d9d9"
    } else {
        set initial $::prefs::bgcolor
    }
    set color [vTcl:get_color $initial $w "PAGE background"] ;# Added 3rd parm
    if {![string equal $color ""]} {
        set prefs::bgcolor $color
    }
}

proc vTcl:prefs:guibgcolor_get {w} {
    # Rozen. Written to get the background color for the generated GUI.
    if {[string equal $::prefs::guibgcolor ""]} {
        set initial "#d9d9d9"
    } else {
        set initial $::prefs::guibgcolor
    }
    set color [vTcl:get_color $initial $w "GUI background"]
    if {![string equal $color ""]} {
        set prefs::guibgcolor $color
    }
}

proc vTcl:prefs:get_default_color {w visual variable} {
    global vTcl
    set v [split $variable :]
    set name [lrange $v end end]
    set default_name "tk_default_$name"
    set color $vTcl($default_name)
    if {![string equal $color ""]} {
        set $variable $color
        $visual configure -bg $color
    }
}

proc vTcl:prefs:color_pref_get {w visual variable} {
    set initial [vTcl:at $variable]
    set color [vTcl:get_color $initial $w]
    if {![string equal $color ""]} {
        set $variable $color
        $visual configure -bg $color
    }
#TRY THIS BINGO
    if {$variable == "::prefs::guibgcolor"} {
        set ::prefs::guicomplement_color \
            [::colorDlg::complement  $::prefs::guibgcolor]
        set analog_colors [::colorDlg::analogous_colors  $::prefs::guibgcolor]
        lassign $analog_colors ::prefs::guianalog_color_p \
            ::prefs::guianalog_color_m
    }

}

proc vTcl:prefs:color_pref {w text variable} {
    set color_frame [vTcl:formCompound:add $w frame]
    pack configure $color_frame -fill x
    set last [vTcl:formCompound:add $color_frame label \
        -text $text -justify left]
    pack configure $last -side left -anchor e

    #set browse [vTcl:formCompound:add $color_frame ::vTcl::BrowseButton]
    set browse [vTcl:formCompound:add $color_frame button \
                    -text "Browse colors ..." -font 10]
    pack configure $browse -side right
    set last [vTcl:formCompound:add $color_frame label \
                  -relief raised \
                -text "" -bg [vTcl:at $variable] -width 8 ]
    pack configure $last -side right -padx 1 -pady 1
    $browse configure -command "vTcl:prefs:color_pref_get $last $last $variable"
    # Rozen, adding reset button.
    set default [vTcl:formCompound:add $color_frame button \
                 -text "Default color" -font 10 \
                 -command "vTcl:prefs:get_default_color $last $last $variable"]
    pack configure $default -side right
    # Rozen, end of reset button.}



proc {vTcl:prefs:bgcolor} {tab} {
    global vTcl                    ;# Rozen
    # Proc where we set color preferences.
    switch $prefs::bgcolor {
        ""                          {set prefs::bgcolortype auto}
        "$vTcl(tk_default_bgcolor)" {set prefs::bgcolortype default}
        default                     {set prefs::bgcolortype custom}
    }
    switch $prefs::guibgcolor {
        "$vTcl(tk_default_bgcolor)" {set prefs::guibgcolortype default}
        default                     {set prefs::guibgcolortype custom}
    }

    ## Rozen.  Chunk to set PAGE colors
    set last  [vTcl:formCompound:add $tab  label \
    -text "PAGE Colors" -background gray -relief raised -foreground white]
    #-text "PAGE Background Color" -background gray -relief raised]
    pack configure $last -fill x
    vTcl:formCompound:add $tab  label -text ""
    vTcl:prefs:color_pref $tab "Background color" \
    ::prefs::bgcolor

    vTcl:formCompound:add $tab  label -text ""
    # Chunk End

    #set last  [vTcl:formCompound:add $tab  label \
    #-text "PAGE Foreground Color" -background gray -relief raised]
    pack configure $last -fill x

    vTcl:prefs:color_pref $tab "Foreground color" \
    ::prefs::fgcolor
    vTcl:formCompound:add $tab  label -text ""

    ## Rozen Chunk to set Widget Tree colors
    #set last  [vTcl:formCompound:add $tab  label \
    #-text "PAGE Widget Tree" -background gray -relief raised]
    pack configure $last -fill x

    vTcl:prefs:color_pref $tab "Widget Tree highlight" \
              ::prefs::treehighlight
    vTcl:formCompound:add $tab  label -text ""


    ## Rozen.  Chunk to set GUI Background Colors
    set last  [vTcl:formCompound:add $tab  label \
    -text "GUI Colors" -background gray -relief raised -foreground white]
    pack configure $last -fill x
    vTcl:formCompound:add $tab  label -text ""
    vTcl:prefs:color_pref $tab "GUI Background color" \
    ::prefs::guibgcolor

    vTcl:formCompound:add $tab  label -text ""

    ## Rozen.  Chunk to set GUI Background Colors
    #set last  [vTcl:formCompound:add $tab  label \
    #-text "GUI Foreground Color" -background gray -relief raised]
    pack configure $last -fill x

    # vTcl:formCompound:add $tab radiobutton \
    # -text "Use GUI default color" \
    # -variable prefs::bgcolortype -value default \
    # -command "set prefs::guibgcolor $vTcl(tk_default_bgcolor)"


    # set last [vTcl:formCompound:add $tab radiobutton \
    # -text "Choose a custom color" \
    # -variable prefs::bgcolortype -value custom]
    # $last configure -command "vTcl:prefs:guibgcolor_get $last"

    vTcl:prefs:color_pref $tab "GUI Foreground color" \
        ::prefs::guifgcolor
    vTcl:formCompound:add $tab  label -text ""
    # Chunk End

    ##-----------------------------------------------------------------------
    #vTcl:DefineAlias "$tab.tEn36" "TEntry2" vTcl:WidgetProc "Tablevel1" 1

    # Removed 11/10/12
    # set last  [vTcl:formCompound:add $tab  label \
    # -text "Entries" -background gray -relief raised]
    # pack configure $last -fill x

    # vTcl:prefs:color_pref $tab "Entry background color" ::prefs::entrybgcolor
    # vTcl:prefs:color_pref $tab "Entry active color" ::prefs::entryactivecolor

    ##----------------------------------------------------------------
    # Following added by Rozen. 11/6/12
    # set last  [vTcl:formCompound:add $tab  label \
    # -text "GUI Entries" -background gray -relief raised]
    # pack configure $last -fill x

    # vTcl:prefs:color_pref $tab "Entry background color" ::prefs::guientrybgcolor
    # vTcl:prefs:color_pref $tab "Entry active color" ::prefs::guientryactivecolor

    ##-----------------------------------------------------------------------

    # Removed 11/19/12
    # set last  [vTcl:formCompound:add $tab  label \
    # -text "Listboxes" -background gray -relief raised]
    # pack configure $last -fill x

    # vTcl:prefs:color_pref $tab "Listbox background color" ::prefs::listboxbgcolor

    ##-----------------------------------------------------------------------
    # Group added by Rozen. 11/6/12
    # set last  [vTcl:formCompound:add $tab  label \
    # -text "GUI Listboxes" -background gray -relief raised]
    # pack configure $last -fill x

    # vTcl:prefs:color_pref $tab "Listbox background color" \
    #            ::prefs::guilistboxbgcolor

    ##---------------------------------- Rozen ------------------------------

    #set last  [vTcl:formCompound:add $tab  label \
    #-text "GUI Menus" -background gray -relief raised]
    pack configure $last -fill x
    vTcl:prefs:color_pref $tab "Menu background color" ::prefs::menubgcolor
    vTcl:formCompound:add $tab  label -text ""
    vTcl:prefs:color_pref $tab "Menu foreground color" ::prefs::menufgcolor
}

proc {vTcl:prefs:project} {tab} {

    Global widget

    set last  [vTcl:formCompound:add $tab  label \
        -text "Option encaps" -background gray -relief raised]
    pack configure $last -fill x

    vTcl:formCompound:add $tab radiobutton  \
        -text "List"   -variable prefs::encase -value list -pady 0
    vTcl:formCompound:add $tab radiobutton  \
        -text "Braces" -variable prefs::encase -value brace -pady 0
    vTcl:formCompound:add $tab radiobutton  \
        -text "Quotes" -variable prefs::encase -value quote -pady 0

    #======================================================================

    set last  [vTcl:formCompound:add $tab  label \
        -text "Project type" -background gray -relief raised]
    pack configure $last -fill x

    vTcl:formCompound:add $tab radiobutton -pady 0 \
        -text "Single file project" -variable prefs::projecttype -value single
    vTcl:formCompound:add $tab radiobutton -pady 0 \
        -text "Multiple file project" -variable prefs::projecttype -value multiple

    #======================================================================

    set last  [vTcl:formCompound:add $tab  label \
        -text "Default manager" -background gray -relief raised]
    pack configure $last -fill x

    vTcl:formCompound:add $tab radiobutton  \
        -text "Grid" -variable prefs::manager -value grid -pady 0
    vTcl:formCompound:add $tab radiobutton  \
        -text "Pack" -variable prefs::manager -value pack -pady 0
    vTcl:formCompound:add $tab radiobutton  \
        -text "Place" -variable prefs::manager -value place -pady 0

    #======================================================================

    set last  [vTcl:formCompound:add $tab  label \
        -text "Source file" -background gray -relief raised]
    pack configure $last -fill x

    vTcl:formCompound:add $tab checkbutton  \
        -text "Save as executable" -variable prefs::saveasexecutable
}

proc {vTcl:prefs:images} {tab} {

    global widget

    vTcl:formCompound:add $tab label \
        -text "Editor for images"

    set form_entry [vTcl:formCompound:add $tab frame]
    pack configure $form_entry -fill x

    set last [vTcl:formCompound:add $form_entry entry  \
        -textvariable prefs::imageeditor]
    pack configure $last -fill x -expand 1 -padx 2 -side left

    set last [vTcl:formCompound:add $form_entry ::vTcl::BrowseButton \
        -command "vTcl:prefs:browse_file prefs::imageeditor"]
    pack configure $last -side right

    vTcl:formCompound:add $tab checkbutton \
        -text "Save images as inline" -variable prefs::saveimagesinline
}

proc vTcl:prefs:libs {tab} {
    set last  [vTcl:formCompound:add $tab  label \
    -text "Load libs on startup" -background gray -relief raised]
    pack configure $last -fill x

    set last [vTcl:formCompound:add $tab listbox -background white -selectmode multiple]
    pack configure $last -fill both -expand 1 -pady 5

    set ::prefs::libsListbox $last
    vTcl:prefs:fillLibs
}

proc vTcl:prefs:fillLibs {} {

    ## not yet initialized?
    if {![info exists ::prefs::libsListbox]} {
        return
    }

    set libs [glob -nocomplain [file join $::vTcl(VTCL_HOME) lib lib*.tcl]]
    set i 0
    foreach load [::vTcl::project::getLibrariesToLoad] {
        lappend toload [file tail $load]
    }
    set listbox [set ::prefs::libsListbox]
    $listbox delete 0 end
    foreach lib $libs {
        set item [file tail $lib]
        $listbox insert end $item
        if {[lsearch -exact $toload $item] != -1} {
            $listbox selection set $i
        }
        incr i
    }
}

proc vTcl:prefs:saveLibs {} {
    set listbox [set ::prefs::libsListbox]
    set indices [$listbox curselection]
    if {$indices == ""} {
        ## selection cannot be empty because
        ## 1) at least one lib must be selected
        ## 2) if the listbox is not in focus it will lose the selection
        return
    }

    set libs ""
    foreach index $indices {
        lappend libs [$listbox get $index]
    }


    set before [::vTcl::project::getLibrariesToLoad]
    ::vTcl::project::setLibrariesToLoad $libs
    set after [::vTcl::project::getLibrariesToLoad]

    if {$before != $after} {
        ::vTcl::MessageBox -icon info \
        -message "Library changes will be valid the next time you start vTcl." \
            -title "Information" -type ok
    }
}

proc vTcl:prefs:external {tab} {
    global widget

    vTcl:formCompound:add $tab label -text "External Editor"
    set f [vTcl:formCompound:add $tab frame]
    pack configure $f -fill x
    set x [vTcl:formCompound:add $f entry -textvariable prefs::texteditor]
    pack configure $x -fill x -expand 1 -side left -padx 2

    set x [vTcl:formCompound:add $f ::vTcl::BrowseButton \
    -command "vTcl:prefs:browse_file prefs::texteditor"]
    pack configure $x -side left -anchor nw
}


proc vTcl:prefs:grid {tab} {
    # Rozen.  Added to allow user to set grid preferences.
    global vTcl

    ttk::label $tab.tLa33 \
        -relief flat -text {Grid Width}  -background $vTcl(pr,bgcolor) \
        -foreground $vTcl(pr,fgcolor)
    ttk::entry $tab.tEn34 \
        -textvariable vTcl(grid,x) -justify right -width  5
    ttk::label $tab.tLa35 \
        -relief flat -text {Grid Height}  -background $vTcl(pr,bgcolor) \
        -foreground $vTcl(pr,fgcolor)
    ttk::entry $tab.tEn36 \
        -textvariable vTcl(grid,y)  -justify right -width  5

    ###################
    # SETTING GEOMETRY
    ###################
    place $tab.tLa33 \
        -in $tab -x 25 -y 100 -anchor nw -bordermode ignore
    place $tab.tEn34 \
        -in $tab -x 240 -y 100 -anchor nw -bordermode ignore
    place $tab.tLa35 \
        -in $tab -x 25 -y 150 -anchor nw -bordermode ignore
    place $tab.tEn36 \
        -in $tab -x 240 -y 150 -anchor nw -bordermode ignore


}