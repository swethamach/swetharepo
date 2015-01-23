#!/bin/bash -f

if [ "x$1" = "x" -o "x$2" = "x" -o "x$3" = "x" ];then
        echo "use: $0 <git_dev_branch> <git_rel_branch> <tag_name>"
        exit 1
fi

today=`date +%Y-%m-%d_%H%M%S`
LOG_FILE=c:/swethaw/merge_$today.log
echo "Start of Build...." >> $LOG_FILE

git branch -a | grep -E '^\*' | awk '{print $2}'  > c:/swethaw/xabc
#sed -i 's/*//g' c:/swethaw/xabc
while read branch
do
	echo "Checking branch $branch" >>$LOG_FILE
	if [ "$1" = "$branch" ]; then
		git checkout $1
		if [ "$?" = 0 ]; then
			echo "Dev branch checkout success" >>$LOG_FILE
			git pull				 
			if [ "$?" = 0 ]; then
				echo "git pull success" >>$LOG_FILE
				RELEASE_FOUND="NO"
				git branch -a | grep -E '^\*' | awk '{print $2}' > c:/swethaw/rabc
				sed -i 's/*//g' c:/swethaw/rabc
				
				#this loop is to check whether the release branch exist or not
				while read relbranch
				do
					echo "Checking Release branch $relbranch" >>$LOG_FILE
					if [ "$2" = "$relbranch" ] ; then
						RELEASE_FOUND="YES"
						echo "Release branch $2 found" >>$LOG_FILE
						git checkout $2
						if [ "$?" = 0 ]; then
							echo "Checkout to release branch success">>$LOG_FILE
							RESULT=`git merge $1`
							echo "$RESULT"  >> $LOG_FILE
							if [ "$RESULT" = "Merged to release branch $2" ]; then
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
								if [$found="YES"]; then
									git tag -d $3
									git push -u origin tag :$3
									echo "Successfully deleted the tag $3" >>$LOG_FILE
								fi
								#Create the tag
								git tag $3
								git push origin tag $3
								echo "Successfully created the tag and merged the code to release branch" >>$LOG_FILE
							else
								echo "conflicts found while merging" >> $LOG_FILE
								exit 1
							fi
						else
							echo "Release branch $2 checkout not successful" >> $LOG_FILE
							exit 1
						fi
						break
					fi
				done < c:/swethaw/rabc					
				
				if [ $RELEASE_FOUND="YES" ]; then
					break
				else
					echo "Release branch $2 not found. Creating the release branch" >> $LOG_FILE
					git checkout -b $2
					git push origin $2
					echo "Successfully pushed the code to release branch $2" >> $LOG_FILE
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
	fi
done < c:/swethaw/xabc
echo "Bye" >> $LOG_FILE

