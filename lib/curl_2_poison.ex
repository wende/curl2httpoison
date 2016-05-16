defmodule Curl2Poison do
  @moduledoc """
  Curl2Poison is a module used for converting curl request string to
  HTTPPoison call.
  """

  @opts [
    switches: [
      header: [:list, :keep]
    ],
    aliases: [
      d: :body,
      X: :method
    ]
  ]
  
  @doc """
  Convert curl string to HTTPPoison call
  ## Example
  iex> Curl2Poison.parse_curl("curl -X POST http://google.pl")
  "request(:post, \\"http://google.pl\\", \\"\\", [], [])\n"
  """
  @spec parse_curl(string) :: string
  def parse_curl(curl) when is_list(curl) do
    parse_curl(List.to_string(curl))
  end
  def parse_curl(curl) do
    {keys, ["curl", url], []} = curl
    |> OptionParser.split()
    |> OptionParser.parse(@opts)

    headers = Keyword.get_values(keys, :header)
    method = Keyword.get(keys, :method) |> String.downcase |> String.to_atom
    body = Keyword.get(keys, :body) || ""

    produce_code(method, url, body, headers)
  end

  defp produce_code(method, url, body, headers \\ []) do
    """
    request(:#{method}, "#{url}", "#{body}", #{inspect(headers)}, [])
    """
  end
end
