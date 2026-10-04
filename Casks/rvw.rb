cask "rvw" do
  version "1.0.0-beta.5"
  sha256 "619736db8393c336d9892da1ae95e4e431a5a7e44b18511075e4693772645c5f"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
