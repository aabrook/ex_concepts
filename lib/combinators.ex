defmodule Combinators do
  @doc ~S"""
    iex> f = fn fib ->
    ...>   fn
    ...>     0 -> 0
    ...>     1 -> 1
    ...>     n -> fib.(n - 1) + fib.(n - 2)
    ...>   end
    ...> end
    ...> fib = Combinators.y(f)
    ...> fib.(12)
    144
    iex> make_length = fn get_length ->
    ...>   fn
    ...>     [] -> 0
    ...>     [h] -> 1
    ...>     [h | t] -> 1 + get_length.(t)
    ...>   end
    ...> end
    ...> length = Combinators.y(make_length)
    ...> length.([1, 2, 3, 4, 5])
    5
  """
  def y(f) do
    (fn
      x ->
        x.(x)
    end).(fn
      x ->
        f.(fn
          t ->
            (x.(x)).(t)
        end)
    end)
  end

  @doc ~S"""
    iex> f = Combinators.k(5)
    ...> f.(12) == 5
    true
  """
  def k(v), do: fn _ -> v end

  @doc ~S"""
    iex> Combinators.i(5)
    5
  """
  def i(v), do: v
end