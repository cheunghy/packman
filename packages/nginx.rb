class Nginx < PACKMAN::Package
  url 'http://nginx.org/download/nginx-1.9.3.tar.gz'
  sha1 '7f91765af249ad14a5f5159b587113e4345b74a5'
  version '1.9.3'

  label :compiler_insensitive

  # Start options.
  option 'user' => 'nobody'
  option 'group' => 'nogroup'
  option 'worker_processes' => 'auto'
  option 'worker_connections' => 1024
  option 'port' => 8080

  depends_on 'pcre'
  depends_on 'zlib'
  depends_on 'openssl'

  def install
    PACKMAN.append 'conf/nginx.conf', "\ninclude servers/*;\n"
    PACKMAN.replace 'conf/nginx.conf', {
      'listen       80;' => "listen       #{port};"
    }
    args = %W[
      --prefix=#{prefix}
      --with-http_ssl_module
      --with-pcre
      --with-ipv6
      --sbin-path=#{bin}/nginx
      --conf-path=#{etc}/nginx/nginx.conf
      --pid-path=#{var}/run/nginx.pid
      --lock-path=#{var}/run/nginx.lock
      --http-client-body-temp-path=#{var}/run/nginx/client_body_temp
      --http-proxy-temp-path=#{var}/run/nginx/proxy_temp
      --http-fastcgi-temp-path=#{var}/run/nginx/fastcgi_temp
      --http-uwsgi-temp-path=#{var}/run/nginx/uwsgi_temp
      --http-scgi-temp-path=#{var}/run/nginx/scgi_temp
      --http-log-path=#{var}/log/nginx/access.log
      --error-log-path=#{var}/log/nginx/error.log
      --with-http_gzip_static_module
      --with-http_dav_module
      --with-http_spdy_module
      --with-http_gunzip_module
    ]
    PACKMAN.set_cppflags_and_ldflags [Pcre, Zlib, Openssl]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    PACKMAN.report_notice "Default listen port is #{PACKMAN.red port}."
    PACKMAN.mkdir etc+'/nginx/servers'
    PACKMAN.mkdir var+'/run/nginx'
    PACKMAN.mkdir man+'/man8'
    PACKMAN.cp 'man/nginx.8', man+'/man8'
  end

  def start options = {}
    return if status
    PACKMAN.replace etc+'/nginx/nginx.conf', {
      /worker_processes.*/ => "worker_processes #{worker_processes};",
      /worker_connections.*/ => "worker_connections #{worker_connections};"
    }
    PACKMAN.run bin+'/nginx'
  end

  def status   
    PACKMAN.is_process_running? `cat #{var}/run/nginx.pid` if File.exist? "#{var}/run/nginx.pid"
  end

  def stop
    PACKMAN.run bin+'/nginx -s stop'
  end
end