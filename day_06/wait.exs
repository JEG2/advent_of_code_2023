defmodule Wait do
  def read_input(path) do
    ["Time:      " <> times, "Distance:  " <> distances] =
      path
      |> File.read!()
      |> String.trim()
      |> String.split("\n")

    Enum.zip(to_number_list(times), to_number_list(distances))
  end

  def solve_part_1(races) do
    races
    |> Enum.map(fn {time, distance} -> find_wins(time, distance) end)
    |> Enum.product()
  end

  def solve_part_2(races) do
    [time, distance] =
      races
      |> Enum.unzip()
      |> Tuple.to_list()
      |> Enum.map(fn digits -> digits |> Enum.join() |> String.to_integer() end)

    find_wins(time, distance)
  end

  defp to_number_list(text) do
    text
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp find_wins(time, distance) do
    travels =
      Enum.map(1..ceil((time - 1) / 2), fn hold ->
        (time - hold) * hold
      end)

    travels =
      if rem(time - 1, 2) == 0 do
        travels ++ Enum.reverse(travels)
      else
        travels ++ Enum.reverse(Enum.slice(travels, 0..-2))
      end

    travels
    |> Enum.filter(fn t -> t > distance end)
    |> length()
  end
end

System.argv()
|> hd()
|> Wait.read_input()
|> Wait.solve_part_2()
|> IO.inspect()
