for (( n=1; n < 8; n++ )) do
    printf " [tput setaf %d] $(tput setaf $n)%s\033[0m" $n "wMwMwMwMwMwMw
"
done