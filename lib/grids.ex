defmodule ExGrids do
  @moduledoc """
  Documentation for `ExGrids`.

  # 2D Grids

  You can create an empty grid with:

      iex> ExGrids.Grid2D.new()
      %Grid2D{width: 0, height: 0, grid: %{}}

  But empty grids aren't all that interesting. Let's create a bigger
  grid with an _integer_ default value:

      iex> ExGrids.Grid2D.Create.new(width: 5, height: 5, default_value: 0) |> ExGrids.Grid2D.Enum.dimensions()
      {5, 5}

  # Examples

  Why would you want to use grids? This section looks at some odd or non-standard
  ways to use grids.

  ## Origami

  The `ExGrids.Grid2D.Mutate.fold/4` method is ideal for doing simple origami
  over a flat shape. For instance the grid:

  ```
  ...#..#..#.
  ....#......
  ...........
  #..........
  ...#....#.#
  ...........
  ...........
  -----------
  ...........
  ...........
  .#....#.##.
  ....#......
  ......#...#
  #..........
  #.#........
  ```

  can be folded over the dashed line with:

  ```
  grid
  |> ExGrids.Grid2D.Mutate.fold(
    :vertical,
    7,
    ".",
    fn a, b ->
      Enum.min([a, b])
    end
  )
  ```

  which folds the grid over in a `vertical` direction, at row `7`. If the one
  half of the fold is larger than another (for instance, if you folded at row
  3 instead of 7), the `.` character would be used to fill in any cells. When
  the fold is created, the function passed as the last parameter determines a
  new cell value that combines the now overlapped cell. In this case a `#` is
  used if it exists, otherwise the `.` is used.

  This fold results in a new grid that looks like:

  ```
  #.##..#..#.
  #...#......
  ......#...#
  #...#......
  .#.#..#.###
  ...........
  ...........
  ```

  If you went a step further and applied a horizontal fold at column `5` over
  this new, smaller grid, the result would be:

  ```
  #####
  #...#
  #...#
  #...#
  #####
  .....
  .....
  ```

  This type of origami-like folding was the subject of the Advent of Code day
  13, 2021 (see [Transparent Origami](https://adventofcode.com/2021/day/13)).

  """


end
