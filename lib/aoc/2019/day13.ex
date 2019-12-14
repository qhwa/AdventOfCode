defmodule AOC.Y2019.Day13 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/13
  """

  alias IO.ANSI

  def p1, do: load_program() |> draw_tiles() |> count()

  # run this game with:
  #
  # $elixir --erl -noinput -S mix run -e AOC.Y2019.Day13.p2
  def p2, do: load_program() |> insert_coin() |> start_game()

  def load_program do
    "priv/data/2019/day13.txt"
    |> Intcode.load_file()
  end

  defp draw_tiles(program) do
    game = Intcode.Computer.start(program, downstream: self())
    Process.register(game, :game)

    listen(%{})
  end

  defp listen(state, printer \\ & &1) do
    with {:ok, x} <- read(),
         {:ok, y} <- read(),
         {:ok, tile_id} <- read() do
      draw(state, {x, y}, tile_id)
      |> printer.()
      |> listen(printer)
    else
      {:halt, _} ->
        state

      {:joystick, input, _} ->
        send(:game, {:data, input, self()})

        state
        |> Map.update({-1, -1}, [input], &[input | &1])
        |> listen(printer)
    end
  end

  defp read do
    receive do
      {:data, data, _} -> {:ok, data}
      other -> other
    end
  end

  defp draw(state, pos, tile_id), do: Map.put(state, pos, tile_id)

  defp count(state) do
    Enum.reduce(state, 0, fn
      {_, 2}, acc -> acc + 1
      _, acc -> acc
    end)
  end

  defp print(state) do
    max_x =
      state
      |> Stream.map(fn {{x, _}, _} -> x end)
      |> Enum.max()

    max_y =
      state
      |> Stream.map(fn {{_, y}, _} -> y end)
      |> Enum.max()

    output =
      for y <- 0..max_y do
        for x <- 0..max_x do
          case Map.get(state, {x, y}, 0) do
            0 -> ' '
            1 -> ?#
            2 -> ?*
            3 -> ?=
            4 -> ?O
          end
        end
      end
      |> Enum.intersperse([?\r, ?\n])
      |> List.flatten()

    score = Map.get(state, {-1, 0}, 0) |> inspect()
    inputs = Map.get(state, {-1, -1}, []) |> Enum.reverse() |> inspect(limit: :infinity)

    send(:monitor, {:print, {output, score, inputs}, self()})

    state
  end

  defp insert_coin(program) do
    %{program | 0 => 2}
  end

  defp start_game(program) do
    game = Intcode.Computer.start(program, downstream: self())
    Process.register(game, :game)
    Process.register(self(), :hud)

    # to win immediately:
    #
    # Day13WinPlay.sequence()
    # |> Enum.each(&send(:game, {:data, &1, self()}))

    spawn(&monitor/0)
    spawn(&joystick/0)

    listen(%{}, &print/1)
  end

  defp monitor do
    Application.put_env(:elixir, :ansi_enabled, true)
    Process.register(self(), :monitor)

    print_loop()
  end

  defp print_loop do
    receive do
      {:print, {data, score, _inputs}, _} ->
        IO.write([ANSI.clear(), ANSI.home()])
        IO.puts(["\r\nscore: ", score, "\r\n"])
        IO.puts(data)
        # record the inputs
        # IO.puts(["\r", inputs])
        IO.write(ANSI.reset())
    end

    print_loop()
  end

  defp joystick do
    Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])

    read_loop()
  end

  defp read_loop do
    receive do
      {_, {:data, data}} ->
        handle_input(data)
        read_loop()
    end
  end

  defp handle_input("\e[A"), do: send(:hud, {:joystick, 0, self()})
  defp handle_input("\e[B"), do: send(:hud, {:joystick, 0, self()})
  defp handle_input("\e[D"), do: send(:hud, {:joystick, -1, self()})
  defp handle_input("\e[C"), do: send(:hud, {:joystick, 1, self()})
  defp handle_input(_other), do: nil
end
