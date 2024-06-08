# frozen_string_literal: true

Facter.add(:ssh_local_keys) do
	confine do
		File.directory?('/etc/ssh/local_keys.d/')
	end
	setcode do
		hash = {}

		Dir.glob('/etc/ssh/local_keys.d/*.pub').each do |file|
			filename = file.split('/').last.gsub('.pub', '')
			content = File.read(file)
			hash[filename] = content.chomp
		end

		hash
	end
end
