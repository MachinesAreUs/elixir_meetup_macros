defmodule MacrosDemo do

  defmacro uninteresting_macro() do
    "Nothing interesting here"
  end

  defmacro sum(foo, bar) do
    foo + bar
  end

  defmacro sum_quoted(foo, bar) do
    quote do
      unquote(foo) + unquote(bar)
    end
  end

  defmacro create_simple_method(method_name) do
    IO.puts "Creating a simple method"
    quote do
      def unquote(method_name)() do 
        "ok"
      end
    end
  end

  defmacro create_2_methods(method_name) do
    IO.puts "Creating a simple method"
    quote do
      def unquote(method_name)() do 
        :good
      end
    end
  end
 
end

