##############################################################################
# $Id: vtclib.tcl,v 1.18 2003/05/07 06:57:52 cgavin Exp $
#
# vtclib.tcl - procedures shared by Visual Tcl and apps it generates
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

proc Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}

proc vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}

proc vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}

proc vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}

## put it back just for backward compatibility, but made it empty
proc vTcl:WindowsCleanup {} {
    ::vTcl::MessageBox -title "Warning" -message "vTcl:WindowsCleanup is no more supported.
You can use the <<DeleteWindow>> virtual event instead.

You should remove any calls to vTcl:WindowsCleanup before saving your project." \
-type ok -icon warning
}

#
# Two utilities:
#
# info script: returns the absolute filename of the currently
#              interpreted script.
# chase filename: chases a given path "filename" and follows any
#              symlinks until getting a real file/directory or
#              whatever, or until 8 levels of symlinks are reached,
#              when it aborts with an error message.
#              The nesting level can be changed at the location
#              "$count ==" below
#

proc {chasehelper} {filename {count 0}} {
    file lstat $filename filestat
    if {$filestat(type) == "link"} {
    if {$count == 8} { error "Too many symbolic links" }
    # Recurse into next link-level
    chasehelper [file readlink $filename] [incr count]
    } else {
    return $filename
    }
}

proc {info_script} {} {

    set scriptinfo [info script]
    if {$::tcl_platform(platform) != "unix"} {
        return $scriptinfo      ;# windows/mac don't have symbolic links
    }

    if {[string index $scriptinfo 0] == "!"} then {
    set scriptdir $scriptinfo
    } else {
    # For cosmetics we remove ./ in front of the filename
    set scriptpath [file split $scriptinfo]
    if {[lindex $scriptpath 0] == "."} {
        set scriptpath [lrange $scriptpath 1 [llength $scriptpath]]
    }
        set filename [eval file join [pwd] $scriptpath]

    set scriptdir [chasehelper $filename]
    }
    return $scriptdir
}

