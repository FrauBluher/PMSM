##############################################################################
# $Id: font.tcl,v 1.3 2013/09/02 00:36:23 rozen Exp rozen $
#
# font.tcl - procedures to select a font and return its description
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

# vTcl:font:add_font
# vTcl:font:init_stock
# vTcl:font:prompt_user_font

proc vTcl:font:prompt_user_font.no {target option} {
    global vTcl
    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"

    if {[catch {set font_desc [$target cget $option]}] == 1} { return }

    vTcl:log "prompt_user_font: base=$base, font=$font_desc"

    set r [vTcl:font:prompt_noborder_fontlist $font_desc]
    if {$r == ""} {
        return
    } else {
        $target configure $option $r

        # refresh property manager
        vTcl:update_widget_info $target
        vTcl:prop:update_attr
    }
}

proc vTcl:font:prompt_user_font {target option} {
    # Rozen's version.
    # I didn't seem to have something loaded that was required
    # for the original version.  However, I really did not like that
    # noborder window with choices that I never made.  I really wanted
    # to get rid of it.  Will play this game for a while.
    global vTcl
    set font [$target cget $option]

    if {[catch {set font_desc [$target cget $option]}] == 1} { return }

    #set font_desc [vTcl:font:prompt_user_font_2 "-family helvetica -size 12"]
    set font_desc [vTcl:font:prompt_user_font_2 $font_desc]

    if {$font_desc == ""} {
        if {$font in $vTcl(standard_fonts)} {
            return
        }
    }
    set vTcl(font,noborder_fontlist,font) \
                [vTcl:font:add_font $font_desc user]
    # refresh font manager
    vTcl:font:refresh_manager 1.0
    set r $vTcl(font,noborder_fontlist,font)
    if {$r == ""} {
        return
    } else {
        $target configure $option $r
        # refresh property manager
        vTcl:update_widget_info $target
        vTcl:prop:update_attr
    }
}

proc vTcl:font:prompt_user_font_2 {font_desc} {
    global vTcl
    set base .vTcl.fontmgr
    set r [::ChooseFont::ChooseFont $font_desc]
              #-background $vTcl(pr,bgcolor)]
    #set r [SelectFont .vTcl.fontmgr -font $font_desc \
              -background $vTcl(pr,bgcolor)]

    if {$r != ""} {
        set r [font actual $r]
    } else {
        set r $font_desc
    }

    # set r [vTcl:font:get_font_dft $base $font_desc]
    return $r
}

proc vTcl:font:init_stock {} {
    set ::vTcl(fonts,objects) ""
    set ::vTcl(fonts,counter) 0

    # stock fontsactual_gui_font_dft_name
    vTcl:font:add_font "-family helvetica -size 12"              stock
    vTcl:font:add_font "-family helvetica -size 12 -underline 1" stock underline
    vTcl:font:add_font "-family courier -size 12"                stock
    vTcl:font:add_font "-family times -size 12"                  stock
    vTcl:font:add_font "-family helvetica -size 12 -weight bold" stockactual_gui_font_dft_name
    vTcl:font:add_font "-family courier -size 12 -weight bold"   stock
    vTcl:font:add_font "-family times -size 12 -weight bold"     stock
    vTcl:font:add_font "-family lucida -size 18"                 stock
    vTcl:font:add_font "-family lucida -size 18 -slant italic"   stock
    # Rozen
    global vTcl
    set gd [is_default_font gui_font_dft]
    set vTcl(font,gui_font_dft) $gd

    set gt [is_default_font gui_font_text]
    set vTcl(font,gui_font_text) $gt

    set gf [is_default_font gui_font_fixed]
    set vTcl(font,gui_font_fixed) $gf

    set gm [is_default_font gui_font_menu]
    set vTcl(font,gui_font_menu) $gm

    set vTcl(default_gui_font_names) [list $gd $gt $gf $gm]

    # In case we do not load an existing GUI-tcl file.actual_gui_font_dft_name
    # These are names like 'font10', 'font11', and 'font12'.
    set vTcl(actual_gui_font_dft_name) $gd     ;# $vTcl(font,gui_font_dft)
    set vTcl(actual_gui_font_text_name) $gt    ;# $vTcl(font,gui_font_text)
    set vTcl(actual_gui_font_fixed_name) $gf   ;# $vTcl(font,gui_font_fixed)
    set vTcl(actual_gui_font_menu_name) $gm   ;# $vTcl(font,gui_font_menu)

    # These are descriptions like "-family times -size 12 -weight bold".
    # I don't think that I need this block of code.  10/13
    # set vTcl(actual_gui_font_dft_desc) $vTcl(pr,gui_font_dft)
    # set vTcl(actual_gui_font_text_desc) $vTcl(pr,gui_font_text)
    # set vTcl(actual_gui_font_fixed_desc) $vTcl(pr,gui_font_fixed)
    # set vTcl(actual_gui_font_menu_desc) $vTcl(pr,gui_font_menu)
}

