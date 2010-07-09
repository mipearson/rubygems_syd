## The original purpose of this file was to pull in all of the local .rb files
## needed by an application.
##
## It's since expanded to automatically set up a user's environment such that
## they can run the application without having rubygems, bundler, etc. This
## is necessary as installing the correct version of bundler and rubygems on
## the systems that this application will be used on may not happen.

def bootstrap_rubygems
  gem_dir = ENV['HOME'] + '/gems'
  
  unless File.directory?(gem_dir)
    puts "*** Installing Rubygems 1.3.7 to homedir..."
    
    pwd = `pwd`
    system [
      "cd ~",
      "curl http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz | tar -xzf -",
      "cd rubygems-1.3.7",
      "ruby setup.rb --prefix=#{gem_dir}",
      "ln -sf #{gem_dir}/bin/gem1.8 #{gem_dir}/bin/gem"
    ].join(" && ")
    system "cd #{pwd}"
    puts "*** Done."
  end
  
  ENV['PATH'] = "#{gem_dir}/bin:#{ENV['PATH']}"
  ENV['RUBYLIB'] = "#{gem_dir}/lib"
  ENV['GEM_HOME'] = "#{gem_dir}"
  puts "*** Using RubyGems 1.3.7 in #{gem_dir} instead of system rubygems."
end

bootstrapped = false
if `gem env | grep 'RUBYGEMS VERSION: 1.3.7' | wc -l`.strip.to_i == 0
  bootstrap_rubygems
  bootstrapped = true
end

if `gem list | grep 'bundler' | grep 0.9 | wc -l`.strip.to_i == 0
  puts "*** Missing bundler 0.9, installing..."
  unless bootstrapped
    # don't want to try to install bundler to the system rubygems automatically
    bootstrap_rubygems
  end
  system 'gem install bundler --no-ri --no-rdoc'
  puts "*** Done."
  
  puts "*** Installing gem dependencies to local rubygems..."
  system "bundle install --relock"
  puts "*** Done."
end

require 'rubygems'
require 'bundler'
Bundler.setup
Dir[
  'lib/*.rb',
  'lib/**/*.rb'
].each do |lib|
  require File.expand_path(lib)
end