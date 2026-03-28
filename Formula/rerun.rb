class Rerun < Formula
  desc "Watch a directory for file changes and automatically restart a command"
  homepage "https://github.com/HayesBarber/rerun"
  url "https://api.github.com/repos/HayesBarber/rerun/tarball/v1.1.0"
  sha256 "b2c7d8a540586a39da46a2653608079b44c0398fc4a14a6f6840ba110dbaa5cc"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    assert_match "rerun", shell_output("#{bin}/rerun --help")
  end
end
