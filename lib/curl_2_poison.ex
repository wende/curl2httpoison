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
      H: :header,
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
    curl
    |> List.to_string
    |> parse_curl
  end
  def parse_curl(curl) do
    {keys, ["curl", url], []} =
      curl
      |> String.trim
      |> OptionParser.split()
      |> OptionParser.parse(@opts)

    headers = Keyword.get_values(keys, :header)
    method =
      keys
      |> Keyword.get(:method)
      |> Kernel.||("GET")
      |> String.downcase
      |> String.to_atom
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
    headers =
      headers
      |> Enum.map(fn h ->
      List.to_tuple String.split(h, ":")
    end)
      |> Macro.to_string
      |> String.replace("\\", "")
    """
    request(:#{method}, "#{url}", "#{body}", #{headers}, [])
    """
  end

  def gen_file(inputfile, outputfile, force \\ false) do
    filename = String.replace(outputfile, ~r/\.ex$/, "")
    modulename = Mix.Utils.camelize(filename)

    output = inputfile
    |> read_from
    |> gen(modulename)
    Mix.Generator.create_file(filename <> ".ex", output, [force: force])
  end

  def gen(curls, name) do
    endpoint = curls
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(fn curl -> parse_curl(curl) end)
    |> Enum.map(&elem(&1, 1))
    |> common_root()

    methods = curls
    |> Enum.map(fn {a, b} -> gen_def(a,b, endpoint) end)
    |> Enum.join("\n\n")
    |> String.split("\n")
    |> Enum.map(&("  " <> &1))
    |> Enum.join("\n")

    """
    defmodule #{name} do
      use HTTPoison.Base

      @endpoint "#{endpoint}"

      def process_url(url), do: @endpoint <> url

    """  <> methods <> "\nend\n"
  end

  def gen_def(name, curl, endpoint \\ "") do
    curl = curl |> parse_curl
    {m, url, body, hs} = curl

    url = if endpoint != "" do
      String.replace(url, endpoint, "")
    else
      url
    end

    {url_params, argumentized_url} = get_arguments(url)
    {body_params, argumentized_body} = get_arguments(body)

    hs = hs
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [header, val] ->
      {params, newval} = get_arguments(val)
      {params, header <> ":" <> newval}
    end)

    hs_params = hs
    |> Enum.reduce([], fn {params, _}, acc -> params ++ acc end)

    arg_hs = hs
    |> Enum.map(&elem(&1, 1))

    curl = {m, argumentized_url, argumentized_body, arg_hs}
    code = curl |> produce_code |> String.strip

    args = Enum.join(body_params ++ url_params ++ hs_params, ", ")
    """
    def #{name}(#{args}) do
      #{code}
    end
    def #{name}!(#{args}) do
      case #{name}(#{args}) do
        {:ok, response} -> response
        {:error, error} -> raise error
      end
    end
    """ |> String.strip
  end

  defp read_from(inputfile) do
    inputfile
    |> Code.eval_file
    |> elem(0)
  end

  def common_root(x, root \\ ""), do: common_root(x, root, String.length(root))
  def common_root([_], _, _), do: ""
  def common_root([h | _], root, length) when h == root, do: root
  def common_root([h | _] = xs, root, length) do
    newroot = elem(String.split_at(h, length + 1), 0)
    if Enum.all?(xs, &String.starts_with?(&1, newroot)) do
      common_root(xs, newroot, length + 1)
    else
      root
    end
  end

  @argregex ~r/\{\w+\}/
  def get_arguments(string) do
    argumentized =
      string
      |> String.replace(@argregex, "#\\g{0}")

    args = Regex.scan(@argregex, string) || []

    params =
      args
      |> List.flatten
      |> Enum.map(fn a -> Regex.run(~r/\w+/, a) |> hd end)

    {params, argumentized}
  end
end
