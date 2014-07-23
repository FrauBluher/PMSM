#!/usr/bin/env tclsh
# -*- mode: tcl; coding: utf-8-unix; -*-
# Time-stamp: <2013-03-12 22:09:40 rozen>%
# $Id: $
#-------------------------------------------------------------------------------
# Inspired by:
#  - colorChooser for pocketPC/etcl at http://wiki.tcl.tk/15599
#  - ColouredColourPecker at http://wfr.tcl.tk/1314
#-------------------------------------------------------------------------------
# Licence NOL: http://wfr.tcl.tk/nol
#-------------------------------------------------------------------------------
# See: http://jack.r.free.fr/index.php?lng=en&page=colordlg
#-------------------------------------------------------------------------------

# ::colorDlg::colorDlg  687   Main callable routine.

# Rozen I added stuff at the bottom of the file to find the complement
# and the analogous colors of a given color and to determine if a
# color is light or dark and therapon return black or white. This last
# is good for getting a foreground color.

# Check if already sourced
if {[info exists ::colorDlg::version]} { return }

namespace eval ::colorDlg {
    variable version 1.0.0

    namespace export colorDlg

    package require Tk 8.6
    package require msgcat
    namespace import ::msgcat::*

    package provide colorDlg $version

    variable widgets
    variable options

    variable hsmap
    variable hsWidth 180
    variable hsHeight 100
    variable bmap
    variable bWidth 10
    variable bHeight 100
    variable currents

    variable bgOk white
    variable bgError red
    variable invalidEntry ""
    variable motion 0
}

#-------------------------------------------------------------------------------
# Languages
#-------------------------------------------------------------------------------
proc ::colorDlg::lng_en {} {
    mcset en "Choose a color" "Choose a color"
    mcset en "Bad window path name %1\$s" "Bad window path name %1\$s"
    mcset en "Color:" "Color:"
    mcset en "Hue:" "Hue:"
    mcset en "Satur.:" "Satur.:"
    mcset en "Value:" "Value:"
    mcset en "Red:" "Red:"
    mcset en "Green:" "Green:"
    mcset en "Blue:" "Blue:"
    mcset en "Ok" "Ok"
    mcset en "Cancel" "Cancel"
}

proc ::colorDlg::lng_fr {} {
    mcset fr "Choose a color" "Choisissez une couleur"
    mcset fr "Bad window path name %1\$s" "Mauvais nom de fenêtre %1\$s"
    mcset fr "Color:" "Couleur :"
    mcset fr "Hue:" "Teinte :"
    mcset fr "Satur.:" "Satur. :"
    mcset fr "Value:" "Valeur :"
    mcset fr "Red:" "Rouge :"
    mcset fr "Green:" "Vert :"
    mcset fr "Blue:" "Bleu :"
    mcset fr "Ok" "Ok"
    mcset fr "Cancel" "Annule"
}

#-------------------------------------------------------------------------------
# Convert red green blue to hue saturation brightness
#-------------------------------------------------------------------------------
# hue is between 0 and 360
# saturation and value are between 0 and 100%
# red, green and blue are between 0 and 255
# Information get from:
#   http://fr.wikipedia.org/wiki/Hue_saturation_value
#   http://en.wikipedia.org/wiki/HSV_color_space
proc ::colorDlg::rgbToHsv {r g b} {
    # Returns a list [h s v]
    set r [expr {int($r)}]
    if {$r < 0} {
        set r 0
    } elseif {$r > 255} {
        set r 255
    }

    set g [expr {int($g)}]
    if {$g < 0} {
        set g 0
    } elseif {$g > 255} {
        set g 255
    }

    set b [expr {int($b)}]
    if {$b < 0} {
        set b 0
    } elseif {$b > 255} {
        set b 255
    }

    # convert to 0-1 range
    set r [expr {$r / 255.0}]
    set g [expr {$g / 255.0}]
    set b [expr {$b / 255.0}]

    if {$r > $g} {
        set max $r
        set min $g
    } else {
        set max $g
        set min $r
    }

    if {$b > $max} {
        set max $b
    } elseif {$b < $min} {
        set min $b
    }
    set range [expr {double($max - $min)}]

    if {$max eq $min} {
        set h 0
    } elseif {$max eq $r} {
        if {$g < $b} {
            set h [expr {(60.0 * (($g - $b) / $range)) + 360.0}]
        } else {
            set h [expr {60.0 * (($g - $b) / $range)}]
        }
    } elseif {$max eq $g} {
        set h [expr {(60.0 * (($b - $r) / $range)) + 120.0}]
    } else {
        set h [expr {(60.0 * (($r - $g) / $range)) + 240.0}]
    }
    if {$max eq 0.0} {
        set s 0
    } else {
        set s [expr {1.0 - ($min / double($max))}]
    }

    set s [expr {$s * 100.0}]
    set v [expr {$max * 100.0}]

    set h [format %.0f $h]
    set s [format %.0f $s]
    set v [format %.0f $v]


    return [list $h $s $v]
}

