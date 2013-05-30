#!/bin/bash
if [ "$(sudo whoami)" != "root" ]; then
  echo "\033[37;1;41mSorry, you are not root.\033[0m"
	exit
fi

read -p "Remove project with name: " projectName

projectDirectory="/home/user/web/"$projectName
vhostFile="/etc/apache2/sites-available/"$projectName
repositoryDirectory="/home/svn/"$projectName

ValidateVirtualHost ()
{
	if [ ! -d $projectDirectory ]
	then
		echo "\033[37;1;41mDirectory for project is not exists.\033[0m"
		error=true
	fi
	if [ ! -f $vhostFile ]
	then
		echo "\033[37;1;41mVirtual host is not exists.\033[0m"
		error=true
	fi
}

ValidateRepository ()
{
	if [ ! -d $repositoryDirectory ]
	then
		echo "\033[37;1;41mDirectory for subversion repository is not exists.\033[0m"
		error=true
	fi
}

VirtualHostQuestion ()
{
	read -p "Do you want to remove virtual host(yes/no)?: " choice
	case "$choice" in 
		"yes") removeVirtualHost=true;;
		"no") ;;
		* ) echo "Type 'yes' or 'no'"; VirtualHostQuestion;;
	esac
}

RepositoryQuestion ()
{
	read -p "Do you want to remove subversion repository(yes/no)?: " choice
	case "$choice" in 
		"yes") removeRepository=true;;
		"no") ;;
		* ) echo "Type 'yes' or 'no'"; RepositoryQuestion;;
	esac
}

RemoveVirtualHost ()
{
	sudo a2dissite $projectName
	sudo /etc/init.d/apache2 restart
	sudo rm -rf $projectDirectory
	sudo rm $vhostFile
}

RemoveRepository ()
{
	sudo rm -rf $repositoryDirectory
}

VirtualHostQuestion
RepositoryQuestion

if [ $removeVirtualHost ]
then
	ValidateVirtualHost
fi

if [ $removeRepository ]
then
	ValidateRepository
fi

if [ $error ]
then
	echo "\033[37;1;41mNothing removed.\033[0m"
	exit
fi

if [ $removeVirtualHost ]
then
	RemoveVirtualHost
fi

if [ $removeRepository ]
then
	RemoveRepository
fi

if [ $removeVirtualHost ]
then
	echo "\033[37;1;42mProject url: http://${projectName}.local/ - removed.\033[0m";
	echo "\033[37;1;42mProject directory: /home/user/web/${projectName} - removed.\033[0m";
	echo "\033[37;1;44mRemove domain '${projectName}.local' from /etc/hosts to complete removing virtual host.\033[0m";
fi

if [ $removeRepository ]
then
	echo "\033[37;1;42mSubversion repository URL: http://svn.local/${projectName}/ - removed.\033[0m";
fi
