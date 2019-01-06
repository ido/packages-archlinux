# $Id$
# Maintainer: Ido Rosen <ido@kernel.org>
#
# NOTE: To request changes to this package, please submit a pull request
#       to the GitHub repository at https://github.com/ido/packages-archlinux
#       Otherwise, open a GitHub issue.  Thank you! -Ido
# 
# From the Stan website, http://mc-stan.org/ :
#   ``Stan is a package for obtaining Bayesian inference using the No-U-Turn
# sampler, a variant of Hamiltonian Monte Carlo.'' (9/22/2013)

pkgname='stanc'
pkgdesc="A package for obtaining Bayesian inference using the No-U-Turn sampler, a variant of Hamiltonian Monte Carlo."
pkgver=2.18.1
pkgrel=1
arch=('i686' 'x86_64')
url='http://mc-stan.org/'
license=('BSD')
depends=('gcc-libs')
makedepends=('texlive-bin' 'texlive-core' 'doxygen')
options=('!libtool' '!strip' '!makeflags')
source=(https://github.com/stan-dev/cmdstan/releases/download/v$pkgver/cmdstan-$pkgver.tar.gz)
sha512sums=('20764f87e6fbc6359bc360a7316ec40773cdc4eb215f2740528830eaee765de71f8041af13235e8c64e25cb791606a739b990962469cd36ef4a87406e8d49645')

prepare() {
  cd "${srcdir}/cmdstan-${pkgver}"
  
}

build() {
  cd "${srcdir}/cmdstan-${pkgver}"
 
  # Remove the line to avoid "fatal error: 'string' file not found"
  # http://discourse.mc-stan.org/t/error-in-compiling-cmdstan-cstddef-string-not-found/1874
  sed -i 's/CXXFLAGS += -stdlib=libc++//' stan/lib/stan_math/make/detect_cc
  make bin/stanc
  make bin/print
  
}

check() {
  cd "${srcdir}/cmdstan-${pkgver}"

  # There are tests for the CmdStan interface
  # make src/test/interface
}

package() {
  cd "${srcdir}/cmdstan-${pkgver}"
  
  # Stan's makefile doesn't have a make install command...
  # Install binaries:
  install -dm755                  "${pkgdir}/usr/bin"
  install -m755 bin/stanc         "${pkgdir}/usr/bin"
  install -Tm755 bin/print         "${pkgdir}/usr/bin/stanc-print"

  # Install static library:
  install -dm755                  "${pkgdir}/usr/lib"
  install -m644 bin/libstanc.a     "${pkgdir}/usr/lib"

  install -dm755                  "${pkgdir}/usr/include/stan"
  cd "stan/src"
  find . -iregex './stan.*.hpp$' -type f -exec install -DTm644 "{}" "${pkgdir}/usr/include/{}" \;
  cd ../.. 
 
  # Install LICENSE file:
  install -dm755                  "${pkgdir}/usr/share/licenses/stan"
  cp -r "stan/licenses/." "${pkgdir}/usr/share/licenses/stan/."
}
