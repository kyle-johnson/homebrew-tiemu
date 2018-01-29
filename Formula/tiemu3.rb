 class Tiemu3 < Formula
  desc "A fast emulator for the TI89(titanium)/92(+)/V200PLT calculators"
  homepage "http://lpg.ticalc.org/prj_tiemu/about.html"
  url "http://www.ticalc.org/pub/unix/tiemu.tar.gz"
  version "3.03"
  sha256 "92d2830842278a8df29ab0717f5b89e06b34e88a50c073fe10ff9e6855b8a592"

  depends_on "gtk+"
  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build  # unsure if we really need this
  depends_on "libtool" => :build
  depends_on "automake" => :build
  depends_on "shtool" => :build  # unsure if we really need this
  depends_on "pkg-config" => :build
  depends_on "libiconv"
  depends_on "libusb"
  depends_on "libusb-compat"
  depends_on "libglade"
  depends_on "libarchive"
  depends_on "sdl"
  depends_on "glib"
  depends_on "pango"
  depends_on :x11

  # this is a little strange, as it contains 4 archives inside it
  resource "tilibs" do
    url "http://www.ticalc.org/pub/unix/tilibs.tar.gz"
    sha256 "af7b61b5115e5cdae6dc9396004de8828ce00d64d4428e5077a4bf1629e78e1d"
  end

  # 1. Clean up old GTK+ deprecations
  # 2. Fix configure.ac so we can run autoconf successfully
  patch do
    url "https://raw.githubusercontent.com/kyle-johnson/homebrew-tiemu3/master/tiemu3-patch.diff"
    sha256 "e0afbeabb9f92ca6aa0beaf49e0ed57f7e2da830268d3bcda24962b1472a671f"
  end

  def install
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["glib"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libglade"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libusb-compat"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libusb"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libiconv"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["gtk+"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["sdl"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["pango"].opt_libexec/"lib/pkgconfig"
    ENV.prepend_create_path "PKG_CONFIG_PATH", lib/"pkgconfig"

    resource("tilibs").stage do

      system "tar", "xjf", "libticonv-1.1.5.tar.bz2"
      cd "libticonv-1.1.5" do
        system "autoreconf", "-i"
        system "./configure",
                   "--enable-iconv",
                   "LDFLAGS=-L/usr/local/opt/libiconv/lib -liconv",
                   "--prefix=#{prefix}"
        system "make"
        system "make", "install"
      end

      system "tar", "xjf", "libticables2-1.3.5.tar.bz2"
      cd "libticables2-1.3.5" do
        system "autoreconf", "-i"
        system "./configure", "--prefix=#{prefix}"
        system "make"
        system "make", "install"
      end

      system "tar", "xjf", "libtifiles2-1.1.7.tar.bz2"
      cd "libtifiles2-1.1.7" do
        system "autoreconf", "-i"
        system "./configure", "--prefix=#{prefix}"
        system "make"
        system "make", "install"
      end

      system "tar", "xjf", "libticalcs2-1.1.9.tar.bz2"
      cd "libticalcs2-1.1.9" do
        system "autoreconf", "-i"
        system "./configure", "--prefix=#{prefix}"
        system "make"
        system "make", "install"
      end
    end

    system "rm", "aclocal.m4"
    system "aclocal"
    system "glibtoolize"
    system "autoreconf", "-i"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--without-kde",
                          "--without-sdltest",
                          "--disable-gdb",
                          "--disable-debugger"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/tiemu", "-v"
  end
end
