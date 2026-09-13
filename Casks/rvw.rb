cask "rvw" do
  version "1.0.0-alpha.6"
  sha256 "31eb9aca397179622854b89ceecf1c819779f2844b1c1068c7cbcdd80a0d3c8a"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"

  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"

  depends_on macos: :sonoma
end
