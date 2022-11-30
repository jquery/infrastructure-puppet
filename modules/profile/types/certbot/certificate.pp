# @summary details for a certificate requested by certbot
type Profile::Certbot::Certificate = Struct[{
  domains => Array[Stdlib::Fqdn, 1],
}]
