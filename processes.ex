defmodule Processes do
  def math do
    receive do
      {:halt} ->
        IO.puts("Server1 (#{inspect(self())}): Halting")
        case Process.whereis(:pid2) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{inspect(registered_pid)}")
                send(registered_pid, {:halt})
            end
        :ok
      {:add, x, y} ->
        IO.puts("Server1 (#{inspect(self())}): Math handling: #{x} + #{y} = #{x + y}")
        math()
      {:sub, x, y} ->
        IO.puts("Server1 (#{inspect(self())}): Math handling: #{x} - #{y} = #{x - y}")
        math()
      {:mult, x, y} ->
        IO.puts("Server1 (#{inspect(self())}): Math handling: #{x} * #{y} = #{x * y}")
        math()
      {:div, x, y} ->
        IO.puts("Server1 (#{inspect(self())}): Math handling: #{x} / #{y} = #{x / y}")
        math()
      {:'neg', x} ->
        IO.puts("Server1 (#{inspect(self())}): Math negation handling: #{x} = #{-x}")
        math()
      {:'sqrt', x} ->
        IO.puts("Server1 (#{inspect(self())}): Math sqrt handling: #{x} = #{:math.sqrt(x)}")
        math()
      something_else ->
        IO.puts("Server1 (#{inspect(self())}) passed #{something_else} down to next server!")
        case Process.whereis(:pid2) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                send(registered_pid,something_else)
            end
        math()
    end
  end

  def list do
    receive do
      {:halt} ->
        IO.puts("Server2 (#{inspect(self())}): Halting")
        case Process.whereis(:pid3) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{inspect(registered_pid)}")
                send(registered_pid, {:halt})
            end
        :ok
      [head | tail] when is_integer(head) ->
        result = Enum.sum([head | tail])
        IO.puts("Server2 (#{inspect(self())}): handing addition of list elements = #{result}")
        list()
      [head | tail] when is_float(head) ->
        result = multiply([head | tail])
        IO.puts("Server2 (#{inspect(self())}): handing multiplication of list elements = #{result}")
        list()
      something_else_tho ->
        IO.puts("Server2 (#{inspect(self())}) passed down to next server! #{something_else_tho}")
        case Process.whereis(:pid3) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{inspect(registered_pid)}")
                send(registered_pid, something_else_tho)
            end
        list()
    end
  end

  def third_one do
    third_one(0)
  end

  def third_one(current_count) do
    receive do
      {:halt} ->
        IO.puts("Server3 (#{inspect(self())}): Halting")
        IO.puts("Server3 (#{inspect(self())}): #{current_count} unprocessed items!")
        :ok
      {:error, x} ->
        IO.puts("Server3 (#{inspect(self())}) - Error: #{x}")
        third_one(current_count)
      something_new ->
        IO.puts("Server3 (#{inspect(self())}) - Not handled: #{something_new}")
        updated_count = current_count + 1
        third_one(updated_count)
    end
  end

  def multiply([]), do: 1
  def multiply([head | tail]), do: head * multiply(tail)

  def make_request(server_id, msg), do: send(server_id, msg)

  def start do
    pid1 = spawn(&math/0)
    IO.puts("Server1 pid is #{inspect(pid1)}")
    Process.register(pid1, :pid1)

    pid2 = spawn(&list/0)
    IO.puts("Server2 pid is #{inspect(pid2)}")
    Process.register(pid2, :pid2)

    pid3 = spawn(&third_one/0)
    IO.puts("Server3 pid is #{inspect(pid3)}")
    Process.register(pid3, :pid3)

    main_loop(pid1)
  end

  def main_loop(pid1) do
    message =  String.trim(IO.gets("Note: Since div is a keyword in Erlang,\nyou MUST provide it in this format: {:div, x, y} (enclose :div in atoms)\nEnter operation (ex. {:add, x, y}, [x, y, z]) or type 'all_done' or 'halt' to exit: "))
    if is_tuple(elem(Code.eval_string(message),0)) do
    message = elem(Code.eval_string(message),0)
    end 
    if is_list(elem(Code.eval_string(message),0)) do
    message = elem(Code.eval_string(message),0)
    end 
        IO.puts("Halting #{inspect(message)}")

    if message == "'halt'" do
    make_request(pid1, {:halt})
    end
    if message == "'all_done'" do
    make_request(pid1, {:halt})
    end
  end
end
