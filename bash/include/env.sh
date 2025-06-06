function check_path(){
    case :${PATH}:
       in *:${HOME}/bin:*) ;;
                        *) echo "FAIL\n"
    esac
    return 0
}
