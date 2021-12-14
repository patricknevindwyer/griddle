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

end
