#!/bin/bash 
set -x
#echo scriptaccount $scriptaccount
#echo repo $repo
#echo loaction $location
#echo overridefile $overridefile
#echo stateaccount $stateaccount
#echo staterepo $staterepo
#echo artifactid $artifactid
#echo command $command
CONFIG_PATH=/home/terraspin/opsmx/app/config
#CONFIG_PATH=.
aws=aws
if [ -z $aws ]
then
        echo " Not Specified the #aws account "
        exit 1
else
        checkaccountstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$aws'")')
        if [ -z "$checkaccountstate" ]
        then
                echo "AWS account is not configured in  artifactaccounts.json"
                exit 1
        else
                        #awsaccesskey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$#aws'")|.#awsaccesskey')
                        #awssecretkey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$#aws'")|.#awssecretkey')
                        #awsregion=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$#aws'")|.region')
                        #aws configure set #aws_access_key_id $#awsaccesskey
                        #aws configure set #aws_secret_access_key $#awssecretkey
                        #aws configure set region $#awsregion
			echo "Aws account is configured Successfully from artifactaccounts.json"
			#echo ""

#cat $CONFIG_PATH/artifactaccounts.json

terraformcommand="$command"
scriptact=$(echo "$scriptaccount" | tr -d [:space:])
tfrepo=$(echo "$repo" | tr -d [:space:])
tflocation=$(echo "$location" | tr -d [:space:])
override=$(echo "$overridefile" | tr -d [:space:])
stateact=$(echo "$stateaccount" | tr -d [:space:])
staterep=$(echo "$staterepo" | tr -d [:space:])
artifact=$(echo "$artifactid" | tr -d [:space:])
TFCMD=$(echo "$terraformcommand" | tr -d [:space:])
statefolder=$(echo "$staterep" | awk -F/ '{print $2}' | awk -F. '{print $1}')

echo "-------- Terraform Command ----------"
echo "            $TFCMD                   "
echo "-------------------------------------"


if [ -z $scriptact ]
then
	echo " Not Specified the Tf script account "
	exit 1
else
	checkaccount=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$scriptact'")')
	if [ -z "$checkaccount" ]
	then
		echo "Script Account is Not there artifactaccounts.json"
		exit 1
	else
		echo "Script account is located in artifactaccounts.json"
		username=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$scriptact'")|.username')
		password=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$scriptact'")|.password')
		hostScriptURL=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$scriptact'")|.host')
                hostScriptHost=$(echo $hostScriptURL |sed 's,https\?://,,g')
	fi
fi


if [ -z $stateact ]
then
        echo " Not Specified the Tf script account "
        exit 1
else
        checkaccountstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")')
        if [ -z "$checkaccountstate" ]
        then
                echo "State Account is Not there in artifactaccounts.json"
		exit 1
        else
                echo "State account is there in artifactaccounts.json"
		s3check=s3
		githubcheck=github
		bitbucketcheck=bitbucket
		artifacttype=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.artifacttype')
		if [ "${artifacttype^^}" == "${s3check^^}" ]
		then
			echo "SPecified the s3 as artifact"
			#awsaccesskey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awsaccesskey')
                        #awssecretkey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awssecretkey')
			#awsregion=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.region')
		elif [ "${artifacttype^^}" == "${githubcheck^^}" ]
		then
			echo "Specified the GitHub as artifact"
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
                        passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
		elif [ "${artifacttype^^}" == "${bitbucketcheck^^}" ]
		then
			echo "Specified the Bitbucket as artifact"
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
			passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
		else
			echo "None of the artifact Present"
			exit 1
		fi
        fi
fi
###################################################
#TERRADORM COMMANDS FUNCTIONALITY 
###################################################
if [ $TFCMD == "plan" ]
then
    echo "Plan executing............"
    cd $HOME
    git -c http.sslVerify=false  clone https://$username:$password@$hostScriptHost/$tfrepo workspace > /dev/null
    cd workspace/$tflocation
    terraform init
    terraform validate
    #terraform plan -var-file=$override -out terraform.plan
    if [ -z $override ]
    then
