# frozen_string_literal: true

require 'ipaddr'

Puppet::Functions.create_function(:'jqlib::fastly_ips') do
  dispatch :main do
    return_type 'Array[Stdlib::IP::Address]'
  end

  def main
    # Use a global variable as cache to de-duplicate any repeat calls
    @fastly_ips ||= begin
      # https://www.fastly.com/documentation/reference/api/utils/public-ip-list/
      output = Puppet::Util::Execution.execute(
        ['/usr/bin/curl', '--fail', '--silent', '--show-error', '--location', '--retry', '3', 'https://api.fastly.com/public-ip-list'],
        failonfail: true
      )
      data = JSON.parse(output)
      ranges = [
        *data['addresses'],
        *data['ipv6_addresses']
      ]

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
