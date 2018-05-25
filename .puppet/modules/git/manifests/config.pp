define git::config (
    $owner = $title,
    $group = $title,
    $path = "/home/$owner/.gitconfig",
    $user_email = undef,
    $user_name = undef,
) {

    file { $path:
        content => template('git/gitconfig.erb'),
        owner   => $owner,
        group   => $group,
        mode    => '0644',
    }

}
