defmodule TogglReader do
  def get(token, uri) do
    HTTPoison.get(uri, [], [ hackney: [basic_auth: {token, "api_token"}] ])
  end

  def to_printable_time(duration) do
    {hours, leftovers} = float_to_tuple(duration / 1000 / 60 / 60)
    {minutes, leftovers} = float_to_tuple(leftovers * 60)
    seconds = Float.ceil(leftovers * 60)

    hh = "#{hours}"   |> String.slice(0..-3) |> String.pad_leading(2, "0")
    mm = "#{minutes}" |> String.slice(0..-3) |> String.pad_leading(2, "0")
    ss = "#{seconds}" |> String.slice(0..-3) |> String.pad_leading(2, "0")

    "#{hh}:#{mm}:#{ss}"
  end

  def float_to_tuple(float) do
    {Float.round(float), float - Float.round(float)}
  end

  def clients_list(token) do
    token
    |> get("https://www.toggl.com/api/v8/clients")
    |> body
    |> JSON.decode
    |> elem(1)
  end

  def body(response) do
    response
    |> elem(1)
    |> Map.get(:body)
  end

  def reports_uri() do
    query = [
      type: "me",
      user_agent: "api_test",
      since: Application.get_env(:toggl_reader, :start),
      until: Application.get_env(:toggl_reader, :finish),
      workspace_id: Application.get_env(:toggl_reader, :workspace)
    ] |> URI.encode_query
    "https://toggl.com/reports/api/v2/summary.json?" <> query
  end
end
