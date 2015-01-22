#!/bin/bash 

if [ "x$1" = "x" -o "x$2" = "x" -o "x$3" = "x" ];then
        echo "use: $0 <git_dev_branch> <git_rel_branch> <tag_name>"
        exit 1
fi

today=`date +%Y-%m-%d_%H%M%S`
LOG_FILE=/opt/buildlog/merge_$today.log
echo "Start of Build...." >> $LOG_FILE

for branch in $(git branch)
do
        echo "Checking branch $branch" >>$LOG_FILE
        if [ "$1"="$branch" -o "*$1"="$branch" ]; then
            git checkout $1
		    if [ "$?" = 0]; then
				git pull <<EOF
stashuser
art#1249
EOF 						 
                if [ "$?" = 0]; then
					RELEASE_FOUND="NO"
					for relbranch in $(git branch -a)
					do
						echo " checking Release branch $relbranch" >> $LOG_FILE
						if [ "$2" = "$relbranch" ] ; then
							RELEASE_FOUND="YES"
							git checkout $2
							if [ "$?" = 0 ]; then
								RESULT=`git merge $1`
								echo "$RESULT"  >> $LOG_FILE
								if [ "$RESULT" = "Merged to release branch $2" ]; then
									git push <<EOF
									art#1249
									EOF
									found="NO"
									for tag_name in $(git tag)
									do
										echo "Checking the tag $tag_name"
										if [ $tag_name = "$3" ]; then
											found="YES"	
											echo "Tag $3 found and need to be deleted" >> $LOG_FILE
											break
										fi										
									done
							        if [$found="YES"]; then
								        git tag -d $3
										git push -u origin tag :$3 <<EOF
										                   art#1249
														    EOF
										echo "Deleted tag $3 successfully" >> $LOG_FILE
							        fi
									
									git tag $3
									git push origin tag $3 <<EOF
									                        art#1249
															EOF
									echo "Created tag $3 successfully" >> $LOG_FILE
								else
									echo "conflicts while merging" >> $LOG_FILE
									exit 1
								fi
							else
								echo "Release branch $2 checkout not successful" >> $LOG_FILE
								exit 1
							fi
						fi
					done
					if[$RELEASE_FOUND="YES"]; then
						break
					else
						git checkout -b $2
						git push origin $2
					fi
				else
					echo "Error while git pull from stash for development branch " >> $LOG_FILE
					exit 1
				fi
			else
			    echo "Cannot Checkout development branch $1" >> $LOG_FILE
                exit 1
            fi
		
                     exit 
		fi	
done < /tmp/xabc
echo "bye" >> $LOG_FILE
