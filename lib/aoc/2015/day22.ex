defmodule AOC.Y2015.Day22 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/22
  """

  require Logger

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
    Logger.configure(level: :warn)
    # example 1
    # hero = %{hp: 10, armor: 0, mana: 250}
    # boss = %{hp: 13, damage: 8}

    # example 2
    hero = %{hp: 10, armor: 0, mana: 250}
    boss = %{hp: 14, damage: 8}

    [{0, hero, boss, [], []}]
    |> iterate()
    |> Enum.find(&win?/1)
    |> replay(hero, boss)
  end

  def p1 do
    Logger.configure(level: :warn)

    [{0, @hero, @boss, [], []}]
    |> iterate()
    |> Enum.find(&win?/1)
  end

  defp iterate(solutions, step \\ 0) do
    ret =
      solutions
      |> Enum.flat_map(fn
        {round, hero, boss, effects, used_spells} ->
          case possible_spells(hero.mana, effects) do
            {:ok, spells} ->
              for spell <- spells do
                play_round(round, spell, hero, boss, effects, used_spells)
              end

            _ ->
              []
          end

        {_, :lose, _} ->
          []

        other ->
          [other]
      end)

    if continue?(ret) do
      iterate(ret, step + 1)
    else
      ret
    end
  end

  def possible_spells(mana, effects) do
    spells =
      for {name, cost} <- @spells, cost <= mana, Keyword.get(effects, name, 0) == 0 do
        {name, cost}
      end

    case {spells, effects} do
      {[], []} ->
        Logger.info("player loses because out of mana (#{mana}), and non effects available")
        :none

      _ ->
        {:ok, spells}
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

    Logger.debug("-- Player turn --")
    Logger.debug("- Player has #{hero.hp} hit points, #{hero.armor} armor, #{hero.mana} mana")
    Logger.debug("- Boss has #{boss.hp} hit points")

    with {1, {effects, {h, b}}} <- {1, take_effects(effects, hero, boss, solution)},
         {:boss_alive, true} <- {:boss_alive, b.hp > 0},
         # IO.inspect("boss still alive after effects", label: round),

         {2, {h, b, new_effects}} <- {2, cast({name, cost}, h, b)},
         {:boss_alive, true} <- {:boss_alive, b.hp > 0},
         # IO.inspect("hero still alive after boss attack", label: round),

         Logger.debug("-- Boss turn --"),
         Logger.debug("- Player has #{h.hp} hit points, #{h.armor} armor, #{h.mana} mana"),
         Logger.debug("- Boss has #{b.hp} hit points"),
         {3, {effects, {h, b}}} <- {3, take_effects(effects ++ new_effects, h, b, solution)},
         {:boss_alive, true} <- {:boss_alive, b.hp > 0},
         # IO.inspect("hero still alive after boss attack", label: round) do

         {4, h} <- {4, boss_attack(b, h)},
         {:hero_alive, true} <- {:hero_alive, h.hp > 0} do
      # IO.inspect("hero still alive after boss attack", label: round) do

      # IO.inspect("#{inspect(effects ++ new_effects)} after casting #{inspect name}", label: round)
      {
        round + 1,
        h,
        b,
        effects,
        [name | solution]
      }
    else
      {:boss_alive, false} ->
        Logger.debug("win after #{inspect([name | solution])}")
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
        {:shield, 1} ->
          Logger.debug("Shield wears off, decreasing armor by 7.")
          {[], {%{hero | armor: 0}, boss}}

        {name, 1} ->
          Logger.debug("#{name} wears off.")
          {[], {hero, boss}}

        {name, t} ->
          {[{name, t - 1}], {hero, boss}}
      end
    end)
  end

  def apply_effect({:shield, t}, hero, boss) do
    Logger.debug("Shield's timer is now #{t - 1}.")
    {%{hero | armor: 7}, boss}
  end

  def apply_effect({name, 0}, hero, boss) do
    Logger.debug("#{name} wears off.")
    {hero, boss}
  end

  def apply_effect({:poison, t}, hero, boss) do
    Logger.debug("Poison deals 3 damage; its timer is now #{t - 1}.")

    {
      hero,
      Map.update!(boss, :hp, &(&1 - 3))
    }
  end

  def apply_effect({:recharge, t}, hero, boss) do
    Logger.debug("Recharge provides 101 mana; its timer is now #{t - 1}.")

    {
      Map.update!(hero, :mana, &(&1 + 101)),
      boss
    }
  end

  def cast({:magic_missile, cost}, hero, boss) do
    Logger.debug("Player casts Magic Missile, dealing 4 damage.")

    {
      hero |> Map.update!(:mana, &(&1 - cost)),
      boss |> Map.update!(:hp, &(&1 - 4)),
      []
    }
  end

  def cast({:drain, cost}, hero, boss) do
    Logger.debug("Player casts Drain, dealing 2 damage, and healing 2 hit points.")

    {
      hero |> Map.update!(:hp, &(&1 + 2)) |> Map.update!(:mana, &(&1 - cost)),
      boss |> Map.update!(:hp, &(&1 - 2)),
      []
    }
  end

  def cast({:shield, cost}, hero, boss) do
    Logger.debug("Player casts Shield, increasing armor by 7.")

    {
      hero |> Map.put(:armor, 7) |> Map.update!(:mana, &(&1 - cost)),
      boss,
      [shield: 6]
    }
  end

  def cast({:poison, cost}, hero, boss) do
    Logger.debug("Player casts Poison.")

    {
      hero |> Map.update!(:mana, &(&1 - cost)),
      boss,
      [poison: 6]
    }
  end

  def cast({:recharge, cost}, hero, boss) do
    Logger.debug("Player casts Recharge.")

    {
      hero |> Map.update!(:mana, &(&1 - cost)),
      boss,
      [recharge: 5]
    }
  end

  defp boss_attack(%{damage: damage}, %{hp: hp, armor: armor} = hero) do
    dmg = max(damage - armor, 1)
    Logger.debug("Boss attacks for #{damage} - #{armor} = #{dmg} damage!")
    %{hero | hp: hp - dmg}
  end

  defp continue?(solutions) do
    should_halt = Enum.any?(solutions, &win?/1) || Enum.all?(solutions, &lose?/1)
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
    Logger.configure(level: :debug)
    Logger.debug("--------------- replay --------")

    spells
    |> Enum.reverse()
    |> Enum.reduce({0, hero, boss, [], []}, fn spell, {round, hero, boss, effects, _} ->
      play_round(round, {spell, Keyword.get(@spells, spell)}, hero, boss, effects, [])
    end)
  end
end
