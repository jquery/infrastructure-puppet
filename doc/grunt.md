# Grunt website

* https://gruntjs.com/
* https://stage.gruntjs.com/

## Control flow

1. Source code at https://github.com/gruntjs/gruntjs.com.git. A webhook notifies `gruntjs` hosts of commits.
2. The `gruntjs` hosts are provisioned with `role::gruntjscom` by Puppet. It receives webhooks with [jquery/notifier](https://github.com/jquery/node-notifier-server/).
3. On main branch commits, it checks out the Git commit, re-installs the project, and restarts the gruntjscom service.
