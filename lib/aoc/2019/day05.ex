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

  defguard is_read(op) when rem(op, 10) == 3

  def p1, do: run(@program, %{pointer: 0, input: 1, output: []})
  def p2, do: run(@program, %{pointer: 0, input: 5, output: []})

  def run(program, %{pointer: p} = context) do
    case program[p] do
      99 ->
        context.output |> Enum.reverse()

      op ->
        {mutation, pt, output} = exec(program, op, p, context)

        run(
          program |> Map.merge(mutation || %{}),
          %{context | pointer: pt, output: append_output(output, context.output)}
        )
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp exec(data, op, p, %{input: input}) do
    r1 = read(data, mode(op, 1), p + 1)
    r2 = read(data, mode(op, 2), p + 2)
    r3 = data[p + 3]

    case rem(op, 10) do
      1 ->
        {%{r3 => r1 + r2}, p + 4, nil}

      2 ->
        {%{r3 => r1 * r2}, p + 4, nil}

      3 ->
        {%{data[p + 1] => input}, p + 2, nil}

      4 ->
        {nil, p + 2, r1}

      5 ->
        {nil, (r1 != 0 && r2) || p + 3, nil}

      6 ->
        {nil, (r1 == 0 && r2) || p + 3, nil}

      7 ->
        {%{r3 => (r1 < r2 && 1) || 0}, p + 4, nil}

      8 ->
        {%{r3 => (r1 == r2 && 1) || 0}, p + 4, nil}
    end
  end

  defp mode(op, pos) do
    op
    |> rem(floor(:math.pow(10, pos + 2)))
    |> div(floor(:math.pow(10, pos + 1)))
  end

  defp read(data, 0, p), do: data[data[p]]
  defp read(data, 1, p), do: data[p]

  defp append_output(nil, output), do: output
  defp append_output(new, output), do: [new | output]
end