proc is_default_font {font} {
    # Check to see if the default font is one of the tk default fonts.
    global vTcl
    if { [string index $vTcl(pr,$font) 0] != "T"} {
        set gd [vTcl:font:add_font $vTcl(pr,$font) stock]
    } else {
        set gd $vTcl(pr,$font)
    }
    return $gd
}

proc vTcl:font:get_type {object} {
    return $::vTcl(fonts,$object,type)
}

proc vTcl:font:get_key {object} {
    return $::vTcl(fonts,$object,key)
}

proc vTcl:font:get_descr {object} {
    return $::vTcl(fonts,$object,font_descr)
}

proc vTcl:font:get_font {key} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.
    if {[info exists ::vTcl(fonts,$key,object)]} then {
        return $::vTcl(fonts,$key,object)
    } else {
        return ""
    }
}

proc vTcl:font:getFontFromDescr {font_descr} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.
    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
        return $::vTcl(fonts,$font_descr,object)
    } else {
        return ""
    }
}

# set standard_fonts [list \
#                         TkDefaultFont \
#                         TkTextFont \
#                         TkFixedFont \
#                         TkMenuFont \
#                         TkHeadingFont \
#                         TkCaptionFont \
#                         TkSmallCaptionFont \
#                         TkIconFont \
#                         TkTooltipFont ]

set vTcl(standard_fonts) [font names]   ;# Same result as the above comment.

proc {vTcl:font:add_font} {font_descr font_type {newkey {}} {check_fonts {1}}} {
    global vTcl

    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.
    set defined_fonts [font names]
    if {$check_fonts} {
        if {[info exists ::vTcl(fonts,$font_descr,object)]} {
            # It already exists
            return $::vTcl(fonts,$font_descr,object)
        }
        if {[lsearch $defined_fonts) $font_descr] > -1} {
            # It's a font already defined..
            return $font_descr
        }
    }

    incr ::vTcl(fonts,counter)
    set newfont [eval font create $font_descr]
    lappend ::vTcl(fonts,objects) $newfont

     ## each font has its unique key so that when a project is
     ## reloaded, the key is used to find the font description
    if {$newkey == ""} {
        set newkey vTcl:font$::vTcl(fonts,counter)

        ## let's find an unused font key
        while {[vTcl:font:get_font $newkey] != ""} {
            incr ::vTcl(fonts,counter)
            set newkey vTcl:font$::vTcl(fonts,counter)
        }
    }
     set ::vTcl(fonts,$newfont,type)       $font_type
     set ::vTcl(fonts,$newfont,key)        $newkey
     set ::vTcl(fonts,$newfont,font_descr) $font_descr
     set ::vTcl(fonts,$font_descr,object)  $newfont
     set ::vTcl(fonts,$newkey,object)      $newfont
     lappend ::vTcl(fonts,$font_type) $newfont

     ## in case caller needs it
     return $newfont
}

proc vTcl:font:add_GUI_font {font_name font_descr} {
    # This is called when we load an existing GUI-tcl file. It get rid
    # of actual fonts and replaces them with the definitions from the
    # GUI-tcl file.

    #set font_descr [font configure $font_name]
    if {[catch {
        font delete $font_name
        set newfont [font create $font_name  {*}$font_descr ]
    } result]} {
        # Create failed
        set newfont "TkDefaultFont"
    }



     #set newkey NEEDS WORK
     #set ::vTcl(fonts,$newfont,type)       $font_type
     #set ::vTcl(fonts,$newfont,key)        $newkey
     set ::vTcl(fonts,$newfont,font_descr) $font_descr
     set ::vTcl(fonts,$font_descr,object)  $newfont  ;# Rozen 8/24/13
     #set ::vTcl(fonts,$newkey,object)      $newfont

}

proc vTcl:font:delete_font {key} {
     global vTcl

     set object $vTcl(fonts,$key,object)
     set font_descr $vTcl(fonts,$object,font_descr)

     set index [lsearch -exact $vTcl(fonts,objects) $object]
     set vTcl(fonts,objects) [lreplace $vTcl(fonts,objects) $index $index]

     font delete $object

     unset vTcl(fonts,$object,type)
     unset vTcl(fonts,$object,key)
     unset vTcl(fonts,$object,font_descr)
     unset vTcl(fonts,$key,object)
     unset vTcl(fonts,$font_descr,object)
}

