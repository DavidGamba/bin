#!/bin/bash

# TODO: I don't know if it is required to do something (or what to do) with the
# libraries located in JAVA_HOME or SCALA_HOME. I don't know if they are required to
# go into "/usr/share/java".

function usage () {
  cat <<EOL
[USAGE]
  $0 <java/scala dir>

[EXAMPLES]
  $0 ~/opt/jdk1.7.0_40/
  $0 ~/opt/scala-2.10.3/

[DESCRIPTION]
  This script will read the name of the extracted directory and based on that
  will install either java (valid names match java, jdk or jre) or scala.

  It will only install the binaries that have an associated man page.

  TODO: I don't know if it is required to do something (or what to do) with the
  libraries located in JAVA_HOME or SCALA_HOME. I don't know if they are required to
  go into "/usr/share/java".

EOL
}

dir=$1
if [[ ! -d "$dir" || ! -d "$dir/bin" ]]; then
  echo "Missing java/scala extracted dir!"
  usage
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
fi

function update_alternatives () {
  directory=$1
  binary=$2

  update-alternatives --install \
    "/usr/bin/$binary" "$binary" \
    "$directory/bin/$binary" 2000 \
    --slave /usr/share/man/man1/${binary}.1 ${binary}.1 $directory/man/man1/${binary}.1

  # Correct file permissions and ownership
  chmod a+x /usr/bin/$binary
}

prefix=/usr/share
system_dir=$prefix/$(basename $dir)
cp -r $dir $system_dir

# binaries=( fsc scala scalac scaladoc scalap )
# binaries=( java javac javaws javadoc )
# for binary in "${binaries[@]}" ; do
shopt -s nullglob
for file in $dir/bin/* ; do
  base_bin=`basename $file`
  # if [[ ! $base_bin =~ \. && -e $dir/man/man1/${base_bin}.1 ]]; then
  if [[ -e $dir/man/man1/${base_bin}.1 ]]; then
    update_alternatives $system_dir $base_bin
  fi
done

chown -R root:root $system_dir

shopt -s nocasematch
if [[ $dir =~ java || $dir =~ jdk || $dir =~ jre ]]; then

  # Create HOME variable
  ln -s $system_dir $prefix/JAVA_HOME
  export JAVA_HOME=$prefix/JAVA_HOME
  cat <<EOL
  # Add this to your bashrc
  if [ -e $prefix/JAVA_HOME ]; then
    export JAVA_HOME=$prefix/JAVA_HOME
  fi
  #
EOL

  # Firefox java system wide
  mkdir -p /usr/lib/mozilla/plugins
  ln -s $system_dir/lib/amd64/libnpjp2.so /usr/lib/mozilla/plugins/

elif [[ $dir =~ scala ]]; then
  ln -s $system_dir $prefix/SCALA_HOME
  export SCALA_HOME=$prefix/SCALA_HOME
  cat <<EOL
  # Add this to your bashrc
  if [ -e $prefix/SCALA_HOME ]; then
    export SCALA_HOME=$prefix/SCALA_HOME
  fi
  #
EOL
fi
