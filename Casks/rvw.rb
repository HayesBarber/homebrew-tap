cask "rvw" do
  version "1.0.0-beta.7"
  sha256 "055945958c2c2d22801ebab02b52506b0214f8ffe0c206b3fa2b9ed388ff5745"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
