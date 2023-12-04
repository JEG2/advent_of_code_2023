defmodule GearRatios do
  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.with_index()
    |> Enum.reduce(Map.new(), fn {line, y}, grid ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(grid, fn
        {".", _x}, grid ->
          grid

        {digit, x}, grid when digit in ~w[0 1 2 3 4 5 6 7 8 9] ->
          Map.put(grid, {x, y}, String.to_integer(digit))

        {symbol, x}, grid ->
          Map.put(grid, {x, y}, symbol)
      end)
    end)
  end

  def solve_part_1(grid) do
    grid
    |> Enum.filter(fn {_xy, contents} -> is_binary(contents) end)
    |> Enum.flat_map(fn {xy, _contents} -> find_adjacent_numbers(grid, xy) end)
    |> Enum.sum()
  end

  def solve_part_2(grid) do
    grid
    |> Enum.filter(fn {_xy, contents} -> contents == "*" end)
    |> Enum.map(fn {xy, _contents} -> find_adjacent_numbers(grid, xy) end)
    |> Enum.filter(fn numbers -> length(numbers) == 2 end)
    |> Enum.map(&Enum.product/1)
    |> Enum.sum()
  end

  defp find_adjacent_numbers(grid, {x, y}) do
    [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
    |> Enum.map(fn {x_offset, y_offset} -> {x + x_offset, y + y_offset} end)
    |> Enum.filter(fn xy -> is_integer(grid[xy]) end)
    |> Enum.map(fn xy ->
      xy
      |> Stream.iterate(fn {x, y} -> {x - 1, y} end)
      |> Stream.take_while(fn xy -> is_integer(grid[xy]) end)
      |> Enum.at(-1)
    end)
    |> Enum.uniq()
    |> Enum.map(fn xy ->
      xy
      |> Stream.iterate(fn {x, y} -> {x + 1, y} end)
      |> Stream.take_while(fn xy -> is_integer(grid[xy]) end)
      |> Enum.map(fn xy -> grid[xy] end)
      |> Enum.join()
      |> String.to_integer()
    end)
  end
end

System.argv()
|> hd()
|> GearRatios.read_input()
|> GearRatios.solve_part_2()
|> IO.inspect()
