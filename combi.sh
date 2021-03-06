#!/bin/sh

options="default check debug symbols"
options="$options nosort noblock nolearn noreduce norestart nomode"

failed () {
  echo
  echo "combi.sh: error: last command failed"
  exit 1
}

run () {
  args="`echo $*|sed -e 's,default,,' -e 's,\<,--,g' -e 's,--no,--no-,g'`"
  args="`echo $args|sed -e 's,-check,c,' -e 's,-debug,g,' -e 's,-symbols,s,'`"
  command="./configure.sh $args"
  echo -n $command
  $command 1>/dev/null 2>/dev/null || failed
  echo -n " && make"
  make 1>/dev/null 2>/dev/null || failed
  echo -n " test"
  make test 1>/dev/null 2>/dev/null || failed
  echo -n " && make clean"
  make clean 1>/dev/null 2>/dev/null || failed
  echo
}

filter () {
  case $1$2 in
    nolearnnoreduce) return 0;;
    norestartnomode) return 0;;
    *) return 1;;
  esac
}

for first in $options
do
  run $first
done
for first in $options
do
  for second in `echo $options|fmt -0|sed "1,/$first/d"`
  do
    filter $first $second && continue
    run $first $second
  done
done
for first in $options
do
  for second in `echo $options|fmt -0|sed "1,/$first/d"`
  do
    filter $first $second && continue
    for third in `echo $options|fmt -0|sed "1,/$second/d"`
    do
      filter $second $third && continue
      run $first $second $third
    done
  done
done
for first in $options
do
  for second in `echo $options|fmt -0|sed "1,/$first/d"`
  do
    filter $first $second && continue
    for third in `echo $options|fmt -0|sed "1,/$second/d"`
    do
      filter $second $third && continue
      for fourth in `echo $options|fmt -0|sed "1,/$third/d"`
      do
        filter $third $fourth && continue
        run $first $second $third $fourth
      done
    done
  done
done
