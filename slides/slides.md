class: center, middle, cover-slide
# Metaprogramación en Elixir

Agustín Ramos

@MachinesAreUs

.bounce[![Elixir Logo](./img/elixir.png)]

---
class: middle
# Code is data

---
background-image: url(./img/code-as-data-twit.png)

---
class: center, middle
## ¿Qué pasa si tu lenguaje de programación te permite manipular los programas de igual manera que cualquier otro dato?

---
class: middle
# Sin las macros, Elixir no existiría...

---
background-image: url(./img/elixir-early-history-depression.png)

---
background-image: url(./img/elixir-early-history-tinkering.png)

---
background-image: url(./img/elixir-early-history-legolang.png)

---
background-image: url(./img/elixir-early-history-nailedit.png)

---
class: middle
# Macros building blocks:
# quote & unquote

---
# quote

--
**`quote`** recibe un bloque y convierte el código dentro del mismo a su representación en forma de AST. 

--
```elixir
iex> quote do: 2 + 3 

{:+, [context: Elixir, import: Kernel], [2, 3]}
```

--
```elixir
iex> quote do: 2 + 3 * 5

{:+, [context: Elixir, import: Kernel],
 [2, {:*, [context: Elixir, import: Kernel], [3, 5]}]}
```

--
```elixir
iex> ast = quote do: 1 * 3 + 10 / 2 

{:+, [context: Elixir, import: Kernel],
 [{:*, [context: Elixir, import: Kernel], [1, 3]},
  {:/, [context: Elixir, import: Kernel], [10, 2]}]}
```

---
# unquote

--
**`unquote`** solo puede utilizarse dentro de un bloque `quote`, y sirve para insertar un fragmento de AST dentro del bloque que se está **`quoteando`** (bad spanglish).

--

```elixir
iex> range_ast = quote do: 1..3

{:.., [context: Elixir, import: Kernel], [1, 3]}
```
--

```elixir
iex> func_ast = quote do: fn(x) -> x*2 end

{:fn, [],
 [{:->, [],
   [[{:x, [], Elixir}],
    {:*, [context: Elixir, import: Kernel], [{:x, [], Elixir}, 2]}]}]}
```

---
# unquote

**`unquote`** solo puede utilizarse dentro de un bloque `quote`, y sirve para insertar un fragmento de AST dentro del bloque que se está **`quoteando`** (bad spanglish).

--

```elixir
iex> prog_ast = quote do
...>   Enum.map unquote(range_ast), unquote(func_ast)
...> end
```
--

```elixir
{{:., [], [{:__aliases__, [alias: false], [:Enum]}, :map]}, [],
 [{:.., [context: Elixir, import: Kernel], [1, 3]},
  {:fn, [],
   [{:->, [],
     [[{:x, [], Elixir}],
      {:*, [context: Elixir, import: Kernel], [{:x, [], Elixir}, 2]}]}]}]}
```
--

```elixir
iex> IO.puts Macro.to_string(prog_ast)
```
--

```elixir
Enum.map(1 .. 3, fn x -> x * 2 end)
:ok
```

---
# AST expansion
--

```elixir
iex> ast = quote do                       
...>   unless 1 > 2 do
...>     :ok
...>   end
...> end

{:unless, [context: Elixir, import: Kernel],
 [{:>, [context: Elixir, import: Kernel], [1, 2]}, [do: :ok]]}
```
--

```elixir
iex> ast2 = Macro.expand_once ast, __ENV__

{:if, [context: Kernel, import: Kernel],
 [{:>, [context: Elixir, import: Kernel], [1, 2]}, [do: nil, else: :ok]]}
```
--

```elixir
iex> IO.puts Macro.to_string(ast2)        

if(1 > 2) do
  nil
else
  :ok
end
:ok
```

---
# AST expansion
--

