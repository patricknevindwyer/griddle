defmodule ExGrids.Grid2D.Mutate do
  @moduledoc """
  Methods for modifying the values in a `ExGrids.Grid2D`
  """

  alias ExGrids.Grid2D
  import ExGrids.Grid2D.Enum, only: [coordinates: 1]

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

end
