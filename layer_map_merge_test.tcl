package require struct::list

proc fileLinesToList {filename} {
    if { ![file exists [file nativename $filename]]} {
		return [list]
	}
    set fileHandle	[open $filename]
    set result [split [read $fileHandle] "\n"]
    close $fileHandle
    return $result
}

proc getChangedIndex { inputList common } {
	set result {}
	if { [llength $inputList ] == [llength $common] } {
		return $result
	}
    for {set index 0} {$index < [llength $inputList]} {incr index} {
        if {$index ni $common} {
            lappend result [expr {$index + 1}]
        }
    }
	return $result
}
proc variedLines {filename1 filename2} {
    set inputList1 [fileLinesToList $filename1]
    set inputList2 [fileLinesToList $filename2]
    lassign [struct::list longestCommonSubsequence $inputList1 $inputList2] common1 common2
    set result1 [getChangedIndex $inputList1 $common1]
	set result2 [getChangedIndex $inputList2 $common2]
    return [list $result1 $result2]
}

proc _printDiff { diff file} {
    if { [llength $diff] != 0} {
		set line_nums [join $diff ","]
		puts "The following lines are unique in $file: $line_nums"
	}
}

proc printDifferences { diffs {file1 "golden"} {file2 "output"} } {
	set diff1 [lindex $diffs 0]
	set diff2 [lindex $diffs 1]
	if { [llength $diff1] == 0 && [llength $diff2] == 0 } {
		puts "Regression Clean!"
	} else {
		_printDiff $diff1 $file1
		_printDiff $diff2 $file2
		
	}
}

proc run_regression { } {
    set outfile "./output.txt" 
	source "./layer_map_merge.tcl"
	file delete $outfile
	layer_map_merge [list "./data/input1.txt"  "./data/input2.txt"  "./data/input3.txt" "./data/input4.txt" "./data/input5.txt"]
	set differences [variedLines "./data/golden.txt" $outfile]
	printDifferences $differences
}

run_regression
