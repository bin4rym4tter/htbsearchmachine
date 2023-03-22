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
  echo -e "\t ${purpleColour}i)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"  
  echo -e "\t ${purpleColour}s)${endColour}${grayColour} Buscar por skill ${endColour}"  
  echo -e "\t ${purpleColour}y)${endColour}${grayColour} Obtener link de la resolucion de la maquina en youtube${endColour}"  
  echo -e "\t ${purpleColour}o)${endColour}${grayColour} Obtener lista de maquinas por su sistema operativo${endColour}"  
  echo -e "\t ${purpleColour}d)${endColour}${grayColour} Obtener lista de maquinas con la dificultad indicada${endColour}"  
  echo -e "\t ${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n" 
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

function searchMachine(){
  machineName="$1"
  machineName_Checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineName_Checker" ]; then
  
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina:${blueColour} $machineName${endColour}${endColour}\n"
    echo -e "$machineName_Checker"
  else
    echo -e "\n${redColour}[!] La maquina indicada no existe${endColour}"
  fi
}

function searchIP(){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep 'name:' | awk '{print $2}' | tr -d '""' | tr -d ',')"
  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la direccion ip${endColour} ${blueColour}$ipAddress${endColour} es: ${blueColour}$machineName${endColour}\n"
  else
    echo -e "\n${redColour}[!] La direccion IP indicada no existe${redColour}"
  fi
}

function getYoutobeLink(){
  machineName="$1"
  youtubelink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resulta:" | tr -d '""' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  if [ "$youtubelink" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El link de youtube para la maquina${endColour} ${blueColour}$machineName${endColour} ${grayColour}es:${endColour} ${blueColour}$youtubelink${endColour}\n"  
  else
    echo -e "\n${redColour}[!] La maquina indicada no tiene cuenta con un link.${redColour}\n"
  fi
}
function getDifficulty(){
  machineDifficulty="$1"
  machineDifficulty_Checker="$(cat bundle.js| grep "dificultad: \"$machineDifficulty\"" -B 7 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$machineDifficulty_Checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Esta es la lista de maquinas disponible para la dificultad${endColour} ${blueColour}$machineDifficulty${endColour}:\n"
    echo -e "$machineDifficulty_Checker"
  else 
    echo -e "\n${redColour}[!] La dificultad indicada no existe.${redColour}\n"
  fi
}

function searchOS(){
  machineOS="$1"
  machineOS_Checker="$(cat bundle.js | grep -i "so: \"$machineOS\"" -B 5 | grep name: | awk '{print $2}' | tr -d '"' | tr -d ',' | column)"
  if [ "$machineOS_Checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Esta es la lista de maquinas disponible que utilizan el OS${endColour} ${blueColour}$machineOS${endColour}:\n"
    echo -e "$machineOS_Checker"
  else 
    echo -e "\n${redColour}[!] No existen hay informacion de maquinas con el sistema operativo${endColour} ${purpleColour}$machineOS${endColour}.\n"
  fi
}

function getOS_Difficulty_Machines(){
  difficulty="$1"
  machineOS="$2"
  check_results="$(cat bundle.js | grep -i "so: \"$machineOS\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk '{print $2}' | tr -d '"' | tr -d ',' | column)"
  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listado de maquinas para OS${endColour} ${purpleColour}$machineOS${endColour} ${grayColour}y dificultad${endColour} ${purpleColour}$difficulty${purpleColour}:\n"
    echo "$check_results"
  else
    echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrecto.${purpleColour}$machineOS${endColour}.\n"
  fi
}
function getSkills(){
  machineSkills="$1"
  skill_check="$(cat bundle.js | grep "skills: " -B 6 | grep -i "$machineSkills" -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$skill_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Buscando por la skill${endColour} ${purpleColour}$machineSkills${endColour}:\n"
    echo -e "$skill_check"
  else
    echo -e "\n${redColour}[!] No existen maquinas en que se implemente la skill ${purpleColour}$machineSkills${endColour}.\n" 
  fi
}
# Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_operativeSystem=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) operativeSystem="$OPTARG"; chivato_operativeSystem=1; let parameter_counter+=6;;
    s) machineSkills="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName 
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutobeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getDifficulty $difficulty  
elif [ $parameter_counter -eq 6 ]; then 
  searchOS $operativeSystem
elif [ $parameter_counter -eq 7 ]; then
  getSkills "$machineSkills"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_operativeSystem -eq 1 ]; then
  getOS_Difficulty_Machines $difficulty $operativeSystem
else
  helpPanel
fi
