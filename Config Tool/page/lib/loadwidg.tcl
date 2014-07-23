##############################################################################
# $Id: loadwidg.tcl,v 1.24 2003/05/03 08:12:52 cgavin Exp $
#
# loadwidg.tcl - procedures to load widget configuration files
#
# Copyright (C) 2000-2001 Damon Courtney
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

# In this modgule, the parameters from the wgt files are read and the
# vTcl(classes,xxx) stuff is initiated at the beginning as the widget
# families are loaded.

proc vTcl:LoadWidgets {dir} {
    # Called from ../vtcl.tcl
    global vTcl tmp
    set lib [file tail $dir]
    foreach file [lsort [glob -nocomplain [file join $dir *.wgt]]] {
        set tmp(lib) $lib
        vTcl:LoadWidget $tmp(lib) $file
    }

    set vTcl(libs) [vTcl:lrmdups $vTcl(libs)]
    set vTcl(classes) [vTcl:lrmdups $vTcl(classes)]
    set vTcl(options) [vTcl:lrmdups $vTcl(options)]
    return
}

proc vTcl:LoadWidget {lib file} {
    global tmp vTcl classes

    set file [file tail $file]
    set file [file join $vTcl(VTCL_HOME) lib Widgets $lib $file]

    if {![file exists $file]} {  set file $file.wgt }
    if {![file exists $file]} { return }


    # The following line causes the text lines in the wgt file to
    # processed by funny procs at end of this module. They become
    # calls to the appropriate proc and the arguments are stored in
    # the global array tmp.  Pretty clever. Rozen

    uplevel #0 source [list $file]
    if {[info exists tmp(isSuperClass)]} {
        if {![info exists tmp(typeCmd)]} {
            return -code error "Must specify a TypeCmd in a super class"
        }

        SetClassArray

        if {![info exists tmp(superClass)]} { unset tmp }
        return
    }

    if {![info exists tmp(class)]} { unset tmp; return }

    SetClassArray

    if {[info exists tmp(isSuperClass)] && $tmp(isSuperClass)} {
        unset tmp
        return
    }

    lappend vTcl(libs) $tmp(lib)
    lappend vTcl(classes) $tmp(class)
    lappend vTcl(lib_$tmp(lib),classes) $tmp(class)

    unset tmp
}

proc SetClassArray {} {
    global vTcl tmp classes
    array set classes "
        $tmp(class),lib             vtcl
        $tmp(class),createCmd       [vTcl:lower_first $tmp(class)]
        $tmp(class),resizable       1
        $tmp(class),dumpChildren    1
        $tmp(class),megaWidget      0
        $tmp(class),dumpCmd         vTcl:dump_widget_opt
        $tmp(class),dumpInfoCmd     vTcl:dump:widget_info
        $tmp(class),compoundCmd     {}
        $tmp(class),tagsCmd         {}
        $tmp(class),options         {}
        $tmp(class),defaultOptions  {}
        $tmp(class),insertCmd       {}
        $tmp(class),selectCmd       {}
        $tmp(class),dblClickCmd     {}
        $tmp(class),exportCmds      {}
        $tmp(class),functionCmds    {}
        $tmp(class),functionText    {}
        $tmp(class),typeCmd         {}
        $tmp(class),aliasPrefix     $tmp(class)
        $tmp(class),widgetProc      vTcl:WidgetProc
        $tmp(class),resizeCmd       vTcl:adjust_widget_size
        $tmp(class),icon            icon_[vTcl:lower_first $tmp(class)].gif
        $tmp(class),balloon         [string tolower $tmp(class)]
        $tmp(class),addOptions      {}
        $tmp(class),autoPlace       0
        $tmp(class),treeLabel       $tmp(class)
        $tmp(class),treeChildrenCmd {}
        $tmp(class),deleteCmd       {}
        $tmp(class),deleteSiteCmd   {}
        $tmp(class),selectSiteCmd   {}
        $tmp(class),defaultValues   {}
        $tmp(class),dontSaveOptions {}
        $tmp(class),ignoreLeftClk   0
        $tmp(class),ignoreRightClk  0
        $tmp(class),TtkOptions      {}
        $tmp(class),ttkWidget       0
    "
    # To access one of the class member defined above use something
    # like:
    #    if {[info exists class(Button,ttkWidget]} {}
    # or:
    #   set z $class($class,ttkWidget)
    foreach elem [array names classes $tmp(class),*] {
        lassign [split $elem ,] name var
        if {![info exists tmp($var)]} { continue }
        set classes($elem) $tmp($var)
    }


    if {[info exists tmp(icon)]} {
        ## Create the toolbar icon.
        if {[vTcl:streq [string index $tmp(icon) 0] "@"]} {
            set cmd [string range $tmp(icon) 1 end]
            set icons [$cmd]
        } else {
            set icons $tmp(icon)
        }
        # FIXME: what's the reason for having more than one icon?
        #   and where is this information found after the creation?
        foreach i $icons {
            set icon [file join $vTcl(VTCL_HOME) images $i]
            if {![file exists $icon]} { continue }
            image create photo $i -file $icon
        }
    } else {
        if {[ensureImage icon_$classes($tmp(class),lib)_unknown.gif]} {
            set classes($tmp(class),icon) icon_tix_unknown.gif
        } else {
            ensureImage icon_unknown.gif
            set classes($tmp(class),icon) icon_unknown.gif
        }
    }
}

