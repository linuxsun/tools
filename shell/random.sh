#!/bin/bash

randonpass() {
    index=0
    str=""
    for i in {a..z}; do arr[index]=$i; index=`expr ${index} + 1`; done
    for i in {A..Z}; do arr[index]=$i; index=`expr ${index} + 1`; done
    for i in {0..9}; do arr[index]=$i; index=`expr ${index} + 1`; done
    #for i in {1..20}; do str="$str${arr[$RANDOM%$index]}"; done
    for i in `eval echo {1..$num}`; do str="$str${arr[$RANDOM%$index]}"; done
    echo $str
}

if [ $# -eq 0 ]; then
  num=16
else
  num="$1"
fi

if [ $num ]; then
  echo `randonpass`
fi
