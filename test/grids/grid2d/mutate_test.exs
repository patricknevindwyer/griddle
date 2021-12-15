defmodule ExGrids.Grid2D.MutateTest do
  use ExUnit.Case
  alias ExGrids.Grid2D
  alias ExGrids.Grid2D.Mutate
  doctest ExGrids.Grid2D.Mutate

  describe "fold/4" do

    test "horizontal - empty" do
      assert_raise ExGrids.Errors.BoundaryError, fn ->
        Grid2D.new() |> Mutate.fold(:horizontal, 0, ".", fn a, _b -> a end)
      end
    end

    test "horizontal - out of bounds fold point (low)" do
      input = """
      ..#..##
      #.#..#.
      #.....#
      """

      assert_raise ExGrids.Errors.BoundaryError, fn ->
        Grid2D.Create.from_string(input, :character_cells)
        |> Mutate.fold(:horizontal, -1, ".", fn a, b -> Enum.min([a, b]) end)
      end
    end

    test "horizontal - out of bounds fold point (high)" do
      input = """
      ..#..##
      #.#..#.
      #.....#
      """

      assert_raise ExGrids.Errors.BoundaryError, fn ->
        Grid2D.Create.from_string(input, :character_cells)
        |> Mutate.fold(:horizontal, 7, ".", fn a, b -> Enum.min([a, b]) end)
      end
    end

    test "horizontal fold at left edge" do
      # common setup
      input = """
      ..#..##
      #.#..#.
      #.....#
      """
      output = """
      ##..#.
      .#..#.
      #.....
      """
      fold_at = 0

      # fold
      out = Grid2D.Create.from_string(input, :character_cells)
      |> Mutate.fold(:horizontal, fold_at, ".", fn a, b -> Enum.min([a, b]) end)

      # setup the expected output
      expected_out = Grid2D.Create.from_string(output, :character_cells)

      # test
      assert out == expected_out
    end

    test "horizontal fold at right edge" do
      # common setup
      input = """
      ..#..##
      #.#..#.
      #.....#
      """
      output = """
      ..#..#
      #.#..#
      #.....
      """
      fold_at = 6

      # fold
      out = Grid2D.Create.from_string(input, :character_cells)
            |> Mutate.fold(:horizontal, fold_at, ".", fn a, b -> Enum.min([a, b]) end)

      # setup the expected output
      expected_out = Grid2D.Create.from_string(output, :character_cells)

      # test
      assert out == expected_out
    end

    test "horizontal - perfect fold" do
      # common setup
      input = """
      ..#..##
      #.#..#.
      #.....#
      """
      output = """
      ###
      ###
      #..
      """
      fold_at = 3

      # fold
      out = Grid2D.Create.from_string(input, :character_cells)
            |> Mutate.fold(:horizontal, fold_at, ".", fn a, b -> Enum.min([a, b]) end)

      # setup the expected output
      expected_out = Grid2D.Create.from_string(output, :character_cells)

      # test
      assert out == expected_out
    end


    test "horizontal - left side larger" do
      # common setup
      input = """
      ..#..##
      #.#..#.
      #.....#
      """
      output = """
      ..#.#
      #.#..
      #...#
      """
      fold_at = 5

      # fold
      out = Grid2D.Create.from_string(input, :character_cells)
            |> Mutate.fold(:horizontal, fold_at, ".", fn a, b -> Enum.min([a, b]) end)

      # setup the expected output
      expected_out = Grid2D.Create.from_string(output, :character_cells)

      # test
      assert out == expected_out
    end

    test "horizontal - right side larger" do
      # common setup
      input = """
      ..#..##
      #.#..#.
      #.....#
      """
      output = """
      ##..#
      .#..#
      #...#
      """
      fold_at = 1

      # fold
      out = Grid2D.Create.from_string(input, :character_cells)
            |> Mutate.fold(:horizontal, fold_at, ".", fn a, b -> Enum.min([a, b]) end)

      # setup the expected output
      expected_out = Grid2D.Create.from_string(output, :character_cells)

      # test
      assert out == expected_out
    end

    test "horizontal - uneven perfect fold" do
      # common setup
      input = """
      ..#..###
      #.#..#.#
      #.....##
      """
      output = """
      .###
      ####
      ###.
      """
      fold_at = 4

      # fold
      out = Grid2D.Create.from_string(input, :character_cells)
            |> Mutate.fold(:horizontal, fold_at, ".", fn a, b -> Enum.min([a, b]) end)

      # setup the expected output
      expected_out = Grid2D.Create.from_string(output, :character_cells)

      # test
      assert out == expected_out
    end

    # TODO: vertical tests
  end

end