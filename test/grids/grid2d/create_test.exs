defmodule ExGrids.Grid2D.CreateTest do
  use ExUnit.Case
  alias ExGrids.Grid2D
  alias ExGrids.Grid2D.Create
  doctest ExGrids.Grid2D.Create

  describe "new/0" do

    test "default values" do
      g = Create.new()

      assert g.width == 0
      assert g.height == 0
      assert g.xoffset == 0
      assert g.yoffset == 0
      assert g.grid == %{}
    end

  end

  describe "new/1" do

    test "default width" do

      g = Create.new(height: 3)
      assert {0, 3} == Grid2D.Enum.dimensions(g)

    end

    test "default height" do

      g = Create.new(width: 7)
      assert {7, 0} == Grid2D.Enum.dimensions(g)

    end

    test "default value scalar" do

      g = Create.new(width: 2, height: 2, default_value: true)
      assert Grid2D.Enum.dimensions(g) == {2, 2}
      assert Grid2D.Enum.at!(g, {1, 0}) == true
    end

    test "default value map" do
      g = Create.new(width: 2, height: 2, default_value: %{biz: 1, bar: [2, 3]})
      assert Grid2D.Enum.dimensions(g) == {2, 2}
      assert Grid2D.Enum.at!(g, {0, 0}) == %{biz: 1, bar: [2, 3]}
      assert is_map(Grid2D.Enum.at!(g, {0, 0}))
    end

    test "default value list" do
      g = Create.new(width: 2, height: 2, default_value: [3, :true, "blah"])
      assert Grid2D.Enum.dimensions(g) == {2, 2}
      assert Grid2D.Enum.at!(g, {0, 0}) == [3, :true, "blah"]
      assert is_list(Grid2D.Enum.at!(g, {0, 0}))
    end

    test "default value keyword list" do
      g = Create.new(width: 2, height: 2, default_value: [foo: 1, bar: 3])
      assert Grid2D.Enum.dimensions(g) == {2, 2}
      assert Grid2D.Enum.at!(g, {0, 0}) == [foo: 1, bar: 3]
      assert Keyword.keyword?(Grid2D.Enum.at!(g, {0, 0}))
    end

    test "negative width" do
      assert_raise ArgumentError, "Negative width", fn -> Create.new(width: -3) end
    end

    test "negative height" do
      assert_raise ArgumentError, "Negative height", fn -> Create.new(height: -3) end
    end

    test "default value 1-arity function" do
      g = Create.new(width: 3, height: 3, default_value: fn {x, y} -> x * y + 3 end)
      assert Grid2D.Enum.at!(g, 2, 2) == 7
    end

    test "improper 1-arity function causes problems" do
      assert_raise ArgumentError, "Fill function should accept {x, y} value", fn -> Create.new(width: 3, height: 3, default_value: fn {x, y, :foo} -> x * y + 3 end) end
    end
  end

  describe "from_string/2" do
    test "single row, single cell" do

      # create
      assert %Grid2D{} = g = """
      1
      """
      |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {1, 1}

      # value
      assert Grid2D.Enum.at!(g, {0, 0}) == 1

    end

    test "single row, multiple cells" do
      # create
      assert %Grid2D{} = g = """
                             7654
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {4, 1}

      # value
      assert Grid2D.Enum.at!(g, {2, 0}) == 5
    end

    test "multiple rows, single column" do
      # create
      assert %Grid2D{} = g = """
                             7
                             6
                             5
                             4
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {1, 4}

      # value
      assert Grid2D.Enum.at!(g, {0, 3}) == 4
    end

    test "5x5" do
      # create
      assert %Grid2D{} = g = """
                             76543
                             65432
                             56789
                             45678
                             12345
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5

    end

    test "non-integer cell" do
      assert_raise ExGrids.Errors.FormatError,
                   fn ->
                     """
                     76543
                     65432
                     5678b
                     45d78
                     12345
                     """
                     |> Create.from_string(:integer_cells)
                   end
    end

    test "trailing blank/newline" do
      # create
      assert %Grid2D{} = g = """
                             76543
                             65432
                             56789
                             45678
                             12345


                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5

    end

    test "leading newlines" do
      # create
      assert %Grid2D{} = g = """


                             76543
                             65432
                             56789
                             45678
                             12345
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5
    end

    test "leading whitespace" do
      # create
      assert %Grid2D{} = g = """
                             76543
                              65432
                              56789
                              45678
                              12345
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5

    end

    test "trailing whitespace" do
      # create
      assert %Grid2D{} = g = """
                             76543
                             65432
                             56789
                             45678
                             12345
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5

    end

    test "spaces between cells" do
      # create
      assert %Grid2D{} = g = """
                             7 6 5 4 3
                             6 5 4 3 2
                             5 6 7 8 9
                             4 5 6 7 8
                             1 2 3 4 5
                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5

    end

    test "hella messy" do
      # create
      assert %Grid2D{} = g = """


                             76543
                             6 5 432
                             567 8 9

                             45 6 78
                             1 2345

                             """
                             |> Create.from_string(:integer_cells)

      # shape
      assert Grid2D.Enum.dimensions(g) == {5, 5}

      # value
      assert Grid2D.Enum.at!(g, {3, 3}) == 7
      assert Grid2D.Enum.at!(g, {1, 1}) == 5

    end
  end

end