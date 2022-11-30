# This is a configuration file for octocatalog-diff (https://github.com/github/octocatalog-diff).

module OctocatalogDiff
  class Config

    def self.config
      settings = {}

      settings[:hiera_config] = 'test_data/hiera.yaml'
      settings[:hiera_path] = ''
      settings[:environment] = 'staging'

      settings[:bootstrap_script] = 'test_data/bootstrap.sh'

      # provided manually
      # settings[:puppetdb_url] = 'https://puppetdb.yourcompany.com:8081'

      # TODO: install once puppet-terminus-puppetdb migrates to testing
      settings[:storeconfigs] = false

      puppet_may_be_in = %w(
        /opt/puppetlabs/puppet/bin/puppet
        /usr/bin/puppet
      )
      puppet_may_be_in.each do |path|
        next unless File.executable?(path)
        settings[:puppet_binary] = path
        break
      end

      settings[:from_env] = 'origin/staging'

      settings[:validate_references] = %w(before notify require subscribe)
      settings[:basedir] = Dir.pwd

      settings
    end
  end
end
