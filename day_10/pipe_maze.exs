defmodule PipeMaze do
  def read_input(path) do
    graph = :digraph.new()

    path
    |> File.stream!()
    |> Stream.with_index()
    |> Enum.each(fn {line, y} ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.each(fn
        {"|", x} ->
          connect_pipes(graph, {x, y}, {x, y - 1}, {x, y + 1})

        {"-", x} ->
          connect_pipes(graph, {x, y}, {x - 1, y}, {x + 1, y})

        {"L", x} ->
          connect_pipes(graph, {x, y}, {x, y - 1}, {x + 1, y})

        {"J", x} ->
          connect_pipes(graph, {x, y}, {x, y - 1}, {x - 1, y})

        {"7", x} ->
          connect_pipes(graph, {x, y}, {x, y + 1}, {x - 1, y})

        {"F", x} ->
          connect_pipes(graph, {x, y}, {x, y + 1}, {x + 1, y})

        {".", _x} ->
          :ignore

        {"S", x} ->
          :digraph.add_vertex(graph, {x, y}, "S")
      end)
    end)

    s =
      graph
      |> :digraph.vertices()
      |> Enum.find(fn v -> elem(:digraph.vertex(graph, v), 1) == "S" end)

    start =
      graph
      |> :digraph.in_edges(s)
      |> hd()
      |> elem(0)

    :digraph.add_edge(graph, {s, start}, s, start, [])
    :digraph.del_edge(graph, {start, s})

    {graph, s}
  end

  def solve_part_1({graph, s}) do
    graph
    |> :digraph.get_cycle(s)
    |> length()
    |> div(2)
  end

  def solve_part_2({graph, s}) do
    polygon = :digraph.get_cycle(graph, s)
    {min_x, max_x} = polygon |> Enum.map(fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = polygon |> Enum.map(fn {_x, y} -> y end) |> Enum.min_max()

    for x <- min_x..max_x, y <- min_y..max_y, {x, y} not in polygon, reduce: 0 do
      count ->
        crossed_lines = Enum.count((x + 1)..max_x, fn x -> {x, y} in polygon end)
        # crossed_lines =
        #   Enum.count(1..max(max_x, max_y), fn offset ->
        #     {x + offset, y + offset} in polygon
        #   end)

        # if rem(crossed_lines, 2) == 1 do
        #   {x, y}
        # end

        if rem(crossed_lines, 2) == 1 do
          count + 1
        else
          count
        end
    end
  end

  defp connect_pipes(graph, from, to_1, to_2) do
    Enum.each([from, to_1, to_2], fn v ->
      unless :digraph.vertex(graph, v) do
        :digraph.add_vertex(graph, v)
      end
    end)

    :digraph.add_edge(graph, {from, to_1}, from, to_1, [])
    :digraph.add_edge(graph, {from, to_2}, from, to_2, [])
  end
end

System.argv()
|> hd()
|> PipeMaze.read_input()
|> PipeMaze.solve_part_2()
|> IO.inspect()
