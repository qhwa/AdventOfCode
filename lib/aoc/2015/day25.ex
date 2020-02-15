defmodule AOC.Y2015.Day25 do
  @start 20_151_125
  # row 2947, column 3029
  @target {3028, 2946}

  def p1 do
    Stream.iterate({@start, {0, 0}}, fn {prev, pos} ->
      next_pos =
        case pos do
          {x, 0} ->
            {0, x + 1}

          {x, y} ->
            {x + 1, y - 1}
        end

      {next_value(prev), next_pos}
    end)
    |> Stream.drop_while(fn {_, pos} -> pos != @target end)
    |> Enum.take(1)
    |> hd()
  end

  defp next_value(prev) do
    rem(prev * 252_533, 33_554_393)
  end
end
