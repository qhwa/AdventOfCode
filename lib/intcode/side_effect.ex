defmodule Intcode.SideEffect do
  @moduledoc """
  SideEffect module represents the result we get after running instruction.

  For instance,
  - `%SideEffect{mem: %{1 => 5}}` means set vaule to `5` at address `1`;
  - `%SideEffect{buffer: []}` means clear the input buffer;
  - `%SideEffect{pt: 5}` means advance the program pointer by 5;
  - `%SideEffect{pt: {:goto, 50}}` means set the program pointer to 50;
  - `%SideEffect{rel_pt: 123}` means set the program **relative pointer** to 123;
  """
  defstruct [:mem, :buffer, :pt, :rel_pt]
end
