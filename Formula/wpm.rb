class Wpm < Formula
  desc "A terminal typing speed test"
  homepage "https://github.com/HayesBarber/wpm"
  url "https://api.github.com/repos/HayesBarber/wpm/tarball/v1.1.0"
  sha256 "8b648a208099a313218ca17402d4953534fe1ef2319bc5887c0e30225d1a0094"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    assert_match "wpm", shell_output("#{bin}/wpm --help")
  end
end