#	    echo "Not Specified the Override File"
	    terraform plan -out=terraform.plan
    else
	    terraform plan -var-file=$override -out=terraform.plan
    fi
    #terraform plan -var-file=input.tfvars -out terraform.plan
    if [ $? -eq 0 ]; then
	    #---------------------------------------------------------------
		s3check=s3
		githubcheck=github
		bitbucketcheck=bitbucket
		artifacttype=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.artifacttype')
		if [ "${artifacttype^^}" == "${s3check^^}" ]
		then
			#awsaccesskey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awsaccesskey')
                        #awssecretkey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awssecretkey')
			#awsregion=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.region')
#		    echo "Pushing state file to S3"
                    cd $HOME/workspace/$tflocation
		    #ls -la
                    zip -r -q $HOME/$artifact.zip /$HOME/workspace/$tflocation -x '*.terraform*'
		    echo "----------- Pushing artifact to s3 ---------------"
                    #AWS_ACCESS_KEY_ID=$awsaccesskey AWS_SECRET_ACCESS_KEY=$#awssecretkey #
                    rm -rf ~/.aws/configure
                    aws s3 cp $HOME/$artifact.zip s3://$staterep/$artifact.zip > /dev/null
		    #echo "----State File Name is terraform.plan----"
		elif [ "${artifacttype^^}" == "${githubcheck^^}" ]
		then
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
                        passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
			email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
			hosturl=$(echo $host |sed 's/https\?:\/\///')
			echo "Pushing state file to Github"
			cd $HOME/workspace/$tflocation
			zip -r -q $HOME/$artifact.zip /$HOME/workspace/$tflocation -x '*.terraform*'
			cd $HOME
			git -c http.sslVerify=false clone https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep  > /dev/null
			cp $HOME/$artifact.zip $HOME/$statefolder/
			cd $HOME/$statefolder
			git add .
			git config --global user.email "$email"
		       	git config --global user.name "$usernamegitstate"
			git commit -m "Pushed Plan State artifact"
			git push https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
		elif [ "${artifacttype^^}" == "${bitbucketcheck^^}" ]
		then
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
			passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
			email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
                        echo "Pushing state file to BitBucket"
                        cd $HOME/workspace/$tflocation
                        zip -r -q $HOME/$artifact.zip /$HOME/workspace/$tflocation -x '*.terraform*'
                        cd $HOME
                        git -c http.sslVerify=false clone https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep  > /dev/null
                        cp $HOME/$artifact.zip $HOME/$statefolder/
                        cd $HOME/$statefolder
                        git add .
                        git config --global user.email "$email"
                        git config --global user.name "$usernamegitstate"
                        git commit -m "Pushed Plan State artifact"
                        git push https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
		else
			echo "None of the artifact Present"
			exit 1
		fi
               #------------------------------------------------------------
    else
	    echo Terraform Plan FAILED
	    exit 1
    fi

elif [ $TFCMD == "apply" ]
then
    echo "Apply executing..........................."
 #   cd $HOME
 #   git -c http.sslVerify=false clone https://$username:$password@github.com/$tfrepo workspace > /dev/null
 #   cd workspace/$tflocation
 #   terraform init > /dev/null
 #   terraform validate > /dev/null
 #   terraform plan -var-file=$override -out terraform.plan > /dev/null
 #   terraform apply -var-file=$override -auto-approve
