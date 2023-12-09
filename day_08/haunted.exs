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
    nodes
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(fn start ->
      moves
      |> Stream.cycle()
      |> Stream.transform(start, fn direction, acc ->
        i = if direction == "L", do: 0, else: 1
        acc = nodes |> Map.fetch!(acc) |> elem(i)
        {[acc], acc}
      end)
      |> Stream.with_index()
      |> Enum.reduce_while(Map.new(), fn
        _wrap, acc when is_integer(acc) ->
          {:halt, acc}

        {n, i}, acc ->
          acc =
            if String.ends_with?(n, "Z") do
              if Map.has_key?(acc, n) do
                i - Map.fetch!(acc, n)
              else
                Map.put(acc, n, i)
              end
            else
              acc
            end

          {:cont, acc}
      end)
    end)
    |> Enum.reduce(1, fn n, lcm -> div(n * lcm, Integer.gcd(n, lcm)) end)
  end
end

System.argv()
|> hd()
|> Haunted.read_input()
|> Haunted.solve_part_2()
|> IO.inspect()