proc vTcl:font:ask_delete_font {base} {
     global vTcl

     set object [vTcl:font:get_selected_font $base.cpd31]
     set key [vTcl:font:get_key $object]
     set descr [font configure $object]

     set result [
          ::vTcl::MessageBox \
        -message "Do you want to remove '$descr' from the project?" \
        -title "PAGE" \
        -type yesno \
        -icon question
     ]

     if {$result == "yes"} {
      set pos [vTcl:font:get_manager_position]

          vTcl:font:delete_font $key
          vTcl:font:refresh_manager $pos
     }
}

proc vTcl:font:remove_user_fonts {} {
     global vTcl

     foreach object $vTcl(fonts,objects) {
    if {$vTcl(fonts,$object,type) == "user"} {
        vTcl:font:delete_font $vTcl(fonts,$object,key)
    }
     }

     vTcl:font:refresh_manager
}

proc {vTcl:font:create_link} {t tag link_cmd} {
     global vTcl

     $t tag configure $tag -foreground blue  -font $vTcl(fonts,underline,object)

     $t tag bind $tag <Enter> "$t tag configure $tag -foreground red"
     $t tag bind $tag <Leave> "$t tag configure $tag -foreground blue"

     $t tag bind $tag <ButtonPress> "$link_cmd"
}

proc vTcl:font:display_fonts {base} {
     set t $base.cpd31

     if {![winfo exists $t]} {
        return
     }

     vTcl:font:display_fonts_in_text $t
}

proc {vTcl:font:display_fonts_in_text} {t} {
    global vTcl

    $t widget delete [$t widget items]

    set imageTextList {}
    foreach object $vTcl(fonts,objects) {

        set family [font configure $object -family]
        set size   [font configure $object -size]
        set weight [font configure $object -weight]
        set slant  [font configure $object -slant]
        set type   [vTcl:font:get_type $object]

        ## no image on left side, just a text
        lappend imageTextList "" "$family $size $weight $slant ($type)"
    }

    $t widget fill $imageTextList

    ## we can now set the font for each item
    set items [$t widget items]
    set i 0
    foreach object $vTcl(fonts,objects) {
        set item [lindex $items $i]
        $t widget itemconfigure $item -font $object
        incr i
    }
}

proc {vTcl:font:font_change} {base} {
     global vTcl

     set object [vTcl:font:get_selected_font $base.cpd31]
     set font_desc [font configure $object]
     vTcl:log "going to change: $font_desc"

     set font_desc [vTcl:font:prompt_user_font_2 $font_desc]

     if {$font_desc != ""} {

        vTcl:log "change font: $font_desc"
        eval font configure $object $font_desc

        set pos [vTcl:font:get_manager_position]
        vTcl:font:refresh_manager $pos
     }
}

proc vTcl:font:get_selected_font {imageListbox} {
    set item [$imageListbox widget selection get]
    if {$item == ""} {
        return ""
    }

    return [$imageListbox widget itemcget $item -font]
}

proc vTcl:font:enableButtons {base} {
    set font [vTcl:font:get_selected_font $base.cpd31]
    if {$font == ""} {
         set type stock
    } else {
         set type [vTcl:font:get_type $font]
    }

    set enabled(stock) disabled
    set enabled(user)  normal

    $base.butfr.but32 configure -state $enabled($type)
    $base.butfr.but33 configure -state $enabled($type)
}

