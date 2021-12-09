defmodule ExGrids.Grid2DTest do
  use ExUnit.Case
  alias ExGrids.Grid2D
  doctest ExGrids.Grid2D

  describe "new/0" do

    test "default values" do
      g = Grid2D.new()

      assert g.width == 0
      assert g.height == 0
      assert g.xoffset == 0
      assert g.yoffset == 0
      assert g.grid == %{}
    end

  end

  describe "new/1" do

    test "default width" do

      g = Grid2D.new(height: 3)
      assert {0, 3} == Grid2D.dimensions(g)

    end

    test "default height" do

      g = Grid2D.new(width: 7)
      assert {7, 0} == Grid2D.dimensions(g)

    end

    test "default value scalar" do

      g = Grid2D.new(width: 2, height: 2, default_value: true)
      assert Grid2D.dimensions(g) == {2, 2}
      assert Grid2D.at!(g, {1, 0}) == true
    end

    test "default value map" do
      g = Grid2D.new(width: 2, height: 2, default_value: %{biz: 1, bar: [2, 3]})
      assert Grid2D.dimensions(g) == {2, 2}
      assert Grid2D.at!(g, {0, 0}) == %{biz: 1, bar: [2, 3]}
      assert is_map(Grid2D.at!(g, {0, 0}))
    end

    test "default value list" do
      g = Grid2D.new(width: 2, height: 2, default_value: [3, :true, "blah"])
      assert Grid2D.dimensions(g) == {2, 2}
      assert Grid2D.at!(g, {0, 0}) == [3, :true, "blah"]
      assert is_list(Grid2D.at!(g, {0, 0}))
    end

    test "default value keyword list" do
      g = Grid2D.new(width: 2, height: 2, default_value: [foo: 1, bar: 3])
      assert Grid2D.dimensions(g) == {2, 2}
      assert Grid2D.at!(g, {0, 0}) == [foo: 1, bar: 3]
      assert Keyword.keyword?(Grid2D.at!(g, {0, 0}))
    end
  end

  describe "contains_point?/2" do
    test "point in bounds" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({3, 3}))
    end

    test "x to low" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({-1, 3}))
    end

    test "x == 0" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({0, 3}))
    end

    test "x to high" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({5, 3}))
    end

    test "x inside width edge" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({4, 3}))
    end

    test "x outside width edge" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({5, 3}))
    end

    test "y to low" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({3, -3}))
    end

    test "y == 0" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({3, 0}))
    end

    test "y to high" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({3, 7}))
    end

    test "y inside height edge" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({3, 4}))
    end

    test "y outside height edge" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?({3, 5}))
    end

    test "0 dimension x grid" do
      assert !(Grid2D.new(width: 0, height: 5) |> Grid2D.contains_point?({0, 5}))
    end

    test "0 dimension y grid" do
      assert !(Grid2D.new(width: 5, height: 0) |> Grid2D.contains_point?({5, 0}))
    end
  end

  describe "contains_point?/3" do
    test "point in bounds" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(3, 3))
    end

    test "x to low" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(-1, 3))
    end

    test "x == 0" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(0, 3))
    end

    test "x to high" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(5, 3))
    end

    test "x inside width edge" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(4, 3))
    end

    test "x outside width edge" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(5, 3))
    end

    test "y to low" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(3, -3))
    end

    test "y == 0" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(3, 0))
    end

    test "y to high" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(3, 7))
    end

    test "y inside height edge" do
      assert (Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(3, 4))
    end

    test "y outside height edge" do
      assert !(Grid2D.new(width: 5, height: 5) |> Grid2D.contains_point?(3, 5))
    end

    test "0 dimension x grid" do
      assert !(Grid2D.new(width: 0, height: 5) |> Grid2D.contains_point?(0, 5))
    end

    test "0 dimension y grid" do
      assert !(Grid2D.new(width: 5, height: 0) |> Grid2D.contains_point?(5, 0))
    end
  end

end