#-------------------------------------------------------------------------------
# Convert hue saturation value to red green blue
#-------------------------------------------------------------------------------
# hue is between 0 and 360
# saturation and value are between 0 and 100%
# red, green and blue are between 0 and 255
# Information get from:
#   http://fr.wikipedia.org/wiki/Hue_saturation_value
#   http://en.wikipedia.org/wiki/HSV_color_space
#   http://codebase.dbp-site.com/code/hsv2dword-2
proc ::colorDlg::hsvToRgb {h s v} {
    set v [expr {255 * $v / 100}]

    if {$s eq 0} {
        return [list $v $v $v]
    } else {
        set s [expr {$s / 100.0}]
        if {$h eq 360} {set h 0}
        set hi [expr {$h / 60}]
        set f  [expr {($h / 60.0) - $hi}]

        set p  [expr {$v * (1.0 - $s)}]
        set q  [expr {$v * (1.0 - ($f * $s))}]
        set t  [expr {$v * (1.0 - ((1 - $f) * $s))}]

        set v [format %.0f $v]
        set p [format %.0f $p]
        set q [format %.0f $q]
        set t [format %.0f $t]

        switch $hi {
            0 {return [list $v $t $p]}
            1 {return [list $q $v $p]}
            2 {return [list $p $v $t]}
            3 {return [list $p $q $v]}
            4 {return [list $t $p $v]}
            5 {return [list $v $p $q]}
        }
    }
}

#-------------------------------------------------------------------------------
# Convert color to red green blue
#-------------------------------------------------------------------------------
proc ::colorDlg::colorToRgb {color} {
    lassign [winfo rgb . $color] r g b
    set r [expr {$r/256}]
    set g [expr {$g/256}]
    set b [expr {$b/256}]
    return [list $r $g $b]
}

#-------------------------------------------------------------------------------
# Convert red green blue to color
#-------------------------------------------------------------------------------
proc ::colorDlg::rgbToColor {r g b} {
    return [format "#%02x%02x%02x" $r $g $b]
}

#-------------------------------------------------------------------------------
# Convert hue saturation to xy coordinate
#-------------------------------------------------------------------------------
proc ::colorDlg::hsToXy {h s width height} {
    if {$h eq 0} {
        set x 0
    } elseif {$h eq 360} {
        set x $width
    } else {
        set x [expr {$h * $width / 360}]
    }
    if {$s eq 0} {
        set y $height
    } elseif {$s eq 100} {
        set y 0
    } else {
        set y [expr {[expr {100 - $s}] * $height / 100}]
    }
    return [list $x $y]
}

#-------------------------------------------------------------------------------
# Convert xy coordinate to hue saturation
#-------------------------------------------------------------------------------
proc ::colorDlg::xyToHs {x y width height} {
    if {$x eq 0} {
        set h 0
    } elseif {$x eq $width} {
        set h 360
    } else {
        set h [expr {$x * 360 / $width}]
    }
    if {$y eq 0} {
        set s 100
    } elseif {$y eq $height} {
        set s 0
    } else {
        set s [expr {100 - (($y * 100) / $height)}]
    }
    return [list $h $s]
}

#-------------------------------------------------------------------------------
# Check and set initialcolor option
#-------------------------------------------------------------------------------
proc ::colorDlg::setInitialColor {value} {
    lassign [::colorDlg::colorToRgb $value] r g b
    set ::colorDlg::options(-initialcolor) [::colorDlg::rgbToColor $r $g $b]
}

#-------------------------------------------------------------------------------
# Check and set parent option
#-------------------------------------------------------------------------------
proc ::colorDlg::setParent {value} {
    if {![winfo exists $value]} {
        error [mc "Bad window path name %1\$s" $value]
    }
    set ::colorDlg::options(-parent) $value
}

#-------------------------------------------------------------------------------
# Check and set title option
#-------------------------------------------------------------------------------
proc ::colorDlg::setTitle {value} {
    set ::colorDlg::options(-title) $value
}


