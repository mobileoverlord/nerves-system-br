defmodule NervesSystem.Mixfile do
  use Mix.Project

  def project do
    [app: :nerves_system,
     version: "0.4.0-dev",
     elixir: "~> 1.2",
     compilers: [:app],
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
