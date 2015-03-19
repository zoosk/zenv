import environmentsettings
import vcs


#: The current environment settings
environ = environmentsettings.EnvironmentSettings()

#: Information about the current checkout's git repo
git_info = vcs.GitInfo()
