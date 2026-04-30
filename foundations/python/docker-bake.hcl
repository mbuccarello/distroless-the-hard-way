# docker-bake.hcl

group "default" {
  targets = ["libffi", "sqlite", "ncurses", "readline", "bzip2", "liblzma", "libxcrypt"]
}

variable "REGISTRY" {
  default = "ghcr.io/mbuccarello"
}

variable "GLOBAL_CFLAGS" {
  default = "-O2 -fPIC -I/artifacts/usr/include"
}

variable "GLOBAL_LDFLAGS" {
  default = "-L/artifacts/usr/lib64 -L/artifacts/usr/lib"
}

target "foundation-base" {
  dockerfile = "Dockerfile"
  context = "."
  args = {
    CFLAGS = GLOBAL_CFLAGS
    LDFLAGS = GLOBAL_LDFLAGS
  }
}

target "libffi" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "libffi"
    LIB_URL = "https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz"
    LIB_SHA = "b0dea9df23c863a7a50e825440f3ebffabd65df1497108e5d437747843895a4e"
  }
  tags = ["${REGISTRY}/foundation-python-libffi:latest"]
}

target "ncurses" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "ncurses"
    LIB_URL = "https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz"
    LIB_SHA = "6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159"
    # Arch Intelligence: Bundle tinfo into ncursesw, use widec
    LIB_CONFIG = "--with-shared --without-debug --without-ada --enable-widec --disable-lp64"
  }
  tags = ["${REGISTRY}/foundation-python-ncurses:latest"]
}

target "readline" {
  inherits = ["foundation-base"]
  contexts = {
    deps = "target:ncurses"
  }
  args = {
    LIB_NAME = "readline"
    LIB_URL = "https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz"
    LIB_SHA = "3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35"
    # Arch Intelligence: Link against ncursesw
    LDFLAGS_EXTRA = "-lncursesw"
  }
  tags = ["${REGISTRY}/foundation-python-readline:latest"]
}

target "sqlite" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "sqlite"
    LIB_URL = "https://www.sqlite.org/2024/sqlite-autoconf-3460000.tar.gz"
    LIB_SHA = "6f8e6a7b335273748816f9b3b62bbdc372a889de8782d7f048c653a447417a7d"
  }
  tags = ["${REGISTRY}/foundation-python-sqlite:latest"]
}

target "bzip2" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "bzip2"
    LIB_URL = "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
    LIB_SHA = "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
  }
  tags = ["${REGISTRY}/foundation-python-bzip2:latest"]
}

target "liblzma" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "liblzma"
    LIB_URL = "https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz"
    LIB_SHA = "8bfd20c0e1d86f0402f2497cfa71c6ab62d4cd35fd704276e3140bfb71414519"
  }
  tags = ["${REGISTRY}/foundation-python-liblzma:latest"]
}

target "libxcrypt" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "libxcrypt"
    LIB_URL = "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz"
    LIB_SHA = "e5e1f4caee0a01de2aee26e3138807d6d3ca2b8e67287966d1fefd65e1fd8943"
    LIB_CONFIG = "--enable-hashes=strong,glibc --enable-obsolete-api=yes"
  }
  tags = ["${REGISTRY}/foundation-python-libxcrypt:latest"]
}
