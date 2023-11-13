defmodule Processes do
  def eval_code_or_default(code) do
    try do
      elem(Code.eval_string(code), 0)
    rescue
      _ -> String.to_atom(code)
    end
  end

  def math do
    receive do
      givenString ->
        convertedString = eval_code_or_default(givenString)

        case convertedString do
          {:halt} ->
            IO.puts("Server1 #{inspect(self())}: Halting")
            make_request(:PidTwo, :halt)
            exit(:kill)

          :halt ->
            IO.puts("Server1 #{inspect(self())}: Halting")
            make_request(:PidTwo, :halt)
            exit(:kill)

          {:all_done} ->
            IO.puts("Server1 #{inspect(self())}: Halting")
            make_request(:PidTwo, :halt)
            exit(:kill)

          :all_done ->
            IO.puts("Server1 #{inspect(self())}: Halting")
            make_request(:PidTwo, :halt)
            exit(:kill)

          {:add, x, y} ->
            result = x + y
            IO.puts("Server1 #{inspect(self())}: Math handling: #{x} + #{y} = #{result}")
            math()

          {:sub, x, y} ->
            result = x - y
            IO.puts("Server1 #{inspect(self())}: Math handling: #{x} - #{y} = #{result}")
            math()

          {:mult, x, y} ->
            result = x * y
            IO.puts("Server1 #{inspect(self())}: Math handling: #{x} * #{y} = #{result}")
            math()

          {:div, x, y} when y != 0 ->
            result = x / y
            IO.puts("Server1 #{inspect(self())}: Math handling: #{x} / #{y} = #{result}")
            math()

          {:neg, x} ->
            result = -x
            IO.puts("Server1 #{inspect(self())}: Math negation handling: #{x} = #{result}")
            math()

          {:sqrt, x} when x >= 0 ->
            result = :math.sqrt(x)
            IO.puts("Server1 #{inspect(self())}: Math sqrt handling: #{x} = #{result}")
            math()

          _ ->
            IO.puts("Server1 #{inspect(self())} passed #{givenString} down to the next server!")

            make_request(:PidTwo, givenString)
            math()
        end
    end
  end

  def list do
    receive do
      :halt ->
        IO.puts("Server2 #{inspect(self())}: Halting")
        make_request(:PidThree, :halt)
        exit(:kill)

      givenString ->
        convertedString = eval_code_or_default(givenString)

        case convertedString do
          [head | tail] when is_integer(head) ->
            result = Enum.sum([head | tail])
            IO.puts("Server2 #{inspect(self())}: Handling addition of list elements = #{result}")
            list()

          [head | tail] when is_float(head) ->
            result = multiply([head | tail])

            IO.puts(
              "Server2 #{inspect(self())}: Handling multiplication of list elements = #{result}"
            )

            list()

          _ ->
            IO.puts("Server2 #{inspect(self())} passed #{givenString} down to the next server! ")

            make_request(:PidThree, givenString)
            list()
        end
    end
  end

  def third_one do
    third_one(0)
  end

  defp third_one(current_count) do
    receive do
      :halt ->
        IO.puts("Server3 #{inspect(self())}: Halting")
        IO.puts("Server3 #{inspect(self())}: #{current_count} unprocessed items!")
        exit(:kill)

      givenString ->
        convertedString = eval_code_or_default(givenString)

        case convertedString do
          {:error, x} ->
            IO.puts("Server3 #{inspect(self())}- Error: #{x}")
            third_one(current_count)

          _ ->
            IO.puts("Server3 #{inspect(self())}- Not handled: #{givenString}")
            updated_count = current_count + 1
            third_one(updated_count)
        end
    end
  end

  def multiply([]), do: 1

  def multiply([head | tail]) do
    head * multiply(tail)
  end

  def make_request(server_id, msg) do
    send(server_id, msg)
  end

  def start do
    firstPID = spawn_link(__MODULE__, :math, [])
    IO.puts("Server1 pid is #{inspect(firstPID)}")
    Process.register(firstPID, :PidOne)

    secondPID = spawn(__MODULE__, :list, [])
    IO.puts("Server2 pid is #{inspect(secondPID)}")
    Process.register(secondPID, :PidTwo)

    thirdPID = spawn(__MODULE__, :third_one, [])
    IO.puts("Server3 pid is #{inspect(thirdPID)}")
    Process.register(thirdPID, :PidThree)
    main_loop(firstPID)
  end

  def main_loop(pid1) do
    IO.puts("Enter operation (ex. {add, X, Y}, [X,Y,Z]) or type 'all_done' or 'halt' to exit: ")

    message = IO.gets("") |> String.trim() |> String.replace_prefix("{", "{:")

    make_request(pid1, message)
    main_loop(pid1)
  end
end

Processes.start()
