# Runbook: Nginx debugging

## Staging and testing

* Push to `puppet-stage`.
* Apply on **wp-01.stage**.ops by running `sudo puppet agent -tv` there.
  * If there are errors, especially the `Nginx[refresh]` line, then stop and fix the patch.
  * To get more details on the error, use `sudo service nginx configtest` and `sudo nginx -t`.
* Push to `puppet-master`.
* Apply on `wp-02.ops` by running `sudo puppet agent -tv` there. Confirm content sites (besides releases/codeorigin) are fine.
* Apply on `wp-03.ops` by running `sudo puppet agent -tv` there. Confirm codeorigin is fine.

## Live hacking

To test and **debug Nginx changes** for jQuery content sites hosted on wp-01, wp-02, or wp03.

The staging server is **wp-01.stage** (for all sites, including codeorigin).

1. Edit the appropriate file under `/tmp/nginx.d/`, e.g. using `sudo nano` (vim isn't installable currently).
2. Then perform the same notify command as Puppet would do:
   ```
   sudo sh -c '/bin/cat /tmp/nginx.d/* > /etc/nginx/conf.d/vhost_autogen.conf'
   ```
3. Then reload the nginx service:
   ```
   sudo service nginx reload
   ```
4. Perform your test against HTTP localhost using `curl` and a Host header. Remember that on the staging server, the hostnames have a `stage.` prefix, for example:
  ```
  wp-01.stage$ curl -i 'http://localhost/color/jquery.color-2.2.0.min.js' -H 'Host: stage.codeorigin.jquery.com'

  wp-01.stage$ curl -i 'http://localhost/git/example-git.js' -H 'Host: stage.releases.jquery.com'

  wp-01.stage$ curl -i 'http://localhost/purge/?uri=/qunit/' -H 'Host: stage.releases.jquery.com'
  wp-01.stage$ curl -i 'http://localhost/purge/?site=code&uri=/jquery-3.6.0.js' -H 'Host: stage.releases.jquery.com'
  wp-01.stage$ curl -i 'http://localhost/purge/?site=code&uri=/color/jquery.color-2.2.0.min.js' -H 'Host: stage.releases.jquery.com'

  wp-03$ curl -i 'http://localhost/git/color/jquery.color-git.min.js' -H 'Host: releases.jquery.com'
  wp-03$ curl -i 'http://localhost/git/color/jquery.color-git.min.js' -H 'Host: codeorigin.jquery.com'
  wp-03$ curl -i 'http://localhost/color/color/jquery.color-2.2.0.min.js' -H 'Host: codeorigin.jquery.com'

  ```
  Or, to test from the outside, use `--connect-to` to bypass Cloudflare and simulate a direct request:
  ```
  curl -I 'https://view.jquery.com/bar' --connect-to '::wp-01.ops.jquery.net'
  ```

Beware that Puppet will run every 30 minutes and may overwrite these changes.
* Check `sudo tail -n100 /var/log/syslog`, to see when Puppet last ran.
* To temporarily disable puppet: `puppet agent --disable "message here"`
* When done, re-enable puppet: `puppet agent --enable`
* To undo your changes, run puppet so that it restores the state: `puppet agent -tv`.

## See also

Ref https://github.com/jquery/infrastructure/commit/79ae864005a12dab9affa502fd5dc5291fff504c
