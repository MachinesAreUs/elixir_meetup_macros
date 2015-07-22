defmodule StateMachine do
  machine = [
    running: {:pause,  :paused},
    running: {:stop,   :stopped},
    paused:  {:resume, :running}
  ]

  for {state, {action, new_state}} <- machine do
    def unquote(action)(unquote(state)) do
      unquote(new_state)
    end
  end

  def initial, do: :running
end
