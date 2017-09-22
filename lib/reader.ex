defmodule Reader do
  def return(initial) do
    fn (_, env) ->
      initial
    end
  end

  def run(func, env) do
    func.(nil, env)
  end

  def compose(f, g) do
    fn (args, env) ->
      g.(f.(args, env), env)
    end
  end
end
