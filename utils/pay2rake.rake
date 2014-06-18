
#####################################################################
# Configuration
#####################################################################

PAY_DEPLOY_TARGET_OVERRIDE 	= nil		# replace with paysvc deploy path if not being used in dev (default - /srv/dev#_payment-service)
DEV_ID_ORVERRIDE						= nil		# override env var DEVID (default - value found in ENV['DEVID'])
ENV_CONFIG_OVERRIDE					= nil		# (default - dev)
PROPS_PATH_OVERRIDE					= nil 	# (default /srv/dev#_payment-service/dev#.properties)


#####################################################################
# Environment Check
#####################################################################

dev_id = DEV_ID_ORVERRIDE ? DEV_ID_ORVERRIDE : ENV['ZENV_DEVID']

if PAY_DEPLOY_TARGET_OVERRIDE
	PAY_DEPLOY_TARGET = PAY_DEPLOY_TARGET_OVERRIDE

elsif dev_id
	# by default use the dev id in user environment to detect deploy target
	PAY_DEPLOY_TARGET = "/srv/dev#{dev_id}_payment-service"
end

if !File.exists?(PAY_DEPLOY_TARGET)
	puts "payment-service deploy directory does not exist [#{PAY_DEPLOY_TARGET}]"
	exit 1
end

ENV_CONFIG = ENV_CONFIG_OVERRIDE ? ENV_CONFIG_OVERRIDE : 'dev'
PROPS_PATH = PROPS_PATH_OVERRIDE ? PROPS_PATH_OVERRIDE : "#{PAY_DEPLOY_TARGET}/dev#{dev_id}.properties"


#####################################################################
# Classes
#####################################################################

class PayRake

	def self.unlink_current
		current_sym = self.current_path
		if File.exists?(current_sym) 
			self.run_cmd "unlink #{current_sym}"
		end
	end

  def self.set_current_link(branch)
  	current_sym = self.current_path
  	branch_path = self.branch_path(branch)
        deploy_path = self.payment_deploy_path
        self.run_cmd "rm #{current_sym}; ln -s #{branch_path}/ #{current_sym}; synccode #{deploy_path}"
  end

  def self.branch_exists?(branch)
  	branch_path = self.branch_path(branch)
  	( File.exists?(branch_path) && File.directory?(branch_path) )
  end

  def self.delete_branch(branch)
	  branch_path = self.branch_path(branch)
	  puts "Deleting Payment-Service Branch[#{branch}] from install directory. This may take a minute. Thank you for your patience."
	  output = self.run_cmd "cd /srv/; rm -rf #{branch_path}; echo 'done'"
	  self.print_cmd_output output
  end 

  def self.svn_update(branch)
  	branch_path = self.branch_path(branch)
  	puts "SVN Updating Payment-Service Branch[#{branch}]. This may take a minute. Thank you for your patience."
 		output = self.run_cmd "cd #{branch_path}; svn update"
    self.print_cmd_output output
  end

  def self.svn_checkout(branch)
  	deploy_path = self.payment_deploy_path
  	branch_path = self.branch_path(branch)

  	puts "SVN Checking Out Payment-Service Branch[#{branch}]. This may take a minute. Thank you for your patience."

  	if 'trunk' == branch
  		output = self.run_cmd "cd #{deploy_path}; svn co https://127.0.0.1:9443/payment-service/trunk/ #{branch_path}"
  	else
	 		output = self.run_cmd "cd #{deploy_path}; svn co https://127.0.0.1:9443/payment-service/branches/#{branch}/ #{branch_path}"
	 	end

    self.print_cmd_output output
  end

  def self.build_branch(branch)

		branch_path = self.branch_path(branch)

		puts "Building payment-service project and installing databases."

	        # invoke full catalog-service install, -Dvm=1 notifies build.xml pick vm.properties file instead of dev.properties file
                output = self.run_cmd "cd #{branch_path}; phing -Dprops=#{self.props_file_path} -Denv=#{environment} -Dvm=1 install"	
	
        	self.print_cmd_output output
  end


  def self.version
  	"1.0"
  end

  protected

	def self.run_cmd(command)
		puts "\tRunning Command: #{command}"
		`#{command}`
	end

	def self.print_cmd_output(output)
  	puts "\n" + output.split("\n").collect{|t| "\t#{t}" }.join("\n")
  end

	def self.payment_deploy_path
		PAY_DEPLOY_TARGET
	end

	def self.branch_path(branch)
		File.join(PAY_DEPLOY_TARGET, "/#{branch}")
	end

  def self.current_path
  	File.join(PAY_DEPLOY_TARGET, '/current')
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
  
desc 'SVN checkout/update branch, point current symbolic link to branch, generate config files, and builds payment databases (e.g. payrake use[trunk] )'
task :use, :branch do |t, args|

	if !args[:branch]
		puts "Branch required but not specified - (e.g. payrake use[trunk] )"
		next	# effectively a return in a ruby block
	end

	timestamp   = Time.now.tv_sec

	branch = args[:branch].downcase.strip  

	PayRake.unlink_current
	
	# Always delete the target path
	if PayRake.branch_exists?( branch )
		PayRake.delete_branch branch 
	end

	# Fresh checout
	PayRake.svn_checkout branch 
	
	PayRake.build_branch branch
	
        PayRake.set_current_link branch

	sec = Time.now.tv_sec - timestamp
	puts "Done. [#{sec}] sec"
end

#desc 'Removes target payment-service branch (e.g. payrake clean[rc-160] )'
#task :clean, :branch do |t, args|

#	if !args[:branch]
#		puts "Branch required but not specified - (e.g. payrake use[trunk] )"
#		next	# effectively a return in a ruby block
#	end

#	branch = args[:branch].downcase.strip

#	puts "Done."
#end

