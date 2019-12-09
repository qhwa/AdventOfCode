defmodule Intcode.Context do
  @moduledoc """
  Context module represents the program running context. Every context has
  following keys:

  - `pointer`: cursor of the program currently pointing at;
  - `rel_pointer`: the relative pointer cursor;
  - `input`: the input buffer;
  - `downstream`: where output will be sent. when `downstream` is null, 
    output is directly printed on screen and discarded.
  """
  defstruct pointer: 0, rel_pointer: 0, input: [], downstream: nil
end
