#!/usr/bin/env bash

mysql_u='user'
mysql_h='127.0.0.1'
mysql_p='pass'
mysql_P=3306
ESurl='http://127.0.0.1:9200/gn_hotel/_search'
WhoseStar=

Help() {
Show="""\033[33m"$0"\033[0m\033[36m [code|price|clear] \033[0m
1 一行一城市名称,存放在 $city_name_file
tee $city_name_file <<-'EOF'
北京
上海
广州
...
EOF

2 $0 code
根据城市名称查询mysql数据库,获得城市代码.

3 $0 price [1-8]
1-8表示酒店星级.
根据执行上一步拿到的城市代码,查询elasticsearch,
获得当时,酒店标间含双早的平均参考价(元/间/夜),
保存好$city_name_code_avg_price 文件,发送给相关人员.

4 $0 clear
清理文件 $city_name_file $city_name_code_avg_price"""
echo -e "$Show"
}

TouchFilePath() {
    city_name_file='./city_name.txt'
    city_name_code_file='./city_name_code.txt'
    city_name_code_avg_price='./city_name_code_avg_price.txt'
}

TouchFile() {
    test -f $city_name_file || touch $city_name_file
    test -f $city_name_code_file || touch $city_name_code_file
    test -f $city_name_code_avg_price || touch $city_name_code_avg_price
}

InitDb() {
    MYSQL_CMD_ALL_CITY_CODE="use st_hotel;SELECT city_name,city_code FROM bs_city WHERE city_code!='' AND city_name!='';"
    MYSQL_CMD="use st_hotel;SELECT city_name,city_code FROM bs_city WHERE city_code!='' AND city_name='CITY_NAME';"
}

InitUrl() {
    EsUrl="$ESurl"
    CurlPar='{"size":0,"_source":["cnName","dayprices.0","star"],"aggs":{"avg_price":{"avg":{"field":"dayprices.0"}}},"query":{"bool":{"filter":[{"term":{"cityCode":"CITYCODE"}},{"bool":{"should":[{"terms":{"star":["WHOSESTAR"]}},{"terms":{"whoseStar":["WHOSESTAR"]}}]}},{"range":{"dayprices.0":{"from":100,"to":10000,"include_lower":true,"include_upper":true}}}]}}}'
}

GetCityCode() {
    # 获取城市代码,需要多次查询数据库,直连数据库效率更高,
    # 如果中间要经mycat查库可能会有超时情况,建议直连数据库.
    # 只有一次while循环效率高,但会有多次查库操作.
    test -s $city_name_file && true || false
    while read LINE; do
        MYSQL_CMD_NEW=$(echo $MYSQL_CMD|sed -e "s|CITY_NAME|$LINE|g")
        #echo $MYSQL_CMD_NEW
        CityNameCode=(`mysql -u"$mysql_u" -p"$mysql_p" -h "$mysql_h" -P $mysql_P -e "$MYSQL_CMD_NEW" | sed -n '$p'`)
        sleep 0.5
        #echo ${CityNameCode[@]}
        if [ -n "$CityNameCode" ]; then
            test -w $city_name_code_file && echo ${CityNameCode[@]} >> $city_name_code_file
        else
            echo "Not Found City Code: $MYSQL_CMD_NEW"
        fi
    done < $city_name_file
}
GetCityCodeAll() {
    # 一次获取所有城市代码,以勉多次查询数据库.
    # 时间复杂应该为O(n),因为执行效率取决于要查询的城市列表规模.
    # AllCityCode=$(mysql -u"$mysql_u" -p"$mysql_p" -h "$mysql_h" -P $mysql_P -e "$MYSQL_CMD_ALL_CITY_CODE")
    # AllCityCode=(`printf '%s,%s|' $AllCityCode`)
    # echo "${AllCityCode[@]}" | grep -o "广州,[[:alnum:]].*[[:alnum:]]\|"
    if [ -s "$city_name_file" -a -r "$city_name_file" ]; then
        LINE=(`cat "$city_name_file"`)
        AllCityCode=$(mysql -u"$mysql_u" -p"$mysql_p" -h "$mysql_h" -P $mysql_P -e "$MYSQL_CMD_ALL_CITY_CODE")
        for line in "${LINE[@]}"; do
            AllCityCodeNew="`echo "${AllCityCode[@]}" | grep -o "${line}[[:blank:]].*[[:alnum:]]$"`"
            echo "$AllCityCodeNew"
            if [[ -w $city_name_code_file ]] && [[ -n "$AllCityCodeNew" ]]; then
                echo "$AllCityCodeNew" >> $city_name_code_file
            fi
            sleep 0.5
        done
    else
        Help
        exit 1
    fi
}

GetAvgPrice() {
    test -s $city_name_code_file && true || false
    test -s $city_name_code_avg_price && true || false
    if [[ $WhoseStar -ge 1 ]] && [[ $WhoseStar -le 8 ]]; then
        :
    else
        echo "$0 price [1-8]"
        exit 1
    fi
    while read LINE; do
        CityCode=($LINE)
        #echo ">>>${CityCode[1]}"
        CurlParNew=`echo $CurlPar | sed -e "s|CITYCODE|${CityCode[1]}|g" -e "s|WHOSESTAR|$WhoseStar|g"`
        echo $CurlParNew
        AvgPrice=`curl -f -m 60 -XPOST "$EsUrl" -d "$CurlParNew" |grep -o '"aggregations":{"avg_price":{"value":.*}}}'|grep -o '"value":.*[0-9$]'|cut -d':' -f2`
        sleep 0.5
        if [ -n $AvgPrice ]; then
            AvgPrice=`printf '%.3f\r\n' $AvgPrice`
            echo $AvgPrice 
            test -w $city_name_code_avg_price && echo "${CityCode[0]} $AvgPrice" >> $city_name_code_avg_price.$WhoseStar.txt
        else
            echo "Not Found..."
        fi
        sleep 0.5
    done < $city_name_code_file
}

Clear() {
    #test -f $city_name_file && cat /dev/null > $city_name_file
    test -f $city_name_file && rm $city_name_file
    test -f $city_name_code_file && rm $city_name_code_file
    test -f $city_name_code_avg_price && rm ${city_name_code_avg_price}
}

if [ "$#" -le 0 -o "$#" -ge 3 ]; then
    TouchFilePath
    Help
    exit 1
else
case $1 in 
    code )
        TouchFilePath
        TouchFile
        InitDb
        InitUrl
        #time GetCityCode
        GetCityCodeAll
    ;;
    price )
        WhoseStar=$2
        TouchFilePath
        TouchFile
        InitDb
        InitUrl
        GetAvgPrice
    ;;
    clear )
        TouchFilePath
        Clear
    ;;
    *)
        TouchFilePath
        Help
    ;;
esac
fi
unset mysql_u mysql_h mysql_p mysql_P ESurl WhoseStar LINE line AllCityCodeNew AllCityCode
#
# 此脚本的用途：获取主要城市,四星级酒店标间含双早的平均参考价（元/间/夜）.
# 要查询的城市是由业务部门提供,一行一城市名称,存放在./city_name.txt文件. 
# 这其中涉及到查询mysql操作，查询elasticsearch操作. 
# 查询mysql操作是为了拿到各个城市对应的城市代码,然后根据城市代码去查询elasticsearch,得到平均参考价. 
# 2018-10-30

