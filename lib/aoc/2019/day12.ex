defmodule AOC.Y2019.Day12 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/12
  """

  @moons [
    {-19, -4, 2},
    {-9, 8, -16},
    {-4, 5, -11},
    {1, 9, -13}
  ]

  def p1, do: simulate(@moons, 1000) |> to_energy()
  def p2, do: AOC.Helper.Timer.tc(fn -> find_repeat_step(@moons) end)

  defp simulate(moons, steps) do
    moons
    |> Enum.map(&%{pos: &1, vel: {0, 0, 0}})
    |> Stream.iterate(&next_frame_3d/1)
    |> Stream.take(1 + steps)
    |> Enum.take(-1)
    |> List.last()
  end

  defp next_frame_3d(moons) do
    Enum.map(moons, fn m ->
      vel = apply_gravities(m, moons)
      %{pos: move(m.pos, vel), vel: vel}
    end)
  end

  defp move({x, y, z}, {dx, dy, dz}), do: {x + dx, y + dy, z + dz}

  defp apply_gravities(%{pos: {x0, y0, z0}, vel: vel}, rest) do
    Enum.reduce(rest, vel, fn %{pos: {x, y, z}}, {vx, vy, vz} ->
      {
        vx + diff(x0, x),
        vy + diff(y0, y),
        vz + diff(z0, z)
      }
    end)
  end

  defp diff(a, a), do: 0
  defp diff(a, b) when a < b, do: 1
  defp diff(a, b) when a > b, do: -1

  defp to_energy(moons) when is_list(moons) do
    moons
    |> Stream.map(&to_energy/1)
    |> Enum.sum()
  end

  defp to_energy(%{pos: {x, y, z}, vel: {vx, vy, vz}}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end

  defp find_repeat_step(moons) do
    to_1d = fn i -> &{elem(&1, i), 0} end

    [
      moons |> Enum.map(to_1d.(0)),
      moons |> Enum.map(to_1d.(1)),
      moons |> Enum.map(to_1d.(2))
    ]
    |> Enum.map(&find_repeat_1d_step/1)
    |> Enum.reduce(&lcm/2)
  end

  defp find_repeat_1d_step(moons_1d) do
    search_loop(moons_1d, moons_1d, 0)
  end

  defp search_loop(moons_1d, target, step) do
    case next_frame_1d(moons_1d) do
      ^target when step > 0 ->
        step

      current ->
        search_loop(current, target, step + 1)
    end
  end

  defp next_frame_1d(moons_1d) do
    Enum.map(moons_1d, fn {pos, v} ->
      Enum.reduce(moons_1d, {pos + v, v}, fn {p, _}, {pos0, v0} ->
        d = diff(pos, p)
        {pos0 + d, v0 + d}
      end)
    end)
  end

  defp lcm(a, b), do: div(a * b, Integer.gcd(a, b))
end
