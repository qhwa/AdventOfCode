defmodule Y2021.Day04 do
  def p1 do
    [{[number | _], boards}] =
      parse_input()
      |> Stream.iterate(fn {[n | rest], boards} ->
        {rest, mark(boards, n)}
      end)
      |> Stream.take_while(fn
        {[], _} -> false
        {_, []} -> false
        {_, boards} -> winner(boards) == nil
      end)
      |> Stream.take(-1)
      |> Enum.to_list()

    boards
    |> mark(number)
    |> winner()
    |> to_score(number)
  end

  def p2 do
    [{[number | _], boards}] =
      parse_input()
      |> Stream.iterate(fn {[n | rest], boards} ->
        {rest, mark(boards, n) |> Enum.reject(&won?/1)}
      end)
      |> Stream.take_while(fn
        {[], _} -> false
        {_, []} -> false
        {_, boards} -> winner(boards) == nil
      end)
      |> Stream.take(-1)
      |> Enum.to_list()

    boards
    |> mark(number)
    |> winner()
    |> to_score(number)
  end

  defp parse_input do
    AOC.Input.stream("2021/day04.txt")
    |> Enum.to_list()
    |> parse_input()
  end

  defp parse_input([seqs, "" | boards]) do
    {parse_seqs(seqs), parse_boards(boards)}
  end

  defp parse_seqs(line) do
    line |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  defp parse_boards([]) do
    []
  end

  defp parse_boards(["" | rest]) do
    parse_boards(rest)
  end

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
      &Map.new(&1, fn
        {pos, ^n} -> {pos, :taken}
        other -> other
      end)
    )
  end

  defp winner(boards) do
    boards |> Enum.find(&won?/1)
  end

  defp won?(board) do
    points = for x <- 0..4, y <- 0..4, do: {x, y}

    Enum.any?(points, fn pos ->
      col_taken?(board, pos) or row_taken?(board, pos)
    end)
  end

  defp col_taken?(board, {x, _}) do
    Enum.all?(0..4, fn y -> pos_taken?(board, {x, y}) end)
  end

  defp row_taken?(board, {_, y}) do
    Enum.all?(0..4, fn x -> pos_taken?(board, {x, y}) end)
  end

  defp pos_taken?(board, pos),
    do: Map.get(board, pos) == :taken

  defp to_score(board, number) do
    board
    |> Stream.map(fn
      {_pos, n} when is_integer(n) -> n
      _ -> 0
    end)
    |> Enum.to_list()
    |> Enum.sum()
    |> Kernel.*(number)
  end
end

Y2021.Day04.p1() |> IO.inspect(label: "part 1")
Y2021.Day04.p2() |> IO.inspect(label: "part 2")
