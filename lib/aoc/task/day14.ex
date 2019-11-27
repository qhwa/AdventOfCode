defmodule AOC.Task.Day14 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/14
  """

  @format ~r'(\w+) .+ (\d+) km/s for (\d+) seconds, .+ (\d+) seconds.$'

  @stats "priv/data/day14.txt"
         |> File.stream!()
         |> Stream.map(fn line ->
           case Regex.run(@format, line) do
             [_, name, speed, duration, cooldown] ->
               {:"#{name}",
                {
                  String.to_integer(speed),
                  String.to_integer(duration),
                  String.to_integer(cooldown)
                }}
           end
         end)
         |> Enum.into([])

  @deers ~w[
    Rudolph Cupid Prancer Donner
    Dasher Comet Blitzen Vixen Dancer
  ] |> Enum.map(&String.to_atom/1)

  @race_dur 2503

  def puzzle() do
    @deers
    |> Enum.map(&distance_after(&1, @race_dur))
    |> Enum.max_by(fn {_, dist} -> dist end)
  end

  def puzzle2() do
    init_scores = for _ <- @deers, do: 0

    dists =
      1..2503
      |> Enum.reduce(init_scores, &update_score_at/2)

    {max_score, i} =
      dists
      |> Enum.with_index()
      |> Enum.max_by(fn {score, _} -> score end)

    {Enum.at(@deers, i), max_score}
  end

  defp update_score_at(t, scores) do
    dists = @deers |> Enum.map(&distance_after(&1, t))
    {_, max_dist} = dists |> Enum.max_by(fn {_, dist} -> dist end)

    scores
    |> Enum.with_index()
    |> Enum.map(fn {score, i} ->
      case Enum.at(dists, i) do
        {_, ^max_dist} ->
          score + 1

        _ ->
          score
      end
    end)
  end

  def distance_after(deer, time) do
    {speed, dur, cd} = Keyword.get(@stats, deer)

    laps = div(time, dur + cd)
    t = rem(time, dur + cd)

    {deer, min(t, dur) * speed + laps * dur * speed}
  end
end
