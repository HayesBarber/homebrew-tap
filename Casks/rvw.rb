cask "rvw" do
  version "2.1.0"
  sha256 "6279c3f34e524035fd4166a230680e4679a3264839d3f3fcc5d35c1fd205d840"

  url "https://github.com/HayesBarber/rvw/releases/download/v#{version}/Rvw-#{version}.zip"
  name "Rvw"
  desc "Code review and annotation tool"
  homepage "https://github.com/HayesBarber/rvw"

  depends_on macos: :sonoma

  app "Rvw.app"
  binary "#{appdir}/Rvw.app/Contents/MacOS/rvw-cli", target: "rvw"
end
