cd /workspace && nohup jupyter notebook --ip=localhost --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.allow_remote_access='true' > /dev/null 2>&1 &