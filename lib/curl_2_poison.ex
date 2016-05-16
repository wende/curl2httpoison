defmodule Curl2Poison do
  @moduledoc false

  @opts [
    switches: [
      header: [:list, :keep]
    ],
    aliases: [
      d: :body,
      X: :method
    ]
  ]

  def feed_curl(curl) when is_list(curl) do
    feed_curl(List.to_string(curl))
  end
  def feed_curl(curl) do
    {keys, ["curl", url], []} = curl
    |> OptionParser.split()
    |> OptionParser.parse(@opts)

    headers = Keyword.get_values(keys, :header)
    method = Keyword.get(keys, :method) |> String.downcase |> String.to_atom
    body = Keyword.get(keys, :body) || ""

    produce_code(method, url, body, headers)
  end

  def produce_code(method, url, body, headers \\ []) do
    """
    request(:#{method}, "#{url}", "#{body}", #{inspect(headers)}, [])
    """
  end
end
