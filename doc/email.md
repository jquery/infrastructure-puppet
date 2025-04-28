# Email

As of 2024, email forwarding is powered by Forward Email. From 2012 to 2023, email groups and aliases were managed via Google Workspace (G Suite).

* Account type: [Premium Team](https://forwardemail.net/en/private-business-email?pricing=true) (Donated)
* Management: <https://forwardemail.net>
* Access: (Credentials in the team vault)

## Private aliases

Manage private aliases in the Premium Team account via <https://forwardemail.net/en/my-account/domains>.

## Public aliases

Email alias destinations can also be configured publicly via DNS. We generally don't do this for privacy and anti-spam reasons, but this can be a useful fallback, e.g. in case of emergencies (if we can't log in to the Forward Email admin panel), or if the Premium account expires (since DNS is supported by Forward Email even on the Free tier).

The Forward Email service queries our DNS records and automatically extends or creates aliases in addition to (not instead of) any private entries.

* Edit the relevant `TXT` records in DNS (currently in Cloudflare for us, see [dns.md](./dns.md)).
* See also <https://forwardemail.net/en/faq#dns-configuration-options>

Query our public aliases (none as of Feb 2024):

```
dig +noall +question +answer TXT jquery.com jquery.org qunitjs.com | grep -E "^;|forward-email=" | sed 's/^.*forward-email=//' | tr -d '"' | tr ',' '\n'
```
