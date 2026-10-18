cask "rvw" do
  version "1.0.2"
  sha256 "c632732ac4a07e001a167afe5e02b5184a20bb85f664804c49b217269d109fbe"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
