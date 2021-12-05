defmodule Y2021.Day04 do
  @moduledoc """
  https://adventofcode.com/2021/day/4

  Run with: `mix run lib/aoc/2021/day04.exs`
  """
  def p1 do
    {seqs, boards} = parse_input()

    [{_, n, winner}] =
      Stream.scan(seqs, {boards, nil, nil}, fn n, {boards, _, _} ->
        boards = mark(boards, n)
        winner = winner(boards)
        {boards, n, winner}
      end)
      |> Stream.drop_while(fn {_, _, winner} -> winner == nil end)
      |> Stream.take(1)
      |> Enum.to_list()

    to_score(winner, n)
  end

  def p2 do
    {seqs, boards} = parse_input()

    [{_, n, winner}] =
      Stream.scan(seqs, {boards, nil, nil}, fn n, {boards, _, _} ->
        boards = mark(boards, n)
        winner = winner(boards)
        boards = Enum.reject(boards, &won?/1)
        {boards, n, winner}
      end)
      |> Stream.drop_while(fn {boards, _, _} -> boards != [] end)
      |> Stream.take(1)
      |> Enum.to_list()

    to_score(winner, n)
  end

  defp parse_input do
    AOC.Input.stream("2021/day04.txt")
    |> Enum.to_list()
    |> parse_input()
  end

  defp parse_input([seqs, "" | boards]),
    do: {parse_seqs(seqs), parse_boards(boards)}

  defp parse_seqs(line),
    do: line |> String.split(",") |> Enum.map(&String.to_integer/1)

  defp parse_boards([]),
    do: []

  defp parse_boards(["" | rest]),
    do: parse_boards(rest)

  defp parse_boards(lines) do
    {board_lines, rest} = lines |> Enum.split_while(&(&1 != ""))
    [parse_board(board_lines) | parse_boards(rest)]
  end

  defp parse_board(board_lines) do
    board_lines
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, board ->
      line
      |> String.split(~r/\s+/, trim: true)
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      |> Enum.reduce(board, fn {i, x}, board ->
        Map.put(board, {x, y}, i)
      end)
    end)
  end

  defp mark(boards, n) do
    boards
    |> Enum.map(
      &(Enum.reject(&1, fn
          {_, ^n} -> true
          _ -> false
        end)
        |> Enum.into(%{}))
    )
  end

  defp winner(boards),
    do: boards |> Enum.find(&won?/1)

  defp won?(board) do
    points = for x <- 0..4, do: {x, x}
    Enum.any?(points, &(col_taken?(board, &1) or row_taken?(board, &1)))
  end

  defp col_taken?(board, {x, _}),
    do: Enum.all?(0..4, &pos_taken?(board, {x, &1}))

  defp row_taken?(board, {_, y}),
    do: Enum.all?(0..4, &pos_taken?(board, {&1, y}))

  defp pos_taken?(board, pos),
    do: not Map.has_key?(board, pos)

  defp to_score(board, number),
    do: Map.values(board) |> Enum.sum() |> Kernel.*(number)
end

Y2021.Day04.p1() |> IO.inspect(label: "part 1")
Y2021.Day04.p2() |> IO.inspect(label: "part 2")
