defmodule ExGrids.BoundaryError do
  defexception [width: 0, height: 0, x: 0, y: 0]

  @impl true
  def message(e) do
    "The coordinate {#{e.x}, #{e.y}} is outside the grid boundary {width: #{e.width}, height: #{e.height}}"
  end
end