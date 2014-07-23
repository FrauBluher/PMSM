##############################################################################
# $Id: do.tcl,v 1.7 2002/11/18 05:31:47 cgavin Exp $
#
# do.tcl - procedures to manage do and undo actions
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

proc vTcl:passive_push_action {do undo} {
    global vTcl
    ::vTcl::change; # update the title bar
    incr vTcl(change) 1
    incr vTcl(action_index)
    set vTcl(action_limit) $vTcl(action_index)
    set vTcl(action,$vTcl(action_index),do) $do
    set vTcl(action,$vTcl(action_index),undo) $undo
}

proc vTcl:push_action {do undo} {
    global vTcl
    vTcl:passive_push_action $do $undo
    eval $do
}

proc vTcl:pop_action {} {
    global vTcl
    incr vTcl(change) -1
    if { $vTcl(action_index) >= 0 } {
        vTcl:destroy_handles
        eval $vTcl(action,$vTcl(action_index),undo)
        incr vTcl(action_index) -1
        vTcl:setup_bind_widget .
    } else {
        ::vTcl::MessageBox -icon error -parent .vTcl -title "No undo!" \
            -message "Nothing to undo!" -type ok
    }
}

proc vTcl:redo_action {} {
    global vTcl
    ::vTcl::change; # update the title bar
    incr vTcl(change) 1
    if { $vTcl(action_index) < $vTcl(action_limit) } {
        vTcl:destroy_handles
        incr vTcl(action_index) 1
        eval $vTcl(action,$vTcl(action_index),do)
        vTcl:setup_bind_widget .
    } else {
        ::vTcl::MessageBox -icon error -parent .vTcl -title "No redo!" \
            -message "Nothing to redo!" -type ok
    }
}



