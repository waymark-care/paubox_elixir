defmodule Paubox.MixProject do
  use Mix.Project

  @source_url "https://github.com/waymark-care/paubox_elixir"
  @version "1.0.0"

  def project do
    [
      app: :paubox,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      source_url: @source_url,
      docs: [
        main: "readme",
        extras: ["README.md", "CHANGELOG.md", "LICENSE.txt"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
      {:mock, "~> 0.3.8", only: :test},
      {:plug, "~> 1.16", only: :test},
      {:typed_struct, ">= 0.3.0"},
      {:jason, ">= 1.0.0"},
      {:req, ">= 0.4.0"},
      {:mail, ">= 0.3.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "deps.compile"],
      clean: ["deps.clean --unused"]
    ]
  end

  defp description do
    """
    An Elixir client for the Paubox Email API
    """
  end

  defp package do
    [
      name: "paubox",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
