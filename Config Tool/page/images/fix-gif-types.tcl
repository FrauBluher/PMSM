set stat  [cvs status .]

set res  {}
set ent  ""
foreach line [split $stat "\n"]  {

	if {[string match "*File: *" $line]}  {
		set fname  [lindex [split $line " \t"] 1]
		append ent  $fname
	}
	if {[string match "*Sticky Options:*" $line]}  {
		set options  [lindex [split [string trim $line] " \t"] 2]
		set ent  "$ent $options"
		# Only GIF files
		if {[string match "*.gif *" $ent]}  {
			lappend res  $ent
		}
		set ent  ""
	}
}

cvsout "[join $res \n]\n"

foreach file $res  {
	foreach {name type} [split $file " "] break
	if {$type == "(none)"}  {
		cvsout "$file\n"
		cvsout "\tcvs remove $name"
		cvsout "\tcvs commit -c \"\" $name"
		cvsout "file copy ../images
		cvsout "\tcvs add -c \"\" $name"
	}
}
