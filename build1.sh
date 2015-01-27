#!/bin/bash -f

if [ "x$1" = "x" -o "x$2" = "x" -o "x$3" = "x" ];then
        echo "Usage: $0 <git_dev_branch> <git_rel_branch> <tag_name>"
        exit 1
fi

today=`date +%Y-%m-%d_%H%M%S`
LOG_FILE=C:\Users\swetha\Desktop\swetharepo\logs/merge_$1_$2_$today.log
echo "Start of Build...." >> $LOG_FILE

DEV_FOUND="NO"

for branch in $(git branch -a | sed 's/* //g' | sed 's/  //g')
do
	echo "Checking $branch for matching dev branch $1" >>$LOG_FILE   # THIS print can be deleted later
	if [ "$1" = "$branch" ]; then
		DEV_FOUND="YES"
		echo "Dev branch $1 found in the branches" >>$LOG_FILE
		git checkout $1
		if [ "$?" = 0 ]; then
			echo "Dev branch $1 checkedout successfully" >>$LOG_FILE
			git pull				 
			if [ "$?" = 0 ]; then
				echo "git pull is done successfully" >>$LOG_FILE
				RELEASE_FOUND="NO"			
				STATUS=1
				#this loop is to check whether the release branch exist or not
				#while read relbranch
				for relbranch in $(git branch -a | sed 's/* //g' | sed 's/  //g')
				do
					echo "Checking $relbranch for matching release branch $2" >>$LOG_FILE # THIS print can be deleted later
					if [ "$2" = "$relbranch" ] ; then
						RELEASE_FOUND="YES"
						echo "Release branch $2 found. Checking out to release branch" >>$LOG_FILE
						git checkout $2
						STATUS=$?
						break
					fi				
				done
				
				if [ $RELEASE_FOUND == "NO" ]; then
					echo "Release branch $2 not found. Creating the release branch and checkingout to it" >> $LOG_FILE
					git checkout -b $2
					STATUS=$?
					git push origin $2   ### CHECK if this needed at this place ???
					echo "Successfully pushed the code to release branch $2" >> $LOG_FILE					
				else
					echo "Release branch $2 found and checkedout status is : $STATUS" >> $LOG_FILE
				fi
				
				####
				if [ "$STATUS" -eq 0 ]; then
						echo "Checkout to release branch is successful">>$LOG_FILE
						RESULT=`git merge $1`
						if [ "$RESULT" == "Merged to release branch $2" -o "$RESULT" == "Already up-to-date." ]; then
							git push                                                                
							TAG_FOUND="NO"
							#Check if the tag exists in git
							for tag_name in $(git tag)
							do
								echo "Checking the tag $tag_name" >>$LOG_FILE
								if [ $tag_name = "$3" ]; then
									TAG_FOUND="YES"
									echo "Tag $3 found and need to be deleted" >>$LOG_FILE
									break
								fi                                                      
							done
								
							#Delete the tag if it is already present
							if [ $TAG_FOUND == "YES" ]; then
								git tag -d $3
								git push origin tag :$3
								echo "Successfully deleted the tag $3" >>$LOG_FILE
							fi
							#Create the tag
							git tag $3
							git push origin tag $3
							echo "Successfully created the tag and pushed to repo" >>$LOG_FILE
					#	elif [ "$RESULT" == "Already up-to-date." ]; then
					#		echo "Result : $RESULT" >> $LOG_FILE
						else								
							echo "Result : $RESULT" >> $LOG_FILE
							echo "Conflicts found while merging to $2" >> $LOG_FILE
							exit 1
						fi
					else
						echo "Release branch $2 checkout not successful" >> $LOG_FILE
						exit 1
					fi
				else
					echo "Release branch $2 checkout status : $STATUS is not successful" >>$LOG_FILE
					exit 1
				fi				
			else
				echo "Error while git pull from stash for development branch " >> $LOG_FILE
				exit 1
			fi
		else
			echo "Cannot Checkout development branch $1" >> $LOG_FILE
			exit 1
		fi
		echo "Done with the script" >> $LOG_FILE
		exit 1
#	fi
done

if [ $DEV_FOUND == "NO" ]; then
	echo "Dev branch $1 is not found" >>$LOG_FILE
fi
echo "Bye" >> $LOG_FILE
