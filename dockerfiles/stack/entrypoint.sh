#!/bin/bash

# Start servers
nohup markserv -a 0.0.0.0 -p 8080 &
nohup jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root \
                       --NotebookApp.token='' --NotebookApp.password='' &

# If a CMD is passed, execute it
exec "$@"