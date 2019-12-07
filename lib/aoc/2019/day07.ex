defmodule AOC.Y2019.Day07 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/5
  """

  import Helper.MyList, only: [to_map: 1, perms: 1]

  @program "priv/data/2019/day07.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Stream.map(&String.to_integer/1)
           |> to_map()

  def p1, do: max_output(@program, perms([0, 1, 2, 3, 4]))
  def p2, do: max_output(@program, perms([5, 6, 7, 8, 9]))

  def max_output(program, sequences) do
    to_process = fn perm ->
      perm
      |> Enum.with_index()
      |> Enum.map(fn {c, i} ->
        %{
          program: program,
          context: %{
            input: if(i == 0, do: [c, 0], else: [c]),
            output: [],
            pointer: 0,
            id: i
          }
        }
      end)
    end

    sequences
    |> Stream.map(to_process)
    |> Stream.map(&final_output/1)
    |> Enum.max()
  end

  defp final_output(processes, id \\ 0, step \\ 0) do
    p = Enum.at(processes, id)
    %{program: program, context: context} = p
    next = rem(id + 1, length(processes))

    case run(program, context) do
      {:halt, _, %{output: out}} when next == 0 ->
        out

      {_, program, ctx} ->
        processes =
          processes
          |> List.replace_at(id, %{p | program: program, context: ctx})
          |> pipe_io(id, next)

        final_output(processes, next, step + 1)
    end
  end

  def run(program, %{pointer: p, input: input} = context) do
    case program[p] do
      99 ->
        {:halt, program, context}

      3 when input == [] ->
        {:iowait, program, context}

      op ->
        {mutation, pt, input, output} = exec(program, op, p, context)

        run(
          program |> Map.merge(mutation || %{}),
          context |> trim_input(input) |> advance_pt(pt) |> append_output(output)
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
        {%{r3 => r1 + r2}, 4, nil, nil}

      2 ->
        {%{r3 => r1 * r2}, 4, nil, nil}

      3 ->
        [read | tail] = input
        {%{data[p + 1] => read}, 2, tail, nil}

      4 ->
        {nil, 2, nil, r1}

      5 ->
        {nil, (r1 != 0 && {:goto, r2}) || 3, nil, nil}

      6 ->
        {nil, (r1 == 0 && {:goto, r2}) || 3, nil, nil}

      7 ->
        {%{r3 => (r1 < r2 && 1) || 0}, 4, nil, nil}

      8 ->
        {%{r3 => (r1 == r2 && 1) || 0}, 4, nil, nil}
    end
  end

  defp mode(op, pos) do
    op
    |> rem(floor(:math.pow(10, pos + 2)))
    |> div(floor(:math.pow(10, pos + 1)))
  end

  defp read(data, 0, p), do: data[data[p]]
  defp read(data, 1, p), do: data[p]

  defp trim_input(ctx, nil), do: ctx
  defp trim_input(ctx, input), do: %{ctx | input: input}

  defp advance_pt(ctx, {:goto, n}), do: %{ctx | pointer: n}
  defp advance_pt(ctx, n), do: %{ctx | pointer: ctx.pointer + n}

  defp append_output(ctx, nil), do: ctx
  defp append_output(ctx, new), do: %{ctx | output: [new | ctx.output]}

  defp pipe_io(processes, from, to) do
    p1 = Enum.at(processes, from)
    p2 = Enum.at(processes, to)

    {data, p} = extract_output(p1)

    processes
    |> List.replace_at(from, p)
    |> List.replace_at(to, %{
      p2
      | context:
          Map.update!(
            p2.context,
            :input,
            &(&1 ++ data)
          )
    })
  end

  defp extract_output(%{context: %{output: data} = ctx} = p) do
    {data, %{p | context: %{ctx | output: []}}}
  end
end
