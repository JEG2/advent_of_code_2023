defmodule LensLibrary do
  def read_input(path) do
    path
    |> File.read!()
    |> String.trim()
    |> String.split(",")
  end

  def solve_part_1(steps) do
    steps
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def solve_part_2(steps) do
    steps
    |> Enum.reduce(Map.new(), fn s, acc ->
      case String.split(s, "=") do
        [label, focal_length] ->
          key = String.to_atom(label)
          value = String.to_integer(focal_length)

          Map.update(acc, hash(label), [{key, value}], fn hashmap ->
            if Keyword.has_key?(hashmap, key) do
              Keyword.replace!(hashmap, key, value)
            else
              [{key, value} | hashmap]
            end
          end)

        _unmatched ->
          label = String.slice(s, 0..-2)
          key = String.to_atom(label)

          Map.update(acc, hash(label), [], fn hashmap ->
            Keyword.delete(hashmap, key)
          end)
      end
    end)
    |> Enum.flat_map(fn {box, lenses} ->
      lenses
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {{_label, focal_length}, slot} ->
        (box + 1) * slot * focal_length
      end)
    end)
    |> Enum.sum()
  end

  defp hash(s) do
    Stream.unfold({s, 0}, fn
      {"", _hash} ->
        nil

      {<<ascii::utf8, rest::binary>>, hash} ->
        hash = rem((hash + ascii) * 17, 256)
        {hash, {rest, hash}}
    end)
    |> Enum.at(-1)
  end
end

System.argv()
|> hd()
|> LensLibrary.read_input()
|> LensLibrary.solve_part_2()
|> IO.inspect()
