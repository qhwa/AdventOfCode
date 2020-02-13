defmodule AOC.Y2015.Day23 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/23
  """
  def p1 do
    "priv/data/2015/day23.txt"
    |> File.read!()
    |> run()
  end

  def p2 do
    "priv/data/2015/day23.txt"
    |> File.read!()
    |> compile()
    |> Map.update!(:registers, &%{&1 | "a" => 1})
    |> run()
  end

  def example do
    source = """
    inc a
    jio a, +2
    tpl a
    inc a
    """

    run(source)
  end

  @initial_state %{"a" => 0, "b" => 0}
  @initial_pos 0

  def run(source) when is_binary(source),
    do: source |> compile() |> run()

  def run(%{pos: pos, program: program} = computer) do
    case program do
      %{^pos => cmd} ->
        run_cmd(computer, cmd)
        |> run()

      _ ->
        computer.registers
    end
  end

  defp run_cmd(%{registers: reg} = computer, [op, r]) when op in [:hlf, :tpl, :inc] do
    instructions = %{
      hlf: &div(&1, 2),
      tpl: &(&1 * 3),
      inc: &(&1 + 1)
    }

    %{computer | registers: Map.update!(reg, r, instructions[op])}
    |> next_line()
  end

  defp run_cmd(computer, [:jmp, offset]) do
    jump(computer, offset)
  end

  defp run_cmd(%{registers: reg} = computer, [:jie, r, offset]) do
    if rem(Map.fetch!(reg, r), 2) == 0 do
      jump(computer, offset)
    else
      next_line(computer)
    end
  end

  defp run_cmd(computer, [:jio, r, offset]) do
    case computer.registers do
      %{^r => 1} ->
        jump(computer, offset)

      _ ->
        next_line(computer)
    end
  end

  defp next_line(computer) do
    jump(computer, 1)
  end

  defp jump(%{pos: pos} = computer, offset) do
    %{computer | pos: pos + offset}
  end

  defp compile(source) do
    program =
      source
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, [" ", ","], trim: true))
      |> Enum.map(&parse_tokens/1)
      |> Enum.with_index()
      |> Enum.map(fn {tokens, n} -> {n, tokens} end)
      |> Enum.into(%{})

    %{
      registers: @initial_state,
      pos: @initial_pos,
      program: program
    }
  end

  defp parse_tokens([op | params]) do
    [
      String.to_atom(op)
      | Enum.map(params, fn w ->
          case Integer.parse(w) do
            {i, ""} -> i
            _ -> w
          end
        end)
    ]
  end
end