#--------------------------------------------------------------------------------------
    if [ $? -eq 0 ]; then
	    #---------------------------------------------------------------
		s3check=s3
		githubcheck=github
		bitbucketcheck=bitbucket
		artifacttype=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.artifacttype')
		if [ "${artifacttype^^}" == "${s3check^^}" ]
		then
			#awsaccesskey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awsaccesskey')
                        #awssecretkey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awssecretkey')
			#awsregion=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.region')
                    cd $HOME
		    ##aws s3 cp <source> <target> [--options]
		    #AWS_ACCESS_KEY_ID=$#awsaccesskey AWS_SECRET_ACCESS_KEY=$#awssecretkey 
                    rm -rf ~/.aws/configure
                    aws s3 cp s3://$staterep/$artifact.zip $HOME/$artifact.zip > /dev/null
		    unzip -q $HOME/$artifact.zip
		    rm -rf $HOME/$artifact.zip
		    cd $HOME/workspace/$tflocation
		    terraform init > /dev/null
		    terraform validate > /dev/null
		    #terraform apply -var-file=$override -state=terraform.plan -auto-approve
		        if [ -z $override ]
			then
				#echo "Not Specified the Override File"
				terraform apply -auto-approve
			else
				terraform apply -var-file=$override -auto-approve
			fi
		    cat terraform.tfstate | jq '.outputs.kube_config.value' -r > kubeconfig
		    if [ $? -eq 0 ]; then
			    echo "Pushing Apply State file to the repo"
			    cd $HOME
			    zip -r -q $HOME/$artifact.zip /$HOME/workspace/$tflocation -x '*.terraform*'
			    #AWS_ACCESS_KEY_ID=$#awsaccesskey AWS_SECRET_ACCESS_KEY=$#awssecretkey
                            rm -rf ~/.aws/configure 
                            aws s3 cp $HOME/$artifact.zip s3://$staterep/$artifact.zip > /dev/null
			    cd $HOME/workspace/$tflocation
		    else
			    echo "Terraform Apply Failed"
			    exit 5
		    fi

		elif [ "${artifacttype^^}" == "${githubcheck^^}" ]
		then
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
                        passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
                        email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
                        #zip -r -q $HOME/$artifact.zip /$HOME/workspace/$tflocation -x '*.terraform*'
                        cd $HOME
                        git -c http.sslVerify=false clone https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
			cp $statefolder gitartifact -r
			cd $HOME/gitartifact
			rm -rf .git
			unzip -q $HOME/gitartifact/$artifact.zip > /dev/null
			cd $HOME/gitartifact/workspace/$tflocation
			terraform init > /dev/null
			terraform validate > /dev/null
                        if [ -z $override ]
                        then
                                #echo "Not Specified the Override File"
                                terraform apply -auto-approve
                        else
                                terraform apply -var-file=$override -auto-approve
                        fi

			cat terraform.tfstate | jq '.outputs.kube_config.value' -r > kubeconfig
			if [ $? -eq 0 ]; then
				cd $HOME
				zip -r -q $HOME/$artifact.zip /$HOME/gitartifact/workspace/$tflocation -x '*.terraform*'
				cp $HOME/$artifact.zip $HOME/$statefolder
				cd $HOME/$statefolder
				git add .
				git config --global user.email "$email"
				git config --global user.name "$username"
				git commit -m "Pushed Apply State file to repo"
				git push https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
				cd $HOME/gitartifact/workspace/$tflocation
			else
				echo "Terraform Apply Failed"
				exit 5
			fi

		elif [ "${artifacttype^^}" == "${bitbucketcheck^^}" ]
		then
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
			passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
                        email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
                        cd $HOME
                        git -c http.sslVerify=false clone https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
                        cp $statefolder gitartifact -r
                        cd $HOME/gitartifact
                        rm -rf .git
                        unzip -q $HOME/gitartifact/$artifact.zip > /dev/null
                        cd $HOME/gitartifact/workspace/$tflocation
                        terraform init > /dev/null
                        terraform validate > /dev/null
                        if [ -z $override ]
                        then
                               # echo "Not Specified the Override File"
                                terraform apply -auto-approve
                        else
                                terraform apply -var-file=$override -auto-approve
                        fi

			cat terraform.tfstate | jq '.outputs.kube_config.value' -r > kubeconfig
                        if [ $? -eq 0 ]; then
                                cd $HOME
                                zip -r -q $HOME/$artifact.zip /$HOME/gitartifact/workspace/$tflocation -x '*.terraform*'
                                cp $HOME/$artifact.zip $HOME/$statefolder
                                cd $HOME/$statefolder
                                git add .
                                git config --global user.email "$email"
                                git config --global user.name "$username"
                                git commit -m "Pushed Apply State file to repo"
                                git push https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
                                cd $HOME/gitartifact/workspace/$tflocation
                        else
                                echo "Terraform Apply Failed"
				exit 5
                        fi
		else
			echo "None of the artifact Present"
			exit 1
		fi
               #------------------------------------------------------------
    else
	    echo Terraform Apply  FAILED
	    exit 1
    fi

