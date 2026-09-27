cask "rvw" do
  version "1.0.0-beta.2"
  sha256 "c94f829fb1f414e1856902cd22417dcc1cbd9ede26339f9bdd190b56d1f99787"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"

  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"

  depends_on macos: :sonoma
end
