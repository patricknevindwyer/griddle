defmodule ExGrids.Grid2D.Create do
  @moduledoc """
  Methods for creating Grid2D instances.
  """

  alias ExGrids.Grid2D
  import ExGrids.Grid2D.Mutate, only: [fill: 2]
  
  @doc """
  Generate a new, empty grid. This is a zero width, zero height
  grid.

  ## Example

      iex> Create.new()
      %Grid2D{width: 0, height: 0}
  """
  def new() do
    %Grid2D{width: 0, height: 0, xoffset: 0, yoffset: 0, grid: %{}}
  end

  @doc """
  Generate a new grid using sizing and default value options. If the
  specified width or height are negatives, the `new/1` method throws
  an `ArgumentError`.

  When called with a `default_value` option, the given value is used
  as the fill value for every entry in the grid. If a 1-arity method
  is given as the `default_value` it is invoked for every entry when
  filling in the grid, as if calling `fill/2` on the grid.

  ## Options

    - `width` - Positive integer, default `0`
    - `height` - Positive integer, default `0`
    - `default_value` - Any. Value to store in all cells by default,
                        or a 1-arity function to call for every cell

  ## Example

      iex> Create.new(width: 7, height: 11) |> Grid2D.Enum.dimensions()
      {7, 11}

      iex> Create.new(width: -7, height: 11)
      ** (ArgumentError) Negative width

      iex> Create.new(width: 1, height: 1, default_value: 1)
      %Grid2D{width: 1, height: 1, grid: %{{0, 0} => 1}}

      iex> Create.new(width: 1, height: 1, default_value: {:checked, 0, true})
      %Grid2D{width: 1, height: 1, grid: %{{0, 0} => {:checked, 0, true}}}

      iex> Create.new(width: 1, height: 1, default_value: fn {x, y} -> x + 3 + y + 7 end)
      %Grid2D{width: 1, height: 1, grid: %{{0, 0} => 10}}

  """
  def new(opts) do

    # setup the grid structures
    g = default_grid()
        |> with_size(opts)

    # ensure this is a properly formed grid
    if g.width < 0 do
      raise ArgumentError, "Negative width"
    end

    if g.height < 0 do
      raise ArgumentError, "Negative height"
    end

    # default value fill, and return the grid
    d_fn = default_function(opts)
    g
    |> fill(d_fn)
  end

  defp default_grid do
    %Grid2D{width: 0, height: 0}
  end

  defp with_size(%Grid2D{}=grid, opts) do

    # select out the size for the grid
    width = opts |> Keyword.get(:width, 0)
    height = opts |> Keyword.get(:height, 0)

    # update the grid
    grid |> Map.merge(%{width: width, height: height})

  end

  defp default_function(opts) do

    cond do

      # wrap the default value in a 1-arity function
      Keyword.has_key?(opts, :default_value) ->

        d = opts |> Keyword.get(:default_value)

        if is_function(d, 1) do
          d
        else
          fn {_x, _y} -> d end
        end

      # we're inserting 0 as the default value
      true ->
        fn {_x, _y} -> 0 end
    end

  end

  # TODO: improve documentation
  # TODO: tests
  # TODO: expand ways to convert from string
  @doc """
  Create a new Grid2D from the contents of a string.
  """
  def from_string(bin, :integer_cells) do

    # generate lists
    bin
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.map(&String.to_integer/1) end)
    |> grid_from_lists()

  end

  defp grid_from_lists(nested_lists) do

    # setup the grid
    w = nested_lists |> List.first() |> length()
    h = length(nested_lists)
    g = new(width: w, height: h)

    # convert the list to coordinate groups
    values = 0..(h - 1)
    |> Enum.map(fn h_idx ->
      row = nested_lists |> Enum.at(h_idx)
      0..(w - 1)
      |> Enum.map(fn w_idx ->
        c = row |> Enum.at(w_idx)
        {{w_idx, h_idx}, c}
      end)
    end)
    |> List.flatten()

    # inject
    g |> inject_values(values)

  end

  # TODO: move to enum
  # TODO: expose as public
  # TODO: document
  # TODO: tests
  defp inject_values(grid, coord_val_pairs) when is_list(coord_val_pairs) do
    coord_val_pairs
    |> Enum.reduce(grid, fn {coord, value}, acc_grid -> put(acc_grid, coord, value) end)
  end

  # TODO: move to mutate
  # TODO: make public
  # TODO: document
  # TODO: tests
  defp put(grid, coord, v) do
    g = grid.grid |> Map.put(coord, v)
    grid |> Map.put(:grid, g)
  end

end