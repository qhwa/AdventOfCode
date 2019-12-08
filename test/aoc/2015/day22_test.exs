defmodule Day22Test do
  import AOC.Y2015.Day22

  use ExUnit.Case

  @hero %{hp: 10, mana: 100, armor: 0}
  @boss %{hp: 20, damage: 5}

  @spells [
    magic_missile: 53,
    drain: 73,
    shield: 113,
    poison: 173,
    recharge: 229
  ]

  describe "possible_spells/2" do
    test "it works" do
      assert possible_spells(2, []) == :none
      assert possible_spells(53, []) == {:ok, [magic_missile: 53]}
    end
  end

  describe "cast/3" do
    test "wait" do
      assert cast({:wait, 0}, @hero, @boss) == {
               @hero,
               @boss,
               []
             }
    end

    test "shield" do
      assert cast({:shield, 50}, @hero, @boss) == {
               %{hp: 10, mana: 50, armor: 7},
               @boss,
               [shield: 6]
             }
    end
  end
end
