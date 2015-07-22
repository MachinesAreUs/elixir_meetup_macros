defmodule SimpleFunctionTest do
  use ExUnit.Case

  test "define a simple function through a macro" do
    
    defmodule TestModule do
      require SimpleFunction
      SimpleFunction.new_function :hello, do: "world"
      SimpleFunction.new_function :foo,   do: "bar"
    end

    assert TestModule.hello == "world"
    assert TestModule.foo   == "bar"
  end
 
  test "define multiple functions through a singl macro call" do

    defmodule TestModule do
      require MultipleFunction
      MultipleFunction.new_functions :hello, do: "ok"
    end
    
    #assert TestModule.hello_1 == "ok" 
    #assert TestModule.hello_2 == "ok" 
    assert TestModule.name == "ok" 
  end

end