#-------------------------------------------------------------------------------
# Build hue saturation map
#-------------------------------------------------------------------------------
proc ::colorDlg::buildHsmap {width height} {
    set img [image create photo -width $width -height $height]
    if {$width <= 0 || $height <= 0} {
        return $img
    }

    # Use max value
    set v 255
    set pixels [list]

    for {set y 0} {$y < $height} {incr y} {
        set p [format %.0f [expr {255 * $y / $height}]]
        for {set x 0} {$x < $width} {incr x} {
            set s [expr {1 - (1.0 * $y / $height)}]
            set hi [expr {6 * $x / $width}]
            set f  [expr {(6.0 * $x / $width) - $hi}]

            switch $hi {
                0 {
                    set t  [expr {$v * (1.0 - ((1 - $f) * $s))}]
                    set t [format %.0f $t]
                    lappend pixels $v $t $p
                }
                1 {
                    set q  [expr {$v * (1.0 - ($f * $s))}]
                    set q [format %.0f $q]
                    lappend pixels $q $v $p
                }
                2 {
                    set t  [expr {$v * (1.0 - ((1 - $f) * $s))}]
                    set t [format %.0f $t]
                    lappend pixels $p $v $t
                }
                3 {
                    set q  [expr {$v * (1.0 - ($f * $s))}]
                    set q [format %.0f $q]
                    lappend pixels $p $q $v
                }
                4 {
                    set t  [expr {$v * (1.0 - ((1 - $f) * $s))}]
                    set t [format %.0f $t]
                    lappend pixels $t $p $v
                }
                5 {
                    set q  [expr {$v * (1.0 - ($f * $s))}]
                    set q [format %.0f $q]
                    lappend pixels $v $p $q
                }
            }
        }
    }

    set header "P6\n\# PPM data\n${width} ${height}\n255\n"
    append tkdata [binary format {a*c*} $header $pixels]
    $img put $tkdata -to 0 0 $width $height -format PPM

    return $img
}

#-------------------------------------------------------------------------------
# Update hue saturation map
#-------------------------------------------------------------------------------
proc ::colorDlg::updateHsmap {} {
    lassign [::colorDlg::hsToXy $::colorDlg::currents(h) \
                 $::colorDlg::currents(s) \
                 $::colorDlg::hsWidth \
                 $::colorDlg::hsHeight] x y
    set x1 [expr {$x - 2}]
    set y1 [expr {$y - 2}]
    set x2 [expr {$x + 4}]
    set y2 [expr {$y + 4}]
    $::colorDlg::widgets(chs) coords hsval $x1 $y1 $x2 $y2
    $::colorDlg::widgets(chs) raise hsval

    set ::colorDlg::bmap [::colorDlg::buildBmap  \
                              $::colorDlg::currents(h)\
                              $::colorDlg::currents(s)\
                              $::colorDlg::bWidth \
                              $::colorDlg::bHeight]
    $::colorDlg::widgets(cb) itemconfigure bmap -image $::colorDlg::bmap
}

#-------------------------------------------------------------------------------
# Build brightness map
#-------------------------------------------------------------------------------
proc ::colorDlg::buildBmap {h s width height} {
    set img [image create photo -width $width -height $height]
    if {$width<=0 || $height<=0} {
        return $img
    }

    for {set y 0} {$y < $height} {incr y} {
        set v [expr {($height -$y) * 100 / $height}]
        lassign [::colorDlg::hsvToRgb $h $s $v] r g b
        set color [::colorDlg::rgbToColor $r $g $b]
        $img put [list [list $color]] -to 0 $y $width [expr {$y+1}]
    }

    return $img
}

#-------------------------------------------------------------------------------
# Update brightness map
#-------------------------------------------------------------------------------
proc ::colorDlg::updateBmap {} {
    set x1 0
    set y1 [expr {(100 - $::colorDlg::currents(v)) * $::colorDlg::bHeight / 100}]
    set x2 $::colorDlg::bWidth
    set y2 $y1
    $::colorDlg::widgets(cb) coords bval $x1 $y1 $x2 $y2
}

#-------------------------------------------------------------------------------
# Validate h s v entry
#-------------------------------------------------------------------------------
proc ::colorDlg::validateHsv {name} {
    set v $::colorDlg::currents($name)
    if {$name eq "h"} {
        set max 360
    } else {
        set max 100
    }
    if {$v eq "" || $v < 0 || $v > $max} {
        set ::colorDlg::invalidEntry $::colorDlg::widgets($name)
        $::colorDlg::widgets($name) configure -background $::colorDlg::bgError
    } else {
        set ::colorDlg::invalidEntry ""
        $::colorDlg::widgets($name) configure -background $::colorDlg::bgOk
        # update rgb
        lassign [::colorDlg::hsvToRgb $::colorDlg::currents(h) \
                     $::colorDlg::currents(s) \
                     $::colorDlg::currents(v)] \
            ::colorDlg::currents(r) \
            ::colorDlg::currents(g) \
            ::colorDlg::currents(b)
        # update color
        set ::colorDlg::currents(color) [::colorDlg::rgbToColor \
                                             $::colorDlg::currents(r) \
                                             $::colorDlg::currents(g) \
                                             $::colorDlg::currents(b)]
        $::colorDlg::widgets(sample) configure \
            -background $::colorDlg::currents(color)
        # update hsmap
        ::colorDlg::updateHsmap
        # update bmap
        ::colorDlg::updateBmap
    }
}

