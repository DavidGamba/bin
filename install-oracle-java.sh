#!/bin/bash
# Reference: http://askubuntu.com/questions/55848/how-do-i-install-oracle-java-jdk-7

java_dir=$1
if [! -d "$java_dir" ]; then
  echo "Missing java extracted dir!"
fi

sudo mv $java_dir /usr/lib/jvm/$java_dir
sudo update-alternatives --install "/usr/bin/java"   "java"   "/usr/lib/jvm/$java_dir/bin/java"   2000
sudo update-alternatives --install "/usr/bin/javac"  "javac"  "/usr/lib/jvm/$java_dir/bin/javac"  2000
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/$java_dir/bin/javaws" 2000
sudo ln -s /usr/lib/jvm/$java_dir /usr/lib/jvm/JAVA_HOME

# Correct file permissions and ownership
sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac
sudo chmod a+x /usr/bin/javaws
sudo chown -R root:root /usr/lib/jvm/$java_dir

# Firefox java system wide
sudo mkdir -p /usr/lib/mozilla/plugins
sudo ln -s /usr/lib/jvm/$java_dir/lib/amd64/libnpjp2.so /usr/lib/mozilla/plugins/

# Add to bashrc
if [ -e /usr/lib/jvm/JAVA_HOME ]; then
  export JAVA_HOME=/usr/lib/jvm/JAVA_HOME
  export PATH=$PATH:$JAVA_HOME/bin
fi
