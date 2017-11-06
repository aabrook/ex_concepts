defmodule Sum do
    defstruct [:num]

    def new(n \\ 0) when is_number(n), do: %Sum{num: n}
    def concat(%Sum{num: a}, %Sum{num: b}), do: %Sum{num: a + b}

    def sum_all(list), do: Enum.reduce(list, Sum.new, &concat/2)
end