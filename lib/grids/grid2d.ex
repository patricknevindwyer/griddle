defmodule ExGrids.Grid2D do

  @enforce_keys [:width, :height]
  defstruct [width: 0, height: 0, xoffset: 0, yoffset: 0, grid: %{}]

  # TODO: type for grid
  alias ExGrids.Grid2D

  @doc """
  Generate a new, empty grid. This is a zero width, zero height
  grid. This is the base case for a grid. All other creation is
  done through the `ExGrids.Grid2D.Create` module.

  ## Example

      iex> Grid2D.new()
      %Grid2D{width: 0, height: 0}
  """
  def new() do
    %Grid2D{width: 0, height: 0, xoffset: 0, yoffset: 0, grid: %{}}
  end

end