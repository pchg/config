for f in *.jpg
do
  exiftool -S -d "%Y%m%d%H%M.%S" -CreateDate "${f}" \
  | awk '{ print $2 }' \
  | xargs -I % touch -m -t % "${f}";
  echo ${f} fait;
done
