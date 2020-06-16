defmodule NarouUpdateNotifyBot.JobService.JobControlActivity do
  def job_activity?, do: !deterrent_file_exist?()

  def on,  do: deterrent_file_exist?()  && delete_deterrent_file()
  def off, do: !deterrent_file_exist?() && create_deterrent_file()

  defp deterrent_file_exist?, do: File.exists? deterrent_file_path()
  defp deterrent_file_path, do: Path.join(file_path(), file_name())
  defp file_path, do: (File.cwd |> elem(1)) <> "/tmp"
  defp file_name, do: "job_deterrent"
  defp create_deterrent_file, do: File.write deterrent_file_path(), ""
  defp delete_deterrent_file, do: File.rm deterrent_file_path()
end
