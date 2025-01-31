# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `Homebrew::DevCmd::GenerateCaskCiMatrix`.
# Please instead update this file by running `bin/tapioca dsl Homebrew::DevCmd::GenerateCaskCiMatrix`.


class Homebrew::DevCmd::GenerateCaskCiMatrix
  sig { returns(Homebrew::DevCmd::GenerateCaskCiMatrix::Args) }
  def args; end
end

class Homebrew::DevCmd::GenerateCaskCiMatrix::Args < Homebrew::CLI::Args
  sig { returns(T::Boolean) }
  def cask?; end

  sig { returns(T::Boolean) }
  def casks?; end

  sig { returns(T::Boolean) }
  def new?; end

  sig { returns(T::Boolean) }
  def skip_install?; end

  sig { returns(T::Boolean) }
  def syntax_only?; end

  sig { returns(T::Boolean) }
  def url?; end
end
