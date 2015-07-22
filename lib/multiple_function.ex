defmodule MultipleFunction do

  defmacro new_functions(base_name, do: block) do
    
    quote do
      ["_1","_2"] 
        |> Enum.map(&((to_string(unquote(base_name)) <> &1) |> String.to_atom))
        |> Enum.map(&Macro.escape/1)
        |> Enum.each fn(name) -> 
          #def unquote(name)() do
          def name() do
            unquote(block)
          end
        end 
    end
  end

end
