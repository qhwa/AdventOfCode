defmodule AOC.Y2019.Day05 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/5
  """

  import Helper.MyList, only: [to_map: 1]

  @program "priv/data/2019/day05.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Stream.map(&String.to_integer/1)
           |> to_map()

  def p1 do
    run(@program, %{pointer: 0, input: 1, output: []})
  end

  def p2 do
    run(@program, %{pointer: 0, input: 5, output: []})
  end

  def run(program, %{pointer: p} = context) do
    case program[p] do
      99 ->
        context.output |> Enum.reverse()

      op ->
        {mutation, pt, output} = exec(program, op, p, context)

        run(
          program |> Map.merge(mutation || %{}),
          %{context | pointer: pt, output: output ++ context.output}
        )
    end
  end

  defp exec(data, 3, p, %{input: input}) do
    {%{data[p + 1] => input}, p + 2, []}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 4 do
    {nil, p + 2, [read(data, mode(op), p + 1)]}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 5 do
    {nil, jump(data, p, op, &(&1 != 0)), []}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 6 do
    {nil, jump(data, p, op, &(&1 == 0)), []}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 7 do
    {compare(data, p, op, &((&1 < &2 && 1) || 0)), p + 4, []}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 8 do
    {compare(data, p, op, &((&1 == &2 && 1) || 0)), p + 4, []}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 1 do
    {calc(data, p, op, &(&1 + &2)), p + 4, []}
  end

  defp exec(data, op, p, _) when rem(op, 10) == 2 do
    {calc(data, p, op, &(&1 * &2)), p + 4, []}
  end

  defp mode(op, pos \\ 0) do
    op
    |> rem(floor(:math.pow(10, pos + 3)))
    |> div(floor(:math.pow(10, pos + 2)))
  end

  defp read(data, 0, p), do: data[data[p]]
  defp read(data, 1, p), do: data[p]

  defp jump(data, p, op, if_jump) do
    value = read(data, mode(op), p + 1)

    if if_jump.(value) do
      read(data, mode(op, 1), p + 2)
    else
      p + 3
    end
  end

  defp compare(data, p, op, fun) do
    r1 = read(data, mode(op), p + 1)
    r2 = read(data, mode(op, 1), p + 2)
    wp = data[p + 3]

    %{wp => fun.(r1, r2)}
  end

  defp calc(data, p, op, fun) do
    {p1, p2, p3} = {p + 1, p + 2, p + 3}

    r1 = read(data, mode(op), p1)
    r2 = read(data, mode(op, 1), p2)
    wp = data[p3]

    %{wp => fun.(r1, r2)}
  end
end
