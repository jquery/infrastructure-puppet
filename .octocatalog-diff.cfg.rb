# This is a configuration file for octocatalog-diff (https://github.com/github/octocatalog-diff).
#
# When octocatalog-diff runs, it will look for configuration files in the following locations:
# - As specified by the environment variable OCTOCATALOG_DIFF_CONFIG_FILE
# - Your current working directory: `$PWD/.octocatalog-diff.cfg.rb`
# - Your home directory: `$HOME/.octocatalog-diff.cfg.rb`
# - The Puppet configuration directory: `/opt/puppetlabs/octocatalog-diff/octocatalog-diff.cfg.rb`
# - The local system directory: `/usr/local/etc/octocatalog-diff.cfg.rb`
# - The system directory: `/etc/octocatalog-diff.cfg.rb`
#
# It will use the first configuration file it finds in the above locations. If it does not find any
# configuration files, a default configuration will be used.
#
# To test this configuration file, place it in one of the above locations and run:
#   octocatalog-diff --config-test
#
# NOTE: This example file contains some of the more popular configuration options, but is
# not exhaustive of all possible configuration options. Any options that can be declared via the
# command line can also be set via this file. Please consult the options reference for more:
#   https://github.com/github/octocatalog-diff/blob/master/doc/optionsref.md
# And reference the source code to see how the underlying settings are constructed:
#   https://github.com/github/octocatalog-diff/tree/master/lib/octocatalog-diff/cli/options

module OctocatalogDiff
  class Config

    def self.config
      settings = {}

      settings[:hiera_config] = 'hiera.yaml'
      settings[:hiera_path] = '../../test_data/hieradata'
      settings[:preserve_environments] = true
      settings[:environment] = 'staging'
      settings[:create_symlinks] = ['bin', 'manifests', 'modules', 'test_data', 'vendor_modules']
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

      settings[:from_env] = 'origin/main'

      settings[:validate_references] = %w(before notify require subscribe)
      settings[:basedir] = Dir.pwd

      settings
    end
  end
end
