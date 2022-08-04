packagemanager -list \
  | awk '{if($1 ~ /feast/){if($3 ~ /NA/){exit 1}}}' \
  && echo "feast is already installed" \
  || packagemanager -add feast
