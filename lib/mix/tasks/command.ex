defmodule Mix.Tasks.Command do
  use Mix.Task
  import Mix.Generator

  @shortdoc "コマンド、テンプレートの生成"
  def run(opt) do
    validate(opt)

    mod_path = opt |> hd

    create(mod_path, :command , spec: true)
    create(mod_path, :template, spec: true)
  end

  def validate(opt) do
    path_to_file_pattern = ~r/^[a-z]+(_[a-z]+)*(\/[a-z]+(_[a-z]+)*)*$/

    unless Regex.match?(path_to_file_pattern, opt |> hd), do: raise "引数が無効です。 path/to/command"
  end

  def create(path, type, _opt) do
    mod = target_mod(path |> String.split("/"), type)

    dao = [module_name: mod, template: template_for(type)]

    create_file(source_path_from(path, type), source_template(dao))
    create_file(spec_path_from(path, type),   spec_template(dao))
  end

  @spec target_mod(list(binary), atom) :: atom
  def target_mod(mod_names, type) do
    [app_module()] ++ (
      ([to_string(type)] ++ mod_names) |> Enum.map(&(Macro.camelize(&1)))
    )
    |> Enum.join(".")
  end

  def pp(mod) do
    IO.inspect mod
    mod
  end

  def source_path_from(mod, type), do: target_path(mod, type) <> ".ex"
  def spec_path_from(mod, type),   do: "spec/" <> target_path(mod, type) <> "_spec.exs"

  def target_path(mod, type) do
    (["lib", Mix.Project.config[:app] |> Atom.to_string(), to_string(type), mod])
    |> Path.join()
    |> Path.relative_to(Mix.Project.app_path)
  end

  def app_module, do: Mix.Project.config[:app] |> Atom.to_string |> Macro.camelize()

  def template_for(:command) do
    String.trim_trailing """
      use NarouUpdateNotifyBot.Command

      def call(param) do

      end
    """
  end

  def template_for(:template) do
    String.trim_trailing """
      use NarouUpdateNotifyBot.Template
      alias LineBot.Message, as: M

      def render(:ok, dao) do

      end
    """
  end

  embed_template :source, """
  defmodule <%= @module_name %> do
  <%= @template %>
  end
  """

  embed_template :spec, """
  defmodule <%= @module_name %>Spec do
    use ESpec
    alias <%= @module_name %>
  end
  """
end
