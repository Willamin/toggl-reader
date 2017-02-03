defmodule Mix.Tasks.TogglReader.Go do
  use Mix.Task
  import TogglReader

  @shortdoc "Give a short salutation"

  def run(_) do
    HTTPoison.start
    Application.get_env(:toggl_reader, :api_token)
    |> get_time_spent
    |> to_printable_time
    |> IO.puts
  end

  def get_time_spent(token) do
    token
    |> get(reports_uri())
    |> body
    |> JSON.decode
    |> elem(1)
    |> Map.get("data")
    |> Enum.filter(fn(x) ->
      x
      |> Map.get("title")
      |> Map.get("client")
      == Application.get_env(:toggl_reader, :client_name)
    end)
    |> Enum.reduce(0, fn(x, acc) ->
      acc + Map.get(x, "time")
    end)
  end
end
