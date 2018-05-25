class docker::dockviz (
    $version = 'v0.5.0',
) {

    exec { 'docker::dockviz::download':
        command => "wget -O /usr/local/bin/dockviz https://github.com/justone/dockviz/releases/download/${version}/dockviz_linux_amd64 && chmod +x /usr/local/bin/dockviz",
        unless  => "test -x /usr/local/bin/dockviz && /usr/local/bin/dockviz --version | grep ${version}",
    }

}
