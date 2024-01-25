{ pkgs, lib }:

let
  vscode-utils = pkgs.vscode-utils;
in
{









































  "valentjn"."vscode-ltex" = (vscode-utils.buildVscodeExtension {
    name = "valentjn.vscode-ltex";
    vscodeExtPublisher = "valentjn";
    vscodeExtName = "vscode-ltex";
    src = (pkgs.fetchurl {
      url = "https://github.com/valentjn/vscode-ltex/releases/download/13.1.0/vscode-ltex-13.1.0-offline-mac-x64.vsix";
      sha256 = "0s9vkgapzsly3143w04axg71xh52miyzsm7q74wqnzydh29ql3dz";
      name = "valentjn.vscode-ltex.zip";
    }).outPath;
    vscodeExtUniqueId = "valentjn.vscode-ltex";
    version = "13.1.0";
  });







  "ms-python"."python" = vscode-utils.extensionFromVscodeMarketplace {
    name = "python";
    publisher = "ms-python";
    version = "2023.25.10221012";
    sha256 = "14bkvlflib4wky6lw1hq0i01ymzf5349cl4d9minaam2lq0451i0";
  };

  "ms-vscode"."cpptools" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cpptools";
    publisher = "ms-vscode";
    version = "1.19.2";
    sha256 = "0amq6f59i12kppg56670a4300k2wswlpnjh12qx914p6r92jq9gx";
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
    version = "2.4.4";
    sha256 = "1c10n36a3bxwwjgd4vhrf79wg14dm0hxvz9z23pqdyxzcwrar49l";
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
    version = "0.43.2024011905";
    sha256 = "0hmv7m38ffai5cz7lsswfw6d58h2miczcppd7x6yc2i7vnv6v6pg";
  };

  "ms-dotnettools"."csharp" = vscode-utils.extensionFromVscodeMarketplace {
    name = "csharp";
    publisher = "ms-dotnettools";
    version = "2.16.24";
    sha256 = "019jr326hsrxvs40gvlz6xcmq37fmw64svs7hckwn8wiab83qv9z";
  };

  "vscjava"."vscode-java-test" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-test";
    publisher = "vscjava";
    version = "0.40.2024011806";
    sha256 = "1fnr8r9z2jz7gabc677zrhvdzqhlrrasnzlr2ralgq9pi3vpwyfa";
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
    version = "0.40.3";
    sha256 = "15kicpv9xpn7l3w9mbmsjdzjmavh88p3skkim0a9prg9p40bsq0m";
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
    version = "3.81.20240117";
    sha256 = "18hcvyvfli7h3y7h7272cbkmfqh6fazkbq75yr92561qq5i9hqc8";
  };

  "yzhang"."markdown-all-in-one" = vscode-utils.extensionFromVscodeMarketplace {
    name = "markdown-all-in-one";
    publisher = "yzhang";
    version = "3.6.2";
    sha256 = "1n9d3qh7vypcsfygfr5rif9krhykbmbcgf41mcjwgjrf899f11h4";
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
    version = "0.4.1818";
    sha256 = "028489jb8f4yy1g8bimna2fk0sk59ymj1zz5yavpm229ln24xkaw";
  };

  "vsls-contrib"."gitdoc" = vscode-utils.extensionFromVscodeMarketplace {
    name = "gitdoc";
    publisher = "vsls-contrib";
    version = "0.1.0";
    sha256 = "0sb5iwsrcqh6gsdngqy1wm6f6kqgqmx2kpqp6hkqri41j2phydjy";
  };

  "ms-dotnettools"."csdevkit" = vscode-utils.extensionFromVscodeMarketplace {
    name = "csdevkit";
    publisher = "ms-dotnettools";
    version = "1.3.6";
    sha256 = "1rwz7cs5raa5mlxal9rs33kbv99iaas82wjr0i1ii7mmps6k0djr";
  };

  "hediet"."vscode-drawio" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-drawio";
    publisher = "hediet";
    version = "1.6.6";
    sha256 = "0hwvcncl2206p7yjh7flr9qxxpk80mdj32fqh7wi57fb5sfi5xs8";
  };

  "bierner"."markdown-mermaid" = vscode-utils.extensionFromVscodeMarketplace {
    name = "markdown-mermaid";
    publisher = "bierner";
    version = "1.21.0";
    sha256 = "1ix0l8h1g32yn65nsc1sja7ddh42y5wdxbr7w753zdqyx04rs8v3";
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
    version = "3.33.1";
    sha256 = "00b9gz599h4dd3f9yy8nnr5vrx210j4pxhhzi4gmj16fbpaj7jp6";
  };

  "jdinhlife"."gruvbox" = vscode-utils.extensionFromVscodeMarketplace {
    name = "gruvbox";
    publisher = "jdinhlife";
    version = "1.18.0";
    sha256 = "07iy4649vjqif40agvp2ck9695vl1kv4zv69rn4j6hi0jra8dhg2";
  };

  "bierner"."markdown-footnotes" = vscode-utils.extensionFromVscodeMarketplace {
    name = "markdown-footnotes";
    publisher = "bierner";
    version = "0.1.1";
    sha256 = "1pp64x8cn4vmpscmzv2dg6bakjhnwd36rms2wl6bs5laq29k5wl7";
  };

  "bpruitt-goddard"."mermaid-markdown-syntax-highlighting" = vscode-utils.extensionFromVscodeMarketplace {
    name = "mermaid-markdown-syntax-highlighting";
    publisher = "bpruitt-goddard";
    version = "1.6.0";
    sha256 = "14vkkha82pnvvpg4pnzi4d5k9wp272mjmd2m3mrx0jn2kj9r10ax";
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


  "tauri-apps"."tauri-vscode" = vscode-utils.extensionFromVscodeMarketplace {
    name = "tauri-vscode";
    publisher = "tauri-apps";
    version = "0.2.6";
    sha256 = "03nfyiac562kpndy90j7vc49njmf81rhdyhjk9bxz0llx4ap3lrv";
  };

  "foam"."foam-vscode" = vscode-utils.extensionFromVscodeMarketplace {
    name = "foam-vscode";
    publisher = "foam";
    version = "0.25.7";
    sha256 = "11za3jb47vrxwxy6mqmvf23amkz27sfhjxfzrchl57ygzw5d0q84";
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
    version = "0.16.0";
    sha256 = "1jmwqbbh5x5z7dscgcn4pb0g41k7zlhgf5i8syl3ipv6z270aq5v";
  };
}

