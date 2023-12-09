defmodule Haunted do
  def read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({nil, %{}}, fn
      line, {nil, %{}} ->
        {String.graphemes(line), %{}}

      "", acc ->
        acc

      line, {moves, nodes} ->
        [key, left, right] =
          Regex.scan(~r{\w+}, line)
          |> List.flatten()

        {moves, Map.put(nodes, key, {left, right})}
    end)
  end

  def solve_part_1({moves, nodes}) do
    moves
    |> Stream.cycle()
    |> Stream.transform("AAA", fn
      _direction, "ZZZ" ->
        {:halt, "ZZZ"}

      direction, acc ->
        i = if direction == "L", do: 0, else: 1
        acc = nodes |> Map.fetch!(acc) |> elem(i)
        {[acc], acc}
    end)
    |> Enum.count()
  end

  def solve_part_2({moves, nodes}) do
    starts = nodes |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))

    moves
    |> Stream.cycle()
    |> Stream.transform(starts, fn
      direction, acc ->
        if Enum.all?(acc, &String.ends_with?(&1, "Z")) do
          {:halt, acc}
        else
          i = if direction == "L", do: 0, else: 1
          acc = Enum.map(acc, fn a -> nodes |> Map.fetch!(a) |> elem(i) end)
          {[acc], acc}
        end
    end)
    |> Enum.count()
  end
end

System.argv()
|> hd()
|> Haunted.read_input()
|> Haunted.solve_part_2()
|> IO.inspect()
