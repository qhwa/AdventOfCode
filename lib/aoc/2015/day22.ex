defmodule AOC.Y2015.Day22 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/22
  """

  @hero %{hp: 50, armor: 0, mana: 500}
  @boss %{hp: 71, damage: 10}

  @spells [
    magic_missile: 53,
    drain: 73,
    shield: 113,
    poison: 173,
    recharge: 229
  ]

  def example do
    # eample 1
    # hero = %{hp: 10, armor: 0, mana: 250}
    # boss = %{hp: 13, damage: 8}

    # eample 2
    hero = %{hp: 10, armor: 0, mana: 250}
    boss = %{hp: 14, damage: 8}

    [{0, hero, boss, [], []}]
    |> Stream.iterate(&map_next_round/1)
    |> Stream.take_while(&continue?/1)
    |> Enum.to_list()
    |> List.flatten()
    |> Enum.find(&win?/1)
    |> replay(hero, boss)
  end

  def p1 do
    [{0, @hero, @boss, [], []}]
    |> Stream.iterate(&map_next_round/1)
    |> Stream.take_while(&continue?/1)
    |> Enum.to_list()
    |> List.flatten()
    |> Enum.find(&win?/1)
  end

  defp map_next_round(solutions) do
    solutions
    |> Enum.flat_map(fn
      {round, hero, boss, effects, used_spells} ->
        for spell <- possible_spells(hero.mana, effects) do
          case spell do
            :none ->
              {round, :lose, used_spells}

            _ ->
              play_round(round, spell, hero, boss, effects, used_spells)
          end
        end

      {_round, :win, _used} ->
        [:halt]

      other ->
        [other]
    end)
  end

  defp possible_spells(mana, effects) do
    spells =
      for {name, cost} <- @spells, cost <= mana, Keyword.get(effects, name, 0) == 0 do
        {name, cost}
      end

    case {spells, effects} do
      {[], []} ->
        # IO.puts("player loses because out of mana (#{mana}), and non effects available")
        [:none]

      {[], _} ->
        [wait: 0]

      _ ->
        spells
    end
  end

  # win
  defp play_round(round, _, _, %{hp: boss_hp}, _, solution) when boss_hp <= 0 do
    {round, :win, solution}
  end

  # lose
  defp play_round(round, _, %{hp: hp}, _, _, solution) when hp <= 0 do
    {round, :lose, solution}
  end

  # fight
  defp play_round(round, {name, cost}, hero, boss, effects, solution) do
    # IO.inspect({hero, boss, effects}, label: round)

    IO.puts("-- Player turn --")
    IO.puts("- Player has #{hero.hp} hit points, #{hero.armor} armor, #{hero.mana} mana")
    IO.puts("- Boss has #{boss.hp} hit points")

    with {1, {effects, {h, b}}} <- {1, take_effects(effects, hero, boss, solution)},
         {:boss_alive, true} <- {:boss_alive, b.hp > 0},
         # IO.inspect("boss still alive after effects", label: round),

         {2, {h, b, new_effects}} <- {2, cast(name, h, b)},
         {:boss_alive, true} <- {:boss_alive, b.hp > 0},
         # IO.inspect("hero still alive after boss attack", label: round),

         {3, {effects, {h, b}}} <- {3, take_effects(effects ++ new_effects, h, b, solution)},
         {:boss_alive, true} <- {:boss_alive, b.hp > 0},
         # IO.inspect("hero still alive after boss attack", label: round) do

         {4, h} <- {4, boss_attack(b, h)},
         {:hero_alive, true} <- {:hero_alive, h.hp > 0} do
      # IO.inspect("hero still alive after boss attack", label: round) do

      # IO.inspect("#{inspect(effects ++ new_effects)} after casting #{inspect name}", label: round)
      {
        round + 1,
        h |> Map.update!(:mana, &(&1 - cost)),
        b,
        effects,
        [name | solution]
      }
    else
      {:boss_alive, false} ->
        # IO.puts("win after #{inspect [name | solution]}")
        {round, :win, [name | solution]}

      {:hero_alive, false} ->
        {round, :lose, [name | solution]}
    end
  end

  defp take_effects(effects, hero, boss, _solution) do
    effects
    |> Enum.flat_map_reduce({hero, boss}, fn effect, {h, b} ->
      # IO.inspect(solution, label: inspect(effect))
      {hero, boss} = apply_effect(effect, h, b)

      case effect do
        {_, 0} ->
          {[], {hero, boss}}

        {name, t} ->
          {[{name, t - 1}], {hero, boss}}
      end
    end)
  end

  def apply_effect({:shield, 0}, hero, boss) do
    IO.puts("Shield wears off.")
    {%{hero | armor: 0}, boss}
  end

  def apply_effect({:shield, t}, hero, boss) do
    IO.puts("Shield's timer is now #{t}.")
    {%{hero | armor: 7}, boss}
  end

  def apply_effect({name, 0}, hero, boss) do
    IO.puts("#{name} wears off.")
    {hero, boss}
  end

  def apply_effect({:poison, t}, hero, boss) do
    IO.puts("Poison deals 3 damage; its timer is now #{t}.")

    {
      hero,
      Map.update!(boss, :hp, &(&1 - 3))
    }
  end

  def apply_effect({:recharge, t}, hero, boss) do
    IO.puts("Recharge provides 101 mana; its timer is now #{t}.")

    {
      Map.update!(hero, :mana, &(&1 + 101)),
      boss
    }
  end

  def cast(:wait, hero, boss) do
    {hero, boss, []}
  end

  def cast(:magic_missile, hero, boss) do
    IO.puts("Player casts Magic Missile, dealing 4 damage.")

    {
      hero,
      boss |> Map.update!(:hp, &(&1 - 4)),
      []
    }
  end

  def cast(:drain, hero, boss) do
    IO.puts("Player casts Drain, dealing 2 damage, and healing 2 hit points.")

    {
      hero |> Map.update!(:hp, &(&1 + 2)),
      boss |> Map.update!(:hp, &(&1 - 2)),
      []
    }
  end

  def cast(:shield, hero, boss) do
    {
      hero,
      boss |> Map.update!(:hp, &(&1 - 2)),
      [shield: 6]
    }
  end

  def cast(:poison, hero, boss) do
    {hero, boss, [poison: 6]}
  end

  def cast(:recharge, hero, boss) do
    IO.puts("Player casts Recharge.")
    {hero, boss, [recharge: 5]}
  end

  defp boss_attack(%{damage: damage}, %{hp: hp, armor: armor} = hero) do
    dmg = max(damage - armor, 1)
    IO.puts("Boss attacks for #{damage} - #{armor} = #{dmg} damage!")
    # IO.puts("boss attack: #{hp} -> #{hp - dmg} (shield: #{armor})")
    %{hero | hp: hp - dmg}
  end

  defp continue?(solutions) do
    should_halt = Enum.any?(solutions, &(&1 == :halt)) || Enum.all?(solutions, &lose?/1)
    !should_halt
  end

  defp win?({_, :win, _}) do
    true
  end

  defp win?({_round, :lose, _}) do
    false
  end

  defp win?({_round, _hero, %{hp: boss_hp}, _effects, _}) do
    boss_hp <= 0
  end

  defp win?({_round, _hero, _boss, _effects, _}) do
    false
  end

  defp lose?({_round, :lose, _}) do
    true
  end

  defp lose?(_) do
    false
  end

  defp replay({_, _, spells}, hero, boss) do
    IO.puts("--------------- replay --------")

    spells
    |> Enum.reverse()
    |> Enum.reduce({0, hero, boss, [], []}, fn spell, {round, hero, boss, effects, _} ->
      play_round(round, {spell, Keyword.get(@spells, spell)}, hero, boss, effects, [])
    end)
  end
end