#-------------------------------------------------------------------------------
# Validate r g b entry
#-------------------------------------------------------------------------------
proc ::colorDlg::validateRgb {name} {
    set v $::colorDlg::currents($name)
    if {$v eq "" || $v < 0 || $v > 255} {
        set ::colorDlg::invalidEntry $::colorDlg::widgets($name)
        $::colorDlg::widgets($name) configure -background $::colorDlg::bgError
    } else {
        set ::colorDlg::invalidEntry ""
        $::colorDlg::widgets($name) configure -background $::colorDlg::bgOk
        # update hsv
        lassign [::colorDlg::rgbToHsv $::colorDlg::currents(r) \
                     $::colorDlg::currents(g) \
                     $::colorDlg::currents(b)] \
            ::colorDlg::currents(h) \
            ::colorDlg::currents(s) \
            ::colorDlg::currents(v)
        # update color
        set ::colorDlg::currents(color) [::colorDlg::rgbToColor \
                                             $::colorDlg::currents(r) \
                                             $::colorDlg::currents(g) \
                                             $::colorDlg::currents(b)]
        $::colorDlg::widgets(sample) configure \
            -background $::colorDlg::currents(color)
        # update hsmap
        ::colorDlg::updateHsmap
        # update bmap
        ::colorDlg::updateBmap
    }
}

#-------------------------------------------------------------------------------
# Validate color entry
#-------------------------------------------------------------------------------
proc ::colorDlg::validateColor {} {
    set v $::colorDlg::currents(color)
    if { [catch {winfo rgb . $v} i] } {
        set ::colorDlg::invalidEntry $::colorDlg::widgets(color)
        $::colorDlg::widgets(color) configure -background $::colorDlg::bgError
    } else {
        set ::colorDlg::invalidEntry ""
        $::colorDlg::widgets(color) configure -background $::colorDlg::bgOk
        # update rgb
        lassign [::colorDlg::colorToRgb $::colorDlg::currents(color)] \
            ::colorDlg::currents(r) \
            ::colorDlg::currents(g) \
            ::colorDlg::currents(b)
        # update hsv
        lassign [::colorDlg::rgbToHsv $::colorDlg::currents(r) \
                     $::colorDlg::currents(g) \
                     $::colorDlg::currents(b)] \
            ::colorDlg::currents(h) \
            ::colorDlg::currents(s) \
            ::colorDlg::currents(v)
        $::colorDlg::widgets(sample) configure \
            -background $::colorDlg::currents(color)
        # update hsmap
        ::colorDlg::updateHsmap
        # update bmap
        ::colorDlg::updateBmap
    }

}

#-------------------------------------------------------------------------------
# Motion in hsmap
#-------------------------------------------------------------------------------
proc ::colorDlg::motionHs {x y} {
    if {$x < 0 } {
        set x 0
    } elseif {$x > $::colorDlg::hsWidth} {
        set x $::colorDlg::hsWidth
    }

    if {$y < 0 } {
        set y 0
    } elseif {$y > $::colorDlg::hsHeight} {
        set y $::colorDlg::hsHeight
    }

    if {$::colorDlg::motion} {
        lassign [::colorDlg::xyToHs $x $y $::colorDlg::hsWidth \
                     $::colorDlg::hsHeight] \
            ::colorDlg::currents(h) \
            ::colorDlg::currents(s)
        # update rgb
        lassign [::colorDlg::hsvToRgb $::colorDlg::currents(h) \
                     $::colorDlg::currents(s) \
                     $::colorDlg::currents(v)] \
            ::colorDlg::currents(r) \
            ::colorDlg::currents(g) \
            ::colorDlg::currents(b)
        # update color
        set ::colorDlg::currents(color) [::colorDlg::rgbToColor \
                                             $::colorDlg::currents(r) \
                                             $::colorDlg::currents(g) \
                                             $::colorDlg::currents(b)]
        $::colorDlg::widgets(sample) configure \
            -background $::colorDlg::currents(color)
        # update hsmap
        ::colorDlg::updateHsmap
    }
}

#-------------------------------------------------------------------------------
# Motion in hsmap
#-------------------------------------------------------------------------------
proc ::colorDlg::motionB {x y} {
    if {$x < 0 } {
        set x 0
    } elseif {$x > $::colorDlg::bWidth} {
        set x $::colorDlg::bWidth
    }

    if {$y < 0 } {
        set y 0
    } elseif {$y > $::colorDlg::bHeight} {
        set y $::colorDlg::bHeight
    }

    if {$::colorDlg::motion} {
        set v [expr {($::colorDlg::bHeight - $y) * $::colorDlg::bHeight / 100}]
        if {$v < 0} {
            set v 0
        } elseif {$v > 100} {
            set v 100
        }
        set ::colorDlg::currents(v) $v
        # update rgb
        lassign [::colorDlg::hsvToRgb $::colorDlg::currents(h) \
                     $::colorDlg::currents(s) \
                     $::colorDlg::currents(v)] \
            ::colorDlg::currents(r) \
            ::colorDlg::currents(g) \
            ::colorDlg::currents(b)
        # update color
        set ::colorDlg::currents(color) [::colorDlg::rgbToColor \
                                             $::colorDlg::currents(r) \
                                             $::colorDlg::currents(g) \
                                             $::colorDlg::currents(b)]
        $::colorDlg::widgets(sample) configure \
            -background $::colorDlg::currents(color)
        # update bmap
        ::colorDlg::updateBmap
    }
}

