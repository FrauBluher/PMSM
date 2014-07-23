
# see if name refers to imported module or another object. If so, skip it.
if {[string first "." $name] >= -1} {
    set spot [string first "." $name]
    set mod [string range $name 0 spot]
    if {$mod != "self"} {
}
