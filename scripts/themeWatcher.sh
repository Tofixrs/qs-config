#!/usr/bin/env bash
path=$1

files=$(ls -1 $path)

for line in $files; do
  if [[ $line != *".json" ]] || [[ $line == "config.json" ]]; then
    continue;
  fi
  json=$(cat $path/$line | jq -c)
  echo "MODIFY|$line|$json"
done

inotifywait -q -m $path -e create -e move  -e close_write -e delete | while read dir action file; do
  if [[ $file != *".json" ]] || [[ $line == "config.json" ]]; then
    continue;
  fi
  case $action in 
    "DELETE" | "MOVED_FROM")
      echo "DELETE|$file" ;;

    "CLOSE_WRITE,CLOSE" | "MOVED_TO")
      json=$(cat $dir/$file | jq -c)
      echo "MODIFY|$file|$json" ;;
  esac
done
