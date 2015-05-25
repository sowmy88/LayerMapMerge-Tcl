
proc check_args {file_list} {
	if {[llength $file_list] < 2} {
		puts "-ERROR- Please provide two files to merge"
		return 1
	}
	foreach inputfile $file_list {
		if {![file exists [file nativename $inputfile]]} {
			puts "-ERROR- File $inputfile does not exist "
			return 1
		}
	}
	return 0
}

proc _lineToList { line_data } {
	set data_list [list]
	#remove blank lines
	if {[string length [string trim $line_data]] == 0 } {
		return $data_list
	}
	# ignore comment lines
	if { [regexp {^#} $line_data] } {
		return $data_list
	}
	#remove redundant white spaces
	regsub -all { +} $line_data { } line_data     
	set data_list [split $line_data " "]
	return $data_list
}

proc _writeOutput { mapping_array_name debug_array_name debugflag } {
	upvar $mapping_array_name mapping_array
	upvar $debug_array_name debug_array
	set outfile [open "output.txt" w]
	puts "Output file : [pwd]\/output.txt"
	if { $debugflag == 1 } { 
		set debugfile [open "debuglog.txt" w]
		puts "Debugfile : [pwd]\/debuglog.txt"
	}
	#iterate and print in alphabetical order of keys into new file
	foreach lpp [lsort [array names mapping_array]] { 
		#lpp refers to layer purpose pair
		puts $outfile "$lpp $mapping_array($lpp)"
		if { $debugflag == 1 } {
			puts $debugfile "$lpp $debug_array($lpp)"
		}
	}
	close $outfile
	if {$debugflag == 1} {
		close $debugfile
	}
}

# Layer Map merge takes a priority list of layer map files which map from OpenAccess layer purpose pairs to GDS number and datatype.
# This is a utility script useful when there are conflicting layer maps and one unique layer mapping has to be generated.
 proc layer_map_merge {file_list} {
    global env;
	if {[check_args $file_list]} {
		return 
	}
	set debugflag 0
	if { [info exists env(MAP_DEBUG)] && $env(MAP_DEBUG)==1} {
	    set debugflag 1
	}
	array set mapping_array {} 
	array set debug_array {}
	foreach inputfile $file_list { 
		set filehandle [open $inputfile r];
		while { [gets $filehandle line_data] >= 0 } { 
		set data_list [_lineToList $line_data]
			if { [llength $data_list] == 0} {
				continue
			}
			set oa_layer_purpose [join "[lindex $data_list 0] [lindex $data_list 1]"] 
			set gds_num [join "[lindex $data_list 2] [lindex $data_list 3]"] 
			set mapping_array($oa_layer_purpose) "$gds_num";
			if { $debugflag == 1 } {
		       set debug_array($oa_layer_purpose) "$gds_num $inputfile"
			}
		}
		close $filehandle
	}
	_writeOutput mapping_array debug_array $debugflag 
	array unset mapping_array
	array unset debug_array
}

if { [info exists argv] } {
	layer_map_merge $argv
}
