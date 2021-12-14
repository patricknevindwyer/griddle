defmodule ExGrids.Grid2D.Enum do
  @moduledoc """
  Methods for enumerating over the coordinates, rows, columns,
  selections, and values of a `ExGrids.Grid2D`
  """

  alias ExGrids.Grid2D

  @doc """
  Retrieve a list of all coordinates in the grid, as a list of `{x, y}`
  tuples. The coordinates are sorted with increasing row, and then
  increasing column.

  ## Examples

      iex> Grid2D.Create.new(width: 2, height: 3) |> Enum.coordinates()
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
  Retrieve the dimensions of the grid as a tuple.

  ## Example

      iex> Grid2D.Create.new(width: 12, height: 37) |> Enum.dimensions()
      {12, 37}

  """
  def dimensions(%Grid2D{width: w, height: h}) do
    {w, h}
  end

  @doc """
  Retrieve the value at a specific location, specified as separate x and
  y coordinates. If the requested location is outside of the bounds of
  the grid, `nil` is returned.

  See also `Grid2D.Enum.at!/3`.

  ## Examples

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at(1, 2)
      {:ok, 42}

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at(1, 7)
      nil

  """
  def at(%Grid2D{}=grid, x, y) when is_integer(x) and is_integer(y), do: at(grid, {x, y})

  @doc """
  Retrieve the value at a specific location, specified as an {x, y} coordinate
  tuple. If the requested location is outside of the bounds of the grid, `nil`
  is returned.

  See also `Grid2D.Enum.at!/2`.

  ## Examples

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at({1, 2})
      {:ok, 42}

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at({1, 7})
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

  See also `Grid2D.Enum.at/3`.

  ## Examples

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at!(1, 2)
      42

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at!(1, 7)
      ** (ArgumentError) location out of bounds

  """
  def at!(%Grid2D{}=grid, x, y) when is_integer(x) and is_integer(y), do: at!(grid, {x, y})

  @doc """
  Retrieve the value at a specific location, specified as an {x, y} coordinate
  tuple. If the requested location is outside of the bounds of the grid, an
  `ArgumentError` is raised.

  See also `Grid2D.Enum.at/2`.

  ## Examples

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at!({1, 2})
      42

      iex> Grid2D.Create.new(width: 3, height: 3, default_value: 42) |> Grid2D.Enum.at!({1, 7})
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

      iex> Grid2D.Create.new(width: 10, height: 10) |> Enum.contains_point?({5, 7})
      true

      iex> Grid2D.Create.new(width: 10, height: 10) |> Enum.contains_point?({10, 1})
      false

      iex> Grid2D.Create.new(width: 10, height: 10) |> Enum.contains_point?({3, -4})
      false

  """
  def contains_point?(%Grid2D{width: w, height: h}, {x, y}) do
    (x >= 0) && (x < w) && (y >= 0) && (y < h)
  end

  @doc """
  Determine if a point (as individual `x`, `y` values) is within the boundaries of
  this grid.

  ## Examples

      iex> Grid2D.Create.new(width: 10, height: 10) |> Enum.contains_point?(5, 7)
      true

      iex> Grid2D.Create.new(width: 10, height: 10) |> Enum.contains_point?(10, 1)
      false

      iex> Grid2D.Create.new(width: 10, height: 10) |> Enum.contains_point?(3, -4)
      false

  """
  def contains_point?(%Grid2D{}=g, x, y), do: contains_point?(g, {x, y})

  # TODO: document the 3 different arity options
  # TODO: add doc test examples of all three arities
  @doc """
  Map all of the values in a Grid2D using a function. The grid is mutated during
  the map, so each call to the map function can see previously updated values.

  The passed function can be a 1-arity, 2-arity, or 3-arity function:

   - *1-arity* - Parameter is the cell value to map
   - *2-arity* - Paremeters are `{x, y}` coordinate, and value to map
   - *3-arity* - Parameters are the mutated grid, the `{x, y}` coordinate, and the value to map

  ## Examples

      iex> Grid2D.Create.new(width: 3, height: 3) |> Grid2D.Enum.map(fn v -> {v, v + 42} end) |> Grid2D.Enum.at!(2, 2)
      {0, 42}

      iex> Grid2D.Create.new(width: 3, height: 3) |> Grid2D.Enum.map(fn _g, {x, y}, v -> (x + y) * (v + 3) end) |> Grid2D.Enum.at!(2, 2)
      12

      iex> Grid2D.Create.new(width: 3, height: 3) |> Grid2D.Enum.map(fn g, {x, y}, v -> (g |> Grid2D.Enum.at!({0, 0})) + (x * y + v + 3) end) |> Grid2D.Enum.at!(2, 2)
      10

  """
  def map(%Grid2D{}=g, m_func) when is_function(m_func, 3) do

    # gather coordinates and values
    g
    |> coordinates_and_values()
    |> Enum.reduce(g, fn {coord, value}, grid_acc ->
      new_value = m_func.(grid_acc, coord, value)
      put(grid_acc, coord, new_value)
    end)

  end

  def map(%Grid2D{}=g, m_func) when is_function(m_func, 2) do

    # gather coordinates and values
    g
    |> coordinates_and_values()
    |> Enum.reduce(g, fn {coord, value}, grid_acc ->
      new_value = m_func.(coord, value)
      put(grid_acc, coord, new_value)
    end)

  end

  def map(%Grid2D{}=g, m_func) when is_function(m_func, 1) do

    # gather coordinates and values
    g
    |> coordinates_and_values()
    |> Enum.reduce(g, fn {coord, value}, grid_acc ->
      new_value = m_func.(value)
      put(grid_acc, coord, new_value)
    end)

  end

  # TODO: document
  # TODO: tests
  # TODO: make more resilient
  def coordinates_and_values(%Grid2D{}=g) do
    g
    |> coordinates()
    |> Enum.map(fn coord -> {coord, at!(g, coord)} end)
  end

  @doc """
  Put a new value in the grid at a specific location. If the location
  is outside of the bounds of the grid,  `ExGrids.Errors.BoundaryError` will
  be raised. See also `ExGrids.Grid2D.Enum.put/4`.

  ## Examples

      iex> Grid2D.Create.new(width: 2, height: 2) |> Grid2D.Enum.put({1, 1}, :foo) |> Grid2D.Enum.at!({1, 1})
      :foo

      iex> Grid2D.Create.new(width: 2, height: 2) |> Grid2D.Enum.put({4, 1}, :foo) |> Grid2D.Enum.at!({1, 1})
      ** (ExGrids.Errors.BoundaryError) The coordinate {4, 1} is outside the grid boundary {width: 2, height: 2}

  """
  def put(grid, {x, y}=coord, v) do
    if contains_point?(grid, coord) do
      g = grid.grid |> Map.put(coord, v)
      grid |> Map.put(:grid, g)
    else
      raise ExGrids.Errors.BoundaryError, x: x, y: y, width: grid.width, height: grid.height
    end
  end

  @doc """
  A convenience wrapper around `ExGrids.Grid2D.Enum.put/3`. Put a new
  value into the grid, or raise an `ExGrids.Errors.BoundaryError` if the x/y
  coordinate is outside the grid.

  ## Examples

      iex> Grid2D.Create.new(width: 2, height: 2) |> Grid2D.Enum.put(1, 1, :foo) |> Grid2D.Enum.at!({1, 1})
      :foo

      iex> Grid2D.Create.new(width: 2, height: 2) |> Grid2D.Enum.put(4, 1, :foo) |> Grid2D.Enum.at!({1, 1})
      ** (ExGrids.Errors.BoundaryError) The coordinate {4, 1} is outside the grid boundary {width: 2, height: 2}

  """
  def put(grid, x, y, v), do: put(grid, {x, y}, v)

  # TODO: update to 1, 2, 3-arity versions
  # TODO: document
  # TODO: tests
  def find_coordinates(%Grid2D{}=g, m_func) when is_function(m_func, 1) do
    g
    |> coordinates_and_values()
    |> Enum.filter(fn {_coord, value} -> m_func.(value) end)
    |> Enum.map(fn {coord, _value} -> coord end)
  end

  # TODO: document
  # TODO: tests
  # TODO: update to neighbors/3 (grid, coordinate, [style, edge options])
  def neighbors(%Grid2D{}=g, {x, y} = coord) do
    -1..1
    |> Enum.map(fn h_mod ->
      -1..1
      |> Enum.map(fn w_mod ->
        {x + w_mod, y + h_mod}
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn n_coord ->
      # must be in the grid and must not be ourself
      (n_coord != coord) && contains_point?(g, n_coord)
    end)
  end

  # TODO: update to 1, 2, 3-arity versions
  # TODO: document
  # TODO: test
  def all?(%Grid2D{}=g, p_func) do
    g
    |> coordinates_and_values()
    |> Enum.map(fn {_c, v} -> p_func.(v) end)
    |> Enum.all?()
  end
end