proc vTclWindow.vTcl.fontManager {args} {
    global vTcl

    set base ""
    if {$base == ""} {
        set base .vTcl.fontManager
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    set vTcl(fonts,font_mgr,win) $base

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000
    wm withdraw $base
    wm focusmodel $base passive
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    update
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Font manager"
    wm transient .vTcl.fontManager .vTcl

    frame $base.butfr

    vTcl:toolbar_button $base.butfr.but30 \
        -command {set font_desc "-family {Helvetica} -size 12"

set font_desc [vTcl:font:prompt_user_font_2 $font_desc]

if {$font_desc != ""} {

   vTcl:log "new font: $font_desc"
   vTcl:font:add_font $font_desc user
   vTcl:font:display_fonts $vTcl(fonts,font_mgr,win)
   $vTcl(fonts,font_mgr,win).cpd31 widget yview moveto 1.0
}} \
        -padx 3 -pady 3 -image [vTcl:image:get_image add.gif]
    vTcl:toolbar_button $base.butfr.but32 \
         -command "vTcl:font:ask_delete_font $base" \
         -image [vTcl:image:get_image remove.gif] \
         -padx 3 -pady 3
    vTcl:toolbar_button $base.butfr.but33 \
         -command "vTcl:font:font_change $base" \
         -image [vTcl:image:get_image replace.gif] \
         -padx 3 -pady 3

    ::vTcl::OkButton $base.butfr.but31 -command "Window hide $base"

    vTcl::widgets::core::compoundcontainer::createCmd $base.cpd31 \
        -compoundType internal -compoundClass {Image Listbox}
    $base.cpd31 widget configure -padx 0
    bind $base.cpd31 <<ListboxSelect>> "
        vTcl:font:enableButtons $base
    "

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.butfr -side top -in $base -fill x
    pack $base.butfr.but30 \
        -anchor nw -expand 0 -fill none -side left
    vTcl:set_balloon $base.butfr.but30 "Add new font"
    pack $base.butfr.but32 \
        -anchor nw -expand 0 -fill none -side left
    vTcl:set_balloon $base.butfr.but32 "Delete selected font"
    pack $base.butfr.but33 \
        -anchor nw -expand 0 -fill none -side left
    vTcl:set_balloon $base.butfr.but33 "Change selected font"
    pack $base.butfr.but31 \
        -anchor nw -expand 0 -fill none -side right
    vTcl:set_balloon $base.butfr.but31 "Close"

    pack $base.cpd31 \
        -in $base -anchor center -expand 1 -fill both -side top

    wm geometry $base 491x544+314+132
    vTcl:center $base 491 544
    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base

    vTcl:font:display_fonts $base
    vTcl:font:enableButtons $base
    wm protocol $base WM_DELETE_WINDOW "wm withdraw $base"
    vTcl:setup_vTcl:bind $base
}

proc vTcl:font:prompt_font_manager {} {
    Window show .vTcl.fontManager
}

proc vTcl:font:dump_create_font {font} {
    return [list [list [vTcl:font:get_descr $font] \
                 [vTcl:font:get_type $font] \
                 [vTcl:font:get_key $font]]]
}

proc vTcl:font:generate_default_fonts {fileID} {
    # Rozen.  Code to bring in the default fonts for unix.  This seems
    # to be giving me fits because on OS X the original test if
    # {$tcl_platform(platform) != "unix"} return was satisfied on OS X
    # when I expected tcl_platform to return 'macintosh'.  so I
    # changed it to tcl_platform(os) != "Linux".  This will probably
    # not work on some Unix systems.
    global vTcl tcl_platform
    #catch {
        if {$tcl_platform(os) != "Linux"} return
        set font_names [font names]`
        foreach f {font10 font11 font12 font13} {
            if {[lsearch $font_names $f] > -1} {
                if {[lsearch $vTcl(default_gui_font_names) $f] > -1} {
                    puts $fileID "vTcl:font:add_GUI_font $f \\"
                    puts $fileID \"[font configure $f]\"
                }
            }
        }
    #}
}


proc vTcl:font:generate_font_stock {fileID} {
    global vTcl
    ## We didn't use any fonts.  We don't need this code.
    if {[lempty $vTcl(dump,stockFonts)] && [lempty $vTcl(dump,userFonts)]} {
        return
    }

    puts $fileID {#############################################################################}
    #  Rozen. Don't think I need this since I don't intend to run
    #  generated tcl file standalone.
return   # NEED WORK.
    puts $fileID "\# vTcl Code to Load Stock Fonts\n"
    puts $fileID "\nif {!\[info exist vTcl(sourcing)\]} \{"
    puts $fileID "set vTcl(fonts,counter) 0"
    foreach i {vTcl:font:add_font
               vTcl:font:getFontFromDescr} {
        puts $fileID [vTcl:dump_proc $i]
    }
    foreach font $vTcl(dump,stockFonts) {
        puts $fileID "vTcl:font:add_font \\"
        puts $fileID "    \"[vTcl:font:get_descr $font]\" \\"
        puts $fileID "    [vTcl:font:get_type $font] \\"
        puts $fileID "    [vTcl:font:get_key $font]"
    }

    puts $fileID "\}"
}

proc vTcl:font:generate_font_user {fileID} {
    global vTcl

    if {[lempty $vTcl(dump,userFonts)]} { return }

    puts $fileID {#############################################################################}
    puts $fileID "\# vTcl Code to Load User Fonts\n"

    foreach font $vTcl(dump,userFonts) {
    puts $fileID "vTcl:font:add_font \\"
    puts $fileID "    \"[vTcl:font:get_descr $font]\" \\"
    puts $fileID "    [vTcl:font:get_type $font] \\"
    puts $fileID "    [vTcl:font:get_key $font]"
    }
}

proc vTcl:font:create_noborder_fontlist {base} {
    if {$base == ""} {
        set base .vTcl.noborder_fontlist
    }

    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global vTcl
    global tcl_platform

    set vTcl(font,noborder_fontlist,win) $base
    set vTcl(font,noborder_fontlist,font) "nope"

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000
    wm focusmodel $base passive

    vTcl:prepare_pulldown $base 396 252

    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm resizable $base 1 1

    vTcl::widgets::core::compoundcontainer::createCmd $base.cpd29 \
        -compoundType internal -compoundClass {Image Listbox}
    $base.cpd29 widget configure -mouseover yes -padx 0
    bind $base.cpd29 <<ListboxSelect>> {
        vTcl:font:listboxSelect %W
    }

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side top

    vTcl:display_pulldown $base 396 252 \
        "set vTcl(font,noborder_fontlist,font) <cancel>"
    vTcl:font:fill_noborder_font_list $base.cpd29
}

proc vTcl:font:listboxSelect {l} {
    set item [$l widget selection get]
    set text [$l widget itemcget $item -text]
    set font [$l widget itemcget $item -font]

    if {$text == "New font..."} {
        set ::vTcl(font,noborder_fontlist,font) <new>
    } elseif {$text == "Cancel"} {
        set ::vTcl(font,noborder_fontlist,font) <cancel>
    } else {
        set ::vTcl(font,noborder_fontlist,font) $font
    }
}

proc {vTcl:font:fill_noborder_font_list} {t} {
    global vTcl

    # set a tab on the right side

    update
    $t widget delete [$t widget items]

    set imageTextList {}
    foreach object $vTcl(fonts,objects) {

        set family [font configure $object -family]
        set size   [font configure $object -size]
        set weight [font configure $object -weight]
        set slant  [font configure $object -slant]

        ## no image on left side, just a text
        lappend imageTextList "" "$family $size $weight $slant"
    }

    lappend imageTextList "" "New font..."

    lappend imageTextList "" "Cancel"

    $t widget fill $imageTextList

    ## we can now set the font for each item
    set items [$t widget items]
    set i 0
    foreach object $vTcl(fonts,objects) {
        set item [lindex $items $i]
        $t widget itemconfigure $item -font $object
        incr i
    }
}

proc vTcl:font:prompt_noborder_fontlist {font} {
    global vTcl
    vTcl:font:create_noborder_fontlist ""

    # do not reposition window according to root window
    vTcl:dialog_wait $vTcl(font,noborder_fontlist,win) vTcl(font,noborder_fontlist,font) 1
    destroy $vTcl(font,noborder_fontlist,win)
    # user wants a new font ?
    if {$vTcl(font,noborder_fontlist,font)=="<new>"} {
        set font_desc [vTcl:font:prompt_user_font_2 "-family helvetica -size 12"]
        if {$font_desc != ""} {
            set vTcl(font,noborder_fontlist,font) \
                [vTcl:font:add_font $font_desc user]

            # refresh font manager
            vTcl:font:refresh_manager 1.0

        } else {
            set vTcl(font,noborder_fontlist,font) ""
        }
    } elseif {$vTcl(font,noborder_fontlist,font)=="<cancel>"} {
        return $font
    }
    return $vTcl(font,noborder_fontlist,font)
}

proc vTcl:font:refresh_manager {{position 0.0}} {
    global vTcl

    if [info exists vTcl(fonts,font_mgr,win)] {
    if [winfo exists $vTcl(fonts,font_mgr,win)] {
        vTcl:font:display_fonts $vTcl(fonts,font_mgr,win)
        $vTcl(fonts,font_mgr,win).cpd31 widget yview moveto $position
    }
    }
}

proc vTcl:font:get_manager_position {} {
    global vTcl
    return [lindex [$vTcl(fonts,font_mgr,win).cpd31 widget yview] 0]
}

TranslateOption    -font vTcl:font:translate
NoEncaseOption     -font 1

proc vTcl:font:translate {value} {
    if [info exists ::vTcl(fonts,$value,font_descr)] {
    set value \
        "\[vTcl:font:getFontFromDescr \"$::vTcl(fonts,$value,font_descr)\"\]"
    }

    return $value
}

