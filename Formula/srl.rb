class Srl < Formula
  include Language::Python::Virtualenv

  desc "Spaced repetition learning CLI tool"
  homepage "https://github.com/HayesBarber/spaced-repetition-learning"
  url "https://api.github.com/repos/HayesBarber/spaced-repetition-learning/tarball/v9.1.0"
  sha256 "SHA256_HERE"
  license "MIT"

  depends_on "python@3.12"

  resource "rich" do
    url "https://files.pythonhosted.org/packages/source/r/rich/rich-VERSION.tar.gz"
    sha256 "RICH_SHA256_HERE"
  end

  resource "fastapi" do
    url "https://files.pythonhosted.org/packages/source/f/fastapi/fastapi-VERSION.tar.gz"
    sha256 "FASTAPI_SHA256_HERE"
  end

  resource "uvicorn" do
    url "https://files.pythonhosted.org/packages/source/u/uvicorn/uvicorn-VERSION.tar.gz"
    sha256 "UVICORN_SHA256_HERE"
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/source/p/pydantic/pydantic-VERSION.tar.gz"
    sha256 "PYDANTIC_SHA256_HERE"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "srl", shell_output("#{bin}/srl --help")
    system "#{bin}/srl", "--version"
  end
end

