cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 {print $1}' | while read user; do 
    printf "%-15s : %s\n" "$user" "$(groups $user)"
done

