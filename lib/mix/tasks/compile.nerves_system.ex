defmodule Mix.Tasks.Compile.NervesSystem do
  use Mix.Task

  @moduledoc """
  Build a Nerves System

  Compiler options
  compiler:
    :local - Compile the system locally
    :bakeware - Compile the system on bakeware

    The bakeware compile option will only download a cached image id the dependency is pulled form hex
  """

  def run(_args) do
    config = Mix.Project.config
    system = config[:app]

    {:ok, _} = Application.ensure_all_started(:nerves_system)
    {:ok, _} = Application.ensure_all_started(system)

    system_config = Application.get_all_env(system)

    target_name = system_config[:target] ||
      raise "Target required to be set in system env"

    nerves_system_config = Application.get_all_env(:nerves_system)
    |> Enum.into(%{})

    cache     = nerves_system_config[:cache]
    compiler  = nerves_system_config[:compiler] || :local

    target = config[:app_path]
    |> Path.join("system")

    stale =
      if (File.dir?(target)) do
        src =  Path.join(File.cwd!, "src")
        sources = src
        |> File.ls!
        |> Enum.map(& Path.join(src, &1))

        Mix.Utils.stale?(sources, [target])
      else
        true
      end
    if stale do
      Mix.shell.info "==> Compile Nerves System"
      system_tar =
        case cache(cache, %{recipe: "nerves/#{target_name}", version: config[:version]}) do
          {:ok, system_tar} -> system_tar
          _ -> #compile(compiler)
        end
      #build(toolchain_tar, target_tuple, config)
    end
    System.put_env("NERVES_SYSTEM", target)

    # Call out to make the system
    # Get config files from the caller "app" src
    #   /scr/nerves_defconfig

    # System.cmd(
    #   "make",
    #   ["-C", "deps/nerves_system_br", "O=_build/something", "NERVES_CONFIG=src/nerves_defconfig" , "config"]
    # )
    # System.cmd(
    #   "make",
    #   ["-C", "_build/something", "all"]
    # )
  end

  defp cache(:bakeware, params) do
    Application.ensure_all_started(:bake)
    Mix.shell.info "==> Checking Bakeware Cache"
    case Bake.Api.System.get(params) do
      {:ok, %{status_code: code, body: body} = resp} when code in 200..299 ->
        cache_response(Poison.decode!(body, keys: :atoms))
      {_, result} -> {:error, result}
    end
  end

  defp cache(_), do: {:error, :nocache}

  defp cache_response(%{data: %{host: host, path: path}}) do
    case Bake.Api.request(:get, "#{host}/#{path}", []) do
      {:ok, %{status_code: code, body: body}} when code in 200..299 ->
        Mix.shell.info "==> Using Bakeware Cache"
        {:ok, body}
      {_, result} -> {:error, result}
    end
  end

end
