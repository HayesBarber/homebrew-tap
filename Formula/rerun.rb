class Rerun < Formula
  desc "Watch a directory for file changes and automatically restart a command"
  homepage "https://github.com/HayesBarber/rerun"
  url "https://api.github.com/repos/HayesBarber/rerun/tarball/v1.2.0"
  sha256 "6b9a2d927d8f3f05db3134b93f17e0e4b6b93c99fc04df4aa0e23c9c27a5272e"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    assert_match "rerun", shell_output("#{bin}/rerun --help")
  end
end
