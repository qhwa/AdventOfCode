defmodule Y2021.Day07 do
  @moduledoc """
  https://adventofcode.com/2021/day/7

  Run with: `mix run lib/aoc/2021/day07.exs`
  """
  @x_list AOC.Input.read_integers("2021/day07.txt")
  @max_x Enum.max(@x_list)
  @population_size 20

  def p1 do
    fitness_fun = fn chromosome ->
      Stream.map(@x_list, &abs(&1 - chromosome.genes))
      |> Enum.sum()
      |> Kernel.*(-1)
    end

    run(fitness_fun)
  end

  def p2 do
    fitness_fun = fn chromosome ->
      Stream.map(@x_list, &abs(&1 - chromosome.genes))
      |> Stream.map(&div((1 + &1) * &1, 2))
      |> Enum.sum()
      |> Kernel.*(-1)
    end

    run(fitness_fun)
  end

  def run(fitness_fun) do
    init_population(@population_size)
    |> evolve(fitness_fun)
  end

  defp init_population(size),
    do:
      for(
        _ <- 1..size,
        do: %{generation: 0, genes: genotype()}
      )

  def genotype,
    do: 0..@max_x |> Enum.random()

  defp evolve(population, fitness_fun, generation \\ 0)

  defp evolve(population, fitness_fun, generation) do
    # IO.inspect(best(population), label: to_string(generation))

    population
    |> calculate_fitness(fitness_fun)
    |> selection()
    |> crossover(generation)
    |> mutation()
    |> terminate_or_next(fitness_fun, generation)
  end

  defp best(population) do
    population
    |> Enum.filter(&Map.get(&1, :fitness))
    |> case do
      [] -> nil
      population -> Enum.max_by(population, & &1.fitness)
    end
  end

  defp calculate_fitness(population, fitness_fun) do
    population
    |> Stream.map(fn
      %{fitness: _} = chromosome ->
        chromosome

      chromosome ->
        Map.put(chromosome, :fitness, fitness_fun.(chromosome))
    end)
    |> Enum.sort_by(& &1.fitness, :desc)
  end

  defp selection(population) do
    select_count = Enum.count(population) |> div(2)
    Enum.take(population, select_count)
  end

  defp crossover(population, generation) do
    population
    |> Stream.chunk_every(2, 2, :discard)
    |> Stream.flat_map(fn [chromosome_a, chromosome_b] ->
      [
        %{
          generation: generation + 1,
          genes: div(chromosome_a.genes + chromosome_b.genes, 2)
        },
        %{
          generation: generation + 1,
          genes: rem(chromosome_a.genes * chromosome_b.genes, @max_x)
        }
      ]
    end)
    |> then(&Enum.concat(population, &1))
  end

  defp mutation(population) do
    population
  end

  defp terminate_or_next(population, fitness_fun, generation) do
    if terminate?(population, generation),
      do: best(population),
      else: evolve(population, fitness_fun, generation + 1)
  end

  def terminate?(_population, generation) do
    generation > 200
  end
end

Y2021.Day07.p1() |> IO.inspect(label: "part 1")
Y2021.Day07.p2() |> IO.inspect(label: "part 2")
