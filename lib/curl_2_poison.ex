defmodule Curl2httpoison do

  @moduledoc """
  Curl2httpoison is a module used for converting curl request string to
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
  iex> Curl2httpoison.parse_curl("curl -X POST http://google.pl")
  {:post, "http://google.pl", "", []}
  """
  @spec parse_curl(String.t()) :: String.t()
  def parse_curl(curl) when is_list(curl) do
    parse_curl(List.to_string(curl))
    |> produce_code()
  end
  def parse_curl(curl) do
    {keys, ["curl", url], []} = curl
    |> String.strip
    |> OptionParser.split()
    |> OptionParser.parse(@opts)

    headers = Keyword.get_values(keys, :header)
    method = Keyword.get(keys, :method) |> String.downcase |> String.to_atom
    body = Keyword.get(keys, :body) || ""

    {method, url, body, headers}
  end

  @doc """
  Convert curl string to HTTPPoison call
  ## Example
  iex> Curl2httpoison.produce_code({:post, "http://google.pl", "", []})
  "request(:post, \\"http://google.pl\\", \\"\\", [], [])\n"
  """
  def produce_code({method, url, body, headers}) do
    """
    request(:#{method}, "#{url}", "#{body}", #{inspect(headers)}, [])
    """
  end

  def gen_file(inputfile, outputfile) do
    filename = String.replace(outputfile, ~r/\.ex$/, "")
    modulename = Mix.Utils.camelize(filename)

    output = inputfile
    |> read_from
    |> gen(modulename)
    Mix.Generator.create_file(filename <> ".ex", output)
  end

  def gen(curls, name) do
    endpoint = curls
    |> Enum.map(&elem(&1, 1))
    |> common_root()

    methods = curls
    |> Enum.map(fn {a, b} -> gen_def(a,b) end)
    |> Enum.join("\n")
    |> String.split("\n")
    |> Enum.map(&("  " <> &1))
    |> Enum.join("\n")

    """
    defmodule #{name} do
      use HTTPoison.Base

      @endpoint "#{endpoint}"

      def process_url(url), do: endpoint <> url

    """  <> methods <> "\nend\n"
  end

  def gen_def(name, curl) do
    """
    def #{name}() do
      #{curl |> parse_curl |> produce_code |> String.strip}
    end
    """ |> String.strip
  end

  defp read_from(inputfile) do
    inputfile
    |> Code.eval_file
    |> elem(0)
  end

  def common_root(xs, root \\ ""), do: common_root(xs, root, String.length(root))
  def common_root([_], _, _), do: ""
  def common_root([h | _] = xs, root, length) do
    newroot = elem(String.split_at(h, length + 1), 0)
    if Enum.all?(xs, &String.starts_with?(&1, newroot)) do
      common_root(xs, newroot, length + 1)
    else
      root
    end
  end
end
