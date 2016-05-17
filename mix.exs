defmodule Curl_2Poison.Mixfile do
  use Mix.Project

  def project do
    [app: :curl2httpoison,
     version: "0.2.0",
     description: "Curl2HTTPoison transform your curl request to HTTPPoison request code",
     elixir: "~> 1.2",
     aliases: aliases,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
  defp package do
    [ maintainers: ["Krzysztof Wende"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/edgurgel/httpoison"} ]
  end

  defp aliases do
    [curl2http: &curl2http/1]
  end

  defp curl2http(args) do
    Mix.shell(Mix.Shell.Process)
    Mix.Tasks.Compile.run([])
    IO.puts Curl2HTTPoison.parse_curl(Enum.join(args, " "))
  end
end
