#############################################################################
# $Id: bind.tcl,v 1.44 2005/11/12 01:18:00 kenparkerjr Exp $
#
# bind.tcl - procedures to control widget bindings
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

proc vTcl:get_bind {target} {
    if {[winfo exists .vTcl.bind]} {
        ::widgets_bindings::fill_bindings $target 0
        ::widgets_bindings::select_show_binding $target ""
        ::widgets_bindings::enable_toolbar_buttons
        wm title [BindingsEditor] "Widget bindings for $target"
    }
}

proc vTclWindow.vTcl.bind {args} {
    global vTcl
    set base .vTcl.bind
    if {[winfo exists $base]} { wm deiconify $base; return }

    global widget
    vTcl:DefineAlias $base BindingsEditor vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias $base.cpd21.01.cpd25.01 ListboxBindings vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.fra22.but24 RemoveBinding vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.fra22.men20 AddBinding vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.cpd21.02.cpd21.03 TextBindings vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.fra22.but25 MoveTagUp vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.fra22.but26 MoveTagDown vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.fra22.but27 AddTag vTcl:WidgetProc BindingsEditor 1
    vTcl:DefineAlias $base.fra22.but28 DeleteTag vTcl:WidgetProc BindingsEditor 1

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel -menu $base.m37
    wm focusmodel $base passive
    wm withdraw $base
    wm geometry $base 660x514+264+138
    update
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Widget bindings"
    wm transient .vTcl.bind .vTcl

    menu $base.m37 -relief flat
    $base.m37 add cascade \
        -menu "$base.m37.men38" -label Insert
    $base.m37 add cascade \
        -menu "$base.m37.men41" -label Move
    $base.m37 add cascade \
        -menu "$base.m37.men40" -label Add
    $base.m37 add cascade \
        -menu "$base.m37.men39" -label Delete
    menu $base.m37.men38 -tearoff 0 \
        -postcommand "vTcl:enable_entries $base.m37.men38 \$::widgets_bindings::uistate(AddBinding)"

    foreach ev {Button-1        Button-2        Button-3
                ButtonRelease-1 ButtonRelease-2 ButtonRelease-3
                Motion          Enter           Leave
                KeyPress        KeyRelease      FocusIn
                FocusOut        Destroy} {
        $base.m37.men38 add command \
            -command "::widgets_bindings::add_binding <$ev>" \
            -label $ev \
            -foreground $vTcl(pr,fgcolor)   ;# Rozen 2013
    }
    $base.m37.men38 add command \
        -command {::widgets_bindings::show_advanced} \
        -label Advanced...
    menu $base.m37.men39 -tearoff 0 \
        -postcommand "$base.m37.men39 entryconfigure 0 -state \
                     \$::widgets_bindings::uistate(RemoveBinding)
                      $base.m37.men39 entryconfigure 1 -state \
                     \$::widgets_bindings::uistate(DeleteTag)"
    $base.m37.men39 add command \
        -command ::widgets_bindings::delete_binding \
        -label Event
    $base.m37.men39 add command \
        -command ::widgets_bindings::delete_tag \
        -label Tag
    menu $base.m37.men40 -tearoff 0
    $base.m37.men40 add command \
        -command {vTcl:Toplevel:WidgetProc .vTcl.newtag ShowModal} \
        -label Tag...
    menu $base.m37.men41 -tearoff 0 \
        -postcommand "$base.m37.men41 entryconfigure 0 -state \
                     \$::widgets_bindings::uistate(MoveTagUp)
                      $base.m37.men41 entryconfigure 1 -state \
                     \$::widgets_bindings::uistate(MoveTagDown) "
    $base.m37.men41 add command \
        -command {::widgets_bindings::movetag up} \
        -label Up
    $base.m37.men41 add command \
        -command {::widgets_bindings::movetag down} \
        -label Down

    # fr22 is the top frame contaning the menu, etc.
    frame $base.fra22 \
        -borderwidth 2 -height 75 \
        -width 125
    # but34 is the one with the check. It appears to save the bindings.
    ::vTcl::OkButton $base.fra22.but34 \
        -command {
            if { [::widgets_bindings::save_current_binding] != 1 } {
                        Window hide .vTcl.bind
            }
         }
    vTcl:set_balloon $base.fra22.but34 "Close"
    # background was #000000
    frame $base.cpd21 \
        -background red -height 100 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 200
    #background was #9900991B99FE
    frame $base.cpd21.01 \
        -background green -highlightbackground #dcdcdc \
        -highlightcolor #000000
    vTcl:toolbar_menubutton $base.fra22.men20 \
        -image [vTcl:image:get_image "add.gif"] -menu $base.fra22.men20.m
    menu $base.fra22.men20.m \
        -borderwidth 1 \
        -tearoff 0
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Button-1>} -label Button-1
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Button-2>} -label Button-2
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Button-3>} -label Button-3
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <ButtonRelease-1>} \
        -label ButtonRelease-1
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <ButtonRelease-2>} \
        -label ButtonRelease-2
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <ButtonRelease-3>} \
        -label ButtonRelease-3
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Motion>} -label Motion
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Enter>} -label Enter
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Leave>} -label Leave
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <KeyPress>} -label KeyPress
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <KeyRelease>} \
        -label KeyRelease
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <FocusIn>} -label FocusIn
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <FocusOut>} -label FocusOut
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Destroy>} -label Destroy
    $base.fra22.men20.m add command \
        -command {::widgets_bindings::show_advanced} -label Advanced...
    ::vTcl::CancelButton $base.fra22.but24 \
    -command "::widgets_bindings::delete_binding"
    vTcl:toolbar_button $base.fra22.but25 \
        -command "::widgets_bindings::movetag up" \
        -image up \
        -padx 0 -pady 0 -text button
    vTcl:toolbar_button $base.fra22.but26 \
        -command "::widgets_bindings::movetag down" \
        -image down \
        -padx 0 -pady 0 -text button
    vTcl:toolbar_button $base.fra22.but27 \
        -command "vTcl:Toplevel:WidgetProc .vTcl.newtag ShowModal" \
        -padx 0 -pady 0 -image icon_message.gif
    vTcl:toolbar_button $base.fra22.but28 \
        -command "::widgets_bindings::delete_tag" \
        -padx 0 -pady 0 -image delete_tag


    #background was #dcdcdc
    ScrolledWindow $base.cpd21.01.cpd25 -background plum
    #background  was white
    listbox $base.cpd21.01.cpd25.01 -background blue ;# This is ListboxBindings
    $base.cpd21.01.cpd25 setwidget $base.cpd21.01.cpd25.01
    bindtags $base.cpd21.01.cpd25.01 "Listbox $base.cpd21.01.cpd25.01 $base all"
    bind $base.cpd21.01.cpd25.01 <Button-3> {
        ListboxBindings selection clear 0 end
        ListboxBindings selection set @%x,%y
        ListboxBindings activate @%x,%y
        ::widgets_bindings::enable_toolbar_buttons
        ::widgets_bindings::select_binding
    }
    bind $base.cpd21.01.cpd25.01 <<ListboxSelect>> {
        ::widgets_bindings::listbox_click
    }
    bind $base.cpd21.01.cpd25.01 <ButtonRelease-3> {
        if {[::widgets_bindings::can_change_modifier %W \
            [lindex [%W curselection] 0] ]} {
            tk_popup %W.menu %X %Y
        }
    }
    bind $base.cpd21.01.cpd25.01 <KeyRelease-Delete> {
        ::widgets_bindings::delete_binding
    }
    menu $base.cpd21.01.cpd25.01.menu \
        -borderwidth 1 \
        -tearoff 0
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier ""} \
        -label {<no modifier>}
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Double} \
        -label Double
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Triple} \
        -label Triple
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Control} \
        -label Control
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Shift} \
        -label Shift
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Meta} -label Meta
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Alt} -label Alt
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Button1} \
        -label Button1
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Button2} \
        -label Button2
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Button3} \
        -label Button3
    frame $base.cpd21.02 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000

    # Background was  #dcdcdc
    ScrolledWindow $base.cpd21.02.cpd21 -background #dcdcdc
    text $base.cpd21.02.cpd21.03 \
        -background white \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8
    $base.cpd21.02.cpd21 setwidget $base.cpd21.02.cpd21.03
    bind $base.cpd21.02.cpd21.03 <ButtonRelease-3> {
        if {![winfo exists %W.menu]} { menu %W.menu }

        %W.menu configure -tearoff 0
        %W.menu delete 0 end
        %W.menu add command -label "%%%% Single percent"  \
            -command "TextBindings insert insert %%"
        %W.menu add command -label "%%\# Request number"  \
            -command "TextBindings insert insert %%\#"
        %W.menu add command -label "%%W Window name"  \
            -command "TextBindings insert insert %%W"
        %W.menu add command -label "%%b Mouse button number"  \
            -command "TextBindings insert insert %%b"
        %W.menu add command -label "%%d Detail"  \
            -command "TextBindings insert insert %%d"
        %W.menu add command -label "%%A Key pressed/released (ASCII)"  \
            -command "TextBindings insert insert %%A"
        %W.menu add command -label "%%K Key pressed/released (Keysym)"  \
            -command "TextBindings insert insert %%K"
        %W.menu add command -label "%%x Mouse x coordinate widget-relative"  \
            -command "TextBindings insert insert %%x"
        %W.menu add command -label "%%y Mouse y coordinate widget-relative"  \
            -command "TextBindings insert insert %%y"
        %W.menu add command -label "%%T Event type"  \
            -command "TextBindings insert insert %%T"
        %W.menu add command -label "%%X Mouse x coordinate desktop-relative"  \
            -command "TextBindings insert insert %%X"
        %W.menu add command -label "%%Y Mouse y coordinate desktop-relative"  \
            -command "TextBindings insert insert %%Y"
        tk_popup %W.menu %X %Y
    }
    #This binding is disabled in  select_bindings so that the
    #syntax is not checked twice
    bind $base.cpd21.02.cpd21.03 <FocusOut> {
        ::widgets_bindings::save_current_binding
    }

    frame $base.cpd21.03 \
        -background #dcdcdc -borderwidth 2 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -relief raised
    bind $base.cpd21.03 <B1-Motion> {
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
    pack $base.fra22 \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.fra22.but34 \
        -in $base.fra22 -anchor center -expand 0 -fill none -side right
    pack $base.cpd21 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd21.01 \
        -x 0 -y 0 -width -1 -relwidth 0.3681 -relheight 1 -anchor nw \
        -bordermode ignore
    pack $base.fra22.men20 \
        -in $base.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra22.but24 \
        -in $base.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra22.but27  \
        -in $base.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra22.but28  \
        -in $base.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra22.but25  \
        -in $base.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.fra22.but26  \
        -in $base.fra22 -anchor center -expand 0 -fill none \
        -side left

    pack $base.cpd21.01.cpd25 \
        -in $base.cpd21.01 -anchor center -expand 1 -fill both -side top
    #pack $base.cpd21.01.cpd25.01      Rozen BWidget

    place $base.cpd21.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.6319 -relheight 1 -anchor ne \
        -bordermode ignore

    pack $base.cpd21.02.cpd21 \
        -in $base.cpd21.02 -anchor center -expand 1 -fill both -side top
    #pack $base.cpd21.02.cpd21.03     Rozen BWidget

    place $base.cpd21.03 \
        -x 0 -relx 0.3681 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore

    #pack [ttk::sizegrip $base.cpd21.sz ] -side right -anchor se

    vTcl:set_balloon $widget(AddBinding)    "Add a binding"
    vTcl:set_balloon $widget(RemoveBinding) "Remove a binding"
    vTcl:set_balloon $widget(MoveTagUp)     "Move tag up"
    vTcl:set_balloon $widget(MoveTagDown)   "Move tag down"
    vTcl:set_balloon $widget(AddTag)        "Add/Reuse tag"
    vTcl:set_balloon $widget(DeleteTag)     "Delete tag"

    Window hide .vTcl.newbind
    #Window show .vTcl.newbind         ;# Rozen

    array set ::widgets_bindings::uistate {
          AddBinding    disabled   RemoveBinding disabled
          MoveTagUp     disabled   MoveTagDown   disabled
          DeleteTag     disabled }

    ## only initializes UI stuff; the list of bindings tags has already
    ## been initialized either on vTcl startup or when closing a project
    ::widgets_bindings::init_ui

    ## setup standard bindings
    vTcl:setup_vTcl:bind .vTcl.bind

    ## override global <KeyPress-Delete> accelerator for the listbox
    bind _vTclBindDelete <KeyPress-Delete> {
        ::widgets_bindings::delete_binding

        # stop event processing here
        break
    }

    bindtags $widget(ListboxBindings) \
        "_vTclBindDelete [bindtags $widget(ListboxBindings)]"

    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base
}