proc ensureImage {name} {
    global vTcl

    if {[catch {image type $name}]} {
        set icon [file join $vTcl(VTCL_HOME) images $name]
        if {![file exists $icon]} {
            return 0
        }
        image create photo $name -file $icon
    }

    return 1
}

proc Name {args} { }

proc Class {name} {
    global tmp
    set tmp(class) $name
}

proc Lib {lib} {
    global tmp
    set tmp(lib) $lib
}

proc CreateCmd {cmd} {
    global tmp
    set tmp(createCmd) $cmd
}

proc Icon {icon} {
    global tmp
    set tmp(icon) $icon
}

proc AddOptions {args} {
    global tmp
    eval lappend tmp(addOptions) $args
}

proc Balloon {args} {
    global tmp
    set tmp(balloon) $args
}

proc Option {args} {
    global tmp
    eval lappend tmp(options) $args
}

proc DefaultOptions {args} {
    global tmp
    eval lappend tmp(defaultOptions) $args
}

proc DefaultValues {args} {
    global tmp
    eval lappend tmp(defaultValues) $args
}

proc DontSaveOptions {args} {
    global tmp
    eval lappend tmp(dontSaveOptions) $args
}

proc DumpCmd {val} {
    global tmp
    set tmp(dumpCmd) $val
}

proc CompoundCmd {val} {
    global tmp
    set tmp(compoundCmd) $val
}

proc TagsCmd {val} {
    global tmp
    set tmp(tagsCmd) $val
}

proc DumpChildren {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(dumpChildren) $num
}

proc MegaWidget {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(megaWidget) $num
}

proc InsertCmd {name} {
    global tmp
    set tmp(insertCmd) $name
}

proc SelectCmd {name} {
    global tmp
    set tmp(selectCmd) $name
}

proc DeleteCmd {name} {
    global tmp
    set tmp(deleteCmd) $name
}

proc DeleteSiteCmd {name} {
    global tmp
    set tmp(deleteSiteCmd) $name
}

proc SelectSiteCmd {name} {
    global tmp
    set tmp(selectSiteCmd) $name
}

proc DoubleClickCmd {name} {
    global tmp
    set tmp(dblClickCmd) $name
}

proc TreeLabel {args} {
    global tmp
    set tmp(treeLabel) $args
}

proc Export {name {c ""}} {
    if {$c == ""} {
        global tmp
        lappend tmp(exportCmds) $name
    } else {
        lappend ::classes($c,exportCmds) $name
    }
}

proc NewOption {args} {
    global tmp options vTcl
    lassign $args option text type choices title
    lappend vTcl(options) $option
    set options($option,text) $text
    set options($option,type) $type
    set options($option,choices) $choices
    set options($option,title) $title
}

proc ClassOption {args} {
    eval lappend ::classoption($::tmp(class)) $args
}

## args contains the name of a proc to configure the option
## the proc to configure receives two parameters:
##   w     widget to configure
##   var   name of the variable containing the value
##
## type is "set", "get", "config", or "update"
proc OptionConfigCmd {opt type args} {
    set ::configcmd($opt,$type) $args
}

