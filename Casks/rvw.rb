cask "rvw" do
  version "1.0.0-beta.6"
  sha256 "6ce154614405d2bc7069fdc46dd5511c64235bae723d176fa05aa6c87a42a84e"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
