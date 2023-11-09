defmodule Processes do
  def math do
    receive do
      {:halt} ->
        IO.puts("Server1 #{self()}: Halting")
        case Process.whereis({:worker, :pid2}) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{registered_pid}")
                send(registered_pid, {:halt})
            end
        :ok
      {:'add', x, y} ->
        IO.puts("Server1 (#{self()}): Math handling: #{x} + #{y} = #{x + y}")
        math()
      {:'sub', x, y} ->
        IO.puts("Server1 (#{self()}): Math handling: #{x} - #{y} = #{x - y}")
        math()
      {:'mult', x, y} ->
        IO.puts("Server1 (#{self()}): Math handling: #{x} * #{y} = #{x * y}")
        math()
      {:'div', x, y} ->
        IO.puts("Server1 (#{self()}): Math handling: #{x} / #{y} = #{x / y}")
        math()
      {:'neg', x} ->
        IO.puts("Server1 (#{self()}): Math negation handling: #{x} = #{-x}")
        math()
      {:'sqrt', x} ->
        IO.puts("Server1 (#{self()}): Math sqrt handling: #{x} = #{:math.sqrt(x)}")
        math()
      something_else ->
        IO.puts("Server1 (#{self()}) passed #{something_else} down to next server!")
        case Process.whereis({:worker, :pid2}) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{registered_pid}")
                send(registered_pid,something_else)
            end
        math()
    end
  end

  def list do
    receive do
      {:halt} ->
        IO.puts("Server2 (#{self()}): Halting")
        case Process.whereis({:worker, :pid3}) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{registered_pid}")
                send(registered_pid, {:halt})
            end
        :ok
      [head | tail] when is_integer(head) ->
        result = Enum.sum([head | tail])
        IO.puts("Server2 (#{self()}): handing addition of list elements = #{result}")
        list()
      [head | tail] when is_float(head) ->
        result = multiply([head | tail])
        IO.puts("Server2 (#{self()}): handing multiplication of list elements = #{result}")
        list()
      something_else_tho ->
        IO.puts("Server2 (#{self()}) passed down to next server! #{something_else_tho}")
        case Process.whereis({:worker, :pid3}) do
            nil ->
                IO.puts("Process not found.")
            registered_pid ->
                IO.puts("Found registered process: #{registered_pid}")
                send(registered_pid, something_else_tho)
            end
        list()
    end
  end

  def third_one do
    third_one(0)
  end

  defp third_one(current_count) do
    receive do
      {:halt} ->
        IO.puts("Server3 (#{self()}): Halting")
        IO.puts("Server3 (#{self()}): #{current_count} unprocessed items!")
        :ok
      {:error, x} ->
        IO.puts("Server3 (#{self()}) - Error: #{x}")
        third_one(current_count)
      something_new ->
        IO.puts("Server3 (#{self()}) - Not handled: #{something_new}")
        updated_count = current_count + 1
        third_one(updated_count)
    end
  end

  defp multiply([]), do: 1
  defp multiply([head | tail]), do: head * multiply(tail)

  defp make_request(server_id, msg), do: send(server_id, msg)

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

  defp main_loop(pid1) do
    IO.write("Note: Since div is a keyword in Erlang,\nyou MUST provide it in this format: {:div, x, y} (enclose :div in atoms)\nEnter operation (ex. {:add, x, y}, [x, y, z]) or type 'all_done' or 'halt' to exit: ")
    message = IO.gets("")

    case String.trim(message) do
      "all_done" ->
        make_request(pid1, {:halt})
      "halt" ->
        make_request(pid1, {:halt})
      _ ->
        make_request(pid1, String.to_existing_atom(message))
        main_loop(pid1)
    end
  end
end
