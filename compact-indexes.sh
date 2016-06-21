#!/bin/bash
#--------------------------------------------------------------------------------#
# Global Variables
#--------------------------------------------------------------------------------#
SOURCE='/data/part/index_0616'
OUTPUT='/data/index/0620'
PART='/data/group'
#--------------------------------------------------------------------------------#
# Wait for signal from all childrent tofinish
#--------------------------------------------------------------------------------#
trap 'echo "Caught SIGUSR1"' SIGUSR1
#--------------------------------------------------------------------------------#
# Merge Directories Indexes
#--------------------------------------------------------------------------------#
function merge_directory_index()
{
  command='/usr/local/bin/xapian-compact -F -m -b 64K '

  # for i in $(find ${SOURCE} -maxdepth 1 -type d) 
  for i in $(ls -d ${PART}/*/)
  do
    command=$command" ${i} "
  done

  command=$command" ${OUTPUT}"

  echo $command
  $command


}
#--------------------------------------------------------------------------------#
# Merge Group Indexes
#--------------------------------------------------------------------------------#
function merge_group_index() {

  #-------------------------------------------#
  x=0
  while read line
  do
    ARRAY[ $x ]="$line"
    (( x++ ))
  done < <(ls -d $SOURCE/*/)
  #-------------------------------------------#

  LEN=${#ARRAY[@]}
  DEV=$(expr $LEN / 4)

  COUNTER=0
  TOTAL=0
  GROUP=0
  command='/usr/local/bin/xapian-compact -m -b 64K '

  while [  $TOTAL -le $LEN ]; do

     if [ "$COUNTER" -gt "$DEV" ]
     then

        echo "-------------------------------------------------"
        mkdir -p ${PART}/${GROUP}
        command=$command" ${PART}/${GROUP}"
        echo $command 
        ##### ATTENTION EXECUTE #####
        $command &
        sleep 1
        command='/usr/local/bin/xapian-compact -m -b 64K '                                                                                                                                                                                                                                                                                                                                                                               
        COUNTER=0
        ((GROUP+=1))

     fi

     command=$command" ${ARRAY[$TOTAL]} "
     let TOTAL=TOTAL+1
     ((COUNTER+=1))

  done

  echo "-------------------------------------------------"
  mkdir -p ${PART}/${GROUP}
  command=$command" ${PART}/${GROUP}"
  echo $command
  ##### ATTENTION EXECUTE #####
  $command &
  sleep 1

}

#--------------------------------------------------------------------------------#
#                                M A I N                                         #
#--------------------------------------------------------------------------------#
merge_group_index

echo "-------------------------------------------------"
wait
echo "Merging Group Directories"

merge_directory_index
