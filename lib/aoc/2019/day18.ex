defmodule AOC.Y2019.Day18 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/18
  """

  defguard is_door(char) when char in ?A..?Z
  defguard is_key(char) when char in ?a..?z

  def p1 do
    "priv/data/2019/day18.txt"
    |> File.read!()
    |> parse()
    |> IO.inspect()
    |> find_best_solution()
  end

  def p2 do
  end

  def example do
    """
    #################
    #i.G..c...e..H.p#
    ########.########
    #j.A..b...f..D.o#
    ########@########
    #k.E..a...g..B.n#
    ########.########
    #l.F..d...h..C.m#
    #################
    """
    |> parse()
    |> find_best_solution()
  end

  @max_generations 1000
  @generation_size 100

  defp find_best_solution(game, solutions \\ build_solutions(), current \\ nil, gen \\ 0)

  defp find_best_solution(_, _, current, @max_generations) do
    current
  end

  defp find_best_solution(game, solutions, _current, gen) do
    solutions
    |> Enum.map(&rate(&1, game))
    |> Enum.sort()
    |> case do
      [{score, order} | _] = solutions ->
        IO.inspect({score, order |> Enum.join()}, label: "gen ##{gen}")

        best5 =
          Enum.take(solutions, 5)
          |> Enum.map(&elem(&1, 1))
          |> Enum.map(&build_seq/1)

        new_solutions = build_new_solutions(solutions, @generation_size)

        find_best_solution(game, best5 ++ new_solutions, order, gen + 1)
    end
  end

  defp build_solutions do
    for _ <- 1..@generation_size, do: build_seq()
  end

  defp build_seq(preset \\ []) do
    Stream.concat(preset, Stream.repeatedly(fn -> :random end))
  end

  defp rate(solution, initial_game) do
    solution
    |> Enum.reduce_while({initial_game, [], 0}, fn key, {game, collection, step} ->
      {_pos, map, doors, keys} = game

      case cached_search_keys(game) do
        empty when empty == %{} ->
          {:halt, {step, collection |> Enum.reverse()}}

        %{^key => distance} ->
          new_game = {
            keys[key],
            map,
            Map.put(doors, key, :open),
            Map.delete(keys, key)
          }

          {:cont, {new_game, [key | collection], step + distance}}

        seen ->
          {key, distance} = Enum.random(seen)

          new_game = {
            keys[key],
            map,
            Map.put(doors, key, :open),
            Map.delete(keys, key)
          }

          {:cont, {new_game, [key | collection], step + distance}}
      end
    end)
  end

  defp build_new_solutions(old_solutions, size, new_solutions \\ [])

  defp build_new_solutions(_, size, new_solutions)
       when size == length(new_solutions) do
    new_solutions |> Enum.map(&build_seq/1)
  end

  defp build_new_solutions(old_solutions, size, new_solutions) do
    old_seqs = Enum.map(old_solutions, fn {_, seq} -> seq end)
    sol = gen_new_solution(old_solutions, old_seqs)

    build_new_solutions(old_solutions, size, [sol | new_solutions])
  end

  defp gen_new_solution(old_solutions, old_seqs) do
    seq = bear(old_solutions)

    if Enum.member?(old_seqs, seq) do
      gen_new_solution(old_solutions, old_seqs)
    else
      seq
    end
  end

  defp parse(str, pos \\ {0, 0}, map \\ %{}, doors \\ %{}, keys \\ %{}, entrance \\ nil)

  defp parse("", _, map, doors, keys, entrance), do: {entrance, map, doors, keys}

  defp parse("\n" <> rest, {_, y}, map, doors, keys, entrance) do
    parse(rest, {0, y + 1}, map, doors, keys, entrance)
  end

  defp parse("@" <> rest, {x, y}, map, doors, keys, _) do
    map = map |> Map.put({x, y}, :open)
    parse(rest, {x + 1, y}, map, doors, keys, {x, y})
  end

  defp parse("." <> rest, {x, y}, map, doors, keys, entrance) do
    map = map |> Map.put({x, y}, :open)
    parse(rest, {x + 1, y}, map, doors, keys, entrance)
  end

  defp parse(<<c, rest::binary>>, {x, y}, map, doors, keys, entrance) when is_key(c) do
    map = map |> Map.put({x, y}, {:key, <<c>>})
    keys = keys |> Map.put(<<c>>, {x, y})
    parse(rest, {x + 1, y}, map, doors, keys, entrance)
  end

  defp parse(<<c, rest::binary>>, {x, y}, map, doors, keys, entrance) when is_door(c) do
    map = map |> Map.put({x, y}, {:door, <<c + 32>>})
    doors = doors |> Map.put(<<c + 32>>, :locked)
    parse(rest, {x + 1, y}, map, doors, keys, entrance)
  end

  defp parse(<<_, rest::binary>>, {x, y}, map, doors, keys, entrance) do
    parse(rest, {x + 1, y}, map, doors, keys, entrance)
  end

  defp cached_search_keys({pos, _map, doors, keys} = game) do
    cache_key = {pos, doors, keys}

    case Process.get(cache_key) do
      nil ->
        ret = search_keys(game)
        Process.put(cache_key, ret)
        ret

      any ->
        any
    end
  end

  defp search_keys({pos, map, doors, keys}) do
    visited = []
    queue = :queue.from_list([{0, pos}])
    seen = %{}

    search_keys(pos, map, doors, keys, seen, visited, queue)
  end

  defp search_keys(_p, map, doors, keys, seen, visited, queue) do
    case :queue.out(queue) do
      {{:value, {step, p}}, old_q} ->
        # IO.inspect({p, open_neighbours(p, map, doors, visited)}, label: :neighbours)

        case map do
          %{^p => {:key, k}} when is_map_key(keys, k) and not is_map_key(seen, k) ->
            visited = [p | visited]
            seen = Map.put(seen, k, step)
            search_keys(p, map, doors, keys, seen, visited, old_q)

          _ ->
            visited = [p | visited]

            next_q =
              p
              |> open_neighbours(map, doors, visited)
              |> enqueue_neighbours(step, old_q)

            search_keys(p, map, doors, keys, seen, visited, next_q)
        end

      {:empty, _} ->
        seen
    end
  end

  defp open_neighbours({x0, y0}, map, doors, visited) do
    neighbours = [{x0 - 1, y0}, {x0 + 1, y0}, {x0, y0 - 1}, {x0, y0 + 1}] -- visited

    for pos <- neighbours, open?(map, doors, pos) do
      pos
    end
  end

  defp open?(map, doors, pos) do
    case Map.get(map, pos, false) do
      false ->
        false

      :open ->
        true

      {:key, _} ->
        true

      {:door, d} ->
        door_open?(doors, d)
    end
  end

  defp door_open?(doors, name) do
    Map.get(doors, name) == :open
  end

  defp enqueue_neighbours(neighbours, step, q) do
    Enum.reduce(neighbours, q, &:queue.in({step + 1, &1}, &2))
  end

  defp bear(solutions) do
    bear(get_one(solutions), get_one(solutions))
  end

  @cross_rate 0.7
  @mutate_rate 0.05

  defp bear(p1, p2) do
    p1 =
      if :rand.uniform() < @cross_rate do
        cross(p1, p2)
      else
        p1
      end

    if :rand.uniform() < @mutate_rate do
      mutate(p1)
    else
      p1
    end
  end

  defp cross(seq1, seq2) do
    len = length(seq1)
    p1 = :rand.uniform(len) - 1
    p2 = trunc(:rand.uniform() * (len - p1 + 1)) + p1

    Enum.slice(seq1, 0..(p1 - 1)) ++
      Enum.slice(seq2, p1..p2) ++
      Enum.slice(seq1, (p2 + 1)..(len - 1))
  end

  defp mutate(seqs) do
    len = length(seqs)
    p1 = :rand.uniform(len) - 1
    p2 = :rand.uniform(len) - 1
    [p1, p2] = Enum.sort([p1, p2])

    if p1 == p2 do
      mutate(seqs)
    else
      case :rand.uniform(4) do
        1 ->
          seqs
          |> List.replace_at(p1, Enum.at(seqs, p2))
          |> List.replace_at(p2, Enum.at(seqs, p1))

        2 ->
          Enum.slice(seqs, 0..(p1 - 1)) ++
            (Enum.slice(seqs, p1..p2) |> Enum.reverse()) ++ Enum.slice(seqs, (p2 + 1)..(len - 1))

        3 ->
          Enum.slice(seqs, 0..(p1 - 1)) ++
            Enum.slice(seqs, (p2 + 1)..(len - 1)) ++ Enum.slice(seqs, p1..p2)

        4 ->
          Enum.slice(seqs, p1..p2) ++
            Enum.slice(seqs, 0..(p1 - 1)) ++ Enum.slice(seqs, (p2 + 1)..(len - 1))
      end
    end
  end

  defp get_one(solutions) do
    solutions =
      solutions
      |> Enum.map(fn {rating, actions} ->
        {rating_to_score(rating), actions}
      end)

    max =
      solutions
      |> Stream.map(&elem(&1, 0))
      |> Enum.sum()
      |> :rand.uniform()

    solutions
    |> Enum.reduce_while(max, fn {score, actions}, count ->
      if count > score do
        {:cont, count - score}
      else
        {:halt, actions}
      end
    end)
  end

  defp rating_to_score(rating) do
    10000 - rating
  end
end
