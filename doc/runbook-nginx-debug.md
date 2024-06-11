# Runbook: Nginx debugging

## Local curl

Use `--connect-to` to bypass any CDN and test the origin directly.

```
you@laptop$ curl -I 'https://view.jquery.com/bar' --connect-to '::miscweb-01.ops.jquery.net'
```

You can also do this from the origin itself over SSH

```
krinkle@miscweb-01:~$ curl -v -I 'https://view.jquery.com/bar' --connect-to ::localhost
```

## Staging and testing

For nginx changes to WordPress hosts, you can use staging:

* Push edits to `staging` branch.
* SSH to a stage host (e.g. **wp-03.stage**.ops) and run `sudo run-puppet-agent` there.
  * If there are errors, especially the `Nginx[refresh]` line, then stop and fix the patch.
  * To get more details on the error, use `sudo service nginx configtest` and `sudo nginx -t`.
* Once happy, forward to `production`.
* Apply on relevant prod (e.g. wp-05 for jqueryui, wp-04 for jquery) by running `sudo run-puppet-agent` there and confirming the behaviour afterwards. Use local curl (example below) instead of the public Clouflare-cached URL if caching might be at play.

## Live hacking

Sometimes iterating through the staging branch is tedious, or there might not be a staging version (e.g. miscweb). To iterate, debug, or preview Nginx changes you can do the following on any wp-stage, codeorigin-stage, or miscweb host.

1. Edit the appropriate file under `/etc/nginx/sites-available/`, e.g. using `sudo nano myfile.txt`.
2. Perform reload nginx, just as Puppet would do:
   ```
   sudo service nginx reload
   ```
3. Perform your test against HTTP localhost using `curl` and a Host header. Remember that on the staging server, the hostnames have a `stage.` prefix in the URL hostname:
  ```
  curl -I 'https://view.jquery.com/bar' --connect-to '::wp-05.ops.jquery.net'
  ```

Beware that Puppet will run every 30 minutes and may overwrite your changes while you're live hacking.
* Check `sudo journalctl -u puppet -n 20`, to see when Puppet last ran.
* To temporarily pause puppet: `puppet agent --disable "message here"`
* When done, re-enable puppet: `puppet agent --enable`
* To undo your changes, simply run puppet: `sudo run-puppet-agent`.

