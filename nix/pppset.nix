{
  lib,
  stdenv,
  makeWrapper,
  symlinkJoin,
  writeText,
  pandoc,
  texlive,
  biz-ud-gothic,
  fira,
  firge-nerd-font,
  noto-fonts,
  noto-fonts-cjk-serif-static,
}:
let
  # 必要なTeX Liveコレクションを束ねます。
  # `scheme-medium`はbeamerやmicrotypeなど一般的な文書クラスを含み、
  # `luatexja`はLuaTeX-jaと`ltjarticle`等のクラスを提供します。
  # `haranoaji`はLuaTeX-jaがデフォルト和文フォントとして読み込むため、
  # 個別の`\setmainjfont`で上書きする前に必須となります。
  pppsetTexlive = texlive.combine {
    inherit (texlive)
      haranoaji
      luatexja
      scheme-medium
      ;
  };

  # `article.sty`と`markdown2beamer`が参照するフォント群です。
  # ロール構成は`~/dotfiles/home/core/font.nix`に揃えています。
  # `noto-fonts-cjk-serif`の通常版はvariable fontを`.ttc`に詰めた形式で、
  # luaotfloadが`loca table not found`で読み込みに失敗するため、
  # ウェイト別に`.ttc`に分かれたstatic版を採用しています。
  pppsetFonts = [
    biz-ud-gothic
    fira
    firge-nerd-font
    noto-fonts
    noto-fonts-cjk-serif-static
  ];

  # luaotfloadが参照する`OSFONTDIR`に単一ディレクトリで渡せるよう、複数フォントパッケージを統合します。
  # kpathseaの`$OSFONTDIR//`再帰展開は、コロン区切りの複数パスでは末尾のパスにしか効かない挙動があるため、
  # `symlinkJoin`でひとつの`share/fonts`ツリーに集約することで全フォントを再帰スキャンの対象にします。
  pppsetFontDir = symlinkJoin {
    name = "pppset-fonts";
    paths = pppsetFonts;
  };

  # 利用者環境のfontconfigに混入した同名フォント(`Noto Serif CJK JP`のVariable Font版など)を
  # 拾わないよう、本パッケージ専用の`fonts.conf`で発見対象を限定します。
  # `nixpkgs.makeFontsConf`は`~/.nix-profile`や`/etc/fonts/conf.d`などをincludeするため、
  # 隔離目的では使えません。自前で最小限の構成を生成します。
  pppsetFontsConf = writeText "pppset-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
    ${lib.concatMapStringsSep "\n" (font: "  <dir>${font}/share/fonts</dir>") pppsetFonts}
      <cachedir prefix="xdg">fontconfig-pppset</cachedir>
    </fontconfig>
  '';

  # luaotfloadは`FONTCONFIG_FILE`を経由せず`/etc/fonts/fonts.conf`を直接読み込みOSフォント走査を行うため、
  # 利用者環境にインストールされた同名のVariable Fontを拾ってしまいます。
  # `location-precedence`を`texmf`のみに絞ってOSフォント走査を抑止し、
  # 走査対象を`OSFONTDIR`が指す本パッケージのフォントのみに限定します。
  pppsetXdgConfig = stdenv.mkDerivation {
    name = "pppset-xdg-config";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/luaotfload
      cat > $out/luaotfload/luaotfload.conf <<'EOF'
      [db]
      location-precedence = texmf
      EOF
    '';
  };
in
stdenv.mkDerivation {
  pname = "pppset";
  version = "0.0.0";

  src = ./..;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 src/bin/markdown2article -t $out/bin/
    install -Dm755 src/bin/markdown2beamer -t $out/bin/
    install -Dm644 src/share/pppset/article.sty -t $out/share/pppset/
    install -Dm644 src/share/pppset/beamer.sty -t $out/share/pppset/

    for script in $out/bin/*; do
      wrapProgram "$script" \
        --prefix PATH : ${
          lib.makeBinPath [
            pandoc
            pppsetTexlive
          ]
        } \
        --prefix OSFONTDIR : ${pppsetFontDir}/share/fonts \
        --set FONTCONFIG_FILE ${pppsetFontsConf} \
        --set XDG_CONFIG_HOME ${pppsetXdgConfig} \
        --run ${
          # luaotfloadのフォント名キャッシュはシステムのfontconfig走査結果を保持しており、
          # 同名フォントの参照先がvariable font版になっていると本パッケージから読めなくなります。
          # 専用の`TEXMFCACHE`を割り当てて、隔離したフォント環境から都度再構築させます。
          lib.escapeShellArg ''
            export TEXMFCACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/pppset/texmf-var"
            mkdir -p "$TEXMFCACHE"
          ''
        }
    done

    runHook postInstall
  '';

  meta = {
    description = "pandoc pdf page personal paranoia profile preset";
    homepage = "https://github.com/ncaq/pppset";
    license = lib.licenses.mit;
    mainProgram = "markdown2article";
    platforms = lib.platforms.linux;
  };
}
