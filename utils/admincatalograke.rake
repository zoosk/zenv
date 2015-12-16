
#####################################################################
# Configuration
#####################################################################

ADMIN_CAT_TARGET_OVERRIDE 	= nil		# replace with catalogsvc deploy path if not being used in dev (default - /srv/dev#_admin-catalog-service)
DEV_ID_ORVERRIDE						= nil		# override env var DEVID (default - value found in ENV['DEVID'])
ENV_CONFIG_OVERRIDE					= nil		# (default - dev)
PROPS_PATH_OVERRIDE					= nil 	# (default /srv/dev#_admin-catalog-service/dev#.properties)
USERNAME_OEVERRIDE                  = nil
DEVSERVER_OVERRID                   = nil


#####################################################################
# Environment Check
#####################################################################

dev_id = DEV_ID_ORVERRIDE ? DEV_ID_ORVERRIDE : ENV['DEVID']

if ADMIN_CAT_TARGET_OVERRIDE
	ADMIN_CAT_DEPLOY_TARGET = ADMIN_CAT_TARGET_OVERRIDE

elsif dev_id
	# by default use the dev id in user environment to detect deploy target
	ADMIN_CAT_DEPLOY_TARGET = "/srv/dev#{dev_id}_admin-catalog-service"
end

if !File.exists?(ADMIN_CAT_DEPLOY_TARGET)
	puts "admin-catalog-service deploy directory does not exist [#{ADMIN_CAT_DEPLOY_TARGET}]"
	exit 1
end

ENV_CONFIG = ENV_CONFIG_OVERRIDE ? ENV_CONFIG_OVERRIDE : 'dev'
PROPS_PATH = PROPS_PATH_OVERRIDE ? PROPS_PATH_OVERRIDE : "#{ADMIN_CAT_DEPLOY_TARGET}/dev#{dev_id}.properties"
USERNAME = USERNAME_OEVERRIDE ? USERNAME_OEVERRIDE : ENV['ZENV_LDAP_USERNAME']
DEV_SERVER = DEVSERVER_OVERRID ? DEVSERVER_OVERRID : "sfo2-dev-vmdev0#{dev_id}.sfo2.zoosk.com"


#####################################################################
# Classes
#####################################################################

class AdminCatalogRake

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
      puts "Deleting Admin Catalog Branch[#{branch}] from install directory. This may take a minute. Thank you for your patience."
      output = self.run_cmd "cd /srv/; rm -rf #{branch_path}; echo 'done'"
      self.print_cmd_output output
  end

  def self.git_update(branch, stash_mode)
  	branch_path = self.branch_path(branch)
  	puts "Git Updating admin-catalog-service Branch[#{branch}]. This may take a minute. Thank you for your patience."
        #stash name = time
        #time = Time.now.getutc.to_i

        if(0 == stash_mode)
                puts "Updating with stash_mode 0, your changes (if any) will be on the stash stack and will not be included in the build"
                output = self.run_cmd "cd #{branch_path}; git fetch --all ; git stash ; git checkout #{branch} ; git pull;"
        elsif(1 == stash_mode)
                puts "Updating with stash_mode 1, you will have to manually drop stash entry after apply"
                output = self.run_cmd "cd #{branch_path}; git fetch --all ; git stash | grep 'No local changes to save' && (git checkout #{branch} && git pull) || (git checkout #{branch} && git pull && git stash apply)"
        elsif(2 == stash_mode)
                puts "Updating with stash_mode 2, stash will be automatically popped after update"
                output = self.run_cmd "cd #{branch_path}; git fetch --all ; git stash | grep 'No local changes to save' && (git checkout #{branch} && git pull) || (git checkout #{branch} && git pull && git stash pop)"
        end
        self.print_cmd_output output
  end

  def self.git_clone(branch)
  	deploy_path = self.admin_cat_deploy_path
  	branch_path = self.branch_path(branch)

  	puts "Git:Cloning admin-catalog-service Branch[#{branch}]. This may take a minute. Thank you for your patience."

  	output = self.run_cmd "cd #{deploy_path}; git clone https://g.zoosk.com/Payment/admin-catalog.git  #{branch_path}"

        self.print_cmd_output output
  end

  def self.build_branch(branch)
		puts "Building admin-catalog-service project."

		# invoke full admin-catalog-service install
		output = self.run_cmd "cd #{current_path}; rm -rf #{current_path}/www; ./gradlew debugAll -Penv=#{environment}"

		self.print_cmd_output output
  end

    def self.sync_branch(branch)
        branch_path = self.branch_path(branch)

        puts "Sync admin-catalog-service from #{current_path}/www/ to #{dev_server}:#{current_path}/www/"

        # invoke full admin-catalog-service install
        output = self.run_cmd "ssh #{username}@#{dev_server} 'if [ -e #{current_path} ]; then rm -rf #{current_path};fi;mkdir -p #{current_path};'; rsync -za --delete #{current_path}/www/ #{username}@#{dev_server}:#{current_path}/www/"

        self.print_cmd_output output
    end

  def self.install_alias
  	user_home_dir = File.expand_path('~')
		bash_aliases	= File.join(user_home_dir, '/.bash_aliases')

		if !File.exists?(bash_aliases)
			puts "Failure - cannot find file to update [#{bash_aliases}]"
			return
		end

		str = "\nalias admincatrake='rake -f #{__FILE__} '"

		contents = File.read(bash_aliases)

		if contents.include?(str)
			puts "Success - admincatrake alias already exists in file [#{bash_aliases}]"
			return
		end

		# write alias to file
		File.open(bash_aliases, 'a') do |f|
			f.write(str)
		end

		puts "Success - admincatrake alias written to file [#{bash_aliases}]"
		puts "Remember to execute your .bash_alias file so that your new alias works in the current shell (new shells should work fine). To do so run the following command:"
		puts ""
		puts ". #{bash_aliases}"
		puts ""
  end

  def self.version
  	"1.0"
  end

  protected

	def self.run_cmd(command)
		puts "Running Command: #{command}"
		`#{command}`
	end

	def self.print_cmd_output(output)
  	puts "\n"+ output.split("\n").collect{|t| "#{t}" }.join("\n")
  end

	def self.admin_cat_deploy_path
		ADMIN_CAT_DEPLOY_TARGET
	end

	def self.branch_path(branch)
		File.join(ADMIN_CAT_DEPLOY_TARGET, "/#{branch}")
	end

  def self.current_path
  	File.join(ADMIN_CAT_DEPLOY_TARGET, '/current')
  end

  def self.props_file_path
  	PROPS_PATH
  end

  def self.environment
  	ENV_CONFIG
  end

    def self.username
    	USERNAME
    end

    def self.dev_server
        DEV_SERVER
    end
