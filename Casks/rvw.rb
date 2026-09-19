cask "rvw" do
  version "1.0.0-alpha.7"
  sha256 "8971d690405ac04ede23c1657f0975f93b2c2f0b82e977b77c58868220393953"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"

  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"

  depends_on macos: :sonoma
end
