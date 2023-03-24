# Monitoring

As of 2013, jQuery Infrastructure is monitored via **StatusCake**.

* Status page: https://status.jquery.com/
* Management: https://app.statuscake.com/
* Access: (Shared)
  * `site-monitor@js.foundation` (forwards to `infrastructure-team@jquery.com`)
  * Credentials in the team vault.

## History

We started using StatusCake in 2013. It was set up by Kris Borchers. As of 2018, it has become a Free account. Free accounts checking upto 10 tests. We have 40 tests, which we're able to keep and replace/change, but no new tests can be added above the "10 Test" limit.

## Coverage

HTTP/HTTPS monitoring every 10-15 minutes, with alerts sent to `site-monitor@js.foundation`.

Monitoring includes:

* jQuery Content: jquery.com, jqueryui.com, jquerymobile.com.
* jQuery CDN: code.jquery.com, content.jquery.com.
* jQuery Blogs: blog.jquery.com, blog.jqueryui.com.
* jQuery Foundation projects: qunitjs.com, gruntjs.com mochajs.org, eslint.org, lodash.com, etc.
