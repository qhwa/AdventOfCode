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
    |> Enum.max_by(fn {deer, dist} -> dist end)
  end

  def distance_after(deer, time) do
    {speed, dur, cd} = Keyword.get(@stats, deer)

    laps = div(time, dur + cd)
    t = rem(time, dur + cd)

    {deer, min(t, dur) * speed + laps * dur * speed}
  end
end
