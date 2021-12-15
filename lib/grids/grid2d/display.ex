defmodule ExGrids.Grid2D.Display do
  @moduledoc """
  Methods for display and output of Grid2D cells.
  """
  alias ExGrids.Grid2D
  alias ExGrids.Grid2D

  # TODO: update with options for spacing, width, etc
  # TODO: test
  # TODO: document
  def display(%Grid2D{}=grid, :integer_cells) do
    height_range(grid)
    |> Enum.map(fn h_idx ->
      width_range(grid)
      |> Enum.map(fn w_idx ->
        grid |> Grid2D.Enum.at!({w_idx, h_idx}) |> Integer.to_string()
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
    grid
  end

  def display(%Grid2D{}=grid, :character_cells) do
    height_range(grid)
    |> Enum.map(fn h_idx ->
      width_range(grid)
      |> Enum.map(fn w_idx ->
        grid |> Grid2D.Enum.at!({w_idx, h_idx})
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
    grid
  end

  # TODO: abstract the display/2 methods to use the to_string methods
  # TODO: tests
  # TODO: docs
  def to_string(%Grid2D{}=grid, :character_cells) do
    height_range(grid)
    |> Enum.map(fn h_idx ->
      width_range(grid)
      |> Enum.map(fn w_idx ->
        grid |> Grid2D.Enum.at!({w_idx, h_idx})
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end

  # TODO: move these to a util module, extract duplicates from Enum.ex
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

end