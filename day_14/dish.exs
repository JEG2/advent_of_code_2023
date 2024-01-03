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
    state.platform
    |> tilt_north(state)
    # |> tap(&print(&1, state))
    |> then(&score(&1, state))
  end

  def solve_part_2(state) do
    state.platform
    |> Stream.iterate(&cycle(&1, state))
    |> Stream.with_index()
    |> Enum.reduce_while(Map.new(), fn {p, i}, acc ->
      if Map.has_key?(acc, p) do
        h = Map.fetch!(acc, p)
        limit = 1_000_000_000 - h
        extra = rem(limit, i - h) + h
        {:halt, acc |> Enum.find(fn {_p, i} -> i == extra end) |> elem(0)}
      else
        {:cont, Map.put(acc, p, i)}
      end
    end)
    # |> tap(&print(&1, state))
    |> then(&score(&1, state))
  end

  defp tilt_north(platform, state) do
    1..state.max_y//1
    |> Enum.reduce(platform, fn y, acc ->
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
  end

  defp tilt_west(platform, state) do
    1..state.max_x//1
    |> Enum.reduce(platform, fn x, acc ->
      0..state.max_y//1
      |> Enum.reduce(acc, fn y, acc ->
        case Map.fetch!(acc, {x, y}) do
          "O" ->
            Enum.reduce_while((x - 1)..0//-1, acc, fn to_x, acc ->
              case Map.fetch!(acc, {to_x, y}) do
                "." -> {:cont, %{acc | {to_x, y} => "O", {to_x + 1, y} => "."}}
                _filled -> {:halt, acc}
              end
            end)

          _non_rolling ->
            acc
        end
      end)
    end)
  end

  defp tilt_south(platform, state) do
    (state.max_y - 1)..0//-1
    |> Enum.reduce(platform, fn y, acc ->
      0..state.max_x//1
      |> Enum.reduce(acc, fn x, acc ->
        case Map.fetch!(acc, {x, y}) do
          "O" ->
            Enum.reduce_while((y + 1)..state.max_y//1, acc, fn to_y, acc ->
              case Map.fetch!(acc, {x, to_y}) do
                "." -> {:cont, %{acc | {x, to_y} => "O", {x, to_y - 1} => "."}}
                _filled -> {:halt, acc}
              end
            end)

          _non_rolling ->
            acc
        end
      end)
    end)
  end

  defp tilt_east(platform, state) do
    (state.max_x - 1)..0//-1
    |> Enum.reduce(platform, fn x, acc ->
      0..state.max_y//1
      |> Enum.reduce(acc, fn y, acc ->
        case Map.fetch!(acc, {x, y}) do
          "O" ->
            Enum.reduce_while((x + 1)..state.max_x//1, acc, fn to_x, acc ->
              case Map.fetch!(acc, {to_x, y}) do
                "." -> {:cont, %{acc | {to_x, y} => "O", {to_x - 1, y} => "."}}
                _filled -> {:halt, acc}
              end
            end)

          _non_rolling ->
            acc
        end
      end)
    end)
  end

  defp cycle(platform, state) do
    platform
    |> tilt_north(state)
    |> tilt_west(state)
    |> tilt_south(state)
    |> tilt_east(state)
  end

  # defp print(platform, state) do
  #   Enum.each(0..state.max_y//1, fn y ->
  #     0..state.max_x//1
  #     |> Enum.map(fn x -> Map.fetch!(platform, {x, y}) end)
  #     |> IO.puts()
  #   end)
  # end

  defp score(platform, state) do
    0..state.max_y//1
    |> Enum.reduce(0, fn y, acc ->
      0..state.max_x//1
      |> Enum.reduce(acc, fn x, acc ->
        case Map.fetch!(platform, {x, y}) do
          "O" -> acc + (state.max_y + 1 - y)
          _non_rolling -> acc
        end
      end)
    end)
  end
end

System.argv()
|> hd()
|> Dish.read_input()
|> Dish.solve_part_2()
|> IO.inspect()
