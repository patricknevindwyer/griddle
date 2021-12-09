grids

2d
 - use a map
 - struct for dimensions, etc
 - optional offset (for grids that extend into negative space, for example)

Sparse2d

 - use a map
 - default values
 - default on access

Methods

 ExGrids.2d
 
 - new()
 - read!(file)
 - from_string()
 - from list!(with dimensions)
 - from list(with dimensions, with default)
 - from list(with dimensions, discard incomplete rows?)
 - to/from latex
 - dimensions()
 
 ExGrids.2d.Display
 
 - display
 
 ExGrids.2d.Modify
 
 - update to new grid (automata style)
 - update to new grid _with_ neighbor data
 - update(grid, update function)
 - update_when(grid, filter function, update function)
 - intersect grids (only overlap)
 - union grids (shape to full size, default value function)
 - rotate
 
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
 