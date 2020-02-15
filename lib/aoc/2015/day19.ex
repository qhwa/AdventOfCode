defmodule AOC.Y2015.Day19 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/19
  """

  @input "CRnCaCaCaSiRnBPTiMgArSiRnSiRnMgArSiRnCaFArTiTiBSiThFYCaFArCaCaSiThCaPBSiThSiThCaCaPTiRnPBSiThRnFArArCaCaSiThCaSiThSiRnMgArCaPTiBPRnFArSiThCaSiRnFArBCaSiRnCaPRnFArPMgYCaFArCaPTiTiTiBPBSiThCaPTiBPBSiRnFArBPBSiRnCaFArBPRnSiRnFArRnSiRnBFArCaFArCaCaCaSiThSiThCaCaPBPTiTiRnFArCaPTiBSiAlArPBCaCaCaCaCaSiRnMgArCaSiThFArThCaSiThCaSiRnCaFYCaSiRnFYFArFArCaSiRnFYFArCaSiRnBPMgArSiThPRnFArCaSiRnFArTiRnSiRnFYFArCaSiRnBFArCaSiRnTiMgArSiThCaSiThCaFArPRnFArSiRnFArTiTiTiTiBCaCaSiRnCaCaFYFArSiThCaPTiBPTiBCaSiThSiRnMgArCaF"

  @mapping "2015/day19.txt"
           |> AOC.Input.stream()
           |> Stream.map(&String.split(&1, " => "))
           |> Stream.map(fn [s, r] -> {r, s} end)
           |> Enum.into([])

  def p2 do
    deduce()
  end

  defp deduce(solutions \\ init_seqs(), gen \\ 0) do
    solutions
    |> Enum.map(&rate/1)
    |> Enum.sort()
    |> case do
      [{1, actions} | _] ->
        length(actions)

      [{score, best} | _] = rated ->
        # IO.inspect(score, label: "genration: ##{gen}, best:")

        new_ones = for _ <- 1..100, do: bear(rated) |> build_seq()

        [build_seq(best) | new_ones]
        |> deduce(gen + 1)
    end
  end

  defp init_seqs() do
    for _ <- 1..100, do: build_seq()
  end

  defp build_seq(start \\ []) do
    Stream.concat(start, Stream.repeatedly(fn -> Enum.random(@mapping) end))
  end

  defp rate(seq) do
    Enum.reduce_while(seq, {[], @input}, fn {ret, origin}, {actions, input} ->
      cond do
        input == "e" ->
          {:halt, {1, actions}}

        String.contains?(input, ret) ->
          next = String.replace(input, ret, origin, global: false)
          {:cont, {[{ret, origin} | actions], next}}

        :else ->
          {:halt, {String.length(input), actions}}
      end
    end)
    |> case do
      {i, actions} when is_integer(i) ->
        {i, actions |> Enum.reverse()}

      {actions, string} ->
        {String.length(string), actions |> Enum.reverse()}
    end
  end

  defp bear(solutions) do
    bear(get_one(solutions), get_one(solutions))
  end

  defp bear(p1, p2) do
    p1 =
      if :rand.uniform() < 0.5 do
        cross(p1, p2)
      else
        p1
      end

    if :rand.uniform() < 0.1 do
      mutate(p1)
    else
      p1
    end
  end

  defp cross(seq1, seq2) do
    len = length(seq1)
    p1 = :rand.uniform(len) - 1
    p2 = trunc(:rand.uniform() * (len - p1 + 1)) + p1

    Enum.slice(seq1, 0..(p1 - 1)) ++
      Enum.slice(seq2, p1..p2) ++
      Enum.slice(seq1, (p2 + 1)..(len - 1))
  end

  defp mutate(seqs) do
    len = length(seqs)
    p1 = :rand.uniform(len) - 1
    p2 = :rand.uniform(len) - 1
    [p1, p2] = Enum.sort([p1, p2])

    if p1 == p2 do
      seqs
    else
      case :rand.uniform(3) do
        1 ->
          seqs
          |> List.replace_at(p1, Enum.at(seqs, p2))
          |> List.replace_at(p2, Enum.at(seqs, p1))

        2 ->
          Enum.slice(seqs, 0..(p1 - 1)) ++
            (Enum.slice(seqs, p1..p2) |> Enum.reverse()) ++ Enum.slice(seqs, p2..(len - 1))

        3 ->
          Enum.slice(seqs, 0..(p1 - 1)) ++
            Enum.slice(seqs, p2..(len - 1)) ++ Enum.slice(seqs, p1..p2)
      end
    end
  end

  defp get_one(solutions) do
    solutions =
      solutions
      |> Enum.map(fn {len, actions} -> {div(500, len), actions} end)

    max =
      solutions
      |> Stream.map(&elem(&1, 0))
      |> Enum.sum()
      |> :rand.uniform()

    solutions
    |> Enum.reduce_while(max, fn {score, actions}, count ->
      if count > score do
        {:cont, count - score}
      else
        {:halt, actions}
      end
    end)
  end
end
