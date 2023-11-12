# Runbook: Fastly debugging

## Real-time logging

Aggregate statistics are available under the "Edge Observer" tab
of the [Observability](https://docs.fastly.com/en/guides/about-the-observability-page)
page in Fastly, this includes for example requests by cache response
type (hit, miss, pass, synthetic, error), status code, object size,
and HTTP version.


There isn't a built-in way to review, e.g. a sampled web request log,
but you can debug actual requests by setting up a logging endpoint
under one of the "services" in your account. This endpiont then
receives a stream of real-time log events.

Documentation:
* https://docs.fastly.com/en/guides/setting-up-remote-log-streaming
* https://docs.fastly.com/en/guides/log-streaming-https
* https://docs.fastly.com/en/guides/useful-conditions-for-logging
* https://docs.fastly.com/en/guides/useful-variables-to-log

### Example: Log "pass" requests

* https://docs.fastly.com/en/guides/using-conditions
* https://developer.fastly.com/reference/vcl/variables/
* https://developer.fastly.com/reference/http/http-headers/

Log the request URLs of requests that are considered uncachable
(as opposed to a cache "miss").

Condition:
```
req.http.Fastly-Cachetype == "PASS"
```

Logging endpoint:

* Condition: "If pass"
* Placement: "Format Version Default"
* Log format: (simplified from the default to not contain any obvious PII)
  ```json
  {
    "host": "%{if(req.http.Fastly-Orig-Host, req.http.Fastly-Orig-Host, req.http.Host)}V",
    "url": "%{json.escape(req.url)}V",
    "request_method": "%{json.escape(req.method)}V",
    "response_status": %{resp.status}V
  }
  ```
* URL: A newly generated URL from https://log-bin.fastly.dev/
* Advanced
  * Content type: `text/plain`
  * Method: `POST`
  * JSON log entry format: "Newline delimited"
  * Select a log line format: "Blank"

### Example: Sampled "miss" log

* https://developer.fastly.com/reference/vcl/functions/randomness/randombool/

```
req.http.Fastly-Cachetype == "PASS"
```
