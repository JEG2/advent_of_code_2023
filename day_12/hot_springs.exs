defmodule HotSprings do
  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.map(fn line ->
      [springs, counts] =
        line
        |> String.trim()
        |> String.split(" ", limit: 2)

      springs = String.graphemes(springs)

      counts =
        counts
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      {springs, counts}
    end)
  end

  def solve_part_1(records) do
    records
    |> Enum.map(fn {springs, counts} ->
      [springs]
      |> Stream.unfold(fn variations ->
        i = Enum.find_index(hd(variations), fn s -> s == "?" end)

        if i do
          variations =
            Enum.flat_map(variations, fn v ->
              [List.replace_at(v, i, "."), List.replace_at(v, i, "#")]
            end)

          {variations, variations}
        else
          nil
        end
      end)
      |> Enum.at(-1)
      |> Enum.map(fn v ->
        v
        |> Enum.chunk_while(
          [],
          fn
            ".", [] ->
              {:cont, []}

            ".", acc ->
              {:cont, acc, []}

            "#", acc ->
              {:cont, ["#" | acc]}
          end,
          fn
            [] ->
              {:cont, []}

            acc ->
              {:cont, acc, []}
          end
        )
        |> Enum.map(&length/1)
      end)
      |> Enum.count(fn c -> c == counts end)
    end)
    |> Enum.sum()
  end
end

System.argv()
|> hd()
|> HotSprings.read_input()
|> HotSprings.solve_part_1()
|> IO.inspect()
