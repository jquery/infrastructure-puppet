# Email

As of 2024, email forwarding is powered by Forward Email. From 2012 to 2023, these were managed via Google Workspace (G Suite).

* Account type: [Free](https://forwardemail.net/en/private-business-email?pricing=true)
* Management: <https://forwardemail.net>

## List current aliases

```
dig +noall +question +answer TXT jquery.com jquery.org qunitjs.com | grep -E "^;|forward-email=" | sed 's/^.*forward-email=//' | tr -d '"' | tr ',' '\n'
```

## Manage aliases

1. Edit the relevant `TXT` records in DNS (currently in Cloudflare for us, see [dns.md](./dns.md)).
2. See also <https://forwardemail.net/en/faq#dns-configuration-options>
