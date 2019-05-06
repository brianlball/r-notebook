FROM jupyter/datascience-notebook

USER root
#link gtar to tar for devtools::install_github to work
RUN ln -s /bin/tar /bin/gtar
#copy notebooks over and set permissions to joyvan
COPY ./parallelCoords.ipynb /home/$NB_USER/parallelCoords.ipynb
RUN chown $NB_USER:users /home/$NB_USER/parallelCoords.ipynb
     
USER $NB_UID     
RUN conda install --quiet --yes \
    'r-rstan' \
    'r-fields' \
    'r-plotly' \
    'r-devtools' \
    && R -e "devtools::install_github('timelyportfolio/parcoords')"

#trust all notebooks
RUN find /home/$NB_USER -name '*.ipynb' -exec jupyter trust {} \;

#start with no creditials, TODO: make secure for production
CMD ["jupyter", \
     "notebook", \
     "--port=8888", \
     "--no-browser", \
     "--ip=0.0.0.0", \
     "--allow-root", \
     "--NotebookApp.token=''", \
     "--NotebookApp.password=''", \
     "--NotebookApp.iopub_data_rate_limit=1.0e10"]