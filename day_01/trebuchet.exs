defmodule Trebuchet do
  @numbers %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def read_input(path), do: File.stream!(path)

  def solve_part_1(input) do
    input
    |> Enum.map(fn line ->
      Regex.scan(~r{\d}, line)
      |> List.flatten()
      |> then(&(List.first(&1) <> List.last(&1)))
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def solve_part_2(input) do
    input
    |> Enum.map(fn line ->
      line
      |> name_to_digit()
      |> name_to_digit()
    end)
    |> solve_part_1()
  end

  defp name_to_digit(line) do
    Regex.replace(
      ~r[#{@numbers |> Map.keys() |> Enum.join("|")}],
      line,
      fn n -> Map.fetch!(@numbers, n) <> String.last(n) end
    )
  end
end

System.argv()
|> hd()
|> Trebuchet.read_input()
|> Trebuchet.solve_part_2()
|> IO.inspect()
