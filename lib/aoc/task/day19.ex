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

  def puzzle do
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

  def puzzle2 do
    step(@input, @mapping)
  end

  def step(input, mapping) do
    mapping =
      mapping
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.update(acc, v, [k], &[k | &1])
      end)

    {^input, min} = build_tree(input, mapping, 0)
    min
  end

  def build_tree(input, mapping, depth) do
    if input =~ ~r/^e+$/ do
      {:done, depth}
    else
      build_tree_node(input, mapping, depth)
    end
  end

  def build_tree_node(input, mapping, depth) do
    groups =
      for {dest, froms} <- mapping, String.contains?(input, dest), f <- froms do
        input |> String.replace(dest, f, global: false)
      end

    {_, min_depth} =
      groups
      |> Enum.map(&build_tree(&1, mapping, depth + 1))
      |> Enum.min_by(&walk/1, fn -> {:halt, 9_999_999} end)

    {input, min_depth}
  end

  def walk({:done, depth}) do
    depth
  end

  def walk({_, min_depth}) do
    min_depth
  end
end
