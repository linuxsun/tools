#!/usr/bin/env bash
#
# 此脚本的用途：获取主要城市,四星级酒店标间含双早的平均参考价（元/间/夜）.
# 因为要查询城市是由业务部门提供的，要查询哪些城市我们不得知，所以城市列表要先放在./city_name.txt文件. 
# 这其中涉及到查询mysql操作，查询elasticsearch操作. 
# 查询mysql操作是为了拿到各个城市对应的城市代码，然后根据城市代码去查询elasticsearch，得到平均参考价. 

InitDb() {
    MYSQL_U='user'
    MYSQL_H='127.0.0.1'
    MYSQL_p='pass'
    MYSQL_P=3306
    MYSQL_CMD_ALL_CITY_CODE="use st_hotel;SELECT city_name,city_code FROM bs_city WHERE city_code!='' AND city_name!='';"
    MYSQL_CMD="use st_hotel;SELECT city_name,city_code FROM bs_city WHERE city_code!='' AND city_name='CITY_NAME';"
}

InitUrl() {
    EsUrl='http://127.0.0.1:9200/gn_hotel/_search'
    CurlPar='{"size":0,"_source":["cnName","dayprices.0","star"],"aggs":{"avg_price":{"avg":{"field":"dayprices.0"}}},"query":{"bool":{"filter":[{"term":{"cityCode":"CITYCODE"}},{"bool":{"should":[{"terms":{"star":["4"]}},{"terms":{"whoseStar":["4"]}}]}},{"range":{"dayprices.0":{"from":100,"to":10000,"include_lower":true,"include_upper":true}}}]}}}'
}

InitFile() {
    city_name_file='./city_name.txt'
    city_name_code_file='./city_name_code.txt'
    city_name_code_avg_price='./city_name_code_avg_price.txt'
    test -f $city_name_file || touch $city_name_file
    test -f $city_name_code_file || touch $city_name_code_file
    test -f $city_name_code_avg_price || touch $city_name_code_avg_price
}

GetCityCode() {
    # 获取城市代码,需要多次查询数据库,直连数据库效率更高,
    # 如果中间要经mycat查库可能会有超时情况,建议直连数据库.
    # 只有一次while循环效率高,但会有多次查库操作.
    test -s $city_name_file && true || false
    while read LINE
    do
        MYSQL_CMD_NEW=$(echo $MYSQL_CMD|sed -e "s|CITY_NAME|$LINE|g")
        #echo $MYSQL_CMD_NEW
        CityNameCode=(`mysql -u"$MYSQL_U" -p"$MYSQL_p" -h "$MYSQL_H" -P $MYSQL_P -e "$MYSQL_CMD_NEW" | sed -n '$p'`)
        echo ${CityNameCode[@]}
        if [ -n "$CityNameCode" ]; then
            test -w $city_name_code_file && echo ${CityNameCode[@]} >> $city_name_code_file
        else
            echo "Not Found City Code: $MYSQL_CMD_NEW"
        fi
        sleep 1
    done < $city_name_file
}
GetCityCodeAll() {
    # 一次获取所有城市代码,以勉多次查询数据库.缺点:while+for循环效率低.
    # 时间复杂应该为O(m+n),因为效率取决于要查询的城市列表规模和所有城市的规模.
    AllCityCode=$(mysql -u"$MYSQL_U" -p"$MYSQL_p" -h "$MYSQL_H" -P $MYSQL_P -e "$MYSQL_CMD_ALL_CITY_CODE")
    sleep 3
    AllCityCode=(`printf ' %s,%s ' $AllCityCode`)
    test -s $city_name_file && true || false
    while read LINE
    do
        for xyz in ${AllCityCode[*]} 
        do
            ijk=`echo $xyz|cut -d',' -f1`
            Code=`echo $xyz|cut -d',' -f2`
            if [ "$LINE" = "$ijk" ];then
                echo "add: $ijk $Code >> $city_name_code_file"
                test -w $city_name_code_file && echo "$ijk $Code" >> $city_name_code_file
            fi
        done
    done < $city_name_file
}

GetAvgPrice() {
    test -s $city_name_code_file && true || false
    test -s $city_name_code_avg_price && true || false
    while read LINE
    do
        CityCode=($LINE)
        #echo ${CityCode[1]}
        CurlParNew=`echo $CurlPar | sed -e "s|CITYCODE|${CityCode[1]}|g"`
        #echo $CurlParNew
        AvgPrice=`curl -f -m 60 -XPOST "$EsUrl" -d "$CurlParNew" |grep -o '"aggregations":{"avg_price":{"value":.*}}}'|grep -o '"value":.*[0-9$]'|cut -d':' -f2`
        if [ -n $AvgPrice ]; then
            AvgPrice=`printf '%.3f\r\n' $AvgPrice`
            echo $AvgPrice 
            test -w $city_name_code_avg_price && echo "${CityCode[0]} $AvgPrice" >> $city_name_code_avg_price
        else
            echo "Not Found..."
        fi
        sleep 1
    done < $city_name_code_file

}

Clear() {
    #test -f $city_name_file && cat /dev/null > $city_name_file
    test -f $city_name_code_file && cat /dev/null > $city_name_code_file
    test -f $city_name_code_avg_price && cat /dev/null > $city_name_code_avg_price
}

Help() {
    InitFile
    Show="""\033[33m"$0"\033[0m\033[36m [code|price|clear] \033[0m
code:
根据城市名查询mysql数据库,获得城市代码.
将要查询的城市名列表保存到 $city_name_file
tee $city_name_file <<-'EOF'
北京
上海
广州
...
EOF

price:
根据执行上一步拿到的城市代码,去查询elasticsearch,
获得 四星级酒店标间含双早的平均参考价(元/间/夜),
保存到$city_name_code_avg_price;

clear:
清空文件,城市代码:$city_name_file,平均参考价:$city_name_code_avg_price.
"""
    echo -e "$Show"
}

if [ "$#" -ne 1 ]; then
    Help
    exit 1
else
case $1 in 
    code )
        InitDb
        InitUrl
        InitFile
        #GetCityCode
        GetCityCodeAll
    ;;
    price )
        InitDb
        InitUrl
        InitFile
        GetAvgPrice
    ;;
    clear )
        InitFile
        Clear
    ;;
    *)
        Help
    ;;
esac
fi
