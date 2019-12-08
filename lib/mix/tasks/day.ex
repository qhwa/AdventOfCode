defmodule Mix.Tasks.Day do
  @moduledoc """
  Mix task to run a specific day puzzle.

  ## Example

  $ mix aoc.day 9
  """
  use Mix.Task

  defp readable_time(t), do: "#{t / 1_000} ms"

  @shortdoc "Run a specific day from the problem set"
  def run(["all"]) do
    {total_time, _} =
      :timer.tc(fn ->
        Enum.each(1..25, fn d ->
          try do
            run(d)
            IO.puts("\n")
          rescue
            ArgumentError -> "That's all folks!"
          end
        end)
      end)

    IO.puts("""
    ============================
        Total Time: #{readable_time(total_time)}
    """)
  end

  def run([day]) do
    day = String.pad_leading(day, 2, "0")

    {total_time, _} =
      :timer.tc(fn ->
        {:ok, input} = apply(String.to_existing_atom("Elixir.AOC.Y2019.Day#{day}"), :setup, [])

        {p1_time, p1_answer} =
          :timer.tc(fn ->
            apply(String.to_existing_atom("Elixir.AOC.Y2019.Day#{day}"), :p1, [input])
          end)

        {p2_time, p2_answer} =
          :timer.tc(fn ->
            apply(String.to_existing_atom("Elixir.AOC.Y2019.Day#{day}"), :p2, [input])
          end)

        IO.puts("""
        Day #{day}:
        ----------------------------
        Part 1:
        #{p1_answer}
        (#{readable_time(p1_time)})
        Part 2:
        #{p2_answer}
        (#{readable_time(p2_time)})
        ----------------------------
        """)
      end)

    IO.puts("total time: #{readable_time(total_time)}")
  end
end
