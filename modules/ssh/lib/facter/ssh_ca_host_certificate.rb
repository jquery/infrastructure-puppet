# SPDX-License-Identifier: Apache-2.0
# frozen_string_literal: true

require 'time'

Facter.add(:ssh_ca_host_certificate) do
  confine do
    !Dir.glob('/etc/ssh/*-cert.pub').empty? && Facter::Core::Execution.which('ssh-keygen')
  end

  setcode do
    hash = {}

    Dir.glob('/etc/ssh/*-cert.pub').each do |file_path|
      cert_data = {}
      cert_data['principals'] = []

      in_principals = false

      # TODO: once on Bookworm and on the Debian provided packages,
      # use the net/ssh gem based fact from the Wikimedia repo
      ssh_data = Facter::Core::Execution.execute("ssh-keygen -L -f #{file_path}")
      ssh_data.each_line do |line|
        line.strip!

        if in_principals
          # this is the first non-principal line with the ssh version in bullseye
          if line.include?('Critical Options:')
            in_principals = false
          else
            cert_data['principals'] << line
          end

          next
        end

        if line.start_with?('Valid:') && !line.include?('forever')
          parts = line.split(' ')
          cert_data['lifetime_remaining_seconds'] = Time.parse(parts[4]).to_i - Time.now.to_i
        elsif line.start_with?('Principals:')
          in_principals = true
        end
      end

      hash[file_path] = cert_data
    end

    hash
  end
end
