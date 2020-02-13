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

  @initial_state %{"a" => 0, "b" => 0}
  @initial_pos 0

  defp compile(source) do
    program =
      source
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, [" ", ","], trim: true))
      |> Enum.with_index()
      |> Enum.map(fn {tokens, n} -> {n, tokens} end)
      |> Enum.into(%{})

    %{
      registers: @initial_state,
      pos: @initial_pos,
      program: program
    }
  end

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

  defp run_cmd(%{registers: reg} = computer, [op, r]) when op in ~w[hlf tpl inc] do
    updater = fn val ->
      case op do
        "hlf" -> div(val, 2)
        "tpl" -> val * 3
        "inc" -> val + 1
      end
    end

    %{computer | registers: %{reg | r => updater.(reg[r])}}
    |> next_line()
  end

  defp run_cmd(computer, ["jmp", offset]),
    do: move_cursor(computer, offset)

  defp run_cmd(%{registers: reg} = computer, ["jie", r, offset]) do
    if rem(Map.fetch!(reg, r), 2) == 0 do
      move_cursor(computer, offset)
    else
      next_line(computer)
    end
  end

  defp run_cmd(computer, ["jio", r, offset]) do
    case computer.registers do
      %{^r => 1} ->
        move_cursor(computer, offset)

      _ ->
        next_line(computer)
    end
  end

  defp next_line(computer), do: move_cursor(computer, 1)

  defp move_cursor(computer, offset) when is_binary(offset),
    do: move_cursor(computer, String.to_integer(offset))

  defp move_cursor(%{pos: pos} = computer, offset),
    do: %{computer | pos: pos + offset}
end
