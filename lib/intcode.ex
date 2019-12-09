defmodule Intcode do
  @moduledoc """
  Intcode program intepreter.
  """

  import Helper.MyList, only: [to_map: 1]

  def load_file(file) do
    file
    |> File.read!()
    |> load()
  end

  def load(source) do
    parse(source)
  end

  defp parse(source) do
    source
    |> String.trim()
    |> String.split(",")
    |> Stream.map(&String.to_integer/1)
    |> to_map()
  end
end
