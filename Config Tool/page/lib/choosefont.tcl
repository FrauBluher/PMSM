 ##+##########################################################################
 #
 # ::ChooseFont -- yet another font chooser dialog
 # by Keith Vetter, June 2006
 #
 # usage: set font [::ChooseFont::ChooseFont]
 # usage: set font [::ChooseFont::ChooseFont "Helvetica 8 italic"]
 #

 package require Tk
 #catch {package require tile}                    ;# Not needed, but looks better

 namespace eval ::ChooseFont {
    variable S

    set S(W) .cfont
    set S(fonts) [lsort -dictionary [font families]]
    set S(styles) {Regular Italic Bold "Bold Italic"}

    set S(sizes) {8 9 10 11 12 14 16 18 20 22 24 26 28 36 48 72}
    set S(strike) 0
    set S(under) 0
    set S(first) 1

    set S(fonts,lcase) {}
    foreach font $S(fonts) { lappend S(fonts,lcase) [string tolower $font]}
    set S(styles,lcase) {regular italic bold "bold italic"}
    set S(sizes,lcase) $S(sizes)

 }
 proc ::ChooseFont::ChooseFont {{defaultFont ""}} {
    variable S

    destroy $S(W)
    toplevel $S(W) -padx 10 -pady 10
    wm title $S(W) "Font"

    #set tile [expr {[catch {package present tile}] ? "" : "::ttk"}]
    set tile ""
    ${tile}::label $S(W).font -text "Font:"
    ${tile}::label $S(W).style -text "Font style:"
    ${tile}::label $S(W).size -text "Size:"
    entry $S(W).efont -textvariable ::ChooseFont::S(font) ;# -state disabled
    entry $S(W).estyle -textvariable ::ChooseFont::S(style) ;# -state disabled
    entry $S(W).esize -textvariable ::ChooseFont::S(size) -width 0 \
        -validate key -vcmd {string is double %P}

    ${tile}::scrollbar $S(W).sbfonts -command [list $S(W).lfonts yview]
    listbox $S(W).lfonts -listvariable ::ChooseFont::S(fonts) -height 7 \
        -yscroll [list $S(W).sbfonts set] -height 7 -exportselection 0
    listbox $S(W).lstyles -listvariable ::ChooseFont::S(styles) -height 7 \
        -exportselection 0
    ${tile}::scrollbar $S(W).sbsizes -command [list $S(W).lsizes yview]
    listbox $S(W).lsizes -listvariable ::ChooseFont::S(sizes) \
        -yscroll [list $S(W).sbsizes set] -width 6 -height 7 -exportselection 0

    bind $S(W).lfonts <<ListboxSelect>> [list ::ChooseFont::Click font]
    bind $S(W).lstyles <<ListboxSelect>> [list ::ChooseFont::Click style]
    bind $S(W).lsizes <<ListboxSelect>> [list ::ChooseFont::Click size]

    set WE $S(W).effects
    ${tile}::labelframe $WE -text "Effects"
    ${tile}::checkbutton $WE.strike -variable ::ChooseFont::S(strike) \
        -text Strikeout -command [list ::ChooseFont::Click strike]
    ${tile}::checkbutton $WE.under -variable ::ChooseFont::S(under) \
        -text Underline -command [list ::ChooseFont::Click under]

    ${tile}::button $S(W).ok -text OK -command [list ::ChooseFont::Done 1]
    ${tile}::button $S(W).cancel -text Cancel -command [list ::ChooseFont::Done 0]
    wm protocol $S(W) WM_DELETE_WINDOW [list ::ChooseFont::Done 0]

    grid $S(W).font - x $S(W).style - x $S(W).size - x -sticky w
    grid $S(W).efont - x $S(W).estyle - x $S(W).esize - x $S(W).ok -sticky ew
    grid $S(W).lfonts $S(W).sbfonts x \
        $S(W).lstyles - x \
        $S(W).lsizes $S(W).sbsizes x \
        $S(W).cancel -sticky news
    grid config $S(W).cancel -sticky n -pady 5
    grid columnconfigure $S(W) {2 5 8} -minsize 10
    grid columnconfigure $S(W) {0 3 6} -weight 1

    grid $WE.strike -sticky w -padx 10
    grid $WE.under -sticky w -padx 10
    grid columnconfigure $WE 1 -weight 1
    grid $WE - x -sticky news -row 100 -column 0

    set WS $S(W).sample
    ${tile}::labelframe $WS -text "Sample"
    label $WS.fsample -bd 2 -relief sunken
    label $WS.fsample.sample -text "AaBbYyZz123"
    set S(sample) $WS.fsample.sample
    pack $WS.fsample -fill both -expand 1 -padx 10 -pady 10 -ipady 15
    pack $WS.fsample.sample -fill both -expand 1
    pack propagate $WS.fsample 0

    grid rowconfigure $S(W) 2 -weight 1
    grid rowconfigure $S(W) 99 -minsize 30
    grid $WS - - - - -sticky news -row 100 -column 3
    grid rowconfigure $S(W) 101 -minsize 30

    trace variable ::ChooseFont::S(size) w ::ChooseFont::Tracer
    trace variable ::ChooseFont::S(style) w ::ChooseFont::Tracer
    trace variable ::ChooseFont::S(font) w ::ChooseFont::Tracer
    ::ChooseFont::Init $defaultFont
    tkwait window $S(W)
    return $S(result)
 }

 proc ::ChooseFont::Done {ok} {
    if {! $ok} {set ::ChooseFont::S(result) ""}
    destroy $::ChooseFont::S(W)
 }
 proc ::ChooseFont::Init {{defaultFont ""}} {
    variable S

    if {$S(first) || $defaultFont ne ""} {
        if {$defaultFont eq ""} {
            set defaultFont [[entry .___e] cget -font]
            destroy .___e
        }
        array set F [font actual $defaultFont]
        set S(font) $F(-family)
        set S(size) $F(-size)
        set S(strike) $F(-overstrike)
        set S(under) $F(-underline)
        set S(style) "Regular"
        if {$F(-weight) eq "bold" && $F(-slant) eq "italic"} {
            set S(style) "Bold Italic"
        } elseif {$F(-weight) eq "bold"} {
            set S(style) "Bold"
        } elseif {$F(-slant) eq "italic"} {
            set S(style) "Italic"
        }

        set S(first) 0
    }

    ::ChooseFont::Tracer a b c
    ::ChooseFont::Show
 }

 proc ::ChooseFont::Click {who} {
    variable S

    if {$who eq "font"} {
        set S(font) [$S(W).lfonts get [$S(W).lfonts curselection]]
    } elseif {$who eq "style"} {
        set S(style) [$S(W).lstyles get [$S(W).lstyles curselection]]
    } elseif {$who eq "size"} {
        set S(size) [$S(W).lsizes get [$S(W).lsizes curselection]]
    }
    ::ChooseFont::Show
 }
 proc ::ChooseFont::Tracer {var1 var2 op} {
    variable S

    set bad 0
    set nstate normal
    # Make selection in each listbox
    foreach var {font style size} {
        set value [string tolower $S($var)]
        $S(W).l${var}s selection clear 0 end
        set n [lsearch -exact $S(${var}s,lcase) $value]
        $S(W).l${var}s selection set $n
        if {$n != -1} {
            set S($var) [lindex $S(${var}s) $n]
            $S(W).e$var icursor end
            $S(W).e$var selection clear
        } else {                                ;# No match, try prefix
            # Size is weird: valid numbers are legal but don't display
            # unless in the font size list
            set n [lsearch -glob $S(${var}s,lcase) "$value*"]
            set bad 1
            if {$var ne "size" || ! [string is double -strict $value]} {
                set nstate disabled
            }
        }
        $S(W).l${var}s see $n
    }
    if {! $bad} ::ChooseFont::Show
    $S(W).ok config -state $nstate
 }

 proc ::ChooseFont::Show {} {
    variable S

    set S(result) [list $S(font) $S(size)]
    if {$S(style) eq "Bold"} { lappend S(result) bold }
    if {$S(style) eq "Italic"} { lappend S(result) italic }
    if {$S(style) eq "Bold Italic"} { lappend S(result) bold italic}
    if {$S(strike)} { lappend S(result) overstrike}
    if {$S(under)} { lappend S(result) underline}

    set S(result) [list "-family" $S(font) "-size" $S(size)]
    if {$S(style) eq "Bold"} { lappend S(result) "-weight" bold }
    if {$S(style) eq "Italic"} { lappend S(result) "-weight" italic }
    if {$S(style) eq "Bold Italic"} { lappend S(result) "-weight" bold italic}
    if {$S(strike)} { lappend S(result) "-overstrike" 1}
    if {$S(under)} { lappend S(result) "-underline" 1}

    $S(sample) config -font $S(result)
 }


 # Quick test
# set font [::ChooseFont::ChooseFont "-family {Arial} -size 16 -weight bold"]
# puts "font is '$font'"
# return
