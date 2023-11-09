defmodule GettingStarted do
    def fullFunction do
      given_num = get_numData()
      
      case is_integer(given_num) do
        true ->
          case given_num < 0 do
            true ->
              result = abs(given_num ** 7)
              IO.puts("Absolute value raised to the 7th power: #{result}")
            false ->
              case given_num do
                0 ->
                  IO.puts("GivenNum is: 0")
                _ when rem(given_num, 7) == 0 ->
                  result = given_num ** (1/5)
                  IO.puts("5th root of GivenNum is: #{result}")
                _ ->
                  result = factorial(given_num)
                  IO.puts("Factorial of GivenNum is: #{result}")
              end
          end
        false ->
          IO.puts("Not an integer")
      end
    end
    
    def get_numData() do
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
        
        a
      end 
    defp factorial(0), do: 1
    defp factorial(n) when n > 0, do: n * factorial(n - 1)
  end
  
  GettingStarted.fullFunction()