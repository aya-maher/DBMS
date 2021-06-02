#!/usr/bin/bash

cd DBMS

function DB_name_validation(){
	if [ -d $1 ]
	then
#		echo Found;
		return 0;
	else
#		echo Not found;
		return 1;
	fi	
}

function create_DB(){
        echo -e "Enter The Name of Database : \c"
        read DB_name
	if [[ $DB_name =~ ^[A-Za-z0-9_]+$ ]]
	then
		DB_name_validation $DB_name
       		if [ $? -eq 1 ]            	  #if DB_name not exist already
       		then
               		mkdir $DB_name
              	        if [ $? -eq 0  ]
              		then
                      		 echo "Database Created Successfully"
              	        else
                        	echo "Database Not Created"
               		fi
        	else
			echo "Name Alrady Exists"
		fi
	else
		echo "Database name is not valid"
	fi	
}

function list_DB(){
	is_empty=`ls | wc -l`
	if [ $is_empty -eq 0 ]
	then
		echo "NO Databases Created"
	else
   		 for result in `ls`
   		 do
        		 if test -d $result
        		 then
             			 echo $result
        		 fi
   		 done
	 fi
}

function connect_to_DB(){
	echo -e "Enter the name of Databas: \c"
	read DB_name
	if [[ $DB_name =~ ^[A-Za-z0-9_]+$ ]]
	then
		DB_name_validation $DB_name
		if [ $? -eq 0 ]
		then
			cd ..
			source CRUD.sh $DB_name
			if [ $? -eq 0 ]	
			then 
				echo "Connected Successfully"
			else 
				echo "Could not connect"
			fi
		else
			echo "Database NOT found!"
		fi
	else
		echo "Input is Not Valid , Try again"
	fi	

}

function drop_DB(){
        echo -e "Enter The Name of Database you want to Drop It : \c"
        read DB_name
	if [[ $DB_name =~ ^[A-Za-z0-9_]+$ ]]
	then
		DB_name_validation $DB_name
        	if test -d $DB_name -a $? -eq 0
       		then
                	  rm -r $DB_name
               		  if [ $? -eq 0  ]
               		  then
                        	echo "Database Droped Successfully"
               		  else
                        	echo "Database Not Droped"
                	  fi
        	else
                	echo "Database Not Found "
        	fi
	else
                echo "Input is Not Valid , Try again"
        fi
	
}

function reset_system(){
        is_empty=`ls | wc -l`
	echo $is_empty
        if [ $is_empty -eq 0 ]
        then
                echo "NO Databases Created"
        else
		 echo -e "Are you sure[y/n]: \c"
                 read confirm
                 if test $confirm = "Y" -o $confirm = "y"
                 then
                 	for result in `ls`
                 	do
                         	if test -d $result
                         	then
                                 	rm -r $result
                         	fi
                 	done
		 	echo "The system has been reset Successfully"
		else
                        echo "Operation Cancelled"
                fi

         fi
}


select choice in "Create Database" "List Databases" "Connect to Databases" "Drop Database" "Reset System" "Exit"
do
        case $choice in
                "Create Database") create_DB
                        ;;
                "List Databases") list_DB
                        ;;
                "Connect to Databases") connect_to_DB
                        ;;
                "Drop Database") drop_DB
                        ;;
		"Reset System") reset_system
                        ;;
		"Exit") exit
			;;
                *) echo Wrong choice
                        ;;
        esac
done