#-------------------------------------------------------------------------------
# Binding for Mouse button 1 press
#-------------------------------------------------------------------------------
proc ::colorDlg::ButtonPress-1 {sender key x y} {
    switch -regexp -- $sender \
        $::colorDlg::widgets(chs) {
            set ::colorDlg::motion 1
            ::colorDlg::motionHs $x $y
        } \
        $::colorDlg::widgets(cb) {
            set ::colorDlg::motion 1
            ::colorDlg::motionB $x $y
        }
}

#-------------------------------------------------------------------------------
# Binding for Mouse button 1 release
#-------------------------------------------------------------------------------
proc ::colorDlg::ButtonRelease-1 {sender key x y} {
    if { $::colorDlg::invalidEntry != "" } {
        if {$sender eq $::colorDlg::widgets(color) || \
                $sender eq $::colorDlg::widgets(h) || \
                $sender eq $::colorDlg::widgets(s) || \
                $sender eq $::colorDlg::widgets(v) || \
                $sender eq $::colorDlg::widgets(r) || \
                $sender eq $::colorDlg::widgets(g) || \
                $sender eq $::colorDlg::widgets(b)} {
            $sender selection clear
        }
        focus -force $::colorDlg::invalidEntry
        return
    }
    switch -regexp -- $sender \
        $::colorDlg::widgets(chs) {::colorDlg::motionHs $x $y} \
        $::colorDlg::widgets(cb) {::colorDlg::motionB $x $y}
    set ::colorDlg::motion 0
}

#-------------------------------------------------------------------------------
# Binding for Mouse motion
#-------------------------------------------------------------------------------
proc ::colorDlg::Motion {sender key x y} {
    switch -regexp -- $sender \
        $::colorDlg::widgets(chs) {::colorDlg::motionHs $x $y} \
        $::colorDlg::widgets(cb) {::colorDlg::motionB $x $y}
}

#-------------------------------------------------------------------------------
# Binding for key press
#-------------------------------------------------------------------------------
proc ::colorDlg::KeyPress {sender key} {
    switch -regexp -- $sender \
        $::colorDlg::widgets(h) {::colorDlg::validateHsv h} \
        $::colorDlg::widgets(s) {::colorDlg::validateHsv s} \
        $::colorDlg::widgets(v) {::colorDlg::validateHsv v} \
        $::colorDlg::widgets(r) {::colorDlg::validateRgb r} \
        $::colorDlg::widgets(g) {::colorDlg::validateRgb g} \
        $::colorDlg::widgets(b) {::colorDlg::validateRgb b} \
        $::colorDlg::widgets(color) {::colorDlg::validateColor}
}

#-------------------------------------------------------------------------------
# Binding for key release
#-------------------------------------------------------------------------------
proc ::colorDlg::KeyRelease {sender key} {
    if { $::colorDlg::invalidEntry != "" } {
        if {$sender eq $::colorDlg::widgets(color) || \
                $sender eq $::colorDlg::widgets(h) || \
                $sender eq $::colorDlg::widgets(s) || \
                $sender eq $::colorDlg::widgets(v) || \
                $sender eq $::colorDlg::widgets(r) || \
                $sender eq $::colorDlg::widgets(g) || \
                $sender eq $::colorDlg::widgets(b)} {
            $sender selection clear
        }
        focus -force $::colorDlg::invalidEntry
    }
}

#-------------------------------------------------------------------------------
# Action when ok button is pressed
#-------------------------------------------------------------------------------
proc ::colorDlg::ok {w} {
    if {$::colorDlg::invalidEntry eq ""} {
        destroy $w
    }
}

#-------------------------------------------------------------------------------
# Action when cancel button is pressed
#-------------------------------------------------------------------------------
proc ::colorDlg::cancel {w} {
    set ::colorDlg::invalidEntry ""
    set ::colorDlg::currents(color) ""
    destroy $w
}

