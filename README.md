sig-deploy - Software Deployment System for AWS

sig-deploy.sh
=============

    sig-deploy.sh usage: [Path to Config File] {Payload}

    * Create as many configuration files as necessary by customizing
      conf/sample.conf.

    * The configuration file you create will be used on both the machine
      from which you deploy and the hosts onto which you are deploying.

    * Execute sig-deploy.sh from any server that has access to the s3cmd
      command and its configuration file.  This can be your desktop or a
      dedicated deployment server inside of EC2.

    * The payload (second parameter) can be any arbitrary stuff that you want
      passed to the script you have configured for post_action.

exec-deploy.sh
==============

    exec-deploy.sh usage: [Path to Config File]

    * Create a crontab entry on all of the hosts onto which you want to deploy
      new software using this system.

    * The path for the configuration file should be the exact same one you used
      when you called sig-deploy.sh.
