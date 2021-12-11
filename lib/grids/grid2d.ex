defmodule ExGrids.Grid2D do

  @enforce_keys [:width, :height]
  defstruct [width: 0, height: 0, xoffset: 0, yoffset: 0, grid: %{}]

  # TODO: type for grid
end