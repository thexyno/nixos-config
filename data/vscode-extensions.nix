{ pkgs, lib }:

let
  vscode-utils = pkgs.vscode-utils;
in
{
  "ms-python"."python" = vscode-utils.extensionFromVscodeMarketplace {
    name = "python";
    publisher = "ms-python";
    version = "2023.25.10111009";
    sha256 = "0bzxdkhxg9yz8ml9xhbghg4cc656gplwbjj969qqhdf60rsyl7il";
  };

  "ms-vscode"."cpptools" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cpptools";
    publisher = "ms-vscode";
    version = "1.19.1";
    sha256 = "1sa9012pbi6wz7c0rx8lwf8lrd7ffc25cd4jly2qk7kqfcp56in9";
  };

  "ms-toolsai"."jupyter-renderers" = vscode-utils.extensionFromVscodeMarketplace {
    name = "jupyter-renderers";
    publisher = "ms-toolsai";
    version = "1.0.17";
    sha256 = "1c065s2cllf2x90i174qs2qyzywrlsjkc6agcc9qvdsb426c6r9l";
  };

  "dbaeumer"."vscode-eslint" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-eslint";
    publisher = "dbaeumer";
    version = "2.4.2";
    sha256 = "1g5mavks3m4fnn7wav659rdnd9f3lp7r96g8niad4g1vaj4xm23q";
  };

  "redhat"."java" = vscode-utils.extensionFromVscodeMarketplace {
    name = "java";
    publisher = "redhat";
    version = "1.27.2024011308";
    sha256 = "134b3ar8qacanp4jxrbdrj97lg7imv93bw6aa1kczppghdi5nhjh";
  };

  "ms-azuretools"."vscode-docker" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-docker";
    publisher = "ms-azuretools";
    version = "1.28.0";
    sha256 = "0nmc3pdgxpmr6k2ksdczkv9bbwszncfczik0xjympqnd2k0ra9h0";
  };

  "vscjava"."vscode-java-debug" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-debug";
    publisher = "vscjava";
    version = "0.55.2023121302";
    sha256 = "0nhly0gvm6rg8ppfqbgb6vln34qpd98h3kxgsxzag880pgj1ak7j";
  };

  "ms-vscode"."cmake-tools" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cmake-tools";
    publisher = "ms-vscode";
    version = "1.17.7";
    sha256 = "0fvq1vkfb8p91y73kykb41ngwxfvak9g3x8nkffrb7gdfi59m9yn";
  };

  "vscjava"."vscode-maven" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-maven";
    publisher = "vscjava";
    version = "0.43.0";
    sha256 = "07bm7q13364zzbfbh6s5p5ll7labn41wdmj5b4dhp03y0fxhk9yi";
  };

  "ms-dotnettools"."csharp" = vscode-utils.extensionFromVscodeMarketplace {
    name = "csharp";
    publisher = "ms-dotnettools";
    version = "2.15.30";
    sha256 = "0s2rwaxbcl689x8gf8rmmzd09hqji32q371p6x3hix6y55n564fa";
  };

  "vscjava"."vscode-java-test" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-test";
    publisher = "vscjava";
    version = "0.40.2023122104";
    sha256 = "1nfbrsldlxadf4wskgpy9vr5qqyarg419pczzv7fh3v2wjm2lhr5";
  };

  "vscjava"."vscode-java-dependency" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-dependency";
    publisher = "vscjava";
    version = "0.23.2024010506";
    sha256 = "1z7v8ys7ksmnkc3b8l24c03221dj9c075yi4i98j66b07m74vzlh";
  };

  "ms-vscode"."cpptools-extension-pack" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cpptools-extension-pack";
    publisher = "ms-vscode";
    version = "1.3.0";
    sha256 = "11fk26siccnfxhbb92z6r20mfbl9b3hhp5zsvpn2jmh24vn96x5c";
  };

  "vscjava"."vscode-java-pack" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-pack";
    publisher = "vscjava";
    version = "0.25.2023121402";
    sha256 = "04vv88lmn4fs3gk84nyxcc0r5ay1pmzs59wwfrx78yqrd0mlj596";
  };

  "ms-vscode-remote"."remote-ssh" = vscode-utils.extensionFromVscodeMarketplace {
    name = "remote-ssh";
    publisher = "ms-vscode-remote";
    version = "0.108.2023112915";
    sha256 = "1ys59dys5kmijr9f2afbzbwm7dx7ps78jdwp89q1kb4c0aajmkx2";
  };

  "golang"."go" = vscode-utils.extensionFromVscodeMarketplace {
    name = "go";
    publisher = "golang";
    version = "0.40.1";
    sha256 = "0844kxbi7qi79wal0cqcd4wiygc42fyhamn33lsx2ms4yj5jxri9";
  };

  "ms-dotnettools"."vscode-dotnet-runtime" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-dotnet-runtime";
    publisher = "ms-dotnettools";
    version = "2.0.0";
    sha256 = "1sn454mv5vb9qspaarr8wp0yqx4g20c1mf0mjhhzmj9x92r9adx1";
  };

  "dart-code"."dart-code" = vscode-utils.extensionFromVscodeMarketplace {
    name = "dart-code";
    publisher = "dart-code";
    version = "3.81.20231227";
    sha256 = "0wqw4q5h3s7smrfd5igg49yf50ws9m5ad68vyshvfj6b0nkkrwzx";
  };

  "yzhang"."markdown-all-in-one" = vscode-utils.extensionFromVscodeMarketplace {
    name = "markdown-all-in-one";
    publisher = "yzhang";
    version = "3.6.1";
    sha256 = "1yibicrnbbrvcdlyjmw0w92391b25bi73k0zb87r793ckwkb3gq4";
  };

  "dart-code"."flutter" = vscode-utils.extensionFromVscodeMarketplace {
    name = "flutter";
    publisher = "dart-code";
    version = "3.81.20231227";
    sha256 = "12cfg4dwf9cbhl2bglfr44rqlmbx5asa7hspgdmwr64hd38wm2px";
  };

  "donjayamanne"."python-environment-manager" = vscode-utils.extensionFromVscodeMarketplace {
    name = "python-environment-manager";
    publisher = "donjayamanne";
    version = "1.2.4";
    sha256 = "02pdq9cllnr2ih638cbhfldsw4l8v6091fxk8wp7yvpylfhywfyn";
  };

  "davidanson"."vscode-markdownlint" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-markdownlint";
    publisher = "davidanson";
    version = "0.53.0";
    sha256 = "1jd2bgzmk11jgv897605ibfl38lr0yssmic6yv6mrrwcgvmrg402";
  };

  "vscodevim"."vim" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vim";
    publisher = "vscodevim";
    version = "1.27.2";
    sha256 = "0m5gdyvd3yg52d8zxwdw188wqjfvdyyvwnw5dz57pn633g5bi49v";
  };

  "bradlc"."vscode-tailwindcss" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-tailwindcss";
    publisher = "bradlc";
    version = "0.11.39";
    sha256 = "1l3iqkyj876ydg6qb0zzibbdx3603q46ivnyxgg0hc024fz47vzq";
  };

  "ms-vscode"."hexeditor" = vscode-utils.extensionFromVscodeMarketplace {
    name = "hexeditor";
    publisher = "ms-vscode";
    version = "1.9.12";
    sha256 = "0m8g3bd9gk0n3wcqy5w3kjz0sr06q0i88m7z8fkx52x9nla75lkf";
  };

  "firefox-devtools"."vscode-firefox-debug" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-firefox-debug";
    publisher = "firefox-devtools";
    version = "2.9.10";
    sha256 = "1w6ncs6f0azi4745zx82pi2z2zxn5vdvyr08y6kk7apzq89ybsy6";
  };

  "james-yu"."latex-workshop" = vscode-utils.extensionFromVscodeMarketplace {
    name = "latex-workshop";
    publisher = "james-yu";
    version = "9.18.0";
    sha256 = "105m211np7m8izg6ciffjaqy7yyzl5b9f7jvfrhi4xajdg6pi8ik";
  };

  "johnpapa"."vscode-peacock" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-peacock";
    publisher = "johnpapa";
    version = "4.2.3";
    sha256 = "04a5akgdzwr05snwam7r9m9mgyani48hy4c4xx9hp8nh7ddfwn29";
  };

  "rust-lang"."rust-analyzer" = vscode-utils.extensionFromVscodeMarketplace {
    name = "rust-analyzer";
    publisher = "rust-lang";
    version = "0.4.1805";
    sha256 = "0b8x02lhlr5049m5vakizlgv1xjawppnrczni1rp8ga0ng3w4d4s";
  };

  "ms-dotnettools"."csdevkit" = vscode-utils.extensionFromVscodeMarketplace {
    name = "csdevkit";
    publisher = "ms-dotnettools";
    version = "1.3.2";
    sha256 = "1niy7nwlvkcsrblg3m8j8bdpbyb9ihnb003pcmw9acbc24zy6253";
  };

  "alexisvt"."flutter-snippets" = vscode-utils.extensionFromVscodeMarketplace {
    name = "flutter-snippets";
    publisher = "alexisvt";
    version = "3.0.0";
    sha256 = "1vq4xpzdkk0bima5mx4nzxrfcqf168pm9wj0xi50lpv24vw4db24";
  };

  "denoland"."vscode-deno" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-deno";
    publisher = "denoland";
    version = "3.31.0";
    sha256 = "0p2y9kai1f768n58jfrk4c3qnz171nwhazik0kg7is08rnx2d8wy";
  };

  "jdinhlife"."gruvbox" = vscode-utils.extensionFromVscodeMarketplace {
    name = "gruvbox";
    publisher = "jdinhlife";
    version = "1.18.0";
    sha256 = "07iy4649vjqif40agvp2ck9695vl1kv4zv69rn4j6hi0jra8dhg2";
  };

  "sswg"."swift-lang" = vscode-utils.extensionFromVscodeMarketplace {
    name = "swift-lang";
    publisher = "sswg";
    version = "1.7.2";
    sha256 = "0h89skpyh5f8ri3jw8d63s0723fd0r6ha43r3cmvn1mzd0xqv8b1";
  };

  "arcanis"."vscode-zipfs" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-zipfs";
    publisher = "arcanis";
    version = "3.0.0";
    sha256 = "0wvrqnsiqsxb0a7hyccri85f5pfh9biifq4x2bllpl8mg79l5m68";
  };

  "valentjn"."vscode-ltex" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-ltex";
    publisher = "valentjn";
    version = "13.1.0";
    sha256 = "15qm97i9l65v3x0zxl1895ilazz2jk2wmizbj7kmds613jz7d46c";
  };

  "tauri-apps"."tauri-vscode" = vscode-utils.extensionFromVscodeMarketplace {
    name = "tauri-vscode";
    publisher = "tauri-apps";
    version = "0.2.6";
    sha256 = "03nfyiac562kpndy90j7vc49njmf81rhdyhjk9bxz0llx4ap3lrv";
  };

  "quarto"."quarto" = vscode-utils.extensionFromVscodeMarketplace {
    name = "quarto";
    publisher = "quarto";
    version = "1.110.1";
    sha256 = "0q25595v6jknb5rw14sy8wd2mpqbg52ffhrk5nwcw5fx9sfk4kgn";
  };

  "jnoortheen"."nix-ide" = vscode-utils.extensionFromVscodeMarketplace {
    name = "nix-ide";
    publisher = "jnoortheen";
    version = "0.2.2";
    sha256 = "1264027sjh9a112si0y0p3pk3y36shj5b4qkpsj207z7lbxqq0wg";
  };

  "mkhl"."direnv" = vscode-utils.extensionFromVscodeMarketplace {
    name = "direnv";
    publisher = "mkhl";
    version = "0.15.2";
    sha256 = "06lp4qgnksklgc6nvx1l9z38y7apbx0a6v886nd15aq9rq8my0ka";
  };
}

