defmodule MacrosTest do
  use ExUnit.Case

  test "quotations returns a tuple representing the AST of the expression" do
    assert (quote do: 1 + 2) == {:+, [context: MacrosTest, import: Kernel], [1, 2]}
  end

  test "you can evaluate a quoted expression with 'Code.eval_quoted'" do
    ast = quote do: 1 + 2
    {val, bindings} = Code.eval_quoted ast
    assert val == 3
    assert bindings == []
  end

  test "unquote allows to introduce AST fragments within a quoted expression" do
    ast = quote do: "hola"
    ast2 = quote do: String.reverse unquote(ast)
    {val,_} = Code.eval_quoted ast2
    assert val == "aloh"
  end

  test "define a simple function through a macro" do
    
    defmodule TestModule do
      require SimpleFunction
      SimpleFunction.new_function :hello, do: "world"
      SimpleFunction.new_function :foo,   do: "bar"
    end

    assert TestModule.hello == "world"
    assert TestModule.foo   == "bar"
  end

  test "You can define methods for a module at compile time" do
    import StateMachine
    assert initial |> pause == :paused
    assert initial |> pause |> resume == :running
    assert initial |> pause |> resume |> stop == :stopped
  end

  test "you can define an API for Github at compile time" do
    repos = Github.__info__(:functions) |> Enum.map &elem(&1,0)
    assert Enum.member?(repos, :elixir_meetup_macros)
    assert Enum.member?(repos, :elm_playground)
    assert Enum.member?(repos, :elixir_playground)
  end

end
