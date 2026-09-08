# frozen_string_literal: true

require 'ipaddr'

Puppet::Functions.create_function(:'jqlib::cloudflare_ips') do
  dispatch :main do
    return_type 'Array[Stdlib::IP::Address]'
  end

  def main
    # Use a global variable as cache to de-duplicate any repeat calls
    @cloudflare_ips ||= begin
      # https://www.cloudflare.com/ips/
      urls = [
        'https://www.cloudflare.com/ips-v4/',
        'https://www.cloudflare.com/ips-v6/',
      ]
      ranges = urls.flat_map do |url|
        output = Puppet::Util::Execution.execute(
          ['/usr/bin/curl', '--fail', '--silent', '--show-error', '--location', '--retry', '3', url],
          failonfail: true
        )
        output.lines.map(&:strip).reject(&:empty?)
      end.uniq

      ranges.each do |range|
        begin
          IPAddr.new(range)
        rescue ArgumentError
          raise Puppet::Error, "Invalid IP range: #{range}"
        end
      end
      raise Puppet::Error, 'List of IPs must be non-empty' if ranges.empty?

      ranges
    end
  end
end
