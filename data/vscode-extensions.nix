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
    version = "2024.3.10641005";
    sha256 = "0ghzcgs1lri35blshs482x0f0mbx0hrrfb3cizv0glrwglz7728p";
  };
  "ms-python"."vscode-pylance" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-pylance";
    publisher = "ms-python";
    version = "2024.2.105";
    sha256 = "0iyz05nbkfmpn564axnd2fi1a4h15nr9yq3lzrxyd6zd7wk5ax73";
  };
  "ms-vscode"."cpptools" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cpptools";
    publisher = "ms-vscode";
    version = "1.19.4";
    sha256 = "0c1dj8ngqwdi9zh203s7mirfhbyqzxdcmq46m4xyaqkkjrya1fd2";
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
    version = "1.29.0";
    sha256 = "0rz32qwdf7a5hn3nnhxviaf8spwsszfrxmhnbbskspi5r9b6qm4r";
  };
  "eamodio"."gitlens" = vscode-utils.extensionFromVscodeMarketplace {
    name = "gitlens";
    publisher = "eamodio";
    version = "2024.3.404";
    sha256 = "01mr5kgz5gm3flmps8kk8j1zal1rrr086qjcm55r7ycb6ll7yaba";
  };
  "ms-vscode"."cmake-tools" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cmake-tools";
    publisher = "ms-vscode";
    version = "1.18.4";
    sha256 = "06gjyv87ncm2l964lj6xydckk7vjmsxlvcah94r3b1g6nygh1wp2";
  };
  "vscjava"."vscode-java-debug" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-debug";
    publisher = "vscjava";
    version = "0.56.2024022605";
    sha256 = "1r0xq2qsyd0vmk2vfa6i1vr8hahj74a2kn1sj7ij8pgks3hjv2x7";
  };
  "vscjava"."vscode-maven" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-maven";
    publisher = "vscjava";
    version = "0.44.2024013105";
    sha256 = "0fpfr1g6dfrrrdc4i8q19xzx5rqd0irpsba2qhipx08kjr3z57iv";
  };
  "ms-dotnettools"."csharp" = vscode-utils.extensionFromVscodeMarketplace {
    name = "csharp";
    publisher = "ms-dotnettools";
    version = "2.19.13";
    sha256 = "1nw7y6lj4qz0k88mb44cp8mg79rps6whlfiab4dj716svnih0afi";
  };
  "ms-vscode"."cpptools-extension-pack" = vscode-utils.extensionFromVscodeMarketplace {
    name = "cpptools-extension-pack";
    publisher = "ms-vscode";
    version = "1.3.0";
    sha256 = "11fk26siccnfxhbb92z6r20mfbl9b3hhp5zsvpn2jmh24vn96x5c";
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
    version = "0.23.2024022305";
    sha256 = "18amdhi17fdwhfzip4l14429fcqw9rl6d03kg4yjfxqshj87jwcr";
  };
  "vscjava"."vscode-java-pack" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-java-pack";
    publisher = "vscjava";
    version = "0.25.2023121402";
    sha256 = "04vv88lmn4fs3gk84nyxcc0r5ay1pmzs59wwfrx78yqrd0mlj596";
  };
  "ms-vscode-remote"."remote-containers" = vscode-utils.extensionFromVscodeMarketplace {
    name = "remote-containers";
    publisher = "ms-vscode-remote";
    version = "0.349.0";
    sha256 = "0krahb8ymnamp20iq4crqjyj37wmvyfrijs4ippxs3620pb9mi6r";
  };
  "ms-vscode-remote"."remote-ssh" = vscode-utils.extensionFromVscodeMarketplace {
    name = "remote-ssh";
    publisher = "ms-vscode-remote";
    version = "0.109.2024022215";
    sha256 = "0bdlqbln7bhlshmi828qkv1l9646rffwaddrikfqiahrz19vm9g4";
  };
  "ms-python"."debugpy" = vscode-utils.extensionFromVscodeMarketplace {
    name = "debugpy";
    publisher = "ms-python";
    version = "2024.3.10611007";
    sha256 = "0bvhv8vxb6l5gyd85imm3p94j8qgfvmcym11v9gvzl0sns38z2bq";
  };
  "golang"."go" = vscode-utils.extensionFromVscodeMarketplace {
    name = "go";
    publisher = "golang";
    version = "0.41.1";
    sha256 = "0i4h458x90v2bfr0la8axg6fs0756f2paby6h34pj4vflhi78axm";
  };
  "ms-dotnettools"."vscode-dotnet-runtime" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-dotnet-runtime";
    publisher = "ms-dotnettools";
    version = "2.0.2";
    sha256 = "018fkmx47fa01hwzqqnjsb0b014vash04llifa8pbrn04lx7rp7c";
  };
  "dart-code"."dart-code" = vscode-utils.extensionFromVscodeMarketplace {
    name = "dart-code";
    publisher = "dart-code";
    version = "3.85.20240304";
    sha256 = "01hfjw146qxrjwp4acr55vgksrwdjwpj9d66glxggihzi3cl822k";
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
    version = "3.85.20240301";
    sha256 = "0wz6bzjjd1z3pg5gv6ywqv5is6qfi1isszqr4dm97nmlph4bh59d";
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
    version = "0.54.0";
    sha256 = "171qw6mymc9hmm8xin3gwr8r2ac8yfr3s8agagsqq9193cawbcq6";
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
    version = "0.11.40";
    sha256 = "10z3gj6jcyszsg6nkqdsfvkl7jhcw5p55122g9515v20vdwqwg4y";
  };
  "ms-vscode"."hexeditor" = vscode-utils.extensionFromVscodeMarketplace {
    name = "hexeditor";
    publisher = "ms-vscode";
    version = "1.9.14";
    sha256 = "0fncakv8v8p1rhka5dvh87kc0vsfaxg1s48blwhv7r6fyw70b9jm";
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
    version = "9.18.2";
    sha256 = "1bzzrq8bd73gjs8jrqnwqil6hd6bs6zbbrv35ngz31hx7wsgkw1s";
  };
  "rust-lang"."rust-analyzer" = vscode-utils.extensionFromVscodeMarketplace {
    name = "rust-analyzer";
    publisher = "rust-lang";
    version = "0.4.1818";
    sha256 = "sha256-PqIqoeDxgwNzXSIaAIgslR7PyeU9Kc5iHaFhRWOL7Tc=";
  };
  "johnpapa"."vscode-peacock" = vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-peacock";
    publisher = "johnpapa";
    version = "4.2.3";
    sha256 = "04a5akgdzwr05snwam7r9m9mgyani48hy4c4xx9hp8nh7ddfwn29";
  };
  "ms-dotnettools"."csdevkit" = vscode-utils.extensionFromVscodeMarketplace {
    name = "csdevkit";
    publisher = "ms-dotnettools";
    version = "1.4.6";
    sha256 = "14q5s272mwnwrvy9ihynq1dvb96zz82ms96273vklbdn2i51f9bl";
  };
  "sonarsource"."sonarlint-vscode" = vscode-utils.extensionFromVscodeMarketplace {
    name = "sonarlint-vscode";
    publisher = "sonarsource";
    version = "4.3.0";
    sha256 = "14cdyiq9wf0yrxkh1sfszmp9vb0qvkp99xs6wxz2y4n8y5npryp6";
  };
  "vsls-contrib"."gitdoc" = vscode-utils.extensionFromVscodeMarketplace {
    name = "gitdoc";
    publisher = "vsls-contrib";
    version = "0.1.0";
    sha256 = "0sb5iwsrcqh6gsdngqy1wm6f6kqgqmx2kpqp6hkqri41j2phydjy";
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
    version = "1.22.0";
    sha256 = "1ii6slnmj5ck40mdnixbybqjqbmqg7wl7yqw66p31wsnpqk71q28";
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
    version = "3.33.3";
    sha256 = "039yj1c9w42w3nwg00ab4kjwxzznscq481rkbjw5mi094cfmh1lk";
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
    version = "1.8.0";
    sha256 = "142qii5lcvp2fmvknjl2zziyydmac76jdxqsnrc2a8pf09hbgd74";
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
    version = "0.25.8";
    sha256 = "0b3bjiw5s0i1jajc9ybmmri566gr8mp68flbyxpn4mqs4bwdfxdn";
  };
  "quarto"."quarto" = vscode-utils.extensionFromVscodeMarketplace {
    name = "quarto";
    publisher = "quarto";
    version = "1.111.0";
    sha256 = "196axk27vclp3iaxf7230sgxjp592p858ga6idrhw61r7nnsngd8";
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

