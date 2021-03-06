defmodule Y2019.Day16Test do
  import AOC.Y2019.Day16
  import Integer, only: [digits: 1]

  use ExUnit.Case

  describe "apply_phase/2" do
    test "it works" do
      assert phase([1, 2, 3, 4, 5, 6, 7, 8], 1) == digits(48_226_158)
      assert phase([1, 2, 3, 4, 5, 6, 7, 8], 2) == digits(34_040_438)
      assert phase([1, 2, 3, 4, 5, 6, 7, 8], 3) == [0 | digits(3_415_518)]
      assert phase([1, 2, 3, 4, 5, 6, 7, 8], 4) == [0 | digits(1_029_498)]

      assert phase(digits(80_871_224_585_914_546_619_083_218_645_595), 100) ==
               digits(24_176_176)

      assert phase(digits(19_617_804_207_202_209_144_916_044_189_917), 100) ==
               digits(73_745_418)

      assert phase(digits(69_317_163_492_948_606_335_995_924_319_873), 100) ==
               digits(52_432_133)
    end
  end

  describe "read_message/1" do
    test "it works" do
      # assert read_message([0 | digits(03036732577212944063491565474664)]) == digits(84462026)
    end
  end

  defp phase(digits, count) do
    apply_phase(digits, count) |> first_eight_digits()
  end
end
