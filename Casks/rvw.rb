cask "rvw" do
  version "1.0.0-beta.3"
  sha256 "044d49c9f6386b7a8a908a69bc5bc5a83754e1b203b2688f7aca15fd416801a9"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
