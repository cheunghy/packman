class Gcc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2'
  sha1 '3f303f403053f0ce79530dae832811ecef91197e'
  version '4.9.1'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'mpc'
  depends_on 'isl'
  depends_on 'cloog'

  label 'compiler'
  provide 'c' => 'gcc'
  provide 'c++' => 'g++'
  provide 'fortran' => 'gfortran'

  def install
    languages = %W[c c++ fortran]
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --enable-languages=#{languages.join(',')}
      --with-gmp=#{PACKMAN::Package.prefix(Gmp)}
      --with-mpfr=#{PACKMAN::Package.prefix(Mpfr)}
      --with-mpc=#{PACKMAN::Package.prefix(Mpc)}
      --with-cloog=#{PACKMAN::Package.prefix(Cloog)}
      --with-isl=#{PACKMAN::Package.prefix(Isl)}
      --disable-multilib
    ]
    PACKMAN.mkdir 'build', :force do
      PACKMAN.run '../configure', *args
      PACKMAN.run 'make -j2 bootstrap'
      PACKMAN.run 'make -j2 install'
    end
    # TODO: Should we link the headers in lib/gcc/.../include into include?
  end
end
