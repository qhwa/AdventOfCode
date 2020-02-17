defmodule AOC.Y2015.Day22 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/22
  """

  defmodule Game do
    @moduledoc false
    defstruct hero: nil, boss: nil, effects: [], mana_used: 0
  end

  require Logger

  @hero %{hp: 50, armor: 0, mana: 500}
  @boss %{hp: 71, max_hp: 71, damage: 10}

  @spells [:magic_missile, :drain, :shield, :poison, :recharge]

  @max_generations 1000
  @generation_size 100

  def p1 do
    deduce(%Game{hero: @hero, boss: @boss})
  end

  def example_1 do
    hero = %{hp: 10, armor: 0, mana: 250}
    boss = %{hp: 13, max_hp: 13, damage: 8}
    deduce(%Game{hero: hero, boss: boss})
  end

  def example_2 do
    hero = %{hp: 10, armor: 0, mana: 250}
    boss = %{hp: 14, max_hp: 14, damage: 8}
    deduce(%Game{hero: hero, boss: boss})
  end

  defp deduce(game, current_best \\ nil, solutions \\ build_seqs(), gen \\ 0)

  defp deduce(_game, best, _, @max_generations) do
    best
  end

  defp deduce(game, _, solutions, gen) do
    solutions
    |> Enum.map(&rate(&1, game))
    |> Enum.uniq()
    |> Enum.sort_by(fn {score, _} -> score end, :desc)
    |> case do
      [{score, best} | _] = rated ->
        IO.inspect({score, best}, label: gen)
        new_ones = for _ <- 1..@generation_size, do: bear(rated) |> build_seq()

        deduce(game, best, [build_seq(best) | new_ones], gen + 1)
    end
  end

  defp build_seqs() do
    # [[:poison, :drain, :magic_missile]]
    # [[:poison, :magic_missile]]
    # [[:recharge, :shield, :drain, :poison, :magic_missile]]
    [
      build_seq([
        :recharge,
        :shield,
        :poison,
        :drain,
        :shield
      ])
    ]

    for _ <- 1..@generation_size, do: build_seq()
  end

  defp build_seq(starting \\ []) do
    Stream.concat(starting, Stream.repeatedly(&random_spell/0))
  end

  defp random_spell() do
    Enum.random(@spells)
  end

  defp rate(solution, game) do
    {game, _turn, spells} =
      solution
      |> Enum.reduce_while({game, 1, []}, fn spell, {game, turn, used_spells} ->
        # IO.puts("**** current spell: #{spell}")

        case play_round(game, spell, turn) do
          {:lose, game, reason} ->
            # IO.inspect(reason, label: :lose)
            {:halt, {game, turn, [spell | used_spells]}}

          {:win, game} ->
            {:halt, {game, turn, [spell | used_spells]}}

          %{} = game ->
            {:cont, {game, turn + 2, [spell | used_spells]}}
        end
      end)

    {score(game), spells |> Enum.reverse()}
  end

  defp score(%{hero: hero, boss: boss, mana_used: mana}) do
    point = (boss.max_hp - boss.hp) * 1000 - mana
    {point, mana, {boss.hp, hero.hp}}
  end

  defp play_round(game, spell, turn) do
    # IO.puts("===> user turn, #{turn}")

    with {:ok, game} <- game |> apply_effects(),
         # IO.inspect(game, label: "before turn #{turn}"),
         {:ok, game} <- game |> check(),
         # IO.puts("---> user casting #{spell}"),
         {:ok, game} <- game |> cast_spell(spell),
         {:ok, game} <- game |> check(),
         # IO.inspect(game, label: "after turn #{turn}"),
         # IO.puts("===> boss turn, #{turn + 1}"),
         {:ok, game} <- game |> apply_effects(),
         {:ok, game} <- game |> check(),
         # IO.inspect(game, label: "before boss attack"),
         {:ok, game} <- game |> boss_attack(),
         {:ok, game} <- game |> check() do
      game
    end
  end

  defp check(%{hero: %{hp: hp}} = game) when hp < 0 do
    {:lose, %{game | hero: %{game.hero | hp: 0}}, :defeated}
  end

  defp check(%{hero: %{mana: mana}} = game) when mana < 0 do
    {:lose, game, :out_of_mana}
  end

  defp check(%{boss: %{hp: hp}} = game) when hp <= 0 do
    {:win, %{game | boss: %{game.boss | hp: 0}}}
  end

  defp check(%{effects: effects} = game) do
    if duplicated_effects?(effects) do
      {:lose, game, :duplicated_effect}
    else
      {:ok, game}
    end
  end

  defp duplicated_effects?(effects) do
    names = effects |> Enum.map(&elem(&1, 0)) |> Enum.sort()
    names != Enum.uniq(names)
  end

  defp apply_effects(%{effects: effects} = game) do
    game = Enum.reduce(effects, game, &apply_effect/2)

    {:ok, %{game | effects: tick_effects(effects)}}
  end

  defp apply_effect({:shield, _}, game) do
    game
  end

  defp apply_effect({:poison, t}, %{boss: boss} = game) do
    # IO.puts("---> poison takes effect, timer #{t}")
    %{game | boss: %{boss | hp: boss.hp - 3}}
  end

  defp apply_effect({:recharge, t}, %{hero: hero} = game) do
    # IO.puts("---> recharge takes effect, timer #{t}")
    %{game | hero: %{hero | mana: hero.mana + 101}}
  end

  defp tick_effects(effects) do
    effects
    |> Enum.map(fn {f, n} -> {f, n - 1} end)
    |> Enum.reject(fn {_, n} -> n == 0 end)
  end

  defp cast_spell(%{hero: hero, boss: boss, effects: effects} = game, spell) do
    no_change = & &1

    %{hero: hero_f, boss: boss_f, effects: effect_f, cost: cost} =
      %{hero: no_change, boss: no_change, effects: no_change}
      |> Map.merge(spell_def(spell))

    game = %{
      game
      | hero: hero_f.(hero) |> Map.update!(:mana, &(&1 - cost)),
        boss: boss_f.(boss),
        effects: effect_f.(effects),
        mana_used: game.mana_used + cost
    }

    {:ok, game}
  end

  defp spell_def(:magic_missile) do
    %{
      cost: 53,
      boss: &%{&1 | hp: &1.hp - 4}
    }
  end

  defp spell_def(:drain) do
    %{
      cost: 73,
      hero: &%{&1 | hp: &1.hp + 2},
      boss: &%{&1 | hp: &1.hp - 2}
    }
  end

  defp spell_def(:shield) do
    %{
      cost: 113,
      effects: &[{:shield, 6} | &1]
    }
  end

  defp spell_def(:poison) do
    %{
      cost: 173,
      effects: &[{:poison, 6} | &1]
    }
  end

  defp spell_def(:recharge) do
    %{
      cost: 229,
      effects: &[{:recharge, 5} | &1]
    }
  end

  defp boss_attack(%{hero: hero, boss: boss, effects: effects} = game) do
    dmg = max(boss.damage - hero.armor - effect_armor(effects), 1)
    # IO.puts("---> boss attack, causing #{dmg} damage")
    {:ok, %{game | hero: %{hero | hp: hero.hp - dmg}}}
  end

  defp effect_armor(effects) do
    if Enum.any?(effects, &(elem(&1, 0) == :shield)) do
      7
    else
      0
    end
  end

  defp bear(solutions) do
    bear(get_one(solutions), get_one(solutions))
  end

  defp bear(p1, p2) do
    p1 =
      if :rand.uniform() < 0.7 do
        cross(p1, p2)
      else
        p1
      end

    if :rand.uniform() < 0.5 do
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
      seqs
    else
      case :rand.uniform(3) do
        1 ->
          seqs
          |> List.replace_at(p1, Enum.at(seqs, p2))
          |> List.replace_at(p2, Enum.at(seqs, p1))

        2 ->
          Enum.slice(seqs, 0..(p1 - 1)) ++
            (Enum.slice(seqs, p1..p2) |> Enum.reverse()) ++ Enum.slice(seqs, p2..(len - 1))

        3 ->
          Enum.slice(seqs, 0..(p1 - 1)) ++
            Enum.slice(seqs, p2..(len - 1)) ++ Enum.slice(seqs, p1..p2)
      end
    end
  end

  defp get_one(solutions) do
    solutions =
      solutions
      |> Enum.map(fn {{a, _, _}, actions} ->
        {a, actions}
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
end
