defmodule AOC.Task.Day21 do
  @moduledoc """
  @see https://adventofcode.com/2115/day/21
  """

  @boss {109, 8, 2}

  # 1
  @weapons [
    # Cost  Damage  Armor
    {:Dagger, {8, 4, 0}},
    {:Shortsword, {10, 5, 0}},
    {:Warhammer, {25, 6, 0}},
    {:Longsword, {40, 7, 0}},
    {:Greataxe, {74, 8, 0}}
  ]

  # 0 - 1
  @armor [
    # Cost  Damage  Armor
    nil,
    {:Leather, {13, 0, 1}},
    {:Chainmail, {31, 0, 2}},
    {:Splintmail, {53, 0, 3}},
    {:Bandedmail, {75, 0, 4}},
    {:Platemail, {102, 0, 5}}
  ]

  # 0 - 2
  @rings [
    # Cost  Damage  Armor
    nil,
    nil,
    {:Damage_1, {25, 1, 0}},
    {:Damage_2, {50, 2, 0}},
    {:Damage_3, {100, 3, 0}},
    {:Defense_1, {20, 0, 1}},
    {:Defense_2, {40, 0, 2}},
    {:Defense_3, {80, 0, 3}}
  ]

  @boss {109, 8, 2}

  def puzzle do
    for w <- @weapons, ar <- @armor, ring1 <- @rings, ring2 <- @rings -- [ring1] do
      [w, ar, ring1, ring2]
    end
    |> Enum.filter(fn items ->
      {d, a} = sum_stats(items)
      win?({100, d, a}, @boss)
    end)
    |> Enum.min_by(&cost/1)
    |> cost()
    |> IO.puts()
  end

  def sum_stats(nil) do
    {0, 0}
  end

  def sum_stats({_, {_cost, d, a}}) do
    {d, a}
  end

  def sum_stats([]) do
    {0, 0}
  end

  def sum_stats([head | tail]) do
    {hd, ha} = sum_stats(head)
    {d, a} = sum_stats(tail)
    {hd + d, ha + a}
  end

  def win?({hp, dmg, armr}, {boss_hp, boss_dmg, boss_armr}) do
    player_rounds = ceil(hp / max(boss_dmg - armr, 1))
    boss_rounds = ceil(boss_hp / max(dmg - boss_armr, 1))
    player_rounds >= boss_rounds
  end

  def cost([]) do
    0
  end

  def cost(nil) do
    0
  end

  def cost({_, {c, _, _}}) do
    c
  end

  def cost([head | tail]) do
    cost(head) + cost(tail)
  end
end
