defmodule Dish do
  def read_input(path) do
    platform =
      path
      |> File.stream!()
      |> Stream.with_index()
      |> Enum.reduce(Map.new(), fn {line, y}, acc ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Stream.with_index()
        |> Enum.reduce(acc, fn {contents, x}, acc ->
          Map.put(acc, {x, y}, contents)
        end)
      end)

    xys = Map.keys(platform)
    max_x = xys |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = xys |> Enum.map(&elem(&1, 1)) |> Enum.max()

    %{
      platform: platform,
      max_x: max_x,
      max_y: max_y
    }
  end

  def solve_part_1(state) do
    1..state.max_y//1
    |> Enum.reduce(state.platform, fn y, acc ->
      0..state.max_x//1
      |> Enum.reduce(acc, fn x, acc ->
        case Map.fetch!(acc, {x, y}) do
          "O" ->
            Enum.reduce_while((y - 1)..0//-1, acc, fn to_y, acc ->
              case Map.fetch!(acc, {x, to_y}) do
                "." -> {:cont, %{acc | {x, to_y} => "O", {x, to_y + 1} => "."}}
                _filled -> {:halt, acc}
              end
            end)

          _non_rolling ->
            acc
        end
      end)
    end)
    # |> tap(fn p ->
    #   Enum.each(0..state.max_y//1, fn y ->
    #     0..state.max_x//1
    #     |> Enum.map(fn x -> Map.fetch!(p, {x, y}) end)
    #     |> IO.puts()
    #   end)
    # end)
    |> then(fn p ->
      0..state.max_y//1
      |> Enum.reduce(0, fn y, acc ->
        0..state.max_x//1
        |> Enum.reduce(acc, fn x, acc ->
          case Map.fetch!(p, {x, y}) do
            "O" -> acc + (state.max_y + 1 - y)
            _non_rolling -> acc
          end
        end)
      end)
    end)
  end
end

System.argv()
|> hd()
|> Dish.read_input()
|> Dish.solve_part_1()
|> IO.inspect()
