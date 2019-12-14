defmodule AOC.Helper.Operator do
  @moduledoc """
  This define some handy operations for use of providing cleaner code.
  """

  defmacro __using__(_opts) do
    quote do
      @doc """
      Add two tuples together.

      ## Examples:

      iex> {1, 2} + {3, 4}
      {4, 6}

      iex> {10, 2, -7} + {-1, -2, -3}
      {9, 0, -10}
      """
      def {a1, b1} + {a2, b2}, do: {a1 + a2, b1 + b2}
      def {a1, b1, c1} + {a2, b2, c2}, do: {a1 + a2, b1 + b2, c1 + c2}

      def left + right do
        Kernel.+(left, right)
      end
    end
  end
end
