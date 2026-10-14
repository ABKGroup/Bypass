# This script was written and developed by ABKGroup students at UCSD VLSI CAD Lab. However, the underlying commands and reports are copyrighted by Cadence.
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.

proc place_macro_mem_stack_outside {macro_list stack_size ch_space origin_x origin_y\
                            isFlip} {
  if {$isFlip == 0} {
    set orient [list "R0" "MY"]
    set stack_dir 1
  } else {
    set orient [list "MX" "R180"]
    set stack_dir -1
  }

  # Extract macro informations
  set macro_width [dbget [dbget top.insts.name [lindex $macro_list 0] -p ].box_sizex]
  set macro_height [dbget [dbget top.insts.name [lindex $macro_list 0] -p ].box_sizey]

  # i indicates the row number and j indicates the column number
  set i 0
  set j 0
  set llx $origin_x
  set lly $origin_y
  foreach macro $macro_list {
    # For each column all the macros have same orientation
    set orientation [lindex $orient [expr $j%2]]
    placeInstance $macro $llx $lly $orientation -placed

    incr i
    if { $i == $stack_size } {
      set i 0
      incr j
      set lly $origin_y
      set llx [expr $origin_x + ($j/2)*$ch_space + $j*$macro_width]
    } else {
      set lly [expr $origin_y + ${stack_dir}*($i*$macro_height)]
    }
  }
}

proc place_macro_mem_stack_inside {macro_list stack_size ch_space origin_x origin_y\
                            isFlip} {
  if {$isFlip == 0} {
    set orient [list "R0" "MY"]
    set stack_dir 1
  } else {
    set orient [list "MX" "R180"]
    set stack_dir -1
  }

  # Extract macro informations
  set macro_width [dbget [dbget top.insts.name [lindex $macro_list 0] -p ].box_sizex]
  set macro_height [dbget [dbget top.insts.name [lindex $macro_list 0] -p ].box_sizey]

  # i indicates the row number and j indicates the column number
  set i 0
  set j 1
  set llx $origin_x
  set lly $origin_y
  foreach macro $macro_list {
    # For each column all the macros have same orientation
    set orientation [lindex $orient [expr $j%2]]
    placeInstance $macro $llx $lly $orientation -placed

    incr i
    if { $i == $stack_size } {
      set i 0
      incr j
      set lly $origin_y
      set llx [expr $origin_x + ($j/2)*$ch_space + ($j-1)*$macro_width]
    } else {
      set lly [expr $origin_y + ${stack_dir}*($i*$macro_height)]
    }
  }
}