#-------------------------------------------------------------------------------
# Widget creation
#-------------------------------------------------------------------------------
proc ::colorDlg::colorDlg {args} {
    # load langue strings
    set lng [string range [mclocale] 0 1]
    eval "::colorDlg::lng_$lng"

    # be sure to have proper default values
    set ::colorDlg::options(-initialcolor)  #ffffff
    set ::colorDlg::options(-parent)        .
    set ::colorDlg::options(-title)         [mc "Choose a color"]

    set ::colorDlg::changing 0

    # options value setup
    foreach {key value} $args {
        switch -exact -- $key {
            -initialcolor   {
                ::colorDlg::setInitialColor $value
            }
            -parent   {
                ::colorDlg::setParent $value
            }
            -title   {
                ::colorDlg::setTitle $value
            }
            default \
                { error "unknown option '$key'" }
        }
    }
    # current values setup
    set ::colorDlg::currents(color) $::colorDlg::options(-initialcolor)
    lassign [::colorDlg::colorToRgb $::colorDlg::currents(color)] \
        ::colorDlg::currents(r) \
        ::colorDlg::currents(g) \
        ::colorDlg::currents(b)
    lassign [::colorDlg::rgbToHsv $::colorDlg::currents(r) \
                 $::colorDlg::currents(g) \
                 $::colorDlg::currents(b)] \
        ::colorDlg::currents(h) \
        ::colorDlg::currents(s) \
        ::colorDlg::currents(v)

    # create widget
    if {$::colorDlg::options(-parent) eq {.} } {
        set w [toplevel .colorDlg]
    } else {
        set w [toplevel $::colorDlg::options(-parent).colorDlg]
    }
    wm withdraw $w

    # container frame
    #ttk::frame $w.c -borderwidth 1 -relief raised
    frame $w.c -borderwidth 1 -relief raised
    # top frame for color gradient, brightness, sample, color entry
    #ttk::frame $w.c.t
    frame $w.c.t
    set ::colorDlg::widgets(chs) $w.c.t.gradient
    set width [expr {$::colorDlg::hsWidth + 1}]
    set height [expr {$::colorDlg::hsHeight + 1}]
    canvas $w.c.t.gradient -width $width -height $height
    set ::colorDlg::hsmap \
        [::colorDlg::buildHsmap $width $height]
    $w.c.t.gradient create image 1 1 -anchor nw \
        -image $::colorDlg::hsmap -tags hsmap
    $w.c.t.gradient create oval -10 -10 -10 -10 -tags [list hsmap hsval]

    incr ::colorDlg::bHeight
    set ::colorDlg::widgets(cb) $w.c.t.bright
    canvas $w.c.t.bright -width $::colorDlg::bWidth -height $::colorDlg::bHeight
    set ::colorDlg::bmap [::colorDlg::buildBmap  0 0 \
                              $::colorDlg::bWidth \
                              $::colorDlg::bHeight]
    $w.c.t.bright create image 1 1 -anchor nw -image $::colorDlg::bmap -tags bmap
    $w.c.t.bright create rectangle 0 10 $::colorDlg::bWidth 10 -fill white \
        -outline white -tags bval

    set ::colorDlg::widgets(sample) $w.c.t.sample
    canvas $w.c.t.sample -width 10 -height 10 \
        -background $::colorDlg::currents(color)
    #ttk::label $w.c.t.lcolor -anchor w -text [mc "Color:"]
    label $w.c.t.lcolor -anchor w -text [mc "Color:"]
    set ::colorDlg::widgets(color) [entry $w.c.t.ecolor \
                                        -width 8 \
                                        -textvariable ::colorDlg::currents(color)]
    set ::colorDlg::bgOk [$::colorDlg::widgets(color) cget -background]
    grid $w.c.t.gradient -row 0 -column 0 -rowspan 3 -padx 5 -pady 5
    grid $w.c.t.bright -row 0 -column 1 -rowspan 3 -padx 0 -pady 5
    grid $w.c.t.sample -row 0 -column 2 -padx 5 -pady 5 -sticky nsew
    grid $w.c.t.lcolor -row 1 -column 2 -padx 5 -pady 0
    grid $w.c.t.ecolor -row 2 -column 2 -padx 5 -pady 5
    grid rowconfigure $w.c.t 0 -weight 1

    # bottom frame for hue, saturation, brightness, red, green, blue input
    #ttk::frame $w.c.b
    #ttk::label $w.c.b.lhue -anchor e -text [mc "Hue:"]
    frame $w.c.b
    label $w.c.b.lhue -anchor e -text [mc "Hue:"]

    set ::colorDlg::widgets(h) [entry $w.c.b.ehue \
                                    -width 5 \
                                    -textvariable ::colorDlg::currents(h)]
    #ttk::label $w.c.b.lsaturation -anchor e -text [mc "Satur.:"]
    label $w.c.b.lsaturation -anchor e -text [mc "Satur.:"]
    set ::colorDlg::widgets(s) [entry $w.c.b.esaturation \
                                    -width 5 \
                                    -textvariable ::colorDlg::currents(s)]
    #ttk::label $w.c.b.lbrightness -anchor e -text [mc "Value:"]
    label $w.c.b.lbrightness -anchor e -text [mc "Value:"]
    set ::colorDlg::widgets(v) [entry $w.c.b.ebrightness \
                                    -width 5 \
                                    -textvariable ::colorDlg::currents(v)]
    #ttk::label $w.c.b.lred -anchor e -text [mc "Red:"]
    label $w.c.b.lred -anchor e -text [mc "Red:"]
    set ::colorDlg::widgets(r) [entry $w.c.b.ered \
                                    -width 5 \
                                    -textvariable ::colorDlg::currents(r)]
    #ttk::label $w.c.b.lgreen -anchor e -text [mc "Green:"]
    label $w.c.b.lgreen -anchor e -text [mc "Green:"]
    set ::colorDlg::widgets(g) [entry $w.c.b.egreen \
                                    -width 5 \
                                    -textvariable ::colorDlg::currents(g)]
    #ttk::label $w.c.b.lblue -anchor e -text [mc "Blue:"]
    label $w.c.b.lblue -anchor e -text [mc "Blue:"]
    set ::colorDlg::widgets(b) [entry $w.c.b.eblue \
                                    -width 5 \
                                    -textvariable ::colorDlg::currents(b)]
    grid $w.c.b.lhue -row 0 -column 0 -padx 5 -pady 5 -sticky e
    grid $w.c.b.ehue -row 0 -column 1 -padx 5 -pady 5
    grid $w.c.b.lsaturation -row 1 -column 0 -padx 5 -pady 5 -sticky e
    grid $w.c.b.esaturation -row 1 -column 1 -padx 5 -pady 5
    grid $w.c.b.lbrightness -row 2 -column 0 -padx 5 -pady 5 -sticky e
    grid $w.c.b.ebrightness -row 2 -column 1 -padx 5 -pady 5
    grid $w.c.b.lred -row 0 -column 2 -padx 5 -pady 5 -sticky e
    grid $w.c.b.ered -row 0 -column 3 -padx 5 -pady 5
    grid $w.c.b.lgreen -row 1 -column 2 -padx 5 -pady 5 -sticky e
    grid $w.c.b.egreen -row 1 -column 3 -padx 5 -pady 5
    grid $w.c.b.lblue -row 2 -column 2 -padx 5 -pady 5 -sticky e
    grid $w.c.b.eblue -row 2 -column 3 -padx 5 -pady 5
    grid columnconfigure $w.c.b 0 -weight 1
    grid columnconfigure $w.c.b 1 -weight 1
    grid columnconfigure $w.c.b 2 -weight 1
    grid columnconfigure $w.c.b 3 -weight 1

    # arrange top and bottom frames
    grid $w.c.t -row 0 -column 0 -sticky ew
    grid $w.c.b -row 1 -column 0 -sticky ew

    # frame for ok / cancel actions
    #ttk::frame $w.a -borderwidth 1 -relief raised
    frame $w.a -borderwidth 1 -relief raised
    #ttk::button $w.a.ok -text [mc "Ok"] -command [list ::colorDlg::ok $w]
    button $w.a.ok -text [mc "Ok"] -command [list ::colorDlg::ok $w]
    #ttk::button $w.a.cancel -text [mc "Cancel"] -command [list ::colorDlg::cancel $w]
    button $w.a.cancel -text [mc "Cancel"] -command [list ::colorDlg::cancel $w]
    grid $w.a.ok -row 0 -column 0 -padx 5 -pady 5
    grid $w.a.cancel -row 0 -column 1 -padx 5 -pady 5
    grid columnconfigure $w.a 0 -weight 1
    grid columnconfigure $w.a 1 -weight 1

    # arrange container and action frames
    grid $w.c -row 0 -column 0 -sticky ew
    grid $w.a -row 1 -column 0 -sticky ew
    grid rowconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 0

    # bindings
    bind $w <ButtonPress-1>   {::colorDlg::ButtonPress-1 %W %K %x %y}
    bind $w <ButtonRelease-1> {::colorDlg::ButtonRelease-1 %W %K %x %y}
    bind $w <Motion>          {::colorDlg::Motion %W %K %x %y}
    bind $w <KeyPress>        {::colorDlg::KeyPress %W %K}
    bind $w <KeyRelease>      {::colorDlg::KeyRelease %W %K}

    # display
    wm title $w $::colorDlg::options(-title)
    update idletasks
    wm minsize $w [winfo reqwidth $w] [winfo reqheight $w]
    wm maxsize $w [winfo reqwidth $w] [winfo reqheight $w]

    wm deiconify $w
    raise $w

    # update hsmap
    ::colorDlg::updateHsmap

    focus $w.a.cancel
    grab $w
    tkwait window $w
    return $::colorDlg::currents(color)
}

