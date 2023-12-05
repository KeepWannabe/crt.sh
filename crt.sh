#!/bin/bash

#### Colors Output

RESET="\033[0m"     # Normal Colour
RED="\033[0;31m"    # Error / Issues
GREEN="\033[0;32m"  # Successful
BOLD="\033[01;01m"  # Highlight
WHITE="\033[1;37m"  # BOLD
YELLOW="\033[1;33m" # Warning

#### Other Colors / Status Code

LYELLOW="\033[0;93m"
LGRAY="\033[0;37m"   # Light Gray
LRED="\033[1;31m"    # Light Red
LGREEN="\033[1;32m"  # Light GREEN
LBLUE="\033[1;34m"   # Light Blue
LPURPLE="\033[1;35m" # Light Purple
LCYAN="\033[1;36m"   # Light Cyan
SORANGE="\033[0;33m" # Standar Orange
SBLUE="\033[0;34m"   # Standar Blue
SPURPLE="\033[0;35m" # Standar Purple
SCYAN="\033[0;36m"   # Standar Cyan
DGRAY="\033[1;30m"   # Dark Gray

# Information Notification
showINF=$(printf "[${GREEN}INF${RESET}]")
showLINF=$(printf "[${LGREEN}INF${RESET}]")
showERR=$(printf "[${RED}ERR${RESET}]")
showWRN=$(printf "[${YELLOW}WRN${RESET}]")
showLWRN=$(printf "[${LYELLOW}WRN${RESET}]")

## Configuration (you can modify it)
OUTPUT_PATH="$(pwd)/crt-result"
TEMP_PATH="/tmp"
FILE_DATE=$(date +"%d-%m-%Y")
SILENT_MODE="false"

## Cool Banner Tho
showBanner(){
    printf "
             __   ${LBLUE}      __      ${RESET}
  __________/ /_  ${LBLUE}_____/ /_     ${RESET}
 / ___/ ___/ __/ ${LBLUE}/ ___/ __ \\   ${RESET}
/ /__/ /  / /__ ${LBLUE}(__  ) / / /    ${RESET}
\___/_/   \__${LYELLOW}(_)${LBLUE}____/_/ /_/${RESET}   v1.0.0

KeepWannabe - 0x0.si\n\n"
}

## Showing Help
getHelp(){
    showBanner
    printf "Usage: bash crt.sh [options]\n\n"
    printf "Options:\n    -h, --help                    Showing Helps\n"
    printf "    -d DOMAIN, --domain=DOMAIN    Search by using Domain Name (${RED}*${RESET}\n"
    printf "    -org ORG-NAME, --organiz..    Search by using Organization Name (${RED}*${RESET}\n\n"
}

## Showing Help if there's no args
[[ "${#}" == 0 ]] && {
    getHelp && exit 1
}

## Timestamp
getCurrentTime(){

    printf "[${SCYAN}%s${RESET}]\n" "$(date +"%T")"

}

# COMMAND LINE SWITCHES
while [[ "${#}" -gt 0 ]]; do
    args="${1}"
    case "$(echo ${args})" in
        # Target
        # Help
        "-h" | "--help")
            getHelp
            exit 1
            ;;
        "-d" | "--domain")
            DOM_TARGET="${2}"
            shift
            shift
            ;;
        "--domain="*)
            DOM_TARGET="${1#*=}"
            shift 1
            ;;
        "-org" | "--organization")
            ORG_TARGET="${2}"
            shift
            shift
            ;;
        "--organization="*)
            ORG_TARGET="${1#*=}"
            shift 1
            ;;
        "-s" | "--silent")
            SILENT_MODE="true"
            shift
            ;;
        "-"*)
        showBanner
            printf "$(getCurrentTime) ${showERR} Invalid option: ${RED}${1}${RESET}" && shift && exit 1
            ;;
        *)
            showBanner
            printf "$(getCurrentTime) ${showERR} Invalid: Unknown option ${RED}${1}${RESET}" && shift && exit
            exit
            ;;
    esac
done

if [ -n "${DOM_TARGET}" ] && [ -n "${ORG_TARGET}" ]; then
    getHelp
    printf "$(getCurrentTime) ${showERR} Please use either '${WHITE}-d,--domain${RESET}' or '${WHITE}-org,--organization${RESET}'. not both at the same time.\n"
    exit 1
fi

if [ -z "${DOM_TARGET}" ] && [ -z "${ORG_TARGET}" ]; then
    getHelp
    printf "$(getCurrentTime) ${showERR} Please specify a target for either '${WHITE}-d,--domain${RESET}' or '${WHITE}-org,--organization${RESET}' option.\n"
    exit 1
fi

createOutputDir(){

    if [ "${SILENT_MODE}" == "false" ]; then
        ## Checking Directory
        if [ ! -d "${OUTPUT_PATH}" ]; then
            printf "$(getCurrentTime) ${showINF} Creating directory at \"${WHITE}${OUTPUT_PATH}\"${RESET}\n"
            mkdir "${OUTPUT_PATH}"
        fi
    else
        ## Checking Directory
        if [ ! -d "${OUTPUT_PATH}" ]; then
            mkdir "${OUTPUT_PATH}"
        fi
    fi

}

