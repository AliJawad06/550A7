defmodule Looping do

  def factorial(0), do: 1
  def factorial(n) when n > 0, do: n * factorial(n - 1)

  def full_function(0), do: :halt
  def full_function(given_num) do
    case is_integer(given_num) do
      true ->
        case given_num < 0 do
          true ->
            result = :math.pow(abs(given_num), 7)
            IO.puts("Absolute value raised to the 7th power: #{result}")
          false ->
            case given_num do
              0 ->
                IO.puts("GivenNum is: 0")
              _ when rem(given_num, 7) == 0 ->
                result = :math.pow(given_num, 1 / 5)
                IO.puts("5th root of GivenNum is: #{result}")
              _ ->
                result = factorial(given_num)
                IO.puts("Factorial of GivenNum is: #{result}")
            end
        end
      false ->
        IO.puts("Not an integer")
    end
    start()
  end

def start do
    numOfGiven = IO.gets("Enter a number: ")
        
        a =
          case String.contains?(numOfGiven, ".") do
            true -> 
              {a, _b} = Float.parse(numOfGiven)
              a
            false -> 
              {a, _b} = Integer.parse(numOfGiven)
              a
          end
    full_function(a)
  end

end

Looping.start()