proc vTclWindow.vTcl.newbind {base} {
    global vTcl
    if {$base == ""} {
        set base .vTcl.newbind
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget
    vTcl:DefineAlias $base BindingsInsert vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias $base.fra23.cpd34.01 BindingsModifiers vTcl:WidgetProc BindingsInsert 1
    vTcl:DefineAlias $base.fra23.cpd35.01 BindingsEvents vTcl:WidgetProc BindingsInsert 1
    vTcl:DefineAlias $base.fra36.ent38 BindingsEventEntry vTcl:WidgetProc BindingsInsert 1

    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm withdraw $base
    #wm geometry $base 500x400+418+226
    wm geometry $base 500x500+418+226  ;# Rozen
    update
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Insert new binding"
    wm transient .vTcl.newbind .vTcl
    bind $base <<Show>> {
        set %W::status 0
    }
    bind $base <<Hide>> {
        set %W::status 1
    }
    bind $base <<DeleteWindow>> {
        BindingsInsert hide
    }

    frame $base.fra20
    label $base.fra20.lab21 \
        -borderwidth 1 -foreground $vTcl(pr,fgcolor) \
        -text {Type keystrokes}
    entry $base.fra20.ent22 \
        -background #ffffff -cursor {} -foreground #000000 \
        -textvariable bindingsKeystrokes -width 10
    bind $base.fra20.ent22 <Key> {
        set bindingsEventEntry "$bindingsEventEntry<Key-%K>"
        after idle {set bindingsKeystrokes ""}
    }

    frame $base.fra23
    label $base.fra23.lab24 \
        -borderwidth 1 \
        -text {Select a mouse event or a key event}

    ScrolledWindow $base.fra23.cpd34 -background #dcdcdc
    listbox $base.fra23.cpd34.01 ;# -foreground black
    $base.fra23.cpd34 setwidget $base.fra23.cpd34.01
    bind $base.fra23.cpd34.01 <Button-1> {
        set modifier [BindingsModifiers get @%x,%y]
        set bindingsEventEntry [::widgets_bindings::set_modifier_in_event \
            $bindingsEventEntry $modifier]
    }

    ScrolledWindow $base.fra23.cpd35
    listbox $base.fra23.cpd35.01 ;#-foreground black
    $base.fra23.cpd35 setwidget $base.fra23.cpd35.01
    bind $base.fra23.cpd35.01 <Button-1> {
        set event [BindingsEvents get @%x,%y]
        if {![string match <<*>> $event]} {
            set event <$event>
        }
        set bindingsEventEntry $bindingsEventEntry$event
    }

    frame $base.fra36
    label $base.fra36.lab37 \
        -borderwidth 1 -text Event
    entry $base.fra36.ent38 \
        -background #ffffff -cursor {} -foreground #000000 \
        -textvariable bindingsEventEntry
    bind $base.fra36.ent38 <ButtonRelease-1> {
        set index [BindingsEventEntry index @%x]
        set stindex ""
        set endindex ""
        ::widgets_bindings::find_event_in_sequence \
            $bindingsEventEntry $index stindex endindex
        BindingsEventEntry selection range $stindex [expr $endindex + 1]
    }
    bind $base.fra36.ent38 <Control-KeyRelease-Left> {
        set index [BindingsEventEntry index insert]
        set stindex ""
        set endindex ""
        ::widgets_bindings::find_event_in_sequence \
            $bindingsEventEntry $index stindex endindex
        BindingsEventEntry selection range $stindex [expr $endindex + 1]
    }
    bind $base.fra36.ent38 <Control-KeyRelease-Right> {
        set index [BindingsEventEntry index insert]
        set stindex ""
        set endindex ""
        ::widgets_bindings::find_event_in_sequence \
            $bindingsEventEntry $index stindex endindex
        BindingsEventEntry selection range $stindex [expr $endindex + 1]
    }
    frame $base.fra37
    button $base.fra37.but01 -text "Add" -width 8 \
            -command {
             if {$bindingsEventEntry != ""} {
                 BindingsInsert hide
                 ::widgets_bindings::add_binding $bindingsEventEntry
             }
         }
    button $base.fra37.but02 -text "Cancel" -width 8 \
        -command {BindingsInsert hide}

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor center -expand 0 -fill x -ipady 10 -side top
    pack $base.fra20.lab21 \
        -in $base.fra20 -anchor center -expand 0 -fill none -side left
    pack $base.fra20.ent22 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 \
        -side left

    pack $base.fra23 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.fra23.lab24 \
        -in $base.fra23 -anchor center -expand 0 -fill none -ipady 10 \
        -side top

    pack $base.fra23.cpd34 \
        -in $base.fra23 -anchor center -expand 1 -fill both -side right
    #pack $base.fra23.cpd34.01   Rozen 7/19 pm

    pack $base.fra23.cpd35 \
        -in $base.fra23 -anchor center -expand 1 -fill both -side left
    #pack $base.fra23.cpd35.01

    pack $base.fra36 \
        -in $base -anchor center -expand 0 -fill x -ipady 10 -side top
    pack $base.fra36.lab37 \
        -in $base.fra36 -anchor center -expand 0 -fill none -side left
    pack $base.fra36.ent38 \
        -in $base.fra36 -anchor center -expand 1 -fill x -side left
    pack $base.fra37 -side bottom
    pack $base.fra37.but01 -side left -padx 5 -pady 5
    pack $base.fra37.but02 -side left -padx 5 -pady 5

    BindingsModifiers delete 0 end
    foreach modifier {
        "<no modifier>" Double Triple Control
        Shift Meta Alt Lock
        Button1 Button2 Button3
    } {
        BindingsModifiers insert end $modifier
    }

    BindingsEvents delete 0 end
    foreach event {
        Button-1 Button-2 Button-3
        ButtonRelease-1 ButtonRelease-2 ButtonRelease-3
        Motion KeyPress KeyRelease Enter Leave
        FocusIn FocusOut Activate Deactivate MouseWheel
        Map Unmap Configure Destroy
    } {
        BindingsEvents insert end $event
    }

    # [event info] list of all virtual event curently defined.
    foreach event [event info] {
        if {[string match <<TkCon*>> $event]} { continue }
        BindingsEvents insert end $event
    }

    # Rozen. Pick up the virtual events defined in the man page.
    set class [winfo class $::widgets_bindings::target]
    if {[info exists vTcl($class,virtual_bindings)]} {
        foreach event $vTcl($class,virtual_bindings) {
            BindingsEvents insert end $event
        }
    }

    vTcl:center $base 500 400
    wm deiconify $base
}

proc vTclWindow.vTcl.newtag {base} {

    if {$base == ""} {
        set base .vTcl.newtag
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    # this window will be a modal one (I have to figure
    # out how to make this work) so this is why I
    # am destroying it when the user clicks "Cancel"

    global widget
    vTcl:DefineAlias $base.fra20.but21 NewBindingTagOK vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra20.but23 NewBindingTagCancel vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra24.cpd26.01 ListboxTags vTcl:WidgetProc $base 1
    vTcl:DefineAlias $base.fra24.ent28 NewBindingTagEntry vTcl:WidgetProc $base 1

    global NewBindingTagName
    set NewBindingTagName ""

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 340x319+149+138
    wm withdraw $base
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    vTcl:center $base 340 319
    wm deiconify $base
    wm title $base "Binding tags"
    wm transient .vTcl.newtag .vTcl

    frame $base.fra20
    button $base.fra20.but21 \
        -text OK -width 8 \
        -command {

                if {$NewBindingTagName != ""} {
                    ::widgets_bindings::add_tag $NewBindingTagName
        } else {
            ::widgets_bindings::add_tag \
                        [ListboxTags get [lindex [ListboxTags curselection] 0] ]
            }
            Window destroy .vTcl.newtag

        } \
        -state disabled
    button $base.fra20.but23 \
        -text Cancel -width 8 \
        -command "Window destroy .vTcl.newtag"
    frame $base.fra24 \
        -borderwidth 2 -height 75
    label $base.fra24.lab25 \
        -text {Select an existing tag:}

    ScrolledWindow $base.fra24.cpd26
    listbox $base.fra24.cpd26.01
    $base.fra24.cpd26 setwidget $base.fra24.cpd26.01

    label $base.fra24.lab27 \
        -text {Or name a new tag:} ;# -fg black
    entry $base.fra24.ent28 \
        -textvariable NewBindingTagName -bg white ;# -fg black
    bind $base.fra24.ent28 <KeyRelease> {
        if {$NewBindingTagName == ""} {
            NewBindingTagOK configure -state disabled
        } else {
            ListboxTags selection clear 0 end
            NewBindingTagOK configure -state normal
        }
    }
    bind $base.fra24.ent28 <ButtonRelease-1> {
        ListboxTags selection clear 0 end
    }
    bind $base.fra24.cpd26.01 <ButtonRelease-1> {
        set indices [ListboxTags curselection]
        if { [llength $indices] > 0} {
            NewBindingTagOK configure -state normal
            set NewBindingTagName \
                [ListboxTags get [lindex $indices 0] ]
        }
    }

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor center -expand 0 -fill none -pady 5 -side bottom
    pack $base.fra20.but21 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 \
        -side left
    pack $base.fra20.but23 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 \
        -side right
    pack $base.fra24 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.fra24.lab25 \
        -in $base.fra24 -anchor center -expand 0 -fill none -side top
    pack $base.fra24.cpd26 \
        -in $base.fra24 -anchor center -expand 1 -fill both -side top
    #pack $base.fra24.cpd26.01    Rozen 7/19 pm

    pack $base.fra24.lab27 \
        -in $base.fra24 -anchor center -expand 0 -fill none -side top
    pack $base.fra24.ent28 \
        -in $base.fra24 -anchor center -expand 0 -fill x -side top

    ListboxTags delete 0 end

    foreach tag $::widgets_bindings::tagslist {
        ListboxTags insert end $tag
    }
}

####################################
# code to manage the bindings editor
#

namespace eval ::widgets_bindings {

    variable tagslist ""
    variable backup_bindings ""

    proc ::widgets_bindings::show_advanced {} {
        Window show .vTcl.newbind
        raise [BindingsInsert]
        grab set [BindingsInsert]
        vwait [BindingsInsert]::status
        grab release [BindingsInsert]
    }

    proc {::widgets_bindings::listbox_click} {} {
    set widgets_bindings::saveselected $::widgets_bindings::lastselected
    set widgets_bindings::lastselected [lindex [ListboxBindings curselection] 0]

        ::widgets_bindings::enable_toolbar_buttons
        after idle "::widgets_bindings::select_binding"
    }

    proc {::widgets_bindings::delete_tag} {} {
        global vTcl widget

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        if {![::widgets_bindings::is_editable_tag $tag]} return

        set target $widgets_bindings::target

        vTcl::lremove vTcl(bindtags,$target) $tag

        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $target ""
    }

    proc {::widgets_bindings::movetag} {moveupdown} {
        global vTcl widget

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        set target $widgets_bindings::target

        set tags $vTcl(bindtags,$target)

        # what position is the existing tag at ?
        set index [lsearch -exact $tags $tag]

        # what new position should it be
        if {$moveupdown == "down"} {
            set newindex [expr $index + 1]
            set oldtag [lindex $tags $newindex]
            set tags [lreplace $tags $index $newindex $oldtag $tag]
        } else {
            set newindex [expr $index - 1]
            set oldtag [lindex $tags $newindex]
            set tags [lreplace $tags $newindex $index $tag $oldtag]
        }

        set vTcl(bindtags,$target) $tags
        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag ""
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::add_tag_to_tagslist} {tag} {

        # new tag ?
        if {[lsearch -exact $::widgets_bindings::tagslist $tag] == -1} {
            lappend ::widgets_bindings::tagslist $tag
        }
    }

    proc {::widgets_bindings::remove_tag_from_widget} {target tag} {
        vTcl::lremove ::vTcl(bindtags,$target) $tag
    }

    proc {::widgets_bindings::add_tag_to_widget} {target tag} {
        # target has tag in its list ?
    set result [lsearch -exact $::vTcl(bindtags,$target) $tag]
        if {$result == -1} {
            lappend ::vTcl(bindtags,$target) $tag
        }
    }

    proc {::widgets_bindings::add_tag} {tag} {

        global vTcl widget

        ::widgets_bindings::add_tag_to_tagslist $tag

        set target $widgets_bindings::target

        ::widgets_bindings::add_tag_to_widget $target $tag
        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag ""
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::is_editable_tag} {tag} {
        global widget

        set target $widgets_bindings::target

        if {$tag == $target} {
            return 1
        }

        if {[lsearch -exact $::widgets_bindings::tagslist $tag] >= 0} {
            return 1
        }

    if {[lsearch -exact [::widgets_bindings::get_subwidgets $target] $tag] >= 0} {
        return 1
    }

        return 0
    }

    proc {::widgets_bindings::add_binding} {event} {
        global widget

        # before selecting a different binding, make sure we
        # save the current one
        if { [::widgets_bindings::save_current_binding] == 1 } {

        return
    }



        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} {
            set index $::widgets_bindings::lastselected
        }

        set tag ""
        set tmp_event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag tmp_event

        set target $widgets_bindings::target

        if {![::widgets_bindings::is_editable_tag $tag]} return

        # event already bound ?
        set old_code [bind $tag $event]
        if {$old_code == ""} {
            ## this is a new event; allow for undoing
            set do ""
            # Rozen.  Too verbose, reduce usability.
            #append do "bind $tag $event \"\# TODO: your event handler here\""
            append do "bind $tag $event \"lambda e: xxx(e)\""
            append do ";::widgets_bindings::fill_bindings $target"
            append do ";::widgets_bindings::select_show_binding $tag $event"
            append do ";::widgets_bindings::enable_toolbar_buttons"
            set undo ""
            append undo "bind $tag $event \"\""
            append undo ";::widgets_bindings::clear_current_binding"
            append undo ";if \{\$vTcl(w,widget)==\"$target\"\} \{vTcl:get_bind $target\}"
            vTcl:push_action $do $undo
        } else {
            ## event has been bound already; just select it, no do/undo required
            ::widgets_bindings::fill_bindings $target
            ::widgets_bindings::select_show_binding $tag $event
            ::widgets_bindings::enable_toolbar_buttons
        }
    }

    proc {::widgets_bindings::can_change_modifier} {l index} {

        global widget

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event $l $index tag event

        if {[::widgets_bindings::is_editable_tag $tag] &&
            $event != ""} {
            return 1
        } else {
            return 0
        }
    }

    proc {::widgets_bindings::change_binding} {tag event modifier} {

        global widget
        set target $widgets_bindings::target

        if {![::widgets_bindings::is_editable_tag $tag]} return

        regexp <(.*)> $event matchAll event_name

        # unbind old event first
        bind $tag $event ""
        set ::widgets_bindings::lasttag ""
        set ::widgets_bindings::lastevent ""

        # rebind new event
        set event [::widgets_bindings::set_modifier_in_event  $event $modifier]

        bind $tag $event [TextBindings get 0.0 end]

        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag $event
    }

    proc {::widgets_bindings::delete_binding} {} {

        global widget

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        set target $widgets_bindings::target

        if {![::widgets_bindings::is_editable_tag $tag] ||
            $event == ""} return

        set do ""
        append do "bind $tag $event \"\""
        append do ";::widgets_bindings::clear_current_binding"
        append do ";::widgets_bindings::fill_bindings $target"
        set undo ""
        append undo "bind $tag $event [list [bind $tag $event]]"
        append undo ";::widgets_bindings::clear_current_binding"
        append undo ";if \{\$vTcl(w,widget)==\"$target\"\} \{vTcl:get_bind $target\}"
        vTcl:push_action $do $undo
    }

    proc {::widgets_bindings::enable_toolbar_buttons} {} {

        global widget vTcl

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} {
            array set ::widgets_bindings::uistate {
                AddBinding    disabled   RemoveBinding disabled
                MoveTagUp     disabled   MoveTagDown   disabled
                DeleteTag     disabled }
            ::widgets_bindings::set_uistate
            return
        }

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        if {[::widgets_bindings::is_editable_tag $tag]} {
            array set ::widgets_bindings::uistate { AddBinding normal }

            if {$event == ""} {
                array set ::widgets_bindings::uistate {
                    DeleteTag normal RemoveBinding disabled }
            } else {
                array set ::widgets_bindings::uistate {
                    RemoveBinding normal DeleteTag disabled }
            }
        } else {
            array set ::widgets_bindings::uistate {
                AddBinding  disabled  RemoveBinding disabled
                DeleteTag   disabled }
        }

        set target $::widgets_bindings::target

    if {$event == "" && [lsearch -exact [get_subwidgets $target] $tag] >=0} {
            array set ::widgets_bindings::uistate {
                MoveTagUp   disabled  MoveTagDown disabled }
    } elseif {$event == ""} {
            if {$index > 0} {
                array set ::widgets_bindings::uistate { MoveTagUp normal }
            } else {
                array set ::widgets_bindings::uistate { MoveTagUp disabled }
            }

            set pos [lsearch -exact $vTcl(bindtags,$target) $tag]
            if {$pos == [expr [llength $vTcl(bindtags,$target)] - 1]} {
                array set ::widgets_bindings::uistate { MoveTagDown disabled }
            } else {
                array set ::widgets_bindings::uistate { MoveTagDown normal }
            }
        } else {
            array set ::widgets_bindings::uistate {
                MoveTagUp   disabled  MoveTagDown disabled }
        }

        ::widgets_bindings::set_uistate
    }

    proc {::widgets_bindings::set_uistate} {} {
        foreach name [array names ::widgets_bindings::uistate] {
            $name configure -state $::widgets_bindings::uistate($name)
        }
    }

    proc get_subwidgets {target} {
        global classes
    set class [vTcl:get_class $target]
    if {[info exists classes($class,editableTagsCmd)]} {
        return [$classes($class,editableTagsCmd) $target]
    } else {
        return ""
    }
    }

    proc {::widgets_bindings::fill_bindings} {target {change 1}} {
        global widget vTcl tk_version
        # before selecting a different binding, make sure we
        # save the current one

        # w is the bindings editor window
        # target is the widgets whose bindings we want to edit

        # This is where we fill in the list box on the left hand
        # side. This may be the place to substitute the alias. Rozen
        set index 0
        set tags $vTcl(bindtags,$target)
        set tags [concat $tags [::widgets_bindings::get_subwidgets $target]]

        set ::widgets_bindings::bindingslist ""
        ListboxBindings delete 0 end

        set ::widgets_bindings::target $target
        foreach tag $tags {
            set alias ""
            if {[catch {set alias $widget(rev,$tag)}] == 0} {
                # We have an alias.
                ListboxBindings insert end $alias
            } else {
                ListboxBindings insert end $tag
            }
           if {[::widgets_bindings::is_editable_tag $tag]} {
               if {$tk_version > 8.2} {
                   ListboxBindings itemconfigure $index  -foreground blue
               }
           }

           lappend ::widgets_bindings::bindingslist [list $tag ""]
           incr index

           set events [bind $tag]
           foreach event $events {
               ListboxBindings insert end "   $event"
               if {[::widgets_bindings::is_editable_tag $tag]} {
                   if {$tk_version > 8.2} {
                       ListboxBindings itemconfigure $index  -foreground blue
                   }
               }

               lappend ::widgets_bindings::bindingslist [list $tag $event]
               incr index
           }
        }

        # enable/disable various buttons
        ::widgets_bindings::enable_toolbar_buttons

        if {$change} { ::vTcl::change }
    }

    proc {::widgets_bindings::find_tag_event} {l index ref_tag ref_event} {
        global widget

        upvar $ref_tag tag
        upvar $ref_event event

        if {$index == ""} {
            set tag ""
            set event ""
            return
        }

        set bindingslist $::widgets_bindings::bindingslist
        set tagevent [lindex $bindingslist $index]

        set tag   [lindex $tagevent 0]
        set event [lindex $tagevent 1]
    }

    proc {::widgets_bindings::enable_editor} {enable} {

        if {![winfo exists .vTcl.bind]} return

        global widget
        variable backup_bindings

        switch $enable {
            1 - yes - true {
                ListboxBindings configure -background white
                if {$backup_bindings != ""} {
                    bindtags $widget(ListboxBindings) $backup_bindings
                }
                $widget(AddTag) configure -state normal
            }
            0 - no - false {
                ListboxBindings selection clear 0 end
                ListboxBindings configure -background gray
                set backup_bindings [bindtags $widget(ListboxBindings)]
                bindtags $widget(ListboxBindings) dummy
                TextBindings configure -state disabled
                TextBindings configure -background gray
                ::widgets_bindings::enable_toolbar_buttons
                $widget(AddTag) configure -state disabled
            }
        }
    }

    proc {::widgets_bindings::init} {} {

        foreach tag $::widgets_bindings::tagslist {
            foreach event [bind $tag] {
                bind $tag $event ""
            }
        }

        set ::widgets_bindings::tagslist ""

        ::widgets_bindings::init_ui
    }

    proc {::widgets_bindings::init_ui} {} {

        global vTcl

        if {![winfo exists .vTcl.bind]} { return }

        # enable editor in case it was disabled in test mode
        ::widgets_bindings::enable_editor 1

        ListboxBindings delete 0 end

        TextBindings configure -state normal
        TextBindings delete 0.0 end
        TextBindings configure -background gray -state disabled
    variable saveselected 0
        variable lastselected 0
        variable lasttag ""
        variable lastevent ""
        variable target ""
        variable bindingslist ""

        # enable/disable various buttons
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::right_click_modifier} {modifier} {

        global widget

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        if {$tag == "" || $event == ""} {
            return
        }

        set target $widgets_bindings::target

        if {![::widgets_bindings::is_editable_tag $tag]} return

        ::widgets_bindings::change_binding $tag $event $modifier
    }

    proc {::widgets_bindings::save_current_binding} {} {

        global widget

        set target $::widgets_bindings::target
        set tag    $::widgets_bindings::lasttag
        set event  $::widgets_bindings::lastevent

        if {$tag == "" || $event == "" || $target == ""} { return }
        if {![winfo exists $target] } { return }
        if {![::widgets_bindings::is_editable_tag $tag]} { return }

        set old_bind [string trim [bind $tag $event]]
        set new_bind [string trim [TextBindings get 0.0 end]]
    if { [info complete $new_bind] == 0 } {
        ::vTcl::MessageBox -icon error \
         -message "Syntax Error: Please check you're code and try again." \
         -title "Syntax Error"
        return 1

    } else {
            # is it really different?
                if {$new_bind != $old_bind} {
                        bind $tag $event $new_bind
                        ::vTcl::change
                return 0
                }
        }

    }

    proc clear_current_binding {} {
        variable lasttag
        set lasttag ""
    }

    proc {::widgets_bindings::select_binding} {} {

    global widget
    #disable focus out binding
    bind $widget(TextBindings) <FocusOut> {  }


        # before selecting a different binding, make sure we
        # save the current one
    #revert to the old selection if there was a syntax error
        if { [::widgets_bindings::save_current_binding] == 1 } {

        ListboxBindings selection clear  0 end

        ListboxBindings selection set $::widgets_bindings::saveselected \
                          $::widgets_bindings::saveselected
        set widgets_bindings::lastselected $::widgets_bindings::saveselected
        focus $widget(TextBindings)
        return
    }

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        if {$tag == "" || $event == ""} {

            TextBindings configure -state normal
            TextBindings delete 0.0 end
            TextBindings configure  -state disabled -background gray
            set ::widgets_bindings::lasttag ""
            set ::widgets_bindings::lastevent ""
            return
        }

        ::widgets_bindings::show_binding $tag $event
        focus $widget(ListboxBindings)
        ListboxBindings selection set $index
focus $widget(TextBindings)
#reenaable the binding for focus out
        bind $widget(TextBindings) <FocusOut> {
            ::widgets_bindings::save_current_binding
        }

    }

    proc {::widgets_bindings::select_show_binding} {tag event} {
        global widget
        # let's find it in the listbox first
        set lasttag ""
        set index 0

        # Tk replaces bindings with shortcuts
        regsub -all Button1 $event B1 event
        regsub -all Button2 $event B2 event
        regsub -all Button3 $event B3 event

        set bindingslist $::widgets_bindings::bindingslist

        foreach tag_event $bindingslist {

            set current_tag   [lindex $tag_event 0]
            set current_event [lindex $tag_event 1]

            if {$current_tag   == $tag &&
                $current_event == $event} {

                ListboxBindings selection clear 0 end
                ListboxBindings selection set $index
                ListboxBindings activate $index
                ListboxBindings see $index

                ::widgets_bindings::show_binding $tag $event
                break
            }

            incr index
        }
    set widgets_bindings::saveselected $index
    set widgets_bindings::lastselected $index

    }

    proc {::widgets_bindings::set_modifier_in_event} {event modifier} {
        global widget

        # modifiers not allowed for virtual events
        if {[string match <<*>> $event]} {
            return $event
        }

        # adds the modifier to the last event in the sequence

        set last [string last < $event]

        if {$last == -1} return

        if {$modifier == "<no modifier>" ||
            $modifier == ""} {
            regsub -all Button- $event Button_ event
            regsub -all ButtonRelease- $event ButtonRelease_ event
            regsub -all Key- $event Key_ event
            set lastmodifier [string last - $event]
            regsub -all Button_ $event Button- event
            regsub -all ButtonRelease_ $event ButtonRelease- event
            regsub -all Key_ $event Key- event

            if {$lastmodifier == -1} {
                return $event
            }

            set newbind [string range $event 0 $last]
            set newbind $newbind[string range $event [expr $lastmodifier+1] end]
            return $newbind
        }

        set newbind [string range $event 0 $last]
        set newbind $newbind${modifier}-[string range $event [expr $last+1] end]
        return $newbind
    }

    proc {::widgets_bindings::show_binding} {tag event} {

        global widget

        set bindcode [string trim [bind $tag $event]]

        TextBindings configure  -state normal
        TextBindings delete 0.0 end
        TextBindings insert 0.0 $bindcode

        if {[::widgets_bindings::is_editable_tag $tag] &&
            $event != ""} {
            TextBindings configure  -background white -state normal
            vTcl:syntax_color $widget(TextBindings) 0 -1

            set ::widgets_bindings::lasttag $tag
            set ::widgets_bindings::lastevent $event
        } else {
            TextBindings configure  -background gray -state disabled

            set ::widgets_bindings::lasttag ""
            set ::widgets_bindings::lastevent ""
        }
    }

    # given an event sequence ("eg. <Key-Space><Button-1>") and
    # an index into this event sequence (eg. 18) returns the start
    # and end index of the event pointed to
    #
    # in the example above the values returned would be 11 and 20

    proc {::widgets_bindings::find_event_in_sequence} \
       {sequence index ref_start_index ref_end_index} {

        upvar $ref_start_index start_index
        upvar $ref_end_index   end_index

        if {$sequence == ""} {
            set start_index -1
            set end_index -1
            return
        }

        regsub -all << $sequence <_ sequence
        regsub -all >> $sequence _> sequence
        set start_index $index
        set end_index   $index

        while {1} {
            set result [string range $sequence $start_index $end_index]

            if { ![string match *>  $result]} {
                incr end_index
                if {$end_index == [string length $sequence]} {
                    incr end_index -1
                    break
                }
            }

            if { ![string match <*  $result]} {
                incr start_index -1
                if {$start_index < 0} {
                    set start_index 0
                    break
                }
            }

            # exit condition ?
            if { [string match <*> $result]} {
                break
            }
        }
    }

    proc {::widgets_bindings::get_standard_bindtags} {target} {

        global vTcl classes
        # returns the default binding tags for any widget
        #
        # for example:
        #        .top19 => ".top19 Toplevel all"
        #
        #        .top19.but22 => ".top19.but22 Button .top19 all"

        set class [winfo class $target]
        if {[info exists classes($class,tagsCmd)] && $classes($class,tagsCmd) != ""} {
            return [$classes($class,tagsCmd) $target]
        }

        if {$class == "Toplevel" || $class == "Vt" || $class == "Menu"} {
            return [list $target $class all]
        }

        set toplevel [winfo toplevel $target]
        return [list $target $class $toplevel all]
    }

} ; # namespace eval



