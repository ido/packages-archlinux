# $Id: 2292c56ecdc8d3b72b867af8b5753f47ebcdaab1 $
# Maintainer: Ido Rosen <ido@kernel.org>
#
# NOTE: To request changes to this package, please submit a pull request
#       to the GitHub repository at https://github.com/ido/packages-archlinux
#       Otherwise, open a GitHub issue.  Thank you! -Ido
# 

pkgname='sfptpd'
pkgdesc="Solarflare Enhanced PTP daemon."
pkgver='2.4.0.1000'
pkgrel=1
arch=('x86_64')
url='http://www.solarflare.com/'
license=('custom')
depends=('openonload')
makedepends=()
options=('!libtool' '!strip' '!makeflags' '!buildflags' 'staticlibs')
source=("SF-108910-LS-12_Solarflare_Enhanced_PTP_Daemon_sfptpd_-_64_bit_binary_tarball.tgz"
        "release note.txt"
	'sfptpd.service')
sha512sums=('0636afcdd68a246aa86d3289f70a436dcbc9b11150bce3d608bc76ffdb7df314821e12aa125ab066155b9b8ef8046387cbf188351cb57f84d2168aa47432ca1a'
            'cc4849977faf2e012f03c203f6a4a10e06c34f3b18986afc69217d82598765b86f7e5c28d49018d15bab799cd8c90707f629cce79e4779533d23ce0ed2a7d64c'
	    'a5d6d249907df34e22ac4c75c3410248cbc715b65ef01722b72e3a1a0fa11007ef71fb1482fee3c17bb68f46010dee47db18d6513f58cbb80595ba4caa1db108')

package() {
  # Systemd service:
  install -dm755                  "${pkgdir}/usr/lib/systemd/system/"
  install -m644 sfptpd.service    "${pkgdir}/usr/lib/systemd/system/"

  cd "${srcdir}/${pkgname}-${pkgver}.${arch}"

  # Binaries:
  install -Dm755 "sfptpd" "${pkgdir}/usr/bin/sfptpd"

  # Documentation:
  install -dm755                  "${pkgdir}/usr/share/doc/${pkgname}"
  RLN="release note.txt"
  install -m644 "${srcdir}/${RLN}" "${pkgdir}/usr/share/doc/${pkgname}"
  install -m644 PTPD2_COPYRIGHT         "${pkgdir}/usr/share/doc/${pkgname}"
  install -dm755                  "${pkgdir}/usr/share/doc/${pkgname}/config"
  install -m644 config/*          "${pkgdir}/usr/share/doc/${pkgname}/config"

  # Install LICENSE file:
  install -dm755                  "${pkgdir}/usr/share/licenses/${pkgname}"
  ln -s "/usr/share/doc/${pkgname}/PTPD2_COPYRIGHT" \
      "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
