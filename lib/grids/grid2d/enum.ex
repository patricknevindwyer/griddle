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

end