proc place_ariane_macro {{halo_width 2} {x_offset 0}} {
  # Core details
  set core_llx [dbget top.fplan.coreBox_llx]
  set core_urx [dbget top.fplan.coreBox_urx]
  set core_lly [dbget top.fplan.coreBox_lly]
  set core_ury [dbget top.fplan.coreBox_ury]
  set ch_space [expr $halo_width*4]
  set macro_height [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_y -u] 0]
  set macro_width [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_x -u] 0]

  # Place i_cache_srams at the center
  set i_cache_srams [dbget [dbget [dbget top.insts.name \
            *i_icache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  
  # Add valid dirty sram to the list 
  set valid_dirty_sram [dbget [dbget top.insts.cell.subClass block -p2 ].name \
              *valid_dirty_sram* ]
  
  set center_macro_list [linsert $i_cache_srams 26 [lindex $valid_dirty_sram 0]]
  set start_x [expr $core_urx - 9*$macro_width - 4*$ch_space - $x_offset]
  set tmp_ch_space [ expr ($core_ury - $core_lly - 13*$macro_height - 2*$ch_space)/2]
  set start_y [expr $core_lly + 4*$macro_height + $tmp_ch_space]

  # Place the macro in the first two row
  set macro_list_tmp [lrange $center_macro_list 0 17]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + $ch_space + 2*$macro_height]
  set macro_list_tmp [lrange $center_macro_list 18 26]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 1 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + $ch_space + $macro_height]
  set macro_list_tmp [lrange $center_macro_list 27 44]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0

  # Place i_nbdcache_srams at the top and bottom boundary
  set i_nbdcache_srams [dbget [dbget [dbget top.insts.name \
      *i_nbdcache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  
  # Place the bottom list in 4 rows
  set start_x [expr $core_urx - $x_offset - 11*$macro_width - 5*$ch_space]
  set start_y $core_lly
  set macro_list_tmp [ lrange $i_nbdcache_srams 0 21]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0
  
  set start_y [expr $start_y + 2*$macro_height + $ch_space]
  set macro_list_tmp [lrange $i_nbdcache_srams 22 43]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0
  
  # Place the top list in 4 rows
  set start_y [expr $core_ury - $macro_height]
  set macro_list_tmp [lrange $i_nbdcache_srams 44 65]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 1

  set start_y [expr $start_y - $ch_space - 2*$macro_height]
  set macro_list_tmp [lrange $i_nbdcache_srams 66 87]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 1
}

proc place_ariane_macro_config1 {{halo_width 2} {x_offset 0}} {
  # Core details
  set core_llx [dbget top.fplan.coreBox_llx]
  set core_urx [dbget top.fplan.coreBox_urx]
  set core_lly [dbget top.fplan.coreBox_lly]
  set core_ury [dbget top.fplan.coreBox_ury]
  set ch_space [expr 4*$halo_width]
  set macro_height [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_y -u] 0]
  set macro_width [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_x -u] 0]

  # Place i_cache_srams at the center
  set i_cache_srams [dbget [dbget [dbget top.insts.name \
            *i_icache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  set i_nbdcache_srams [dbget [dbget [dbget top.insts.name \
      *i_nbdcache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  
  set macro_list [lrange $i_nbdcache_srams 0 43]
  # Add valid dirty sram to the list 
  set valid_dirty_sram [dbget [dbget top.insts.cell.subClass block -p2 ].name \
              *valid_dirty_sram* ]
  
  set center_macro_list [linsert $macro_list 26 [lindex $valid_dirty_sram 0]]
  set start_x [expr $core_urx - 9*$macro_width - 4*$ch_space - $x_offset]
  set tmp_ch_space [ expr ($core_ury - $core_lly - 13*$macro_height - 2*$ch_space)/2]
  set start_y [expr $core_lly + 4*$macro_height + $tmp_ch_space]

  # Place the macro in the first two row
  set macro_list_tmp [lrange $center_macro_list 0 17]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + $ch_space + 2*$macro_height]
  set macro_list_tmp [lrange $center_macro_list 18 26]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 1 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + $ch_space + $macro_height]
  set macro_list_tmp [lrange $center_macro_list 27 44]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0

  # Place i_nbdcache_srams at the top and bottom boundary
  set macro_list $i_cache_srams

  # Place the bottom list in 4 rows
  set start_x [expr $core_urx - $x_offset - 11*$macro_width - 5*$ch_space]
  set start_y $core_lly
  set macro_list_tmp [ lrange $macro_list 0 21]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0
  
  set start_y [expr $start_y + 2*$macro_height + $ch_space]
  set macro_list_tmp [lrange $macro_list 22 43]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 0
  
  # Place the top list in 4 rows
  set macro_list [lrange $i_nbdcache_srams 44 87]
  set start_y [expr $core_ury - $macro_height]
  set macro_list_tmp [lrange $macro_list 0 21]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 1

  set start_y [expr $start_y - $ch_space - 2*$macro_height]
  set macro_list_tmp [lrange $macro_list 22 43]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 2 $ch_space $start_x $start_y 1
}

proc place_ariane_macro_config2 {{halo_width 2} {x_offset 0} {y_offset 0}} {
  # Core details
  set core_llx [dbget top.fplan.coreBox_llx]
  set core_urx [dbget top.fplan.coreBox_urx]
  set core_lly [dbget top.fplan.coreBox_lly]
  set core_ury [dbget top.fplan.coreBox_ury]
  set ch_space [expr 4*$halo_width]
  set macro_height [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_y -u] 0]
  set macro_width [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_x -u] 0]

  # Place i_cache_srams at the center
  set i_cache_srams [dbget [dbget [dbget top.insts.name \
            *i_icache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  set i_nbdcache_srams [dbget [dbget [dbget top.insts.name \
      *i_nbdcache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  set valid_dirty_sram [dbget [dbget top.insts.cell.subClass block -p2 ].name \
              *valid_dirty_sram*]
  
  ## Place the macro on the right boundary
  set macro_list $i_cache_srams
  set macro_list [linsert $macro_list 26 [lindex $valid_dirty_sram 0]]
  set start_x [expr $core_urx - 3*$macro_width - $ch_space - $x_offset]
  set ch_space_y [expr ($core_ury - $core_lly - 15*$macro_height - 2*$y_offset)/2]
  set start_y [expr $core_lly - $y_offset]

  set macro_list_tmp [lrange $macro_list 0 14]
  place_macro_mem_stack_outside $macro_list_tmp 5 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + 5*$macro_height + $ch_space_y]
  set macro_list_tmp [lrange $macro_list 15 29]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 5 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + 5*$macro_height + $ch_space_y]
  set macro_list_tmp [lrange $macro_list 30 44]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 5 $ch_space $start_x $start_y 0

  ## Place the bottom macro
  set macro_list [lrange $i_nbdcache_srams 0 43]
  set start_y [expr $core_lly + $y_offset]
  set start_x [expr $core_llx + $x_offset]
  place_macro_mem_stack_inside $macro_list 4 $ch_space $start_x $start_y 0

  ## Place the top macro
  set macro_list [lrange $i_nbdcache_srams 44 87]
  set start_y [expr $core_ury - $start_y - $macro_height]
  place_macro_mem_stack_inside $macro_list 4 $ch_space $start_x $start_y 1
}

proc place_ariane_macro_config4 {{halo_width 2} {x_offset 0} {y_offset 0}} {
  # Core details
  set core_llx [dbget top.fplan.coreBox_llx]
  set core_urx [dbget top.fplan.coreBox_urx]
  set core_lly [dbget top.fplan.coreBox_lly]
  set core_ury [dbget top.fplan.coreBox_ury]
  set ch_space [expr 4*$halo_width]
  set macro_height [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_y -u] 0]
  set macro_width [lindex [dbget [dbget top.insts.cell.subClass block -p\
              ].size_x -u] 0]

  # Place i_cache_srams at the center
  set i_cache_srams [dbget [dbget [dbget top.insts.name \
            *i_icache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  set i_nbdcache_srams [dbget [dbget [dbget top.insts.name \
      *i_nbdcache*sram_block[*].*_sram* -p ].cell.subClass block -p2 ].name]
  set valid_dirty_sram [dbget [dbget top.insts.cell.subClass block -p2 ].name \
              *valid_dirty_sram*]
  
  ## Place the macro on the right boundary
  set macro_list [lrange $i_nbdcache_srams 0 43]
  set macro_list [linsert $macro_list 26 [lindex $valid_dirty_sram 0]]
  set start_x [expr $core_urx - 3*$macro_width - $ch_space - $x_offset]
  set ch_space_y [expr ($core_ury - $core_lly - 15*$macro_height - 2*$y_offset)/2]
  set start_y [expr $core_lly - $y_offset]

  set macro_list_tmp [lrange $macro_list 0 14]
  place_macro_mem_stack_outside $macro_list_tmp 5 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + 5*$macro_height + $ch_space_y]
  set macro_list_tmp [lrange $macro_list 15 29]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 5 $ch_space $start_x $start_y 0

  set start_y [expr $start_y + 5*$macro_height + $ch_space_y]
  set macro_list_tmp [lrange $macro_list 30 44]
  set macro_list_tmp [lreverse $macro_list_tmp]
  place_macro_mem_stack_outside $macro_list_tmp 5 $ch_space $start_x $start_y 0

  ## Place the bottom macro
  set macro_list $i_cache_srams
  set start_y [expr $core_lly + $y_offset]
  set start_x [expr $core_llx + $x_offset]
  place_macro_mem_stack_inside $macro_list 4 $ch_space $start_x $start_y 0

  ## Place the top macro
  set macro_list [lrange $i_nbdcache_srams 44 87]
  set start_y [expr $core_ury - $start_y - $macro_height]
  place_macro_mem_stack_inside $macro_list 4 $ch_space $start_x $start_y 1
}