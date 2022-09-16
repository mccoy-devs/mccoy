beast -version  # Need to call beast once (even just to query the version) to create support dirs
packagemanager -add feast | grep -e 'feast is \(already \)\?installed'
