defmodule CosmicExpansion do
  def read_input(path) do
    galaxies =
      path
      |> File.stream!()
      |> Stream.with_index()
      |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Stream.with_index()
        |> Enum.reduce(acc, fn
          {".", _x}, acc -> acc
          {"#", x}, acc -> MapSet.put(acc, {x, y})
        end)
      end)

    xs = galaxies |> Enum.map(fn {x, _y} -> x end) |> MapSet.new()
    max_x = Enum.max(xs)

    expanded_xs =
      for x <- 0..max_x, not MapSet.member?(xs, x), into: MapSet.new() do
        x
      end

    ys = galaxies |> Enum.map(fn {_x, y} -> y end) |> MapSet.new()
    max_y = Enum.max(ys)

    expanded_ys =
      for y <- 0..max_y, not MapSet.member?(ys, y), into: MapSet.new() do
        y
      end

    %{
      galaxies: galaxies,
      max_x: max_x,
      max_y: max_y,
      expanded_xs: expanded_xs,
      expanded_ys: expanded_ys
    }
  end

  def solve_part_1(state) do
    gs = Enum.to_list(state.galaxies)
    last_i = length(gs) - 1

    Enum.reduce(0..last_i, 0, fn i, acc ->
      Enum.reduce((i + 1)..last_i//1, acc, fn j, acc ->
        {gx_1, gy_1} = Enum.at(gs, i)
        {gx_2, gy_2} = Enum.at(gs, j)

        x_offset =
          Enum.reduce(min(gx_1, gx_2)..max(gx_1, gx_2), 0, fn x, acc ->
            if MapSet.member?(state.expanded_xs, x) do
              acc + 3
            else
              acc + 1
            end
          end)

        y_offset =
          Enum.reduce(min(gy_1, gy_2)..max(gy_1, gy_2), 0, fn y, acc ->
            if MapSet.member?(state.expanded_ys, y) do
              acc + 3
            else
              acc + 1
            end
          end)

        acc + x_offset + y_offset
      end)
    end)
  end
end

System.argv()
|> hd()
|> CosmicExpansion.read_input()
|> CosmicExpansion.solve_part_1()
|> IO.inspect()