proc Function {name command} {
    global tmp
    lappend tmp(functionText) $name
    lappend tmp(functionCmds) $command
}

proc SuperClass {val} {
    global tmp
    set tmp(superClass) $val
    vTcl:LoadWidget $tmp(lib) $val
    unset tmp(isSuperClass)
}

proc IsSuperClass {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(isSuperClass) $num
}

proc Resizable {val} {
    global tmp
    set val [string tolower $val]
    if {[string match "n*" $val]} { set tmp(resizable) 0 }
    if {[string match "b*" $val]} { set tmp(resizable) 1 }
    if {[string match "h*" $val]} { set tmp(resizable) 2 }
    if {[string match "v*" $val]} { set tmp(resizable) 3 }
}

proc TypeCmd {val} {
    global tmp
    set tmp(typeCmd) $val
}

proc AutoPlace {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(autoPlace) $num
}

proc AliasPrefix {val} {
    global tmp
    set tmp(aliasPrefix) $val
}

proc WidgetProc {val} {
    global tmp
    set tmp(widgetProc) $val
}

proc ResizeCmd {val} {
    global tmp
    set tmp(resizeCmd) $val
}

proc SpecialOpt {args} {
    global specialOpts tmp
    lassign $args option text type choices title
    set specialOpts($tmp(class),$option,text) $text
    set specialOpts($tmp(class),$option,type) $type
    set specialOpts($tmp(class),$option,choices) $choices
    set specialOpts($tmp(class),$option,title) $title
}

proc AdditionalClasses {args} {

    foreach arg $args {
        lappend ::vTcl(classes) $arg
        set ::classes($args,treeChildrenCmd) {}
        set ::classes($args,megaWidget) 0
        set ::classes($args,ignoreLeftClk) 0
        set ::classes($args,ignoreRightClk) 0
        set ::classes($args,functionCmds) {}
        set ::classes($args,lib) $::tmp(lib)
    }
}

proc IgnoreTreeLeftClick {} {
    global tmp
    set tmp(ignoreLeftClk) 1
}

proc IgnoreTreeRightClick {} {
    global tmp
    set tmp(ignoreRightClk) 1
}

proc TreeChildrenCmd {val} {
    global tmp
    set tmp(treeChildrenCmd) $val
}

proc GetImagesCmd {cmd} {
    set ::classes($::tmp(class),getImagesCmd) $cmd
}

proc GetFontsCmd {cmd} {
    set ::classes($::tmp(class),getFontsCmd) $cmd
}

proc InsertChildCmd {cmd {c ""}} {
    if {$c == ""} {
        set ::classes($::tmp(class),insertChildCmd) $cmd
    } else {
        set ::classes($c,insertChildCmd) $cmd
    }
}

proc IgnoreProc {args} {
    eval lappend ::vTcl(proc,ignore) $args
}

proc TranslateOption {option proc} {
    set ::vTcl(option,translate,$option) $proc
}

proc NoEncaseOption {option value} {
    set ::vTcl(option,noencase,$option) $value
}

proc NoEncaseOptionWhen {option proc} {
    set ::vTcl(option,noencasewhen,$option) $proc
}

proc Insertable {{c ""}} {
    if {$c == ""} {
        set c $::tmp(class)
    }
    set ::classes($c,insertable) 1
}

proc DumpInfoCmd {val} {
    global tmp
    set tmp(dumpInfoCmd) $val
}

proc EditableTagsCmd {val} {
    set ::classes($::tmp(class),editableTagsCmd) $val
}

proc QueryInsertOptionsCmd {val} {
    set ::classes($::tmp(class),queryInsertOptionsCmd) $val
}

proc VirtualEvents {args} {
    # Rozen: To keep track of tk man page specified virtual events.
    global vTcl
    global tmp
    set vTcl($::tmp(class),virtual_bindings) [split $args]
}

#proc DefaultOptions {args} {
proc TtkOptions {args} {
    # Rozen: List of style configure configurations to be done
    global tmp
    eval lappend tmp(TtkOptions) $args
}

#proc DumpChildren {val} {
proc TtkWidget {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(ttkWidget) $num
}
