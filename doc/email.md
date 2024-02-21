# Email

As of 2024, email forwarding is powered by Forward Email. From 2012 to 2023, email groups and aliases were managed via Google Workspace (G Suite).

* Account type: [Premium Team](https://forwardemail.net/en/private-business-email?pricing=true) (Donated)
* Management: <https://forwardemail.net>
* Access: (Credentials in the team vault)

## Private aliases

Manage private aliases in the Premium Team account via <https://forwardemail.net/en/my-account/domains>.

## Public aliases

Public aliases are managed in DNS. Use these as emergency supplement, or as alternative if the paid account expires. The Forward Email service DNS uses it to create or extend aliases in addition to (not instead of) any private entries.

* Edit the relevant `TXT` records in DNS (currently in Cloudflare for us, see [dns.md](./dns.md)).
* See also <https://forwardemail.net/en/faq#dns-configuration-options>

List public aliases:

```
dig +noall +question +answer TXT jquery.com jquery.org qunitjs.com | grep -E "^;|forward-email=" | sed 's/^.*forward-email=//' | tr -d '"' | tr ',' '\n'
```
