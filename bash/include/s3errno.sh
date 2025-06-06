function error(){
  local argv=("$1")
  case $argv in
        2)
          printf "Sorry but this script take no args\n"
          exit 2
          ;;
        3) printf "golang missing installing\n"
           go_get_go
          ;;
        4) printf "Grabbing the aws client now\n"
           get_aws
           ;;
        5) printf "Installing s3cmd\n"
           get_s3cmd
           ;;
	6) printf "Minimum arguements not met\n"
	   ;;
        *)
          exit 255
          ;;
  esac

  unset argv
  return 0
}