#--------------------------------------------------------------------------------------
    #cd $HOME/workspace/$tflocation
   # spin_deck=$(cat $override | grep spin_deck_url | cut -d '='  -f 2 | tr -d \" | tr -d [:space:])
   # spin_gate=$(cat $override | grep spin_gate_url | cut -d '='  -f 2 | tr -d \" | tr -d [:space:])
   # oes_deck=$(cat $override | grep oes_deck_url | cut -d '='  -f 2 | tr -d \" | tr -d [:space:])
   # oes_gate=$(cat $override | grep oes_gate_url | cut -d '='  -f 2 | tr -d \" | tr -d [:space:])

    #echo "SPINNAKER_PROPERTY_SPINNAKER_DECK_URL="$spin_deck""
    #echo "SPINNAKER_PROPERTY_SPINNAKER_GATE_URL="$spin_gate""
    #echo "SPINNAKER_PROPERTY_OES_URL="$oes_deck""
    echo "SPINNAKER_PROPERTY_TERRAFORMAPPLY="COMPLETED""
    echo "------------------------------------------------"
    echo "           Terraform Apply Completed            "
    echo "------------------------------------------------"

elif [ $TFCMD == "destroy" ]
then
    echo "Destroy executed"
        if [ $? -eq 0 ]; then
	    #---------------------------------------------------------------
		s3check=s3
		githubcheck=github
		bitbucketcheck=bitbucket
		artifacttype=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.artifacttype')
		if [ "${artifacttype^^}" == "${s3check^^}" ]
		then
			#awsaccesskey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awsaccesskey')
                        #awssecretkey=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.#awssecretkey')
			#awsregion=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.region')
                    cd $HOME
		    ##aws s3 cp <source> <target> [--options]
		    #AWS_ACCESS_KEY_ID=$#awsaccesskey AWS_SECRET_ACCESS_KEY=$#awssecretkey
                    rm -rf ~/.aws/configure 
                    aws s3 cp s3://$staterep/$artifact.zip $HOME/$artifact.zip > /dev/null
		    unzip -q $HOME/$artifact.zip
		    cd $HOME/workspace/$tflocation
		    terraform init > /dev/null
		    terraform validate > /dev/null
                        if [ -z $override ]
                        then
                            #    echo "Not Specified the Override File"
                                terraform destroy -auto-approve
                        else
                                terraform destroy -var-file=$override -auto-approve
                        fi
		elif [ "${artifacttype^^}" == "${githubcheck^^}" ]
		then
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
                        passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
                        email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
                        cd $HOME
                        git -c http.sslVerify=false clone https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
                        cp $statefolder gitartifact -r
			unzip -q $HOME/gitartifact/$artifact.zip > /dev/null
                        cd $HOME/gitartifact/workspace/$tflocation
			terraform init > /dev/null
			terraform validate > /dev/null
                        if [ -z $override ]
                        then
                             #   echo "Not Specified the Override File"
                                terraform destroy -auto-approve
                        else
                                terraform destroy -var-file=$override -auto-approve
                        fi

		elif [ "${artifacttype^^}" == "${bitbucketcheck^^}" ]
		then
			usernamegitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.username')
			passwordgitstate=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.password')
			host=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.host')
                        email=$(cat $CONFIG_PATH/artifactaccounts.json | jq -r '.[][] | select (.accountname == "'$stateact'")|.email')
                        hosturl=$(echo $host |sed 's/https\?:\/\///')
                        cd $HOME
                        git -c http.sslVerify=false clone https://$usernamegitstate:$passwordgitstate@$hosturl/$staterep > /dev/null
                        cp $statefolder gitartifact -r
                        unzip -q $HOME/gitartifact/$artifact.zip > /dev/null
                        cd $HOME/gitartifact/workspace/$tflocation
                        terraform init > /dev/null
                        terraform validate > /dev/null
                        if [ -z $override ]
                        then
                              #  echo "Not Specified the Override File"
                                terraform destroy -auto-approve
                        else
                                terraform destroy -var-file=$override -auto-approve
                        fi
		else
			echo "None of the artifact Present"
			exit 1
		fi
               #------------------------------------------------------------
    else
	    echo Terraform Destroy  FAILED
	    exit 1
    fi
else
    echo "Not able to validate Terraform state "plan" or "apply" or "destroy" "
fi

fi
fi
