grids

2d

 - [x] use a map
 - [x] struct for dimensions, etc
 - optional offset (for grids that extend into negative space, for example)

Sparse2d

 - use a map
 - default values
 - default on access

Dynamic2d

 - excel style, updating cells, etc
 
Methods

 ExGrids.2d
 
 - [x] new()
 - read!(file)
 - from_string()
 - from list!(with dimensions)
 - from list(with dimensions, with default)
 - from list(with dimensions, discard incomplete rows?)
 - to/from latex
 - [x] dimensions()
 
 ExGrids.2d.Display
 
 - display
 
 ExGrids.2d.Kernels
 
  - How would we solve AoC 2021//Day 09 with Kernels
  - predefined kernels for iterating over grid and selecting specific neighboring cells, and using those in functions
  - Kernel: cardinal
  - Kernel: ordinal
  - Kernel: neighborhood(size)
  - All kernels should accept a value for what to do at edges
   - nothing
   - wrap around
   - default value
   - inset (only select cells that have enough neighbors)
  - filter_by_kernel (select coordinates or select values)
  - create_new_by_kernel
  - predefined Kernel update functions
   - Game of Life
  - predefined kernel filter functions
   - minima
   - maxima  	
 
 ExGrids.2d.Modify
 
 - update to new grid (automata style) (move to kernels)
 - update to new grid _with_ neighbor data (move to kernels)
 - update(grid, update function)
 - update_when(grid, filter function, update function)
 - intersect grids (only overlap)
 - union grids (shape to full size, default value function)
 - rotate
 - select sub grid
 - select with Excel style identifiers
 
 ExGrids.2d.Enum

 - row iterator
 - column iterator
 - cells()
 - all?() - cells/rows/columns
 - any?() - cells/rows/columns
 - none?() - cells/rows/columns
 - trim
 - drop row
 - drop row if
 - drop column
 - drop column if
 - add row
 - add column
 - shift (move values in x/y plane)
 - neighbors() (options for values at edges)
 - get/set/at
 - select row
 - select column
 - get diagonal(s)
 - inject values (list of points/values)
 