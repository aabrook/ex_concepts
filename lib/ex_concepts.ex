defmodule ExConcepts do
  @moduledoc """
  Documentation for ExConcepts.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExConcepts.hello
      :world

  """
  def hello do
    :world
  end

  def recurseA 8 do
    raise "Boom"
  end

  def recurseA i do
    recurseB i + 1
  end

  def recurseB i do
    recurseA i
  rescue
    e -> IO.inspect System.stacktrace
  end
end
