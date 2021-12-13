defmodule ExGrids.Grid2D.Create do
  @moduledoc """
  Methods for creating Grid2D instances.
  """

  alias ExGrids.Grid2D
  import ExGrids.Grid2D.Mutate, only: [fill: 2]
  import ExGrids.Grid2D.Enum, only: [put: 3]

  # TODO: Carry typing/setup info along with a grid (like :integer_cells or :character_cells)
  #       and use this to pick things like display functions


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

  @doc """
  Create a new Grid2D from the contents of a string. This function has multiple
  modes to parse strings of different shapes and sizes.

  ## Modes

  Each mode is distinguished with either a single atom, or a keyword list which
  contains distinct settings for a run time mode.

  The following modes are supported:

    - `:integer_cells` - Flat, compact single integer layout
    - `:character_cells` - Flat, compact single character layout

  ### `:integer_cells`

  This mode parses single digit integer values packed together, with delimiters
  for rows as newlines. For example, a grid with 3 rows, with 4 values per row:

  ```
  1234
  5678
  9876
  ```

  #### Examples

      iex> Create.from_string("1234\\n5678\\n9876", :integer_cells) |> Grid2D.Enum.dimensions()
      {4, 3}

      iex> Create.from_string("1234\\n5678\\n9876", :integer_cells) |> Grid2D.Enum.at!({2, 1})
      7

  ### `:character_cells`

  This mode parses characters packed together, with newline delimited rows. For
  example, a grid of hashes and dots:

  ```
  #.##..
  #...#.
  ......
  #...#.
  ```

  #### Examples

      iex> Create.from_string("#.##..\\n#...#.\\n......\\n#...#.\\n", :character_cells) |> Grid2D.Enum.at!({4, 1})
      "#"
  """
  def from_string(bin, :integer_cells) do

    # generate lists of lines
    bin
    |> String.split("\n", trim: true)

    # strip empty lines
    |> Enum.filter(fn line -> String.trim(line) != "" end)

    # convert to rows of ints
    |> Enum.map(fn line ->

      # trim whit space
      line
      |> String.trim()

      # split to cells
      |> String.split("", trim: true)

      # drop empty cells
      |> Enum.filter(fn c -> String.trim(c) != "" end)

      # convert to integers
      |> Enum.map(&String.to_integer/1)
    end)
    |> grid_from_lists()

  rescue
    _e in [ArgumentError] -> reraise ExGrids.Errors.FormatError, [message: "Formatting issue with integer cells"], __STACKTRACE__
  end

  def from_string(bin, :character_cells) do
    # generate lists of lines
    bin
    |> String.split("\n", trim: true)

      # strip empty lines
    |> Enum.filter(fn line -> String.trim(line) != "" end)

      # convert to rows of ints
    |> Enum.map(fn line ->

      # trim whit space
      line
      |> String.trim()

        # split to cells
      |> String.split("", trim: true)

        # drop empty cells
      |> Enum.filter(fn c -> String.trim(c) != "" end)

    end)
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

end