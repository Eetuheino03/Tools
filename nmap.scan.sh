#!/bin/bash

#värien lisäys shelliin
RED='\033[0;3IPm'
WHITE='\033[0;37m' 
NC='\033[0m' # ei väriä
RI=$(whoami)
ROT="root"
NULL="0.0.0.0"
ZERO="00"
#sudo oikeuden tarkistus
if [ "$RI" == "$ROT" ];
then
echo "_________________________________"
echo "| Tarkistetaan oikeudet! on ok! |"
echo "================================="
else
echo "======================================"
echo "Suorita skripit sudo komenolla        "
echo "======================================"
exit 0
fi
#tarvittavien työkalujen tarkistus!
REQUIRED_PKG="nmap"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo "______________________________________________"
echo  Tarkistetaan työkalua! $REQUIRED_PKG: $PKG_OK
echo "=============================================>"
if [ "" = "$PKG_OK" ]; then
    echo "____________________________________________________________________________________________"
    echo "ei löytynyt $REQUIRED_PKG. Asennan sen puolestasi..... (${RED}Asennetaan $REQUIRED_PKG.) \c"
    echo "============================================================================================"
    sudo apt-get --yes install $REQUIRED_PKG 
fi
REQUIRED_PKG="gobuster"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo "______________________________________________"
echo  Tarkistetaan työkalua! $REQUIRED_PKG: $PKG_OK
echo "=============================================>"
if [ "" = "$PKG_OK" ]; then
    echo "____________________________________________________________________________________________"
    echo "ei löytynyt $REQUIRED_PKG. Asennan sen puolestasi..... (${RED}Asennetaan $REQUIRED_PKG.) \c"
    echo "============================================================================================"
    sudo apt-get --yes install $REQUIRED_PKG
fi
REQUIRED_PKG="nikto"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo "______________________________________________"
echo  Tarkistetaan työkalua! $REQUIRED_PKG: $PKG_OK
echo "=============================================>"
if [ "" = "$PKG_OK" ]; then
    echo "____________________________________________________________________________________________"
    echo "ei löytynyt $REQUIRED_PKG. Asennan sen puolestasi..... (${RED}Asennetaan $REQUIRED_PKG.) \c"
    echo "============================================================================================"
    sudo apt-get --yes install $REQUIRED_PKG 
fi
clear
#Hae päivä tiedoston nimeksi
DATE=`date +%Y-%m-%d`
filename=$IP_$DATE
#Ip osoitteen syöttö ja muut infot
echo "<===========================================>"
echo "| Syötä ip osoite tai domain mitä skannatta |"
echo "<===========================================>"
read  IP
echo "===============|"
case $IP in
    0.0.0.0)
        echo "______________________________________"
        echo "| $IP osoitetta ei pysty skannaaman! |"
        echo "|====================================|"
        exit 0
    ;;

    IP72.0.0.0.IP)
        echo "______________________________________"
        echo "| $IP osoitetta ei pysty skannaaman! |"
        echo "|====================================|"
        exit 0
    ;;
esac
#nmapin paketin jälitys
echo "_______________________________________________________"
echo "|Haluatko ottaa paketin jäljityksen nmapissa käyttöön?|"
echo "|_____________________________________________________|"
read answer
echo "=====|"
if [ "$answer" != "${answer#[kyllä]}" ] ;then
    echo "__________________________________________"
    echo "|suoritetaan nmap paketin jäljityksellä! |"
    echo "|________________________________________|"
    PAKETTI="--packet-trace"
else
    echo "______________"
    echo "| Jatketaan! |"
    echo "|============>"
fi
clear
#nmapin portti laajuden määrittäminen
echo "Määritä portit mitkä skannataan?"
echo "_________________________________________"
echo "| Pieni | keskikokoinen | Kaikki portit |"
echo "|=======================================|"
echo "| Tai paina enteriä automaatti skannaus |"
echo "| automaatti skannauksessa IP000 porttia |"
echo "|_______________________________________|"
read answer
case $answer in 
    Pieni)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="-F"
    ;;
    Keskikokoinen)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="--top-ports IP500"
    ;;
    Kaikki)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="-p-"
    ;;
    IP)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="-F"
    ;;
    2)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="--top-ports IP50"
    ;;
    3)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="-p-"
    ;;
    pieni)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="-F"
    ;;
    keskikokoinen)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="--top-ports IP500"
    ;;
    kaikki)
        echo "_____________________________"
        echo "| asetetaan portti asetusta |"
        echo "|===========================>"
        Portti="-p-"
    ;;
