#!/bin/bash
if [ "$(sudo whoami)" != "root" ]; then
  echo "\033[37;1;41mSorry, you are not root.\033[0m"
	exit
fi

read -p "Create new project name: " projectName

projectDirectory="/home/user/web/"$projectName 
vhostFile="/etc/apache2/sites-available/"$projectName
hostsFile="/etc/hosts"
hostsFileTmp="${hostsFile}.tmp"
repositoryDirectory="/home/svn/"$projectName

ValidateVirtualHost ()
{
	if [ -d $projectDirectory ]
	then
		echo "\033[37;1;41mDirectory for project is already exists.\033[0m"
		error=true
	fi
	if [ -f $vhostFile ]
	then
		echo "\033[37;1;41mVirtual host is already exists.\033[0m"
		error=true
	fi
}

ValidateRepository ()
{
	if [ -d $repositoryDirectory ]
	then
		echo "\033[37;1;41mDirectory for subversion repository is already exists.\033[0m"
		error=true
	fi
}

VirtualHostQuestion ()
{
	read -p "Do you want to create virtual host(yes/no)?: " choice
	case "$choice" in 
		"yes") createVirtualHost=true;;
		"no") ;;
		* ) echo "Type 'yes' or 'no'"; VirtualHostQuestion;;
	esac
}

RepositoryQuestion ()
{
	read -p "Do you want to create subversion repository(yes/no)?: " choice
	case "$choice" in 
		"yes") createRepository=true;;
		"no") ;;
		* ) echo "Type 'yes' or 'no'"; RepositoryQuestion;;
	esac
}

CreateVirtualHost ()
{
	mkdir $projectDirectory

	sudo cp /etc/apache2/sites-available/host.original $vhostFile
	echo "<VirtualHost *:80>" | sudo tee $vhostFile
	echo "\tServerName ${projectName}.local" | sudo tee -a $vhostFile
	echo "\tDocumentRoot /home/user/web/${projectName}" | sudo tee -a $vhostFile
	echo "</VirtualHost>" | sudo tee -a $vhostFile

	sudo cp $hostsFile $hostsFileTmp
	echo "127.0.0.1\t${projectName}.local" | sudo tee $hostsFile
	cat $hostsFileTmp | sudo tee -a $hostsFile
	sudo rm $hostsFileTmp

	sudo a2ensite $projectName
	sudo /etc/init.d/apache2 restart

	echo "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><title>${projectName} - Empty project</title></head><body bgcolor='#C9E0ED'><center><h3>Welcome to <i>${projectName}</i></h3><p>Project directory: <code>${projectDirectory}</code></p></center></body></html>" > "${projectDirectory}/index.html"
}

CreateRepository ()
{
	sudo svnadmin create $repositoryDirectory
	sudo chmod -R g+rws $repositoryDirectory
	sudo chown www-data:www-data $repositoryDirectory
}

VirtualHostQuestion
RepositoryQuestion

if [ $createVirtualHost ]
then
	ValidateVirtualHost
fi

if [ $createRepository ]
then
	ValidateRepository
fi

if [ $error ]
then
	echo "\033[37;1;41mNothing created.\033[0m"
	exit
fi

if [ $createVirtualHost ]
then
	CreateVirtualHost
fi

if [ $createRepository ]
then
	CreateRepository
fi

if [ $createVirtualHost ]
then
	echo "\033[37;1;42mProject url: http://${projectName}.local/\033[0m";
	echo "\033[37;1;42mProject directory: /home/user/web/${projectName}\033[0m";
fi

if [ $createRepository ]
then
	echo "\033[37;1;42mSubversion repository URL: http://svn.local/${projectName}/\033[0m";
fi
