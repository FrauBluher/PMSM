namespace eval kpwidgets::SBands {
}
proc kpwidgets::SBands { path args } {

    return [eval SBands::create $path $args]
}
proc kpwidgets::SBands::configure { path args } {

}

proc kpwidgets::SBands::create { path args } {
    array set maps [list SBands {} :cmd {}]
    eval frame $path $maps(:cmd) -class SBands
    #::Widget::initFromODB SBands $path $maps(SBands)
    bind $path <Destroy> { destroy $path.sf }
    rename $path ::$path:cmd
    proc ::$path { cmd args } "return \[eval kpwidgets::SBands::\$cmd $path \$args\]"

    set sfw [ ScrolledWindow $path.sw -scrollbar vertical]
    set sff [ ScrollableFrame $path.sw.sff ]
    $sfw setwidget $sff
    set sf [$sff getframe]

    pack $sfw -fill both -expand yes
    return $path
}
proc kpwidgets::SBands::new_frame { path args } {
    set frame_name [ lindex $args 0 ]
    set title [ lindex $args 1 ]

    set bfrm [$path.sw.sff getframe].bfrm$frame_name
    set lbl $bfrm.lbl
    set frm $bfrm.frm
    pack [ frame $bfrm ] -expand yes -fill x
    set title [ linsert $title end (+) ]
    # Rozen Added th "-fb black" in the next statement.
    pack [ label $lbl -text $title \
               -bg #aaaaaa -bd 1 -relief groove -width 31 -fg black] \
        -side top -fill x -expand yes -padx 2
    frame $frm
    bind $lbl <ButtonPress> "kpwidgets::SBands::Expand $bfrm"
    set $path $frm

}
proc kpwidgets::SBands::Expand { bfrm } {
    set frm $bfrm.frm
    set lbl $bfrm.lbl
    set title [$lbl cget -text]
    if { [catch { pack info $frm  } ] } {
        pack $frm -expand yes -fill both -padx 10
        lset title end (-)
    } else {
        lset title end (+)
        pack forget $frm
    }
    $lbl configure -text $title

}
proc kpwidgets::SBands::childsite { path frame_name } {
    return [$path.sw.sff getframe].bfrm$frame_name.frm
}
proc kpwidgets::SBands::current_childsite { path args } {

}

