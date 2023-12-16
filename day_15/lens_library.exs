defmodule LensLibrary do
  def read_input(path) do
    path
    |> File.read!()
    |> String.trim()
    |> String.split(",")
  end

  def solve_part_1(steps) do
    steps
    |> Enum.map(fn s ->
      Stream.unfold({s, 0}, fn
        {"", _hash} ->
          nil

        {<<ascii::utf8, rest::binary>>, hash} ->
          hash = rem((hash + ascii) * 17, 256)
          {hash, {rest, hash}}
      end)
      |> Enum.at(-1)
    end)
    |> Enum.sum()
  end
end

System.argv()
|> hd()
|> LensLibrary.read_input()
|> LensLibrary.solve_part_1()
|> IO.inspect()
