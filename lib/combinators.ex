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
end