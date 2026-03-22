class Wpm < Formula
  desc "A terminal typing speed test"
  homepage "https://github.com/HayesBarber/wpm"
  url "https://api.github.com/repos/HayesBarber/wpm/tarball/v1.0.0"
  sha256 "883745d9726cac4bcdfe51b8edb405148eec60a021c85250174c331b1e24d3bd"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    assert_match "wpm", shell_output("#{bin}/wpm --help")
  end
end
