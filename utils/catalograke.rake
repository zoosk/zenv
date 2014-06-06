
#####################################################################
# Configuration
#####################################################################

CATALOG_DEPLOY_TARGET_OVERRIDE  = nil       # replace with catalogsvc deploy path if not being used in dev (default - /srv/dev#_catalog-service)
DEV_ID_ORVERRIDE                        = nil       # override env var DEVID (default - value found in ENV['DEVID'])
ENV_CONFIG_OVERRIDE                 = nil       # (default - dev)
PROPS_PATH_OVERRIDE                 = nil   # (default /srv/dev#_catalog-service/dev#.properties)


#####################################################################
# Environment Check
#####################################################################

dev_id = DEV_ID_ORVERRIDE ? DEV_ID_ORVERRIDE : ENV['ZENV_DEVID']

if CATALOG_DEPLOY_TARGET_OVERRIDE
    CATALOG_DEPLOY_TARGET = CATALOG_DEPLOY_TARGET_OVERRIDE

elsif dev_id
    # by default use the dev id in user environment to detect deploy target
    CATALOG_DEPLOY_TARGET = "/srv/dev#{dev_id}_catalog-service"
end

if !File.exists?(CATALOG_DEPLOY_TARGET)
    puts "catalog-service deploy directory does not exist [#{CATALOG_DEPLOY_TARGET}]"
    exit 1
end

ENV_CONFIG = ENV_CONFIG_OVERRIDE ? ENV_CONFIG_OVERRIDE : 'dev'
PROPS_PATH = PROPS_PATH_OVERRIDE ? PROPS_PATH_OVERRIDE : "#{CATALOG_DEPLOY_TARGET}/dev#{dev_id}.properties"


#####################################################################
# Classes
#####################################################################

class CatalogRake

    def self.unlink_current
        current_sym = self.current_path
        if File.exists?(current_sym) 
            self.run_cmd "unlink #{current_sym}"
        end
    end

  def self.set_current_link(branch)
    current_sym = self.current_path
    branch_path = self.branch_path(branch)
    self.run_cmd "ln -s #{branch_path}/ #{current_sym}"
  end

  def self.branch_exists?(branch)
    branch_path = self.branch_path(branch)
    ( File.exists?(branch_path) && File.directory?(branch_path) )
  end

  def self.delete_branch(branch)
      branch_path = self.branch_path(branch)
      puts "Deleting Catalog-Service Branch[#{branch}] from install directory. This may take a minute. Thank you for your patience."
      output = self.run_cmd "cd /srv/; rm -rf #{branch_path}; echo 'done'"
      self.print_cmd_output output
  end

  def self.svn_update(branch)
    branch_path = self.branch_path(branch)
    puts "SVN Updating Catalog-Service Branch[#{branch}]. This may take a minute. Thank you for your patience."
        output = self.run_cmd "cd #{branch_path}; svn update"
    self.print_cmd_output output
  end

  def self.svn_checkout(branch)
    deploy_path = self.catalog_deploy_path
    branch_path = self.branch_path(branch)

    puts "SVN Checking Out Catalog-Service Branch[#{branch}]. This may take a minute. Thank you for your patience."

    if 'trunk' == branch
        output = self.run_cmd "cd #{deploy_path}; svn co https://127.0.0.1:9443/catalog-service/trunk/ #{branch_path}"
    else
        output = self.run_cmd "cd #{deploy_path}; svn co https://127.0.0.1:9443/catalog-service/branches/#{branch}/ #{branch_path}"
    end

    self.print_cmd_output output
  end

  def self.build_branch(branch)

        branch_path = self.branch_path(branch)

        puts "Building catalog-service project and installing databases."

        # invoke full catalog-service install
        output = self.run_cmd "cd #{branch_path}; phing -Dprops=#{self.props_file_path} -Denv=#{environment} install; synccode #{CATALOG_DEPLOY_TARGET}"
        
        self.print_cmd_output output
  end

  def self.install_alias
    user_home_dir = File.expand_path('~')
        bash_aliases    = File.join(user_home_dir, '/.bash_aliases')

        if !File.exists?(bash_aliases)
            puts "Failure - cannot find file to update [#{bash_aliases}]"
            return
        end

        str = "alias catalograke='rake -f #{__FILE__} '"

        contents = File.read(bash_aliases)

        if contents.include?(str)
            puts "Success - catalograke alias already exists in file [#{bash_aliases}]"
            return
        end

        # write alias to file
        File.open(bash_aliases, 'a') do |f|
            f.write(str)
        end

        puts "Success - catalograke alias written to file [#{bash_aliases}]"
        puts "Remember to execute your .bash_aliases file so that your new alias works in the current shell (new shells should work fine). To do so run the following command:"
        puts ""
        puts ". #{bash_aliases}"
        puts ""
  end

  def self.version
    "1.2"
  end

  protected

    def self.run_cmd(command)
        puts "\tRunning Command: #{command}"
        `#{command}`
    end

    def self.print_cmd_output(output)
    puts "\n" + output.split("\n").collect{|t| "\t#{t}" }.join("\n")
  end

    def self.catalog_deploy_path
        CATALOG_DEPLOY_TARGET
    end

    def self.branch_path(branch)
        File.join(CATALOG_DEPLOY_TARGET, "/#{branch}")
    end

  def self.current_path
    File.join(CATALOG_DEPLOY_TARGET, '/current')
  end

  def self.props_file_path
    PROPS_PATH
  end

  def self.environment
    ENV_CONFIG
  end
end


#####################################################################
# Task Targets
#####################################################################
  
desc 'SVN checkout/update branch, point current symbolic link to branch, generate config files, and builds catalog databases (e.g. catalograke use[trunk] )'
task :use, :branch do |t, args|

    if !args[:branch]
        puts "Branch required but not specified - (e.g. catalograke use[trunk] )"
        next    # effectively a return in a ruby block
    end

    timestamp   = Time.now.tv_sec

    branch = args[:branch].downcase.strip  

    CatalogRake.unlink_current

    # Always delete the target path
    if CatalogRake.branch_exists?( branch )
        CatalogRake.delete_branch branch 
    end

    # Fresh checkout
    CatalogRake.svn_checkout branch 
    
    CatalogRake.set_current_link branch

    CatalogRake.build_branch branch

    sec = Time.now.tv_sec - timestamp
    puts "Done. [#{sec}] sec"
end

#desc 'Removes target catalog-service branch (e.g. catalograke clean[rc-160] )'
#task :clean, :branch do |t, args|

#   if !args[:branch]
#       puts "Branch required but not specified - (e.g. catalograke use[trunk] )"
#       next    # effectively a return in a ruby block
#   end

#   branch = args[:branch].downcase.strip

#   puts "Done."
#end

desc 'Installs catalograke alias to .bash_aliases so that catalograke.rake can be invoked throughout shell.'
task :install_alias do |t, args|
    timestamp   = Time.now.tv_sec
    CatalogRake.install_alias
    sec = Time.now.tv_sec - timestamp
    puts "Done. [#{sec}] sec"
end

task :default do
    puts ""
    puts "CatalogRake Version[#{CatalogRake.version}]"
    puts ""
    # setting up the default so that the task targets are listed by default (rather than specifying catalograke -T)
  system("rake -f #{__FILE__} -sT") # s is for silent option, T lists the tasks
end
