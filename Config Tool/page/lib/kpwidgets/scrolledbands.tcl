##############################################################################
#
# scrolledbands.tcl - Widget designed for widget toolbar and attribute bar.
#                     Part of the vTcl Project.
#
# Copyright (C) 2005 Kenneth Parker
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
#This widget is a simply implimentation of a bands control. The technique used
#to create it should be improved before writing a wrapper class.
#kp stands for Kenneth Parker. Widgets that I create for the project will be put
#into this namespace.

   if {[catch {
               package require Itcl
               package require Itk
               package require Iwidgets
           } errorText]} {
             vTcl:log $errorText
        lappend vTcl(libNames) \
        {(not detected) Incr Tcl/Tk MegaWidgets Support Library}
        exit 2
    }
lappend vTcl(libNames) {Incr Tcl/Tk MegaWidgets Support Library}


namespace eval kpwidgets { }
#Just for this script I will forget them at the end
namespace import itk::*
namespace import itcl::*



class kpwidgets::scrolledbands {
    inherit itk::Widget
    private variable frame_position 0
    constructor {args} {
        itk_component add sfw {

            iwidgets::Scrolledframe $itk_interior.sfw -width 4i -height 5i \
                -sbwidth 10\
                -hscrollmode none  -vscrollmode dynamic -relief flat \
                -background #d9d9d9 -foreground black

        }
        pack $itk_component(sfw)  -fill both -expand yes


        eval itk_initialize $args

    }
    destructor { }
        itk_option define -width width Width 30
        itk_option define -height height Height 30


    public method new_frame { frame_name } {
        incr frame_position
        set sf $itk_component(sfw)

        label [$sf childsite].bt$frame_position -width \
            [expr $itk_option(-width) ] -bg #aaaaaa \
            -fg #000000 \
        -bd 1 -relief groove\
        -text [concat $frame_name " (-)"]

        bind [$sf childsite].bt$frame_position <ButtonPress> [ itcl::code $this  Expand  $frame_position]



        frame [$sf childsite].fr$frame_position -width [expr $itk_option(-width)] \
                            -relief raised -bd 1 -bg #d9d9d9

        pack [$sf childsite].bt$frame_position -fill both -side top -expand yes
        pack [$sf childsite].fr$frame_position -fill both -side top -expand yes


    }
    public method childsite { fr_position } {
        set sf $itk_component(sfw)
        return [$sf childsite].fr$fr_position
    }

    public method current_childsite {} {

        set sf $itk_component(sfw)
        return [$sf childsite].fr$frame_position
    }
    #This method invoked by the label when clicked. It unpacks the frame if it is visible or packs it if it is
    #not currently packed.
    private method Expand {frame_position} {
        set sf $itk_component(sfw)


        if  { [ catch { pack info [$sf childsite].fr$frame_position } ] } {
            pack [$sf childsite].fr$frame_position -after [$sf childsite].bt$frame_position \
                                -fill both -side top \
                                -expand yes
            set title [ [$sf childsite].bt$frame_position cget -text ]
            lset title end (-)
            [$sf childsite].bt$frame_position configure -text $title
        } else {
            pack forget [$sf childsite].fr$frame_position
            set title [ [$sf childsite].bt$frame_position cget -text ]
            lset title end (+)
            [$sf childsite].bt$frame_position configure -text $title

        }

    }

}
itcl::configbody kpwidgets::scrolledbands::width {
    set sf $itk_component(sfw)
    set itk_option(-width) [expr $itk_option(-width) / 2]
        $sf configure -width $itk_option(-width)

}
itcl::configbody kpwidgets::scrolledbands::height {
    set sf $itk_component(sfw)
    set itk_option(-height) [expr $itk_option(-height) / 2]
    $sf configure -height $itk_option(-height)
}


namespace forget itk::*
namespace forget itcl::*