```elixir
iex> ast3 = Macro.expand_once ast2, __ENV__

{:case, [optimize_boolean: true],
 [{:>, [context: Elixir, import: Kernel], [1, 2]},
  [do: [{:->, [],
     [[{:when, [],
        [{:x, [counter: 1], Kernel},
         {:in, [context: Kernel, import: Kernel],
          [{:x, [counter: 1], Kernel}, [false, nil]]}]}], :ok]},
    {:->, [], [[{:_, [], Kernel}], nil]}]]]}
```
--

```elixir
iex> IO.puts Macro.to_string(ast3)         

case(1 > 2) do
  x when x in [false, nil] ->
    :ok
  _ ->
    nil
end
:ok
```

---
# Creación de una macro

--

**1.** Se define con la macro **`defmacro`**. Sus partes son: 

  + **nombre**
  + **parámetros** que recibe
  + bloque de **código**

--

```elixir
defmacro my_macro(param1, param2...) do
  # code here...
end
```
--
**2.** Todas las macros deben definirse **dentro de un módulo**.

--

**3.** Se espera que el cuerpo de una macro **devuelva un fragmento de AST**.

--

```elixir
defmodule MyModule do
  defmacro my_macro(param1, param2...) do
    # Maybe some code here
    quote do
      # quoted code (AST fragment) here
    end
  end
end
```
--
**4.** **Importante**: los parámetros que recibe el cuerpo de la macro vienen en forma de AST (quoted).

---
# Uso de una macro

--
**1.** Para usar una macro, es necesario que el módulo donde está definida esté disponible

--

```elixir
require MyModule
```
--

**2.** Al invocar una macro, el punto de la llamada se sustituye por el fragmento de AST generado dentro del cuerpo de la macro. Por ejemplo:
--

```elixir
require MyModule
MyModule.sum 1, 2  ===> {:+, [context: Elixir, import: Kernel], [1, 2]}
```
--

**3**. Las macros se procesan en **tiempo de compilación** mediante un proceso llamado **expansión de macros**.

--

**4**. El proceso de se repite hasta que ya no hay más macros por expandir.

---
background-image: url(./img/macro-expansion-1.png)
# Proceso de compilación de Elixir

---
# Ejemplo 1

Nuestra macro va a crear un método dentro del módulo desde donde es llamada la macro. El módulo cliente especifica el nombre y el cuerpo de la función.
--

```elixir
defmodule MyMacros do                      
  defmacro new_function(name, do: block) do
    quote do                               
      def unquote(name)() do               
        unquote(block)
      end
    end
  end
end
```
--

```elixir
defmodule MyModule do
  require MyMacros
  MyMacros.new_function :hello, do: "world"
  MyMacros.new_function :fo,    do: "bar"
end
```
--

```elixir
iex(5)> MyModule.hello
"world"
iex(6)> MyModule.foo
"bar"
```

---
# Y eso... ¿para qué sirve?

--
+ Para extender el lenguaje

--
+ i.e. Para crear DSL's

--
+ Para dar pláticas mafufas.

---
class: middle
# Importancia de las macros en Elixir

---
# stdlib

En la stdlib, el uso de macros es [interesante](https://docs.google.com/spreadsheets/d/11IZJIZyr2173wsOu7fu6DJoQ6YBH7f5C_nBn4mpYTZE/edit?usp=sharing)

---
# Ecto

--

+ Ecto es el framework oficial  para acceder a bases de datos.
--

+ Provee DSL's para:
  - Modeladoude datos
  - Migraciones de datos
  - Queries

--

```elixir
defmodule MyApp.Comment do  
  use Ecto.Model
  import Ecto.Query

  schema "comments" do
    field :commenter, :string
    field :title, :string
    field :votes, :integer

    belongs_to :post, MyApp.Post
  end
end  
```
--

```elixir
iex> query = from c in MyApp.Comment,
iex>   join: p in assoc(c, :post),
iex>  where: p.id == 1,
iex> select: c
iex> App.Repo.all query
```

---
class: middle
# Y para tus propios DSLs...

---