esac
clear
#Nmappi skannaus ja jos serveri ei vastaa!
NMAP=$(nmap  -A $IP > nmap_$IP_$DATE.txt)
echo "__________________________"
echo "| Käynnistetään nmappia! |"
echo "|========================>"
if $NMAP | fgrep 'Host is up' nmap_$IP_$DATE.txt
then
echo "_______________________________________"
echo "| Serveri ei vastannut ping pyyntöön! |"
echo "|=====================================x"
nmap -A $IP
else
echo "____________________________________________" 
echo "| Aloitetaan, skannaus ilman ping pyyntöä! |"
echo "|==========================================>"
nmap -T3 -sS -Pn $Portti -sV -v $PAKETTI $IP -oN no_ping_nmap_$IP_$DATE
fi
if fgrep '80/open' no_ping_nmap_$IP_$DATE.txt
then 
PORT="80"
fi
if fgrep '443/open' no_ping_nmap_$IP_$DATE.txt
then
PORT="443"
fi
echo "                                   ======================================="
echo "                                   | Valitse työkalu mitä haluat käyttää |"
echo "                                   | (Gobuster)    (Nikto)      (Kaikki) |"
echo "                                   |     (g)         (n)          (k)    |"
echo "                                   ======================================="
read answer2
case $answer2 in 
    Gobuster)
        echo "_______________________________"
        echo "| Suoritetaan gobuster =====> |"
        echo "|=============================|"
            gobuster dir --url http://$IP:$PORT -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -t 50 > gobuster_$filename.txt
        echo "  ______________________________________________________________________" 
        echo -e "${WHITE}gobuster tiedot on tiedostossa ${RED}gobuster_$filename.txt | ${WHITE}"
        echo "  =====================================================================>"
    ;;
    Nikto)
        echo "___________________________________"
        echo "| Käynnistetään Nikto Scan ...... |"
        echo "|===============================> |_____"
        echo "|________________________________________|"
        echo "| Tämä voi kestää muutama minuuttia....  |"
        echo "|________________________________________|"
            nikto --host $IP:$PORT > nikto_$filename.txt &
        echo "   __________________________________________________________________________"
        echo -e "| ${WHITE}nikto tiedot on tiedostossa ${RED}nikto_$filename.txt ${WHITE} |"
        echo "   =========================================================================>"
    ;;
    Kaikki)
        echo "_______________________________"
        echo "| Suoritetaan gobuster =====> |"
        echo "|=============================|"
            gobuster dir --url http://$IP:$PORT -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -t 50 > gobuster_$filename.txt 
        echo "  ______________________________________________________________________" 
        echo -e "${WHITE}gobuster tiedot on tiedostossa ${RED}gobuster_$filename.txt | ${WHITE}"
        echo "  =====================================================================>"
        echo "___________________________________"
        echo "| Käynnistetään Nikto Scan ...... |"
        echo "|===============================> |_____"
        echo "|________________________________________|"
        echo "| Tämä voi kestää muutama minuuttia....  |"
        echo "|________________________________________|"
            nikto --host $IP:$PORT > nikto_$filename.txt &
        echo "   __________________________________________________________________________"
        echo -e "| ${WHITE}nikto tiedot on tiedostossa ${RED}nikto_$filename.txt ${WHITE} |"
        echo "   =========================================================================>"
    ;;
    gobuster)
        echo "_______________________________"
        echo "| Suoritetaan gobuster =====> |"
        echo "|=============================|"
        echo "  ______________________________________________________________________" 
        echo -e "${WHITE}gobuster tiedot on tiedostossa ${RED}gobuster_$filename.txt | ${WHITE}"
        echo "  =====================================================================>"
    ;;
    nikto)
        echo "___________________________________"
        echo "| Käynnistetään Nikto Scan ...... |"
        echo "|===============================> |_____"
        echo "|________________________________________|"
        echo "| Tämä voi kestää muutama minuuttia....  |"
        echo "|________________________________________|"
            nikto --host $IP:$PORT > nikto_$filename.txt &
        echo "   __________________________________________________________________________"
        echo -e "| ${WHITE}nikto tiedot on tiedostossa ${RED}nikto_$filename.txt ${WHITE} |"
        echo "   =========================================================================>"
    ;;
    kaikki)
         echo "_______________________________"
        echo "| Suoritetaan gobuster =====> |"
        echo "|=============================|"
        echo "  ______________________________________________________________________" 
        echo -e "${WHITE}gobuster tiedot on tiedostossa ${RED}gobuster_$filename.txt | ${WHITE}"
        echo "  =====================================================================>"
        echo "___________________________________"
        echo "| Käynnistetään Nikto Scan ...... |"
        echo "|===============================> |_____"
        echo "|________________________________________|"
        echo "| Tämä voi kestää muutama minuuttia....  |"
        echo "|________________________________________|"
            nikto --host $IP:$PORT > nikto_$filename.txt &
        echo "   __________________________________________________________________________"
        echo -e "| ${WHITE}nikto tiedot on tiedostossa ${RED}nikto_$filename.txt ${WHITE} |"
        echo "   =========================================================================>"
    ;;
    g)
        echo "_______________________________"
        echo "| Suoritetaan gobuster =====> |"
        echo "|=============================|"
        echo "  ______________________________________________________________________" 
        echo -e "${WHITE}gobuster tiedot on tiedostossa ${RED}gobuster_$filename.txt | ${WHITE}"
        echo "  =====================================================================>"
    ;;
    n)
        echo "___________________________________"
        echo "| Käynnistetään Nikto Scan ...... |"
        echo "|===============================> |_____"
        echo "|________________________________________|"
        echo "| Tämä voi kestää muutama minuuttia....  |"
        echo "|________________________________________|"
            nikto --host $IP:$PORT > nikto_$filename.txt &
        echo "   __________________________________________________________________________"
        echo -e "| ${WHITE}nikto tiedot on tiedostossa ${RED}nikto_$filename.txt ${WHITE} |"
        echo "   =========================================================================>"
    ;;
    k)
        echo "_______________________________"
        echo "| Suoritetaan gobuster =====> |"
        echo "|=============================|"
        echo "  ______________________________________________________________________" 
        echo -e "${WHITE}gobuster tiedot on tiedostossa ${RED}gobuster_$filename.txt | ${WHITE}"
        echo "  =====================================================================>"
    ;;
esac
echo "   _____________________"
echo "   | Skannaus valmis!. |______"
echo "   |                         |"
echo -e "| ${WHITE}Nähdään Pian (: |"
echo "   ==========================="

exit 0
fi