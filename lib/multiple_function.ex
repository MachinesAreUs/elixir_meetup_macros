defmodule MultipleFunction do

  defmacro new_functions(base_name, do: block) do
    
    quote do
      ["_1","_2"] 
        |> Enum.map(&(to_string(unquote(base_name)) <> &1))
        |> Enum.map(&String.to_atom/1)
        |> Enum.map(&Macro.escape/1)
        |> Enum.each fn(name) -> 
          def name() do
            unquote(block)
          end
        end 
    end
  end

end
