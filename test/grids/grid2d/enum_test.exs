defmodule ExGrids.Grid2D.EnumTest do
  use ExUnit.Case
  alias ExGrids.Grid2D
  alias ExGrids.Grid2D.Enum
  doctest ExGrids.Grid2D.Enum

  describe "coordinates/1" do
    test "empty grid" do
      assert (Grid2D.Create.new() |> Enum.coordinates()) == []
    end

    test "0 width" do
      assert (Grid2D.Create.new(height: 3) |> Enum.coordinates()) == []
    end

    test "0 height" do
      assert (Grid2D.Create.new(width: 3) |> Enum.coordinates()) == []
    end

    test "entry ordering" do
      assert (Grid2D.Create.new(width: 2, height: 2) |> Enum.coordinates()) == [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
    end
  end


  describe "contains_point?/2" do
    test "point in bounds" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({3, 3}))
    end

    test "x to low" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({-1, 3}))
    end

    test "x == 0" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({0, 3}))
    end

    test "x to high" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({5, 3}))
    end

    test "x inside width edge" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({4, 3}))
    end

    test "x outside width edge" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({5, 3}))
    end

    test "y to low" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({3, -3}))
    end

    test "y == 0" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({3, 0}))
    end

    test "y to high" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({3, 7}))
    end

    test "y inside height edge" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({3, 4}))
    end

    test "y outside height edge" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?({3, 5}))
    end

    test "0 dimension x grid" do
      assert !(Grid2D.Create.new(width: 0, height: 5) |> Enum.contains_point?({0, 5}))
    end

    test "0 dimension y grid" do
      assert !(Grid2D.Create.new(width: 5, height: 0) |> Enum.contains_point?({5, 0}))
    end
  end

  describe "contains_point?/3" do
    test "point in bounds" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(3, 3))
    end

    test "x to low" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(-1, 3))
    end

    test "x == 0" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(0, 3))
    end

    test "x to high" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(5, 3))
    end

    test "x inside width edge" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(4, 3))
    end

    test "x outside width edge" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(5, 3))
    end

    test "y to low" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(3, -3))
    end

    test "y == 0" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(3, 0))
    end

    test "y to high" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(3, 7))
    end

    test "y inside height edge" do
      assert (Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(3, 4))
    end

    test "y outside height edge" do
      assert !(Grid2D.Create.new(width: 5, height: 5) |> Enum.contains_point?(3, 5))
    end

    test "0 dimension x grid" do
      assert !(Grid2D.Create.new(width: 0, height: 5) |> Enum.contains_point?(0, 5))
    end

    test "0 dimension y grid" do
      assert !(Grid2D.Create.new(width: 5, height: 0) |> Enum.contains_point?(5, 0))
    end
  end

  describe "at/2" do
    test "empty grid" do
      assert (Grid2D.Create.new(width: 0, height: 0, default_value: 17) |> Grid2D.Enum.at({0, 0})) == nil
    end

    test "0 width" do
      assert (Grid2D.Create.new(width: 0, height: 3, default_value: 17) |> Grid2D.Enum.at({0, 0})) == nil
    end

    test "0 height" do
      assert (Grid2D.Create.new(width: 3, height: 0, default_value: 17) |> Grid2D.Enum.at({0, 0})) == nil
    end

    test "in grid" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({1, 1})) == {:ok, 17}
    end

    test "negative x" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({-1, 1})) == nil
    end

    test "0 x" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({0, 1})) == {:ok, 17}
    end

    test "inside width" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({2, 1})) == {:ok, 17}
    end

    test "outside width" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({3, 1})) == nil
    end

    test "negative y" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({1, -1})) == nil
    end

    test "0 y" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({1, 0})) == {:ok, 17}
    end

    test "inside height" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({1, 2})) == {:ok, 17}
    end

    test "outside height" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at({1, 3})) == nil
    end
  end

  describe "at/3" do
    test "empty grid" do
      assert (Grid2D.Create.new(width: 0, height: 0, default_value: 17) |> Grid2D.Enum.at(0, 0)) == nil
    end

    test "0 width" do
      assert (Grid2D.Create.new(width: 0, height: 3, default_value: 17) |> Grid2D.Enum.at(0, 0)) == nil
    end

    test "0 height" do
      assert (Grid2D.Create.new(width: 3, height: 0, default_value: 17) |> Grid2D.Enum.at(0, 0)) == nil
    end

    test "in grid" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(1, 1)) == {:ok, 17}
    end

    test "negative x" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(-1, 1)) == nil
    end

    test "0 x" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(0, 1)) == {:ok, 17}
    end

    test "inside width" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(2, 1)) == {:ok, 17}
    end

    test "outside width" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(3, 1)) == nil
    end

    test "negative y" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(1, -1)) == nil
    end

    test "0 y" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(1, 0)) == {:ok, 17}
    end

    test "inside height" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(1, 2)) == {:ok, 17}
    end

    test "outside height" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at(1, 3)) == nil
    end
  end

  describe "at!/2" do
    test "empty grid" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 0, height: 0, default_value: 17) |> Grid2D.Enum.at!({0, 0})) end
    end

    test "0 width" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 0, height: 3, default_value: 17) |> Grid2D.Enum.at!({0, 0})) end
    end

    test "0 height" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 0, default_value: 17) |> Grid2D.Enum.at!({0, 0})) end
    end

    test "in grid" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({1, 1})) == 17
    end

    test "negative x" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({-1, 1})) end
    end

    test "0 x" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({0, 1})) == 17
    end

    test "inside width" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({2, 1})) == 17
    end

    test "outside width" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({3, 1})) end
    end

    test "negative y" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({1, -1})) end
    end

    test "0 y" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({1, 0})) == 17
    end

    test "inside height" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({1, 2})) == 17
    end

    test "outside height" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!({1, 3})) end
    end
  end

  describe "at!/3" do
    test "empty grid" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 0, height: 0, default_value: 17) |> Grid2D.Enum.at!(0, 0)) end
    end

    test "0 width" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 0, height: 3, default_value: 17) |> Grid2D.Enum.at!(0, 0)) end
    end

    test "0 height" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 0, default_value: 17) |> Grid2D.Enum.at!(0, 0)) end
    end

    test "in grid" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(1, 1)) == 17
    end

    test "negative x" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(-1, 1)) end
    end

    test "0 x" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(0, 1)) == 17
    end

    test "inside width" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(2, 1)) == 17
    end

    test "outside width" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(3, 1)) end
    end

    test "negative y" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(1, -1)) end
    end

    test "0 y" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(1, 0)) == 17
    end

    test "inside height" do
      assert (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(1, 2)) == 17
    end

    test "outside height" do
      assert_raise ArgumentError, fn -> (Grid2D.Create.new(width: 3, height: 3, default_value: 17) |> Grid2D.Enum.at!(1, 3)) end
    end
  end

end