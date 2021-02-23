#!/bin/bash
set -x
myFolder=trino_server
myDir=~/sukanm/$myFolder/
buildFile=$myDir/Dockerfile
imageTag=custom_trino
dockerFile=$myDir/docker-compose.yml
catalogDir=$myDir/catalog

mkdir -p $myDir
if [ ! -e $buildFile ]; then
  echo >> $buildFile
fi

#create a linked directory
mkdir $catalogDir

#copy catalog properties files into docker build context
cp /mnt/hgfs/trino/catalog/*.properties $catalogDir

#Dockerfile is based on the trinodb/trino on docker hub
echo "FROM trinodb/trino" >> $buildFile

#copy in the catalog files from the host OS into the image
echo "COPY ./catalog /etc/trino/catalog" >> $buildFile

# run the docker build command in the folder where the Dockerfile resides
# give the image a tag "custom_trino"

cd $myDir

sudo docker build  -t $imageTag .

echo 'version: "3"' >> $dockerFile
echo 'services:'  >> $dockerFile
echo '   custom_trino:' >> $dockerFile
echo '      image: custom_trino' >> $dockerFile
echo '      build: .' >> $dockerFile
echo '      ports:' >> $dockerFile
echo '      - 8080:8080' >> $dockerFile

#now we run this command from the directory where the docker-compose.yml resides
#this creates a container based on the image 
sudo docker-compose up --detach 

echo ${myFolder}_${imageTag}_1

# Now we can shell into the container to make sure that the catalog are as expected
sudo docker exec -it ${myFolder}_${imageTag}_1 sh

# Now we can run the trino command 
#sudo docker exec -it $myFolder_$imageTag_1 trino

