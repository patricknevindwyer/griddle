defmodule ExGrids do
  @moduledoc """
  Documentation for `ExGrids`.

  ## 2D Grids

  You can create an empty grid with:

      iex> ExGrids.Grid2D.new()
      %Grid2D{width: 0, height: 0, grid: %{}}

  But empty grids aren't all that interesting. Let's create a bigger
  grid with an _integer_ default value:

      iex> ExGrids.Grid2D.Create.new(width: 5, height: 5, default_value: 0) |> ExGrids.Grid2D.Enum.dimensions()
      {5, 5}


  """


end
