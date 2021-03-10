{ pkgs, ... }:

{
  nnn-vim = pkgs.vimUtils.buildVimPlugin {
    name = "nnn-vim";
    src = pkgs.fetchFromGitHub {
      owner = "mcchrish";
      repo = "nnn.vim";
      rev = "edfc91e1189a36a5f0d5438d7f9c575571f759fa";
      sha256 = "11dzqhd2kp537ig8zcny0j56644mmrgygiw3wvfh1ly9gb9l2r9f";
    };
  };
  coc-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "coc-vnim";
    src = pkgs.fetchFromGitHub {
      owner = "neoclide";
      repo = "coc.nvim";
      rev = "ab4f3f5797754334def047466a998b92f3076db9";
      sha256 = "1wr0v1kgv9km5rfc9g49897043gk3hraf07z8i937144z34qasf1";
      fetchSubmodules = true;
    };
  };
}