end


#####################################################################
# Task Targets
#####################################################################

desc 'Git clone/pull branch, point current symbolic link to branch, generate config files (e.g. admincatlograke use[master] )'
task :use, [:branch, :stash_mode] do |t, args|

	if !args[:branch]
		puts "Branch required but not specified - (e.g. admincatalograke use[master] )"
		next	# effectively a return in a ruby block
	end

	if !args[:stash_mode]
        puts "stash mode not selected, using default (0)"
        puts "options (0 = stash catalog changes do not 'pop'/'apply', changes not included in build"
        puts "         1 = stash catalog changes + 'apply' before build (manual cleanup of stash)"
        puts "         2 = stash catalog changes + 'pop' before build"
        stash_mode = 0
    else
        stash_mode = args[:stash_mode].to_i
    end

	timestamp   = Time.now.tv_sec

	branch = args[:branch].strip

	AdminCatalogRake.unlink_current

	if AdminCatalogRake.branch_exists?( branch )
		AdminCatalogRake.git_update(branch, stash_mode)
	else
		AdminCatalogRake.git_clone branch
	end

	AdminCatalogRake.set_current_link branch

	AdminCatalogRake.build_branch branch

	AdminCatalogRake.sync_branch branch

	sec = Time.now.tv_sec - timestamp
	puts "Done. [#{sec}] sec"
end

#desc 'Removes target admin-catalog-service branch (e.g. admincatrake clean[rc-160] )'
#task :clean, :branch do |t, args|

#	if !args[:branch]
#		puts "Branch required but not specified - (e.g. admincatrake use[trunk] )"
#		next	# effectively a return in a ruby block
#	end

#	branch = args[:branch].downcase.strip

#	puts "Done."
#end

#desc 'Installs catalograke alias to .bash_aliases so that catalograke.rake can be invoked throughout shell.'
#task :install_alias do |t, args|
#	timestamp   = Time.now.tv_sec
#	AdminCatalogRake.install_alias
#	sec = Time.now.tv_sec - timestamp
#	puts "Done. [#{sec}] sec"
#end

task :default do
	puts ""
	puts "AdminCatalogRake Version[#{AdminCatalogRake.version}]"
	puts ""
	# setting up the default so that the task targets are listed by default (rather than specifying admincatalograke -T)
  system("rake -f #{__FILE__} -sT") # s is for silent option, T lists the tasks
end
