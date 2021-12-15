defmodule ExGrids.Grid2D.Mutate do
  @moduledoc """
  Methods for modifying the values in a `ExGrids.Grid2D`
  """

  alias ExGrids.Grid2D
  import ExGrids.Grid2D.Enum, only: [coordinates: 1, at!: 2, put: 3, dimensions: 1]

  # TODO: Tests
  @doc """
  Fill every cell in a grid using a provided value or function. If the
  provided function is a 1-arity function, it will be called for every
  cell in the grid, with the result used to fill the cell.

  A fill function passed in this way should accept a `{x, y}` tuple as
  the only parameter. For example, creating a grid where each entry is
  recorded as a multiple of the `x` and `y` might look like:

  ```elixir
  Grid2D.new(width: 5, height: 5)
  |> Grid2D.fill(
    fn {x, y} ->
      (2 * x) + (-3 * y)
    end
  )
  ```

  Any other value will be used as the literal fill value for the grid.

  ## Examples

      iex> Grid2D.Create.new(width: 1, height: 2) |> Mutate.fill(17)
      %Grid2D{width: 1, height: 2, grid: %{{0, 0} => 17, {0, 1} => 17}}

      iex> Grid2D.Create.new(width: 2, height: 2) |> Mutate.fill(fn {x, y} -> x + y end)
      %Grid2D{width: 2, height: 2, grid: %{{0, 0} => 0, {0, 1} => 1, {1, 0} => 1, {1, 1} => 2}}

  """
  def fill(%Grid2D{}=grid, func) when is_function(func, 1) do
    updated_grid =
      grid
      |>  coordinates()
      |> Enum.reduce(
           grid.grid,
           fn coord, acc_grid ->
             acc_grid |> Map.put(coord, func.(coord))
           end
         )

    grid |> Map.put(:grid, updated_grid)

  rescue
    _fce in [FunctionClauseError] -> reraise ArgumentError, "Fill function should accept {x, y} value", __STACKTRACE__
  end

  def fill(%Grid2D{}=grid, v) do
    updated_grid =
      grid
      |>  coordinates()
      |> Enum.reduce(
           grid.grid,
           fn coord, acc_grid ->
             acc_grid |> Map.put(coord, v)
           end
         )

    grid |> Map.put(:grid, updated_grid)
  end

  @doc """
  Fold a grid like a piece of paper. This fold can go in one of two directions.

   - `:vertical` - Fold at a specific row, from the bottom to the top
   - `:horizontal` - Fold at a specific column, from the right to the left

  All folds drop the data from the fold point.

  A _merge_ function is required taking two parameters, the order of parameters
  is dependent on the fold mode:

   - `:vertical` - Merge parameters are `top value`, `bottom value`
   - `:horizontal` - Merge parameters are `left value`, `right value`

  ## Example

      iex> Grid2D.Create.from_string("#.##..#..#.\\n#...#......", :character_cells) |> Mutate.fold(:horizontal, 5, ".", fn t, b -> Enum.min([t, b]) end) |> Grid2D.Enum.at!({1, 0})
      "#"

      iex> Grid2D.Create.from_string("#.#.#\\n.....\\n.#.#.", :character_cells) |> Mutate.fold(:vertical, 1, ".", fn l, r -> Enum.min([l, r]) end) |> Grid2D.Enum.at!({1, 0})
      "#"

  """
  def fold(%Grid2D{}=og, :vertical, y_fold, fill_value, merge_fn) when is_integer(y_fold) and is_function(merge_fn, 2) do

    # split the grid
    {top, bottom} = og |> cut(:vertical, y_fold)

    # flip the bottom grid
    bottom = bottom |> flip(:vertical)

    # folds can be anywhere, so we need to adjust the grids
    {_top_width, top_height} = dimensions(top)
    {_bottom_width, bottom_height} = dimensions(bottom)

    {top, bottom} = cond do
      top_height == bottom_height -> {top, bottom}
      top_height > bottom_height ->
        # top is larger than bottom
        {
          top,
          bottom |> shift(:down, top_height - bottom_height, fill_value)
        }

      top_height < bottom_height ->
        # bottom is larger than top
        {
          top |> shift(:down, bottom_height - top_height, fill_value),
          bottom
        }
    end

    # merge the grids
    merge_c_and_v = Enum.zip(coordinates_and_values(top), coordinates_and_values(bottom))
    |> Enum.map(fn { {{top_x, top_y}, top_v}, {_bottom_coord, bottom_v}} ->
      merge_v = merge_fn.(top_v, bottom_v)
      {{top_x, top_y}, merge_v}
    end)

    top |> inject_values(merge_c_and_v)
  end

  def fold(%Grid2D{}=og, :horizontal, x_fold, fill_value, merge_fn) when is_integer(x_fold) and is_function(merge_fn, 2) do

    # split the grid
    {left, right} = og |> cut(:horizontal, x_fold)

    # flip the right grid
    right = right |> flip(:horizontal)

    # folds can be anywhere, so we need to adjust the grids
    {left_width, _left_height} = dimensions(left)
    {right_width, _right_height} = dimensions(right)

    {left, right} = cond do
      left_width == right_width -> {left, right}
      left_width > right_width ->
        # left is larger than right
        {
          left,
          right |> shift(:right, left_width - right_width, fill_value)
        }

      left_width < right_width ->
        # right is larger than left
        {
          left |> shift(:right, right_width - left_width, fill_value),
          right
        }
    end

    # merge the grids
    merge_c_and_v = Enum.zip(coordinates_and_values(left), coordinates_and_values(right))
                    |> Enum.map(fn { {{left_x, left_y}, left_v}, {_right_coord, right_v}} ->
      merge_v = merge_fn.(left_v, right_v)
      {{left_x, left_y}, merge_v}
    end)

    left |> inject_values(merge_c_and_v)

  end

  # TODO: tests
  # TODO: more documentation
  @doc """
  Split a grid into two new grids, horizontally or vertically. The cut drops an
  actual row or column from the grid along the cut line.

  Cut options:

   - `:horizontal` - Split into left and right grids
   - `:vertical` - Split into top and bottom grids

  ## Example

      iex> {a, b} = Grid2D.Create.new(width: 10, height: 5) |> Mutate.cut(:horizontal, 4)
      ...> [a, b] |> Enum.map(&Grid2D.Enum.dimensions/1)
      [{4, 5}, {5, 5}]

      iex> {a, b} = Grid2D.Create.new(width: 10, height: 5) |> Mutate.cut(:vertical, 2)
      ...> [a, b] |> Enum.map(&Grid2D.Enum.dimensions/1)
      [{10, 2}, {10, 2}]

  """
  def cut(%Grid2D{width: w, height: h}=g, :horizontal, col_idx) do
    # grab all coordinates
    c_and_v = g
    |> coordinates_and_values()

    # split into groups and shift values for the right side
    left = c_and_v
    |> Enum.filter(fn {{x, _y}, _v} -> x < col_idx end)

    right = c_and_v
    |> Enum.filter(fn {{x, _y}, _v} -> x > col_idx end)
    |> Enum.map(fn {{x, y}, v} -> {{x - col_idx - 1, y}, v} end)

    # inject into new grids
    grid_left = Grid2D.new()
                |> Map.merge(%{width: col_idx, height: h})
                |> inject_values(left)

    grid_right = Grid2D.new()
                 |> Map.merge(%{width: (w - col_idx - 1), height: h})
                 |> inject_values(right)

    {grid_left, grid_right}
  end

  def cut(%Grid2D{width: w, height: h}=g, :vertical, row_idx) do
    # grab all coordinates
    c_and_v = g
              |> coordinates_and_values()

    # split into groups and shift values for the bottom portion
    top = c_and_v
           |> Enum.filter(fn {{_x, y}, _v} -> y < row_idx end)

    bottom = c_and_v
            |> Enum.filter(fn {{_x, y}, _v} -> y > row_idx end)
            |> Enum.map(fn {{x, y}, v} -> {{x, y - row_idx - 1}, v} end)

    # inject into new grids
    grid_top = Grid2D.new()
                |> Map.merge(%{width: w, height: row_idx})
                |> inject_values(top)

    grid_bottom = Grid2D.new()
                 |> Map.merge(%{width: w, height: (h - row_idx - 1)})
                 |> inject_values(bottom)

    {grid_top, grid_bottom}
  end

  # TODO: Tests
  # TODO: more documentation
  @doc """
  Flip a grid either vertically or horizontally.

  ## Examples

      iex> Grid2D.Create.from_string("..##\\n..##", :character_cells) |> Mutate.flip(:horizontal) |> Grid2D.Enum.at!({0, 0})
      "#"

      iex> Grid2D.Create.from_string("..aa\\n..bb", :character_cells) |> Mutate.flip(:vertical) |> Grid2D.Enum.at!({3, 0})
      "b"

  """
  def flip(%Grid2D{height: h}=g, :vertical) do

    offset = h - 1

    # we do inline cell renumbering before injecting into the existing
    # grid
    flipped_c_and_v = g
    |> coordinates_and_values()
    |> Enum.map(fn {{x, y}, v} ->
      # go negative and add the offset for y
      {{x, (y * -1) + offset}, v}
    end)

    g
    |> inject_values(flipped_c_and_v)
  end

  def flip(%Grid2D{width: w}=g, :horizontal) do
    offset = w - 1

    # we do inline cell renumbering before injecting into the existing
    # grid
    flipped_c_and_v = g
                      |> coordinates_and_values()
                      |> Enum.map(fn {{x, y}, v} ->
      # go negative and add the offset for y
      {{(x * -1) + offset, y}, v}
    end)

    g
    |> inject_values(flipped_c_and_v)

  end

  # TODO: document
  # TODO: tests
  # TODO: extend to shifts > 1
  # TODO: add alias for single shift?
  def shift(grid, direction, count, default_value \\ 0)
  def shift(%Grid2D{width: w, height: h}=og, :right, count, default_value) do

    # renumber all the columns
    shifted_cells = og
    |> coordinates_and_values()
    |> Enum.map(fn {{x, y}, v} -> {{x + count, y}, v} end)

    # create all the default cells
    new_cells = 1..h
    |> Enum.map(
         fn h_idx ->
           1..count
           |> Enum.map(fn w_idx ->
            {{w_idx - 1, h_idx - 1}, default_value}
           end)
         end
       )
    |> List.flatten()

    # now inject to the larger grid
    og
    |> Map.merge(%{width: w + count})
    |> inject_values(shifted_cells ++ new_cells)
  end

  def shift(%Grid2D{width: w, height: h}=og, :down, count, default_value) do

    # renumber all the columns
    shifted_cells = og
    |> coordinates_and_values()
    |> Enum.map(fn {{x, y}, v} -> {{x, y + count}, v} end)

    # create all the default cells
    new_cells = 1..w
    |> Enum.map(
         fn w_idx ->
           1..count
           |> Enum.map(fn h_idx ->
            {{w_idx - 1, h_idx - 1}, default_value}
           end)
         end
       )
    |> List.flatten()

    # now inject to the larger grid
    og
    |> Map.merge(%{height: h + count})
    |> inject_values(shifted_cells ++ new_cells)
  end

  # TODO: remove when Enum exposes this as public
  defp coordinates_and_values(%Grid2D{}=g) do
    g
    |> coordinates()
    |> Enum.map(fn coord -> {coord, at!(g, coord)} end)
  end

  # TODO: add tests
  # TODO: add documentation
  # TODO: Extend with further testing for format
  def inject_values(grid, coord_val_pairs) when is_list(coord_val_pairs) do
    coord_val_pairs
    |> Enum.reduce(grid, fn {coord, value}, acc_grid -> put(acc_grid, coord, value) end)
  end


end
