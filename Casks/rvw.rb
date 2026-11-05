cask "rvw" do
  version "2.0.0"
  sha256 "141f2121cb1b0ed5de9bd425f27639793d165871fd0b7b39c4a4f134a928ec3f"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
