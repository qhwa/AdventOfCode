defmodule AOC.Task.Day22 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/22
  """

  @boss %{hp: 71, damage: 10}
  @hero %{hp: 50, armor: 0, mana: 500}

  @spells [
    magic_missile: 53,
    drain: 73,
    shield: 113,
    poison: 173,
    recharge: 229
  ]

  def puzzle do
    @spells
    |> Helper.MyList.perms()
    |> Enum.map(fn perm ->
      perm
      |> emu_game(@hero, @boss, [], :hero)
    end)
  end

  def emu_game(_, %{hp: hp}, _, _, _) when hp <= 0 do
    :lose
  end

  def emu_game(_, _, %{hp: hp}, _, _) when hp <= 0 do
    :win
  end

  def emu_game([], _, _, _, :hero) do
    :unknow
  end

  def emu_game([spell | tail], hero, boss, effects, :hero) do
    # step 1: apply effects
    {effects, {h, b}} = take_effects(effects, hero, boss)

    # step 2: attack!
    case cast_spell(spell, h, b, effects) do
      {hero, boss, new_effects} ->
        {_, cost} = spell

        emu_game(
          tail,
          Map.update!(hero, :mana, &(&1 - cost)),
          boss,
          effects ++ new_effects,
          :boss
        )

      ret when is_atom(ret) ->
        ret
    end
  end

  def emu_game(spells, hero, boss, effects, :boss) do
    # step 1: apply effects
    {effects, {h, b}} = take_effects(effects, hero, boss)

    # step 2: attack!
    case boss_attack(b, h) do
      :lose ->
        :lose

      hero ->
        emu_game(spells, hero, boss, effects, :hero)
    end
  end

  def take_effects(effects, hero, boss) do
    effects
    |> Enum.flat_map_reduce({hero, boss}, fn {effect, t}, {h, b} ->
      apply_effect({effect, t - 1}, h, b)
    end)
  end

  def apply_effect({:shield, 0}, hero, boss) do
    {
      [],
      {%{hero | armor: 0}, boss}
    }
  end

  def apply_effect({:shield, _} = effect, hero, boss) do
    {
      [effect],
      {%{hero | armor: 7}, boss}
    }
  end

  def apply_effect({_, 0}, hero, boss) do
    {
      [],
      {hero, boss}
    }
  end

  def apply_effect({:drain, _} = effect, hero, boss) do
    {
      [effect],
      {
        Map.update!(hero, :hp, &(&1 + 2)),
        Map.update!(boss, :hp, &(&1 - 2))
      }
    }
  end

  def apply_effect({:poison, _} = effect, hero, boss) do
    {
      [effect],
      {
        hero,
        Map.update!(boss, :hp, &(&1 - 3))
      }
    }
  end

  def apply_effect({:recharge, _} = effect, hero, boss) do
    {
      [effect],
      {
        Map.update!(hero, :mana, &(&1 + 101)),
        boss
      }
    }
  end

  def cast_spell({name, _} = spell, hero, boss, effects) do
    if Keyword.has_key?(effects, name) do
      :effect_already_exists
    else
      cast_spell(spell, hero, boss)
    end
  end

  def cast_spell(_, _, %{hp: hp}) when hp <= 0 do
    :win
  end

  def cast_spell({_name, cost}, %{mana: mana}, _boss) when cost > mana do
    :out_of_mana
  end

  def cast_spell({:magic_missile, _}, hero, boss) do
    {
      hero,
      Map.update!(boss, :hp, &(&1 - 4)),
      []
    }
  end

  def cast_spell({:drain, _}, hero, boss) do
    {
      hero
      |> Map.update!(:hp, &(&1 + 2)),
      boss
      |> Map.update!(:hp, &(&1 - 2)),
      []
    }
  end

  def cast_spell({:shield, _}, hero, boss) do
    {
      hero,
      boss
      |> Map.update!(:hp, &(&1 - 2)),
      [shield: 6]
    }
  end

  def cast_spell({:poison, _}, hero, boss) do
    {hero, boss, [poison: 6]}
  end

  def cast_spell({:recharge, _}, hero, boss) do
    {hero, boss, [recharge: 5]}
  end

  def boss_attack(%{damage: damage}, %{hp: hp, armor: armor} = hero) do
    dmg = max(armor - damage, 1)

    case hp - dmg do
      x when x <= 0 ->
        :lose

      x ->
        %{hero | hp: x}
    end
  end
end
