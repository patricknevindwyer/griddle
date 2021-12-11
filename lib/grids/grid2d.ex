defmodule ExGrids.Grid2D do

  @enforce_keys [:width, :height]
  defstruct [width: 0, height: 0, xoffset: 0, yoffset: 0, grid: %{}]
  # TODO: type for grid

  alias ExGrids.Grid2D

  @doc """
  Generate a new, empty grid. This is a zero width, zero height
  grid.

  ## Example

      iex> Grid2D.new()
      %Grid2D{width: 0, height: 0}
  """
  def new() do
    %Grid2D{width: 0, height: 0, xoffset: 0, yoffset: 0, grid: %{}}
  end

  # TODO: default_value as function (basically a pass through to fill)
  @doc """
  Generate a new grid using sizing and default value options. If the
  specified width or height are negatives, the `new/1` method throws
  an `ArgumentError`.

  When called with a `default_value` option, the given value is used
  as the fill value for every entry in the grid. If a 1-arity method
  is given as the `default_value` it is invoked for every entry when
  filling in the grid, as if calling `fill/2` on the grid.

  ## Options

    - `width` - Positive integer, default `0`
    - `height` - Positive integer, default `0`
    - `default_value` - Any. Value to store in all cells by default,
                        or a 1-arity function to call for every cell

  ## Example

      iex> Grid2D.new(width: 7, height: 11) |> Grid2D.dimensions()
      {7, 11}

      iex> Grid2D.new(width: -7, height: 11)
      ** (ArgumentError) Negative width

      iex> Grid2D.new(width: 1, height: 1, default_value: 1)
      %Grid2D{width: 1, height: 1, grid: %{{0, 0} => 1}}

      iex> Grid2D.new(width: 1, height: 1, default_value: {:checked, 0, true})
      %Grid2D{width: 1, height: 1, grid: %{{0, 0} => {:checked, 0, true}}}

      iex> Grid2D.new(width: 1, height: 1, default_value: fn {x, y} -> x + 3 + y + 7 end)
      %Grid2D{width: 1, height: 1, grid: %{{0, 0} => 10}}

  """
  def new(opts) do

    # setup the grid structures
    g = default_grid()
    |> with_size(opts)

    # ensure this is a properly formed grid
    if g.width < 0 do
      raise ArgumentError, "Negative width"
    end

    if g.height < 0 do
      raise ArgumentError, "Negative height"
    end

    # default value fill, and return the grid
    d_fn = default_function(opts)
    g
    |> fill(d_fn)
  end

  defp default_grid do
    %Grid2D{width: 0, height: 0}
  end

  defp with_size(%Grid2D{}=grid, opts) do

    # select out the size for the grid
    width = opts |> Keyword.get(:width, 0)
    height = opts |> Keyword.get(:height, 0)

    # update the grid
    grid |> Map.merge(%{width: width, height: height})

  end

  defp default_function(opts) do

    cond do

      # wrap the default value in a 1-arity function
      Keyword.has_key?(opts, :default_value) ->

        d = opts |> Keyword.get(:default_value)

        if is_function(d, 1) do
          d
        else
          fn {_x, _y} -> d end
        end

      # we're inserting 0 as the default value
      true ->
        fn {_x, _y} -> 0 end
    end

  end

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

      iex> Grid2D.new(width: 1, height: 2) |> Grid2D.fill(17)
      %Grid2D{width: 1, height: 2, grid: %{{0, 0} => 17, {0, 1} => 17}}

      iex> Grid2D.new(width: 2, height: 2) |> Grid2D.fill(fn {x, y} -> x + y end)
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

  defp width_range(%Grid2D{width: w}) do
    if w > 0 do
      0..(w - 1)
    else
      []
    end
  end
  defp height_range(%Grid2D{height: h}) do
    if h > 0 do
      0..(h - 1)
    else
      []
    end
  end

  @doc """
  Retrieve a list of all coordinates in the grid, as a list of `{x, y}`
  tuples. The coordinates are sorted with increasing row, and then
  increasing column.

  ## Examples

      iex> Grid2D.new(width: 2, height: 3) |> Grid2D.coordinates()
      [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}]
  """
  def coordinates(%Grid2D{}=grid) do
    width_range(grid)
    |> Enum.map(fn x_idx ->
      height_range(grid)
      |> Enum.map(fn y_idx ->
        {x_idx, y_idx}
      end)
    end)
    |> List.flatten()
  end

  @doc """
  Retrieve the dimensions of the grid as a tuple.

  ## Example

      iex> Grid2D.new(width: 12, height: 37) |> Grid2D.dimensions()
      {12, 37}

  """
  def dimensions(%Grid2D{width: w, height: h}) do
    {w, h}
  end

  @doc """
  Retrieve the value at a specific location, specified as separate x and
  y coordinates. If the requested location is outside of the bounds of
  the grid, `nil` is returned.

  See also `Grid2D.at!/3`.

  ## Examples

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at(1, 2)
      {:ok, 42}

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at(1, 7)
      nil

  """
  def at(%Grid2D{}=grid, x, y) when is_integer(x) and is_integer(y), do: at(grid, {x, y})

  @doc """
  Retrieve the value at a specific location, specified as an {x, y} coordinate
  tuple. If the requested location is outside of the bounds of the grid, `nil`
  is returned.

  See also `Grid2D.at!/2`.

  ## Examples

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at({1, 2})
      {:ok, 42}

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at({1, 7})
      nil

  """
  def at(%Grid2D{grid: g}=grid, {x, y}=coord) when is_integer(x) and is_integer(y) do
    if contains_point?(grid, coord) do
      {:ok, g |> Map.get(coord)}
    else
      nil
    end
  end

  @doc """
  Retrieve the value at a specific location, specified as separate x and
  y coordinates. If the requested location is outside of the bounds of
  the grid, an `ArgumentError` is raised.

  See also `Grid2D.at/3`.

  ## Examples

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at!(1, 2)
      42

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at!(1, 7)
      ** (ArgumentError) location out of bounds

  """
  def at!(%Grid2D{}=grid, x, y) when is_integer(x) and is_integer(y), do: at!(grid, {x, y})

  @doc """
  Retrieve the value at a specific location, specified as an {x, y} coordinate
  tuple. If the requested location is outside of the bounds of the grid, an
  `ArgumentError` is raised.

  See also `Grid2D.at/2`.

  ## Examples

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at!({1, 2})
      42

      iex> Grid2D.new(width: 3, height: 3, default_value: 42) |> Grid2D.at!({1, 7})
      ** (ArgumentError) location out of bounds

  """
  def at!(%Grid2D{}=grid, {x, y}=coord) when is_integer(x) and is_integer(y) do
    case at(grid, coord) do
      nil -> raise ArgumentError, "location out of bounds"
      {:ok, v} -> v
    end
  end

  @doc """
  Determine if a point (as an `{x, y}` tuple) is within the boundaries of
  this grid.

  ## Examples

      iex> Grid2D.new(width: 10, height: 10) |> Grid2D.contains_point?({5, 7})
      true

      iex> Grid2D.new(width: 10, height: 10) |> Grid2D.contains_point?({10, 1})
      false

      iex> Grid2D.new(width: 10, height: 10) |> Grid2D.contains_point?({3, -4})
      false

  """
  def contains_point?(%Grid2D{width: w, height: h}, {x, y}) do
    (x >= 0) && (x < w) && (y >= 0) && (y < h)
  end

  @doc """
  Determine if a point (as individual `x`, `y` values) is within the boundaries of
  this grid.

  ## Examples

      iex> Grid2D.new(width: 10, height: 10) |> Grid2D.contains_point?(5, 7)
      true

      iex> Grid2D.new(width: 10, height: 10) |> Grid2D.contains_point?(10, 1)
      false

      iex> Grid2D.new(width: 10, height: 10) |> Grid2D.contains_point?(3, -4)
      false

  """
  def contains_point?(%Grid2D{}=g, x, y), do: contains_point?(g, {x, y})

end