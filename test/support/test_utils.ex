defmodule ExGrids.TestUtils do

  def read_test_file(f) do
    Path.join([:code.priv_dir(:exgrids), "data", f])
    |> File.read!()
  end
end