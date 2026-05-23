class Srl < Formula
  include Language::Python::Virtualenv

  desc "Spaced repetition learning CLI tool"
  homepage "https://github.com/HayesBarber/spaced-repetition-learning"
  url "https://api.github.com/repos/HayesBarber/spaced-repetition-learning/tarball/v18.0.0"
  sha256 "1dfa25055dd6bf3c6c6a5372979af808dab6efa3d97cfdd0f23000240653acee"
  license "MIT"

  depends_on "python@3.10"

  resource "rich" do
    url "https://files.pythonhosted.org/packages/fb/d2/8920e102050a0de7bfabeb4c4614a49248cf8d5d7a8d01885fbb24dc767a/rich-14.2.0.tar.gz"
    sha256 "73ff50c7c0c1c77c8243079283f4edb376f0f6442433aecb8ce7e6d0b92d1fe4"
  end

  def install
    ENV["SETUPTOOLS_SCM_PRETEND_VERSION"] = version.to_s

    virtualenv_install_with_resources
  end

  test do
    assert_match "usage: srl", shell_output("#{bin}/srl --help")
  end
end

