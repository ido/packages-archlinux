# $Id: ff2dae5d6715bf31a3852a3b84a0fac2112e2d45 $
# Maintainer: Ido Rosen <ido@kernel.org>
#
# NOTE: To request changes to this package, please submit a pull request
#       to the GitHub repository at https://github.com/ido/packages-archlinux
#       Otherwise, open a GitHub issue.  Thank you! -Ido
# 
# From the MOSEK website, http://mosek.com/introduction/ :
#   ``MOSEK is a tool for solving mathematical optimization problems.  Some
#   examples of problems MOSEK can solve are linear programs, quadratic
#   programs, conic problems, and mixed integer problems [...]''

pkgname='mosek'
pkgdesc="A tool for solving mathematical optimization problems."
pkgver=8.0.0.81
pkgrel=1
arch=('x86_64')
url='http://mosek.com/'
license=('custom')
epoch=1

# XXX: Matlab is a dependency (libmex, libmat, etc.)
depends=('gcc-libs' 'java-environment' 'bash')

options=('!libtool' '!strip')

_mosekarch=linux64x86
sha512sums=('caa5b0decb7edf431851456b5e09307aa284d4ed8d2d8005d26cb7556722eb30e27c9907349c3f08f1b75ba908750cf1ef7955152e0f0ae62127d6397fe14645')

source=("http://download.mosek.com/stable/${pkgver}/mosektools${_mosekarch}.tar.bz2")

check() {
  cd "${srcdir}/"

  "mosek/8/tools/platform/${_mosekarch}/bin/mosek" -f
}

package() {
  cd "${srcdir}/"
 
  # Install binaries into /opt/mosek/8: 
  install -dm755                  "${pkgdir}/opt/mosek/8"
  cp -r mosek/8/.                 "${pkgdir}/opt/mosek/8/."

  # Symlink mosek:
  install -dm755                  "${pkgdir}/usr/bin"
  ln -s /opt/mosek/8/tools/platform/${_mosekarch}/bin/mosek \
                                  "${pkgdir}/usr/bin/mosek"

  # Symlink header file:
  install -dm755                  "${pkgdir}/usr/include"
  ln -s /opt/mosek/8/tools/platform/${_mosekarch}/h/mosek.h \
                                  "${pkgdir}/usr/include/mosek.h"

  # Symlink documentation, examples, and licenses:
  install -dm755                  "${pkgdir}/usr/share/doc/mosek"
  ln -s /opt/mosek/8/tools/examples \
                                  "${pkgdir}/usr/share/doc/mosek/examples"
  ln -s /opt/mosek/8/doc/html     "${pkgdir}/usr/share/doc/mosek/html"
  ln -s /opt/mosek/8/doc/pdf      "${pkgdir}/usr/share/doc/mosek/pdf"

  install -dm755                  "${pkgdir}/usr/share/licenses/mosek"
  ln -s /opt/mosek/8/license.pdf  "${pkgdir}/usr/share/licenses/mosek/license.pdf"

  # Symlink MATLAB toolbox:
  ln -s /opt/mosek/8/toolbox      "${pkgdir}/usr/share/doc/mosek/matlab"

  # Symlink Python modules:
  ln -s /opt/mosek/8/tools/platform/${_mosekarch}/python \
                                  "${pkgdir}/usr/share/doc/mosek/python"

}