namespace import ::colorDlg::colorDlg

# Rozen. The color complement stuff
proc ::colorDlg::complement {color} {
    # This routine returns the complement of a color given in r g b.

    # First step is to convert to HSV.

    # Returns hex form of color: #%02x%02x%02x
    set rgb [::colorDlg::colorToRgb $color]
    lassign $rgb r g b
    set hsv [rgbToHsv $r $g $b]
    foreach {h s v} $hsv {}
    set hue_complement [expr ($h + 180) % 360 ]
    set rgb_complement [::colorDlg::hsvToRgb $hue_complement $s $v]
    foreach {rn gn bn} $rgb_complement {}
    return [::colorDlg::rgbToColor $rn $gn $bn]
    #return [list $rn $gn $bn]
}

proc ::colorDlg::dark_color {color} {
    # Determine whether color is light or dark.
    set rgb [::colorDlg::colorToRgb $color]
    lassign $rgb r g b
    set a [expr 1 - ( 0.299 * $r + 0.587 * $g + 0.114 * $b)/255]
    if {$a < 0.5} {
        return 0      ;# Light
    }
    return 1          ;# Dark
}

proc ::colorDlg::analogous_colors {color} {
    # Returns two colors the plus analogous color and the minus
    # analogous color. Returns a list of hex colors.
    set rgb [::colorDlg::colorToRgb $color]
    lassign $rgb r g b

    set hsv [rgbToHsv $r $g $b]
    lassign $hsv h s v
    set hue_plus [expr ($h + 30) % 360 ]
    set rgb_plus [::colorDlg::hsvToRgb $hue_plus $s $v]
    lassign $rgb_plus rp gp bp
    set plus [::colorDlg::rgbToColor $rp $gp $bp]
    set hue_minus [expr ($h - 30) % 360 ]
    set rgb_minus [::colorDlg::hsvToRgb $hue_minus $s $v]
    lassign $rgb_minus rm gm bm
    set minus [::colorDlg::rgbToColor $rm $gm $bm]
    return [list $plus $minus]
}

