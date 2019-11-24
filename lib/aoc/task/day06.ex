defmodule AOC.Task.Day06 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/6
  """

  use Bitwise

  def puzzle() do
    {1000, lights} =
      "priv/data/day06.txt"
      |> File.stream!()
      |> Enum.to_list()
      |> operate({1000, 0..1_000_000 |> Enum.map(fn _ -> 0 end)})

    Enum.count(lights, fn i -> i == 1 end)
  end

  def operate([], lights) do
    lights
  end

  def operate([head | tail], lights) do
    operate(tail, operate(head, lights))
  end

  def operate(ins, lights) when is_binary(ins) do
    ins
    |> parse_instruction()
    |> operate(lights)
  end

  def operate({operation, {x0, y0, x1, y1}}, {w, lights}) do
    pins = for x <- x0..x1, y <- y0..y1, do: y * w + x
    IO.inspect operation

    lights =
      pins
      |> Enum.reduce(lights, fn i, lights ->
        List.update_at(lights, i, &update_pin(operation, &1))
      end)

    {w, lights}
  end

  def operate(_, lights) do
    lights
  end

  def update_pin(:on, _), do: 1
  def update_pin(:off, _), do: 0
  def update_pin(:toggle, x), do: 1 - x

  def parse_instruction("turn on " <> raw) do
    {:on, parse_range(raw)}
  end

  def parse_instruction("turn off " <> raw) do
    {:off, parse_range(raw)}
  end

  def parse_instruction("toggle " <> raw) do
    {:toggle, parse_range(raw)}
  end

  def parse_instruction(_) do
    {:error, :invalid}
  end

  def parse_range(raw) do
    ~r/\d+/
    |> Regex.scan(raw)
    |> Enum.map(fn [x] -> String.to_integer(x) end)
    |> List.to_tuple()
  end
end
