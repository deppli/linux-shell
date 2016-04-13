#Author: lishuhong

if [[ $# != 1 ]]; then
	echo "USAGE:./create.sh sqlfilename"
	exit 1;
fi

fileName=$1

if [[  ! -f $fileName ]]; then
	echo $fileName" is not a File"
	exit 1;
fi

echo "****** started ******"

tableName=$(cat $fileName| grep -i 'create table'| grep -o -E '\w*_\w*')
specialIndex=$(expr $(echo $tableName|awk -F "_" '{print  length($1)}') + 1)
lastLength=$(expr ${#tableName} - $specialIndex)
beanName=${tableName:$specialIndex:$lastLength}
smallBeanName=$(echo ${beanName:0:1}|tr '[A-Z]' '[a-z]')${beanName:1:$(expr ${#beanName} - 1)}

fieldStartLine=$(expr $(cat $fileName| grep -n -i 'create table'|awk -F ':' '{print $1}') + 1)
fieldEndLine=$(expr $(cat $fileName| grep -n -i 'primary key'|awk -F ':' '{print $1}') - 1)
javaFileName=$beanName'.java'

if [[ -f $javaFileName ]]; then
	rm -rf $javaFileName
fi


echo "****** bean name is "$beanName" ******"

function getJavaType(){
	sqlType=$(echo $1|tr '[A-Z]' '[a-z]')

	if [[ $sqlType =~ 'int' ]]; then
		tmpJavaType='int'
		tmpJavaImport=''
		return	
	fi
	
	if [[ $sqlType =~ 'time' ]]; then
		tmpJavaType='Date'
		tmpJavaImport='importjava.util.Date;'
		return
	fi

	if [[ $sqlType =~ 'char' || $sqlType =~ 'text' ]]; then
		tmpJavaType='String'
		tmpJavaImport=''
		return
	fi

	if [[ $sqlType =~ 'decimal' ]]; then
		tmpJavaType='BigDecimal'
		tmpJavaImport='importjava.math.BigDecimal;'
		return
	fi

	if [[ $sqlType =~ 'blob' ]]; then
		tmpJavaType='byte[]'
		tmpJavaImport=''
		return
	fi

	if [[ $sqlType =~ 'bit' ]]; then
		tmpJavaType='boolean'
		tmpJavaImport=''
		return
	fi
	echo "mysql type not found"
	echo "please send email to shuhong.li@dianping.com for mysql type "$sqlType
	exit 1;
}


echo "" >> $javaFileName
echo "" >> $javaFileName
echo "importorg.apache.commons.lang.builder.ToStringBuilder;" >> $javaFileName
echo "importorg.apache.commons.lang.builder.ToStringStyle;" >> $javaFileName
echo "importjava.io.Serializable;" >>$javaFileName

cat $fileName | sed -n $fieldStartLine','$fieldEndLine'p' > tmpFile

while read line; do
	line=$(echo $line|grep -o "[^ ]\+\( \+[^ ]\+\)*")
	if [[ ${#line} -gt 0 ]]; then
		fieldName=$(echo $line| awk '{print $1}')
		fieldName=$(echo $fieldName|grep -o "[^ ]\+\( \+[^ ]\+\)*")
		sqlType=$(echo $line| awk '{print $2}')
		sqlType=$(echo $sqlType|grep -o "[^ ]\+\( \+[^ ]\+\)*")
		comment=$(echo $line| awk -F 'COMMENT'  '{print $2}')
		comment=$(echo $comment|grep -o "[^ ]\+\( \+[^ ]\+\)*")

		if [[ ${fieldName:0:1} == "\`" ]]; then
			length=$(expr ${#fieldName} - 2)
			fieldName=${fieldName:1:$length} 
		fi

		if [[ ${comment:0:1} == "'" ]]; then
			length=$(expr ${#comment} - 3)
			comment=${comment:1:$length} 
		fi
		if [[ $comment == ',' || $comment == '' ]]; then
			comment="please write a comment for "$fieldName
		fi
		getJavaType $sqlType
		importLineNo=$(cat $javaFileName|grep  -n 'import'|sed -n '$p'|awk -F ":" '{print $1}')
		if [[ ${#tmpJavaImport} -gt 0 ]]; then
			num=$(cat $javaFileName|grep -n $tmpJavaImport)
			if [[ ${#num} -eq 0 ]]; then
				sed -i '' -e ${importLineNo}'a \
				'$tmpJavaImport  $javaFileName
			fi
		fi
		javaTypeArray[k++]=$tmpJavaType
		bigFieldAarray[n++]=$fieldName
		smallFieldName=$(echo ${fieldName:0:1}|tr '[A-Z]' '[a-z]')${fieldName:1:$(expr ${#fieldName} - 1)}
		smallFieldArray[j++]=$smallFieldName
		commentArray[i++]=$comment
	fi
done < tmpFile

sed 's/import/import /g' $javaFileName > tmpFile
cat tmpFile > $javaFileName

echo "" >> $javaFileName
echo "public class "$beanName" implements Serializable,Cloneable { " >> $javaFileName

#write java type
arrayLength=${#smallFieldArray[@]}
for (( i = 0; i < $arrayLength; i++ )); do
	echo "" >> $javaFileName
	echo "/**" >> $javaFileName
	echo " * "${commentArray[i]} >> $javaFileName
	echo " */" >> $javaFileName
	echo "private "${javaTypeArray[i]} ${smallFieldArray[i]}";" >> $javaFileName
done

#write get set
echo "" >> $javaFileName
for (( i = 0; i < $arrayLength; i++ )); do
	echo "public "${javaTypeArray[i]}" get"${bigFieldAarray[i]}"() { " >> $javaFileName
	echo "	return "${smallFieldArray[i]}";" >> $javaFileName
	echo "}" >> $javaFileName

	echo "" >> $javaFileName
	echo "public void set"${bigFieldAarray[i]}"("${javaTypeArray[i]}" "${smallFieldArray[i]}") { " >> $javaFileName
	echo "	this."${smallFieldArray[i]}" = "${smallFieldArray[i]}";" >> $javaFileName
	echo "}" >> $javaFileName
done

echo " @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this,
                ToStringStyle.SHORT_PREFIX_STYLE);
    }" >> $javaFileName

echo "}" >> $javaFileName

dtoBeanName=$beanName'DTO'
dtoFileName=$dtoBeanName'.java'

if [[ -f $dtoFileName ]]; then
	rm -rf $dtoFileName
fi

cat $javaFileName > $dtoFileName

sed "s/$beanName/$dtoBeanName/g" $dtoFileName > tmpFile

cat tmpFile > $dtoFileName


#dao file
daoBeanName=$beanName'Dao'
daoFileName=$daoBeanName'.java'

if [[ -f $daoFileName ]]; then
	rm -rf $daoFileName
fi

echo "" >> $daoFileName
echo "import com.dianping.avatar.dao.GenericDao;" >> $daoFileName
echo "import com.dianping.avatar.dao.annotation.DAOAction;" >> $daoFileName
echo "import com.dianping.avatar.dao.annotation.DAOActionType;" >> $daoFileName
echo "import com.dianping.avatar.dao.annotation.DAOParam;" >> $daoFileName
echo "" >> $daoFileName

echo "public interface "$daoBeanName 'extends GenericDao{ ' >> $daoFileName
echo "" >> $daoFileName
echo "	@DAOAction(action = DAOActionType.INSERT)" >> $daoFileName
echo '	public int add'$beanName'(@DAOParam("'$smallBeanName'") '$beanName $smallBeanName');' >> $daoFileName
echo "" >> $daoFileName
echo "	@DAOAction(action = DAOActionType.UPDATE)" >> $daoFileName
echo '	public int update'$beanName'(@DAOParam("'$smallBeanName'") '$beanName $smallBeanName');' >> $daoFileName
echo "" >> $daoFileName
echo "}" >> $daoFileName


#xml file
xmlFileName=$beanName'.xml'

if [[ -f $xmlFileName ]]; then
	rm -rf $xmlFileName
fi

echo '<?xml version="1.0" encoding="UTF-8"?>' >> $xmlFileName
echo '<!DOCTYPE sqlMap PUBLIC "-//ibatis.apache.org//DTD SQL Map 2.0//EN" "http://ibatis.apache.org/dtd/sql-map-2.dtd">' >> $xmlFileName
echo '<sqlMap namespace="'${beanName}'">' >> $xmlFileName
echo "" >> $xmlFileName
echo '<typeAlias alias="'$smallBeanName'" type="'$beanName'"/>' >> $xmlFileName
echo "" >> $xmlFileName

#allFields
echo '<sql id="allFields">' >> $xmlFileName
for (( i = 0; i < $arrayLength; i++ )); do
	if [[ $i == $(expr $arrayLength - 1) ]]; then
		echo " "${bigFieldAarray[i]} >> $xmlFileName
	else
		echo " "${bigFieldAarray[i]}"," >> $xmlFileName
	fi
done
echo "</sql>" >> $xmlFileName
echo "" >> $xmlFileName

#resultMap
echo '<resultMap id="'$smallBeanName'Map" class="'$smallBeanName'">' >> $xmlFileName
for (( i = 0; i < $arrayLength; i++ )); do
	echo '	<result property="'${smallFieldArray[i]}'" column="'${bigFieldAarray[i]}'"/>' >> $xmlFileName
done
echo '</resultMap>' >> $xmlFileName

echo "" >> $xmlFileName

#insert
echo '<insert id="add'$beanName'" parameterClass="map">' >> $xmlFileName
echo '	<![CDATA[' >> $xmlFileName
echo '	INSERT INTO '$tableName >> $xmlFileName
echo '	(' >> $xmlFileName
for (( i = 0; i < arrayLength; i++ )); do
	if [[ $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') != 'id' ]]; then
		if [[ $i == $(expr $arrayLength - 1) ]]; then
			echo " 	"${bigFieldAarray[i]} >> $xmlFileName
		else
			echo " 	"${bigFieldAarray[i]}"," >> $xmlFileName
		fi	
	fi
done
echo " 	)" >> $xmlFileName
echo "	VALUES" >> $xmlFileName
echo "	(" >> $xmlFileName
for (( i = 0; i < arrayLength; i++ )); do
	if [[ $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') != 'id' ]]; then
		if [[ $i == $(expr $arrayLength - 1) ]]; then
			if [[ $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'addtime' || $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'updatetime' ]]; then
				echo "	NOW()" >> $xmlFileName
			else
				echo '	#'$smallBeanName'.'${smallFieldArray[i]}'#' >> $xmlFileName
			fi
		else
			if [[ $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'addtime' || $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'updatetime' ]]; then
				echo "	NOW()," >> $xmlFileName
			else
				echo '	#'$smallBeanName'.'${smallFieldArray[i]}'#,' >> $xmlFileName
			fi
		fi	
	fi
done
echo ")" >> $xmlFileName
echo "]]>" >> $xmlFileName
echo '<selectKey resultClass="int" keyProperty="id">' >> $xmlFileName
echo ' SELECT @@IDENTITY' >> $xmlFileName
echo '  AS Id' >> $xmlFileName
echo '</selectKey>' >> $xmlFileName
echo '</insert>' >> $xmlFileName
echo '' >> $xmlFileName

#update
echo '<update id="update'$beanName'" parameterClass="map">' >> $xmlFileName
echo '  <![CDATA[' >> $xmlFileName
echo '  UPDATE '$tableName >> $xmlFileName
echo '  SET' >> $xmlFileName
for (( i = 0; i < arrayLength; i++ )); do
	if [[ $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') != 'id' && $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') != 'addtime' ]]; then
		if [[ $i == $(expr $arrayLength - 1) ]]; then
			if [[  $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'updatetime' ]]; then
				echo "	 UpdateTime=NOW()" >> $xmlFileName
			else
				echo '  '${bigFieldAarray[i]}'=#'$smallBeanName'.'${smallFieldArray[i]}'#' >> $xmlFileName
			fi
		else
			if [[  $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'updatetime' ]]; then
				echo "  UpdateTime=NOW()," >> $xmlFileName
			else
				echo '  '${bigFieldAarray[i]}'=#'$smallBeanName'.'${smallFieldArray[i]}'#,' >> $xmlFileName
			fi
		fi	
	fi
done

for (( i = 0; i < arrayLength; i++ )); do
	if [[ $(echo ${bigFieldAarray[i]}|tr '[A-Z]' '[a-z]') == 'id' ]]; then
		idBigField=${bigFieldAarray[i]}
	fi

	if [[ $(echo ${smallFieldArray[i]}|tr '[A-Z]' '[a-z]') == 'id' ]]; then
		idSmallField=${smallFieldArray[i]}
	fi
done


echo '  WHERE' >> $xmlFileName
echo '  '$idBigField'=#'$smallBeanName'.'$idSmallField'#' >> $xmlFileName
echo '  ]]>' >> $xmlFileName
echo '</update>' >> $xmlFileName
echo '' >> $xmlFileName

echo "</sqlMap>" >> $xmlFileName

echo "****** end ******"

rm -rf tmpFile

 