proc ::colorDlg::contrast {color} {
    # Determine if the color is dark or light and return white or
    # black, respectivly.  Returns hex form of result: #%02x%02x%02x
    set rgb [::colorDlg::colorToRgb $color]
    lassign $rgb r g b
    set l_d [::colorDlg::dark_color $r $g $b]
    if {$l_d == 0} {
        set d 0
    } else {
        set d 255
    }
    return [::colorDlg::rgbToColor $d $d $d]
}

proc ::colorDlg::colorToHex {color} {
    set rgb [::colorDlg::colorToRgb $color]  ;#   returns a vector.
    set val [::colorDlg::rgbToColor {*}$rgb] ;#   rewrites vector to #rrggbb
    return $val
}

proc ::colorDlg::compare_colors {color1 color2} {
    # Color1 is #rgb, color2 is name.
    set c1 [::colorDlg::colorToHex $color1]
    set c2 [::colorDlg::colorToHex $color2]
    if {$c1 == $c2} {
        return 1
    } else {
        return 0
    }
}

#-------------------------------------------------------------------------------
# Demo if called directly
#-------------------------------------------------------------------------------
#option add *background #f5deb3
#option add *font {Helvetica 14}

if {[file tail [info script]] eq [file tail $argv0]} {
    rename ::tk_chooseColor ::_tk_chooseColor
    proc ::tk_chooseColor {args} {
        return [eval colorDlg $args]
    }

    proc run {} {
        set result [tk_chooseColor -title "Select color" -initialcolor $::color]
        if {$result ne ""} {
            set ::color $result
            set ::msg "color: $result"
            # Rozen This stuff figures out a complementary color for
            # use in a background and contrasting colors (black or
            # white) for the foreground.
            set rgb [::colorDlg::colorToRgb $::color]
            set ::color_complement [::colorDlg::complement $::color]
            set ::color_contrast [::colorDlg::contrast $::color]
            .l1 configure -background $::color \
                -foreground $::color_contrast
            .l11 configure -background $::color_complement \
                -foreground $::color_contrast

            set ::color_analogous [::colorDlg::analogous_colors $::color]
            lassign $::color_analogous hexp hexm
            set ::color_plus_analogous $hexp
            set ::comp_contrast_plus [::colorDlg::contrast $hexp]
            .lpc configure -background $::color_plus_analogous  \
                -foreground $::comp_contrast_plus

            #foreach {r g b} $rgbm {}
            #set ::color_minus_analogous [::colorDlg::rgbToColor $r $g $b]
            set ::color_minus_analogous $hexm
            set ::comp_contrast_minus [::colorDlg::contrast $hexm]
            .lmc configure -background $::color_minus_analogous \
                -foreground $::comp_contrast_minus

            set ::msg_comp "complement: $::color_complement"
            set ::msg_plus "analog-plus: $::color_plus_analogous"
            set ::msg_minus "analog-minus: $::color_minus_analogous"

        } else {
            set ::msg "no color selected"
        }
    }

    #set ::color #12aa34
    set ::color wheat
    set ::msg ""
    set b1 [button .b1 \
                -text "click to select a color" \
                -command run ]

    set l1 [label .l1 -textvariable ::msg]
    set l11 [label .l11 -textvariable ::msg_comp]
    set lpc [label .lpc -textvariable ::msg_plus]
    set lmc [label .lmc -textvariable ::msg_minus]
    pack $b1
    pack $l1
    pack $l11
    pack $lpc
    pack $lmc

    tkwait window .
    exit
}

# Found on the internet:
# Color ContrastColor(Color color)
#         {
#             int d = 0;

#             // Counting the perceptive luminance - human eye favors green color...
#             double a = 1 - ( 0.299 * color.R + 0.587 * color.G + 0.114 * color.B)/255;

#             if (a < 0.5)
#                 d = 0; // bright colors - black font
#             else
#                 d = 255; // dark colors - white font

#             return  Color.FromArgb(d, d, d);
#         }