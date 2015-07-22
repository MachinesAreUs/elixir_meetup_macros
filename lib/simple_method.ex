defmodule MyMacros do
  defmacro new_function(name, do: block) do
    quote do
      def unquote(name)() do
        unquote(block)
      end
    end
  end
end

defmodule MyModule do
  require MyMacros
  MyMacros.new_function :hello, do: "world"
  MyMacros.new_function :foo,   do: "bar"
end
