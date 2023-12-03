defmodule CodeConundrum do
  @limits %{"red" => 12, "green" => 13, "blue" => 14}

  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.into(Map.new(), fn line ->
      ["Game " <> game, reveals] = String.split(line, ~r{:\s*})

      reveals =
        reveals
        |> String.trim()
        |> String.split(~r{;\s*})
        |> Enum.map(fn cubes ->
          cubes
          |> String.split(~r{,\s*})
          |> Enum.into(Map.new(), fn color_count ->
            [count, color] = String.split(color_count, ~r{\s+})
            {color, String.to_integer(count)}
          end)
        end)

      {String.to_integer(game), reveals}
    end)
  end

  def solve_part_1(input) do
    input
    |> Enum.filter(fn {_game, reveals} ->
      Enum.all?(@limits, fn {color, limit} ->
        Enum.all?(reveals, fn cubes ->
          Map.get(cubes, color, 0) <= limit
        end)
      end)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def solve_part_2(input) do
    input
    |> Map.values()
    |> Enum.map(fn reveals ->
      reveals
      |> Enum.reduce(fn cubes, highs ->
        Map.merge(highs, cubes, fn _color, count_1, count_2 ->
          max(count_1, count_2)
        end)
      end)
      |> Map.values()
      |> Enum.product()
    end)
    |> Enum.sum()
  end
end

System.argv()
|> hd()
|> CodeConundrum.read_input()
|> CodeConundrum.solve_part_2()
|> IO.inspect()
