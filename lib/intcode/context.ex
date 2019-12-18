defmodule Intcode.Context do
  @moduledoc """
  Context module represents the program running context. Every context has
  following keys:

  - `pointer`: cursor of the program currently pointing at;
  - `rel_pointer`: the relative pointer cursor;
  - `input`: the input buffer;
  - `downstream`: where output will be sent. when `downstream` is nil, 
    output saved in `output` message buffer for further read. The buffer
    will be cleared after read.
  """
  defstruct pointer: 0, rel_pointer: 0, input: [], downstream: nil, output: []
end
