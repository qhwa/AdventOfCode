defmodule AOC.Task.Day06 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/6
  """

  def puzzle() do
    {x_stops, y_stops, ops} =
      "priv/data/day06.txt"
      |> File.stream!()
      |> Enum.to_list()
      |> build_ranges([], [], [])

    squares =
      for {x, i} <- Enum.with_index(x_stops), {y, j} <- Enum.with_index(y_stops) do
        # {point, size}
        {{x, y}, (next_stop(x_stops, i) - x) * (next_stop(y_stops, j) - y)}
      end

    walk(squares, ops)
  end

  def build_ranges([], x_stops, y_stops, ops) do
    x_stops =
      x_stops
      |> Enum.uniq()
      |> Enum.sort()

    y_stops =
      y_stops
      |> Enum.uniq()
      |> Enum.sort()

    {x_stops, y_stops, ops}
  end

  def build_ranges([head | tail], x_stops, y_stops, ops) do
    {op, {x0, y0, x1, y1}} = parse_instruction(head)

    build_ranges(
      tail,
      x_stops ++ [x0, x1 + 1],
      y_stops ++ [y0, y1 + 1],
      ops ++ [{op, x0..x1, y0..y1}]
    )
  end

  def next_stop(stops, i) when i == length(stops) - 1 do
    1000
  end

  def next_stop(stops, i) do
    Enum.at(stops, i + 1)
  end

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

  def walk(squares, ops) do
    Enum.reduce(squares, 0, fn {point, size}, acc ->
      if walk_point(point, ops), do: acc + size, else: acc
    end)
  end

  def walk_point({x, y}, ops) do
    Enum.reduce(ops, false, fn {op, x_range, y_range}, acc ->
      if Enum.member?(x_range, x) && Enum.member?(y_range, y) do
        case op do
          :on -> true
          :off -> false
          :toggle -> !acc
        end
      else
        acc
      end
    end)
  end
end
