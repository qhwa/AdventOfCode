defmodule Intcode.Process do
  @moduledoc """
  This module represents the intcode computer process.
  """

  def init(program, opts) do
    {:ok, run(program, build_context(opts))}
  end

  defp build_context(opts) do
    Enum.into(opts, %{pointer: 0, input: [], output: []})
  end

  def run(program, %{pointer: p} = context) do
    case program[p] do
      99 ->
        {:halt, self(), program, context}

      op ->
        {mutation, pt, input, output} = exec(program, op, p, context)

        run(
          program |> Map.merge(mutation || %{}),
          context |> trim_input(input) |> advance_pt(pt) |> append_output(output)
        )
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp exec(data, op, p, ctx) do
    r1 = read(data, mode(op, 1), p + 1)
    r2 = read(data, mode(op, 2), p + 2)
    r3 = data[p + 3]

    case rem(op, 10) do
      1 ->
        {%{r3 => r1 + r2}, 4, nil, nil}

      2 ->
        {%{r3 => r1 * r2}, 4, nil, nil}

      3 ->
        [head | tail] = fetch_input(ctx)
        {%{data[p + 1] => head}, 2, tail, nil}

      4 ->
        send(ctx.parent, {:output, r1, ctx.name})
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

  defp fetch_input(%{input: []}) do
    receive do
      {:data, data} -> [data]
    end
  end

  defp fetch_input(%{input: input}), do: input

  defp trim_input(ctx, nil), do: ctx
  defp trim_input(ctx, input), do: %{ctx | input: input}

  defp advance_pt(ctx, {:goto, n}), do: %{ctx | pointer: n}
  defp advance_pt(ctx, n), do: %{ctx | pointer: ctx.pointer + n}

  defp append_output(ctx, nil), do: ctx
  defp append_output(ctx, new), do: %{ctx | output: [new | ctx.output]}
end
