# KOAD-S04: Insecure Jupyter Notebook
# No authentication — anyone can execute arbitrary code
# DO NOT deploy in production environments.
FROM jupyter/base-notebook:latest

USER root
RUN pip install --no-cache-dir requests kubernetes

USER ${NB_USER}

CMD ["start-notebook.sh", \
     "--NotebookApp.token=''", \
     "--NotebookApp.password=''", \
     "--NotebookApp.allow_origin='*'", \
     "--NotebookApp.disable_check_xsrf=True"]
