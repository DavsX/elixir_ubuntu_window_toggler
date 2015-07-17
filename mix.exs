defmodule WindowToggler.Mixfile do
  use Mix.Project

  def project do
    [app: :window_toggler,
     version: "0.0.1",
     elixir: "~> 1.0",
     escript: escript,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp escript do
    [main_module: WindowToggler]
  end
end
