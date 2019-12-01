defmodule AOC.Y2015.Day13 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/13
  """

  @format ~r/(\w+) .+ (lose|gain) (\d+) .+ (\w+)\.$/

  @relations "priv/data/2015/day13.txt"
             |> File.stream!()
             |> Stream.map(fn line ->
               case Regex.run(@format, line) do
                 [_, person, "lose", value, neighbor] ->
                   {
                     :"#{person}_#{neighbor}",
                     -String.to_integer(value)
                   }

                 [_, person, "gain", value, neighbor] ->
                   {
                     :"#{person}_#{neighbor}",
                     String.to_integer(value)
                   }
               end
             end)
             |> Enum.into(%{})

  @people ~w[Alice Bob Carol David Eric Frank George Mallory]

  def puzzle() do
    [:me | @people]
    |> build_arrs()
    |> walk()
    |> Enum.max_by(fn {_arr, score} -> score end)
  end

  def build_arrs([person]) do
    [[person]]
  end

  def build_arrs(people) do
    people
    |> Enum.flat_map(fn person ->
      people
      |> Enum.reject(&(&1 == person))
      |> build_arrs()
      |> Enum.map(&[person | &1])
    end)
  end

  def walk(list) do
    list
    |> Enum.map(&{&1, arr_score(&1)})
  end

  def arr_score(arr) do
    count = length(arr)
    init = {0, List.last(arr), Enum.at(arr, 1)}

    {score, _, _} =
      arr
      |> Enum.with_index()
      |> Enum.reduce(init, fn {person, index}, {total, prev, next} ->
        {
          total + relation(person, prev) + relation(person, next),
          person,
          Enum.at(arr, rem(index + 2, count))
        }
      end)

    score
  end

  defp relation(:me, _), do: 0
  defp relation(_, :me), do: 0

  defp relation(a, b) do
    @relations
    |> Map.get(:"#{a}_#{b}")
  end
end
