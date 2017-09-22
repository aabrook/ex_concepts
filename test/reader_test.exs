defmodule ExConcepts.ReaderTest do
  use ExUnit.Case

  def repeat(v, n) when n <= 0, do: [v]
  def repeat(v, n), do: [v] ++ repeat(v, n - 1)

  test "will compose a single function" do
    result = Reader.return("Hello")
      |> Reader.compose(fn arg, env -> arg <> env end)
      |> Reader.run(" world")

    assert result == "Hello world"
  end

  test "will compose multiple functions" do
    result = Reader.return("Hello")
      |> Reader.compose(fn arg, env -> arg <> " " <> env.text end)
      |> Reader.compose(fn arg, env -> arg <> " " <> Enum.join(repeat(env.text, env.repeat), " ") end)
      |> Reader.run(%{repeat: 5, text: "world"})

    assert result == "Hello world world world world world world world"
  end
end
