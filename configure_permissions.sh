#!/bin/bash

chown -R 8983:8983 ./data-solr/
chmod -R 777 ./data/
chmod +x ./entrypoint.sh

echo "Permission changed on data-solr and data."
ls -al ./data-solr ./data ./entrypoint.sh