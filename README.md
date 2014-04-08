sig-deploy
Software Deployment System for AWS

HOW TO
======

    - Create as many configuration files as you need by customizing
      conf/sample.conf.

    - Execute sig-deploy.sh on any server that has access to the s3cmd command
      and your configuration file.

    - Add a crontab entry for exec-deploy.sh on each server that needs to
      process signals to deploy code.  Depending on your configuration you may
      need to add the crontab for root (but preferably not).
