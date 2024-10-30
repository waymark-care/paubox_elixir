defmodule Paubox.ReadmeTest do
  use ExUnit.Case, async: true

  # Test if the README install version matches the current app version
  # Thanks to Dockyard's blog post for the idea
  # https://dockyard.com/blog/2019/02/22/keep-your-readme-install-instructions-up-to-date
  test "README install version check" do
    app = :paubox

    app_version = "#{Application.spec(app, :vsn)}"
    readme = File.read!("README.md")
    [_, readme_versions] = Regex.run(~r/{:#{app}, "(.+)"}/, readme)

    assert Version.match?(
             app_version,
             readme_versions
           ),
           """
           Install version constraint in README.md does not match to current app version.
           Current App Version: #{app_version}
           Readme Install Versions: #{readme_versions}
           """
  end
end
