class Srl < Formula
  include Language::Python::Virtualenv

  desc "Spaced repetition learning CLI tool"
  homepage "https://github.com/HayesBarber/spaced-repetition-learning"
  url "https://api.github.com/repos/HayesBarber/spaced-repetition-learning/tarball/v9.1.0"
  sha256 "f0597d9d2cff7fff5b906be6bf236d0fcb9c40e408db79d4bde74c7f2febe973"
  license "MIT"

  depends_on "python@3.12"

  resource "rich" do
    url "https://files.pythonhosted.org/packages/fb/d2/8920e102050a0de7bfabeb4c4614a49248cf8d5d7a8d01885fbb24dc767a/rich-14.2.0.tar.gz"
    sha256 "73ff50c7c0c1c77c8243079283f4edb376f0f6442433aecb8ce7e6d0b92d1fe4"
  end

  resource "fastapi" do
    url "https://files.pythonhosted.org/packages/0c/02/2cbbecf6551e0c1a06f9b9765eb8f7ae126362fbba43babbb11b0e3b7db3/fastapi-0.127.0.tar.gz"
    sha256 "5a9246e03dcd1fdb19f1396db30894867c1d630f5107dc167dcbc5ed1ea7d259"
  end

  resource "uvicorn" do
    url "https://files.pythonhosted.org/packages/c3/d1/8f3c683c9561a4e6689dd3b1d345c815f10f86acd044ee1fb9a4dcd0b8c5/uvicorn-0.40.0.tar.gz"
    sha256 "839676675e87e73694518b5574fd0f24c9d97b46bea16df7b8c05ea1a51071ea"
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/69/44/36f1a6e523abc58ae5f928898e4aca2e0ea509b5aa6f6f392a5d882be928/pydantic-2.12.5.tar.gz"
    sha256 "4d351024c75c0f085a9febbb665ce8c0c6ec5d30e903bdb6394b7ede26aebb49"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage: srl", shell_output("#{bin}/srl --help")
  end
end

