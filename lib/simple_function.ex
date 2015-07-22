defmodule SimpleFunction do
  defmacro new_function(name, do: block) do
    quote do
      def unquote(name)() do
        unquote(block)
      end
    end
  end
end

