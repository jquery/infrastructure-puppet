# jQuery CDN: TLS Certificate

Every year we need to renew the TLS certificate used by the jQuery CDN. Linux Foundation IT provisions these as needed.

## Process to obtain new certificate

1. Create a ticket with LF IT under "Project Support Services" <https://support.linuxfoundation.org>.

   LF IT purchases a 3-year certificate and mints a 1-year certificate for us to use. They share the `.crt` and `.ca-bundle` files via email, and share the private key via 1Password.
2. The `.crt` and `.ca-bundle` file for each domain needs to be converted to `.pem` format by concatenating them with the `.crt` file first.
   * `cat __jquery_com.crt __jquery_com.ca-bundle > star.jquery.com.pem`
   * The `.crt` file may not have an EOL character, so open `star.jquery.com.pem` and make sure that all block terminators look like this (i.e., not on one line, and no blank lines between):
     ```
     -----END CERTIFICATE-----
     -----BEGIN CERTIFICATE-----
     ```
3. Copy the contents of the private key (shared via 1Password) into a file called `star.jquery.com.key`
4. **Test it!** by running `bin/verify_cert.sh path/to/your/star.jquery.com.pem`

   Note that if the `.key` file contains `ENCRYPTED` (that is, if `verify_cert.sh` causes openssl to prompt you for a password), then **convert this to plaintext first** via `bin/decrypt_cert_key.sh`, so that the file can be safely used by a webserver.

## Example ticket

> Project: Open JS Foundation
> Services: DNS management, Domain ownership
>
> The wildcart cert for jquery.com, as used for the jQuery CDN at code.jquery.com is expiring soon on ….
>
> We ideally take a few days to test it first, and after that I can upload it to Fastly (at least 48 hours after issuing, which ensures the a majority of browser clients that suffer clockskew, will accept the new certificate).
>
> Our current one was issued in … by ….
>
> Thanks!

## Process to deploy new certificate

When in doubt, refer to a recent issue that documents what we actually did.
Renewal in 2023: https://github.com/jquery/infrastructure-puppet/issues/21

1. **Upload**. After obtaining and locally **testing** the new certificate in the above process,
   upload it to Fastly management as new unused certificate.
2. Enable for a **secondary service** at Fastly, such as "miscweb" (https://podcast.jquery.com) or "code2".
3. **Verify**. In a browser of your choice, verify that when viewing a page on the secondary domain, that the browser is in fact using our new certificate. Check the expiry date to confirm this.
4. **Test cross-browser**. Once you've confirmed that the new cert is deployed and used, it's time to test it across a wide range of browsers. Especially old browsers that don't support certain kinds of TLS versions or cipher suites. You can use BrowserStack to go through old Windows/IE versions and old iPhone devices until you encounter a failure. Then confirm that there are no old browsers that fail on the new certificate, unless that same browser also already fails to open https://releases.jquery.com. Confirm that the old/new domain are both browseable over plain HTTP without issue/redirect.
5. **Wait 48 hours** before deploying the new cert to our primary services. This is to account for clockskew on real devices. Certificates will be considered invalid by browsers if their local system clock says the new certificate's begin date ("Not before") has not yet started. Learn more about why at https://phabricator.wikimedia.org/T196248.
6. Enable the new cert for all services.
7. **Delete your unencrypted** star.jquery.com.key file from your workstation.

## Fastly docs

https://docs.fastly.com/en/guides/setting-up-tls-with-your-own-certificates
