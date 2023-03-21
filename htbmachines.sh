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

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# sleep 10
# ctrl+c
trap ctrl_c INT

# Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n ${yellowColour}[+]${endColour}${grayColour}Uso:${endColour}"  
  echo -e "\t ${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"   
  echo -e "\t ${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"  
  echo -e "\t ${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n" 
}

function searchMachine(){
  machineName="$1"
  
  echo "$machineName"
}

function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando ficheros necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados.${endColour}"
    tput cnorm
  else
    echo -e "\n${yellowColour}[+]${endColour} ${turquoiseColour}La lista de maquinas ya existe.${endColour} ${grayColour}Comprobando si existen actualizaciones pendientes...${endColour}" 
    tput civis
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
      
      if [ "$md5_original_value" == "$md5_temp_value" ]; then
        echo -e "\n${greenColour}[+]${endColour}${grayColour} No se han detectado actualizaciones ;)${endColour}"
        rm -rf bundle_temp.js
      else
        echo -e "\n${greenColour}[+]${endColour}${grayColour} Actualizaciones aplicadas. Ahora estas al dia 󰚰 ${endColour}"
        rm bundle.js
        mv bundle_temp.js bundle.js
      fi
    tput cnorm
  fi  
}

# Indicadores
declare -i parameter_counter=0

while getopts "m:uh" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName 
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
else
  helpPanel
fi
