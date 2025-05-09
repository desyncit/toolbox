function errno(){
        local argv=("$1")

        case ${argv[0]} in
                "1")
                  printf "No args passed\n"
                  exit 1
                ;;
                "30")
                  printf "EMPTYFILELIST"
                exit 30                   
                ;;
                "*")
                  exit 255
                ;;
        esac
        unset argv
  return 0
}