getByDomain(){

    if [ "${SILENT_MODE}" = "true" ]; then
        ## Create Output Dir
        createOutputDir
        ## Create 5 Random String for temp file name
        randString=$(openssl rand -base64 7 | tr -dc 'a-zA-Z0-9')
        ## Send GET Request to https://crt.sh
        reqByDomain=$(curl -skL "https://crt.sh?q=${DOM_TARGET}&output=json" -o "${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt")
        ## Parsing Result and Save to ${OUTPUT_PATH} (see config on top)
        $(cat "${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt" | jq -r ".[].common_name,.[].name_value"| cut -d '"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g'| sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' | sort | uniq >> "${OUTPUT_PATH}/result-${DOM_TARGET}.txt")
        ## Delete temp file
        rm "${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt"
        ## Showing Result
        printf "$(cat "${OUTPUT_PATH}/result-${DOM_TARGET}.txt" | uniq)\n"
    else
        showBanner
        printf "[*] starting @ $(date +"%T /%Y-%m-%d/")\n"
        ## Create Output Dir
        createOutputDir
        printf "$(getCurrentTime) ${showINF} Searching subdomain of ${DOM_TARGET}\n"

        ## Create 5 Random String for temp file name
        randString=$(openssl rand -base64 7 | tr -dc 'a-zA-Z0-9')
        ## Send GET Request to https://crt.sh
        reqByDomain=$(curl -skL "https://crt.sh?q=${DOM_TARGET}&output=json" -o "${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt")
        ## Parsing Result and Save to ${OUTPUT_PATH} (see config on top)
        $(cat "${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt" | jq -r ".[].common_name,.[].name_value"| cut -d '"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g'| sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' | sort | uniq >> "${OUTPUT_PATH}/result-${DOM_TARGET}.txt")

        printf "$(getCurrentTime) ${showINF} Success collecting ${LGREEN}$(cat "${OUTPUT_PATH}/result-${DOM_TARGET}.txt" | wc -l) subdomain${RESET} from ${DOM_TARGET}\n"
        ## Showing Result
        printf "%s\n" "---"
        printf "$(cat "${OUTPUT_PATH}/result-${DOM_TARGET}.txt" | uniq)\n"
        printf "%s\n" "---"
        printf "$(getCurrentTime) ${showINF} Result saved to '${LGREEN}${OUTPUT_PATH}/result-${DOM_TARGET}.txt${RESET}'\n"
        printf "$(getCurrentTime) ${showINF} Deleting temp file '${WHITE}${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt'${RESET}\n"

        ## Delete temp file
        rm "${TEMP_PATH}/${randString}-${DOM_TARGET}-temp.txt"

        printf "\n[*] ending @ $(date +"%T /%Y-%m-%d/")\n"
    fi

}

getByOrganization(){

    if [ "${SILENT_MODE}" = "true" ]; then
        ## Create Output Dir
        createOutputDir
        ## Replacing `space` to `dash` for file name
        dashedORG_TARGET=$(echo ${ORG_TARGET} | sed 's/ /-/g')
        ## Create 5 Random String for temp file name
        randString=$(openssl rand -base64 7 | tr -dc 'a-zA-Z0-9')
        ## Send GET Request to https://crt.sh
        reqByOrganization=$(curl -skL "https://crt.sh?q=${ORG_TARGET}&output=json" -o "${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt")
        ## Parsing Result and Save to ${OUTPUT_PATH} (see config on top)
        $(cat "${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt" | jq ".[].common_name" | cut -d '"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g' | sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' | sort |  uniq >> "${OUTPUT_PATH}/result-${dashedORG_TARGET}.txt")
        ## Delete temp file
        rm "${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt"
        ## Showing File
        printf "$(cat "${OUTPUT_PATH}/result-${dashedORG_TARGET}.txt" | uniq)\n"
    else
        showBanner
        printf "[*] starting @ $(date +"%T /%Y-%m-%d/")\n"
        ## Create Output Dir
        createOutputDir
        printf "$(getCurrentTime) ${showINF} Searching subdomain of ${ORG_TARGET}\n"

        ## Replacing `space` to `dash` for file name
        dashedORG_TARGET=$(echo ${ORG_TARGET} | sed 's/ /-/g')
        ## Create 5 Random String for temp file name
        randString=$(openssl rand -base64 7 | tr -dc 'a-zA-Z0-9')
        ## Send GET Request to https://crt.sh
        reqByOrganization=$(curl -skL "https://crt.sh?q=${ORG_TARGET}&output=json" -o "${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt")
        ## Parsing Result and Save to ${OUTPUT_PATH} (see config on top)
        $(cat "${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt" | jq ".[].common_name" | cut -d '"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g' | sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' | sort |  uniq >> "${OUTPUT_PATH}/result-${dashedORG_TARGET}.txt")

        printf "$(getCurrentTime) ${showINF} Success collecting ${LGREEN}$(cat "${OUTPUT_PATH}/result-${dashedORG_TARGET}.txt" | wc -l) subdomain${RESET} from ${ORG_TARGET}\n"
        ## Showing Result
        printf "%s\n" "---"
        printf "$(cat "${OUTPUT_PATH}/result-${dashedORG_TARGET}.txt" | uniq)\n"
        printf "%s\n" "---"
        printf "$(getCurrentTime) ${showINF} Result saved to '${LGREEN}${OUTPUT_PATH}/result-${dashedORG_TARGET}.txt${RESET}'\n"
        printf "$(getCurrentTime) ${showINF} Deleting temp file '${WHITE}${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt'${RESET}\n"

        ## Delete temp file
        rm "${TEMP_PATH}/${randString}-${dashedORG_TARGET}-temp.txt"

        printf "\n[*] ending @ $(date +"%T /%Y-%m-%d/")\n"
    fi

}

if [ -n "${DOM_TARGET}" ]; then
    getByDomain
elif [ -n "${ORG_TARGET}" ]; then
    getByOrganization
fi