defmodule ExGrids.Grid2D.Examples.Aoc2021Test do
  @moduledoc """
  This test suite uses examples from Advent of Code 2021.

  ## Puzzles

   - [Day 13 - Transparent Origami](https://adventofcode.com/2021/day/13)

  """
  use ExUnit.Case
  alias ExGrids.Grid2D
  import ExGrids.TestUtils, only: [read_test_file: 1]

  describe "day 13" do

    test "simple fold" do

      folded_output = """
      #####
      #...#
      #...#
      #...#
      #####
      .....
      .....
      """ |> String.trim()

      # load the grid
      %{grid: grid, folds: folds} = read_test_file("aoc/day_13_test_01.dat") |> read_transparency()

      # let's do some folds
      folded_grid = folds
      |> Enum.reduce(grid, fn {fold_direction, fold_point}, grid_acc ->
        # apply the fold to the grid
        case fold_direction do
          :vertical -> grid_acc |> Grid2D.Mutate.fold(:vertical, fold_point, ".", fn t, b -> Enum.min([t, b]) end)
          :horizontal -> grid_acc |> Grid2D.Mutate.fold(:horizontal, fold_point, ".", fn l, r -> Enum.min([l, r]) end)
        end
      end)

      # now render the results to a string
      assert (folded_grid |> Grid2D.Display.to_string(:character_cells)) == folded_output

    end

    test "complex fold" do

      # load the grid
      %{grid: grid, folds: folds} = read_test_file("aoc/day_13_input_01.dat") |> read_transparency()

      # let's do some folds
      folded_grid = folds
                    |> Enum.reduce(grid, fn {fold_direction, fold_point}, grid_acc ->
        # apply the fold to the grid
        case fold_direction do
          :vertical -> grid_acc |> Grid2D.Mutate.fold(:vertical, fold_point, ".", fn t, b -> Enum.min([t, b]) end)
          :horizontal -> grid_acc |> Grid2D.Mutate.fold(:horizontal, fold_point, ".", fn l, r -> Enum.min([l, r]) end)
        end
      end)

      IO.puts(folded_grid |> Grid2D.Display.to_string(:character_cells))
    end
  end

  defp read_transparency(data) do
    [dots, folds] = data |> String.split("\n\n")

    # convert the dots to a graph, first by parsing, then by
    # finding the max dimensions
    coords = dots
             |> String.split("\n")
             |> Enum.map(fn dot ->
      [x, y] = String.split(dot, ",", trim: true)
      {{String.to_integer(x), String.to_integer(y)}, "#"}
    end)

    width = (coords |> Enum.map(fn {{x, _y}, _v} -> x end) |> Enum.max()) + 1
    height = (coords |> Enum.map(fn {{_x, y}, _v} -> y end) |> Enum.max()) + 1

    # now parse the fold info
    fold_instructins = folds
                       |> String.split("\n")
                       |> Enum.map(fn fold ->
      [dir, point] = fold |> String.replace("fold along ", "") |> String.split("=")
      {parse_direction(dir), String.to_integer(point)}
    end)

    grid = Grid2D.Create.new(width: width, height: height, default_value: ".") |> Grid2D.Mutate.inject_values(coords)
    %{folds: fold_instructins, grid: grid}
  end

  def parse_direction("y"), do: :vertical
  def parse_direction("x"), do: :horizontal

end