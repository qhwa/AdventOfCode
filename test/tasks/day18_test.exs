defmodule Day18Test do
  import AOC.Y2015.Day18

  use ExUnit.Case

  @init_state "test/fixtures/day18.txt"
              |> File.stream!()
              |> Stream.with_index()
              |> Stream.map(fn {line, y} ->
                line
                |> String.trim_trailing()
                |> String.to_charlist()
                |> Enum.with_index()
                |> Enum.map(fn {char, x} -> {:"#{x}_#{y}", {x, y, char}} end)
              end)
              |> Enum.to_list()
              |> List.flatten()
              |> Enum.into(%{})

  describe "next/1" do
    test "it works" do
      assert @init_state |> next(6) |> count_light() == 11
      assert @init_state |> run_after(2, 6) |> count_light() == 8
      assert @init_state |> run_after(3, 6) |> count_light() == 4
      assert @init_state |> run_after(4, 6) |> count_light() == 4
    end
  end
end
