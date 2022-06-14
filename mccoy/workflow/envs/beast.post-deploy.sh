packagemanager -list \
    | awk '{if($1 ~ /feast/ && $3 ~ /NA/){exit 0} else {exit 1}}' \
    && packagemanager -add feast || true
