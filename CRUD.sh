#!/usr/bin/bash

cd DBMS/$1 

function name_validation(){
        if [ -f  $1 ]
        then
#               echo Found;
                return 0;
        else
#               echo Not found;
                return 1;
        fi
}
function type_validation(){
	echo -e "Enter Columns types separated by space : \c"
        read -a columns_types
		types_length=${#columns_types[*]}
		flag2=0
		if [ $types_length -eq 0 ]
        	then
			flag2=1
		else
			for (( i=0 ; i < $types_length ; i++)){
				if [ "${columns_types[i]}" != "string" -a "${columns_types[i]}" != "int" -a "${columns_types[i]}" != "mix"  ]
				then
					flag2=1
				fi
			}
		fi
	return $flag2
}
function create_columns(){
	echo "*********** Note : Column ID wil be entered dynamically .***********"
        echo -e "Enter Columns names separated by space : \c"
        read -a columns_names
	if [ $columns_names  ] #chk enter 
	then
		#echo -e "Enter Columns types: \c"
                #read -a columns_types
		type_validation
		while [ $? -ne 0 ]
		do
			echo "Invalid , Data Type Should be string or int or mix ."
			type_validation 
		done
       		names_length=${#columns_names[*]}
        	types_length=${#columns_types[*]}
        	if [ $names_length != $types_length ]
        	then
                	echo "Number of columns' names is not equal number of their types"
                	return 1
        	else
			echo $1,$((names_length+1)) >> .meta_$1
                	echo -e "ID, \c" >> $1
			echo "ID,int" >> .meta_$1
			for (( i=0 ; i < $names_length ; i++ )){
                        	echo ${columns_names[$i]},${columns_types[$i]} >> .meta_$1 
				if [[ $i -eq $names_length-1 ]]
                         	then
                                	echo -e "${columns_names[$i]} \c" >> $1
                         	else
                                  	echo -e "${columns_names[$i]}, \c" >> $1
                         	fi

                 	}
                	echo  >> $1                 #new line
			echo 0 >> .meta_$1  #number of records at the beginning 
                	return 0
        	fi
	else
		echo "Input is Not Valid , Try again."
		return 1
	fi	
}

function create_table(){
	echo -e "Enter The Name of Table : \c"
        read table_name
	if [[ $table_name =~ ^[A-Za-z0-9_]+$ ]]
	then
       		name_validation $table_name
        	if [ $? -eq 1 ]                   #if table_name not exist already
        	then
                	touch $table_name
			touch .meta_$table_name
                	if [ $? -eq 0  ]
                	then
                        	echo "Table Created Successfully"
				create_columns $table_name
		        	while [ $? -ne 0 ]
       				do
                			create_columns $table_name
        			done
        			echo "Columns created Successfully"
                	else
                        	echo "Table Not Created"
                	fi
        	else
                	echo "Name Alrady Exists "
        	fi
	else
		echo "Input is Not Valid , Try again."
	fi	
}

function list_tables(){
	is_empty=`ls | wc -l`
        if [ $is_empty -eq 0 ]
        then
                echo "Database is Empty"
        else
                 for result in `ls`
                 do
                         if test -f $result
                         then
                                 echo $result
                         fi
                 done
         fi

}

function drop_table(){
	echo -e "Enter The Name of Table you want to Drop It : \c"
        read table_name
	if [[ $table_name =~ ^[A-Za-z0-9_]+$ ]]
	then
        	name_validation $table_name
        	if test -f $table_name -a $? -eq 0
        	then
                	rm $table_name
			rm .meta_$table_name
                	if [ $? -eq 0  ]
                	then
                        	echo "Table Droped Successfully"
                	else
                        	echo "Table Not Droped"
                	fi
        	else
                	echo "Table Not Found"
        	fi
	else
		echo "Input is not Valid , Try again."
	fi	

}

function data_validation(){
	flag=0
        for (( i=0 ; i < $data_length ; i++)){
		data_type=`awk -F, '{if ( NR == "'$((i+3))'" ) print $2 }' .meta_$1`
		if [ "$data_type" == "string" ]
                then
			if [[ ${data[i]} =~ ^[A-Za-z]+$ ]]
			then
                       		echo "${data[i]} is a string"
			else
				echo "${data[i]} is Not a string"
				flag=1	
			fi
		elif [ "$data_type" == "int" ]
		then
                        if [[ ${data[i]} =~ ^[0-9]+$ ]]
                        then
                                echo "${data[i]} is an int"
                        else
                                echo "${data[i]} is Not an int"
				flag=1
                        fi
		elif [ "$data_type" == "mix" ]
                then
                      echo "${data[i]} is a mixed"
                fi
        }
	return $flag

}


function insert_into_table(){
	echo -e "Enter the name of table: \c"
	read table
	if [[ $table =~ ^[A-Za-z0-9_]+$ ]]
	then
		name_validation $table
        	if [ $? -eq 1 ]                   #if table_name not exist already
        	then
                        echo "Table is Not found"
        	else
			echo -e "Enter the data: \c"
      	        	read -a data
    			data_length=${#data[*]}
			fields=`awk -F, '{if ( NR == 1 ) print $2}' .meta_$table`
			fields=$((fields-1))
			if [ $fields -ne $data_length ]
      			then
	       			echo "Number of data is not equal number of columns"
        		else
				data_validation $table
				if [ $? -eq 0 ]
				then
                			primary_key=`sed -n '$p' .meta_$table`
					primary_key=$((primary_key+1))
					echo -e "$primary_key, \c" >> $table
                			for (( i=0 ; i < $data_length ; i++ )){
						if [[ $i -eq $data_length-1 ]]
                         			then
                                  			echo -e "${data[$i]} \c" >> $table
                         			else
                                  			echo -e "${data[$i]}, \c" >> $table
                         			fi
                 			}
                			echo  >> $table			#new line
					sed -i '$d' .meta_$table
					echo $primary_key >> .meta_$table
					echo "Data has been added Successfully"
				else
					echo "Data has not been added"
				fi
        		fi
		fi
	else
		echo "Input is Not valid , try again."
	fi	
}

function show_table(){
        echo -e "Enter the name of table: \c"
        read table
	if [[ $table =~ ^[A-Za-z0-9_]+$ ]]
	then
        	name_validation $table
        	if [ $? -eq 1 ]                   #if table_name not exist already
        	then
                	echo "Table is Not found"
        	else
                	cat $table
        	fi
	else
		echo "Input is Not Valid , Try again."
	fi	

}

function select_from_table(){
	echo -e "Enter the name of table: \c"
        read table
	if [[ $table =~ ^[A-Za-z0-9_]+$ ]]
	then
        	name_validation $table
        	if [ $? -eq 1 ]                   #if table_name not exist already
        	then
                	echo "Table is Not found"
        	else
                	echo -e "Enter the ID of Record you want to Select: \c"
                	read id
                	fid=`awk -F, '{if ($1 == "'$id'")  print  $1}' $table`
                	if [ $fid ]
                	then
                        	awk -F, '{if ($1 == "'$id'" || NR==1 )  print  $0}' $table
                	else
				echo "ID $id is NOT found!"
                	fi

        	fi
	else
		echo "Input is not Valid, Try again."
	fi	
}

function delete_from_table(){
	echo -e "Enter the name of table: \c"
	read table
	if [[ $table =~ ^[A-Za-z0-9_]+$ ]]
	then
		name_validation $table
		if [ $? -eq 1 ]                   #if table_name not exist already
        	then
                	echo "Table is Not found"
        	else
			echo -e "Enter the ID: \c"
       			read id
			fid=`awk -F, '{if ($1 == "'$id'")  print  NR}' $table`
			if [ ! $fid ] 
			then
				echo "ID $id is NOT found!"
			else
				sed -i "$fid"d $table    # -i to edit in the same file
				echo "Record $id has been deleted"
			fi
		fi
	else
		echo "Input is Not Valid, Try again."
	fi	
}

function reset_DB(){
        is_empty=`ls -a | wc -l`
        if [ $is_empty -eq 0 ]
        then
                echo "Database is Empty"
        else
		 echo -e "Are you sure[y/n]: \c"
		 read confirm
		 if test $confirm = "Y" -o $confirm = "y" 
		 then
                 	for result in `ls -a`
                 	do
                         	if test -f $result
                         	then
                                	 rm $result
                         	fi
                 	done
			echo "Database has been reset Successfully"
		else
			echo "Operation Cancelled"	
		fi
	fi

}

function back_to_main_menu(){
	cd ../..
	source DB.sh
}

select choice in "Create Table" "List Tables" "Drop Table" "Show Table" "Insert into Table" "Select from Table" "Delete from Table" "Reset Database" "Back to main menu" "Exit"
do
        case $choice in
                "Create Table") create_table
                        ;;
                "List Tables") list_tables
                        ;;
                "Drop Table") drop_table
                        ;;
		"Show Table") show_table
                        ;;
                "Insert into Table") insert_into_table
                        ;;
		"Select from Table") select_from_table
                        ;;
		"Delete from Table") delete_from_table
                        ;;
		"Reset Database") reset_DB
                        ;;
		"Back to main menu") back_to_main_menu
			;;
		"Exit") exit
			;;
                *) echo Wrong choice
                        ;;
        esac
done


