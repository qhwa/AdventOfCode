defmodule Y2019.Day05Test do
  import AOC.Y2019.Day05
  import Helper.MyList

  use ExUnit.Case

  describe "run_program/1" do
    test "it works" do
      assert r([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], 8) == [1]
      assert r([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], 2) == [0]

      assert r([3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], 7) == [1]
      assert r([3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], 9) == [0]

      assert r([3, 3, 1108, -1, 8, 3, 4, 3, 99], 9) == [0]
      assert r([3, 3, 1108, -1, 8, 3, 4, 3, 99], 8) == [1]

      assert r([3, 3, 1107, -1, 8, 3, 4, 3, 99], 9) == [0]
      assert r([3, 3, 1107, -1, 8, 3, 4, 3, 99], 7) == [1]
    end

    test "jumps work" do
      assert r([3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9], 3) == [1]
      assert r([3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9], 0) == [0]
    end

    test "integration" do
      p = [
        3,
        21,
        1008,
        21,
        8,
        20,
        1005,
        20,
        22,
        107,
        8,
        21,
        20,
        1006,
        20,
        31,
        1106,
        0,
        36,
        98,
        0,
        0,
        1002,
        21,
        125,
        20,
        4,
        20,
        1105,
        1,
        46,
        104,
        999,
        1105,
        1,
        46,
        1101,
        1000,
        1,
        20,
        4,
        20,
        1105,
        1,
        46,
        98,
        99
      ]

      assert r(p, 8) == [1000]
      assert r(p, 1) == [999]
      assert r(p, 9) == [1001]
    end
  end

  defp r(program, input) do
    program
    |> to_map()
    |> run(%{pointer: 0, input: input, output: []})
  end
end
