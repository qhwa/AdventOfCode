defmodule AOC.Task.Day19 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/19
  """

  @reg ~r/[A-z][a-z]*/
  @input "CRnCaCaCaSiRnBPTiMgArSiRnSiRnMgArSiRnCaFArTiTiBSiThFYCaFArCaCaSiThCaPBSiThSiThCaCaPTiRnPBSiThRnFArArCaCaSiThCaSiThSiRnMgArCaPTiBPRnFArSiThCaSiRnFArBCaSiRnCaPRnFArPMgYCaFArCaPTiTiTiBPBSiThCaPTiBPBSiRnFArBPBSiRnCaFArBPRnSiRnFArRnSiRnBFArCaFArCaCaCaSiThSiThCaCaPBPTiTiRnFArCaPTiBSiAlArPBCaCaCaCaCaSiRnMgArCaSiThFArThCaSiThCaSiRnCaFYCaSiRnFYFArFArCaSiRnFYFArCaSiRnBPMgArSiThPRnFArCaSiRnFArTiRnSiRnFYFArCaSiRnBFArCaSiRnTiMgArSiThCaSiThCaFArPRnFArSiRnFArTiTiTiTiBCaCaSiRnCaCaFYFArSiThCaPTiBPTiBCaSiThSiRnMgArCaF"

  @mapping "priv/data/day19.txt"
           |> File.stream!()
           |> Stream.map(&String.trim_trailing/1)
           |> Stream.map(&String.split(&1, " => "))
           |> Stream.map(&List.to_tuple/1)
           |> Enum.into([])

  def puzzle() do
    @input
    |> group_count(@mapping)
  end

  def group_count(atoms, mapping) when is_binary(atoms) do
    @reg
    |> Regex.scan(atoms)
    |> List.flatten()
    |> group_count(mapping)
  end

  def group_count(atoms, mapping) do
    atoms
    |> all_groups(mapping)
    |> Enum.uniq()
    |> length()
  end

  def all_groups(atoms, mapping) do
    for {atom, i} <- Enum.with_index(atoms), {k, v} <- mapping, atom == k do
      {i, v}
    end
    |> Enum.map(fn {i, v} ->
      atoms
      |> List.replace_at(i, v)
      |> Enum.join("")
    end)
  end
end
