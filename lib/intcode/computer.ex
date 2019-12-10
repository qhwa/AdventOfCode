defmodule Intcode.Computer do
  @moduledoc """
  This module represents the intcode computer process.
  """

  alias Intcode.{Context, SideEffect}

  def start(program, opts) do
    spawn(fn ->
      run(program, build_context(opts))
    end)
  end

  defp build_context(opts) do
    opts
    |> Enum.into(%{})
    |> Context.__struct__()
  end

  def run(program, %{pointer: p, downstream: ds} = context) do
    case program[p] do
      99 ->
        send(ds, {:halt, self()})
        :halt

      op ->
        %{mem: mem, buffer: input, pt: pt, rel_pt: rel_pt} =
          program
          |> exec(op, p, context)
          |> SideEffect.__struct__()

        run(
          program |> Map.merge(mem || %{}),
          context |> trim_input(input) |> advance_pt(pt) |> advance_rel_pt(rel_pt)
        )
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp exec(data, op, p, ctx) do
    r1 = read(data, mode(op, 1), p + 1, ctx)
    r2 = read(data, mode(op, 2), p + 2, ctx)

    r3 = write_addr(data, mode(op, 3), p + 3, ctx)

    case rem(op, 10) do
      1 ->
        %{mem: %{r3 => r1 + r2}, pt: 4}

      2 ->
        %{mem: %{r3 => r1 * r2}, pt: 4}

      3 ->
        [head | tail] = fetch_input(ctx)

        %{
          mem: %{write_addr(data, mode(op, 1), p + 1, ctx) => head},
          pt: 2,
          buffer: tail
        }

      4 ->
        output(r1, ctx.downstream)
        %{pt: 2}

      5 ->
        %{pt: (r1 != 0 && {:goto, r2}) || 3}

      6 ->
        %{pt: (r1 == 0 && {:goto, r2}) || 3}

      7 ->
        %{mem: %{r3 => (r1 < r2 && 1) || 0}, pt: 4}

      8 ->
        %{mem: %{r3 => (r1 == r2 && 1) || 0}, pt: 4}

      9 ->
        %{pt: 2, rel_pt: r1}
    end
  end

  defp mode(op, pos) do
    op
    |> rem(floor(:math.pow(10, pos + 2)))
    |> div(floor(:math.pow(10, pos + 1)))
  end

  defp read(data, 0, p, _), do: Map.get(data, data[p], 0)
  defp read(data, 1, p, _), do: data[p]
  defp read(data, 2, p, ctx), do: Map.get(data, ctx.rel_pointer + data[p], 0)

  defp write_addr(data, 0, p, _), do: data[p]
  defp write_addr(data, 2, p, ctx), do: ctx.rel_pointer + data[p]

  defp fetch_input(%{input: []}) do
    receive do
      {:data, data, _} -> [data]
    end
  end

  defp fetch_input(%{input: input}), do: input

  defp output(val, nil), do: IO.puts(val)

  defp output(val, downstream) do
    send(downstream, {:data, val, self()})
  end

  defp trim_input(ctx, nil), do: ctx
  defp trim_input(ctx, input), do: %{ctx | input: input}

  defp advance_pt(ctx, {:goto, n}), do: %{ctx | pointer: n}
  defp advance_pt(ctx, n), do: %{ctx | pointer: ctx.pointer + n}

  defp advance_rel_pt(ctx, nil), do: ctx
  defp advance_rel_pt(ctx, n), do: Map.update!(ctx, :rel_pointer, &(&1 + n))
end
