for inc in /etc/profile.d/include.d/*.include; do 
     . "$inc"
done
unset inc
