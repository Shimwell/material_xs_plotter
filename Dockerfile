
# build with the following command
# sudo docker build -t gcr.io/material_xs_plotter-cloud-run/api:latest .
# run with 
# docker run gcr.io/material_xs_plotter-cloud-run/api:latest
# To push the docker ifle run gcloud init then ...
# docker push gcr.io/find-tbr-cloud-run/api:latest(base)


# build with the following command
# sudo docker build -f Dockerfile_openmc -t openmcworkshop/openmc

FROM ubuntu:18.04

# Python and OpenMC installation

RUN apt-get --yes update && apt-get --yes upgrade

RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install Packages Required
RUN apt-get --yes update && apt-get --yes upgrade
RUN apt-get --yes install gfortran 
RUN apt-get --yes install g++ 
RUN apt-get --yes install cmake 
RUN apt-get --yes install libhdf5-dev 
RUN apt-get --yes install git
RUN apt-get update

RUN apt-get install -y python3-pip
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-setuptools
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y ipython3
RUN apt-get update
RUN apt-get install -y python3-tk

#Install unzip
RUN apt-get update
RUN apt-get install -y unzip

#Install Packages Optional
RUN apt-get --yes update
RUN apt-get --yes install imagemagick
RUN apt-get --yes install hdf5-tools
RUN apt-get --yes install paraview
RUN apt-get --yes install eog
RUN apt-get --yes install wget
RUN apt-get --yes install firefox
RUN apt-get --yes install dpkg
RUN apt-get --yes install libxkbfile1

#Install Packages Optional for distributed memory parallel simulations
RUN apt install --yes mpich libmpich-dev
RUN apt install --yes openmpi-bin libopenmpi-dev

RUN apt-get --yes install libblas-dev 
# RUN apt-get --yes install libatlas-dev 
RUN apt-get --yes install liblapack-dev

# Python Prerequisites Required
RUN pip3 install numpy
RUN pip3 install pandas
RUN pip3 install six
RUN pip3 install h5py
RUN pip3 install Matplotlib
RUN pip3 install uncertainties
RUN pip3 install lxml
RUN pip3 install scipy

# Python Prerequisites Optional (Required)
RUN pip3 install cython
RUN pip3 install vtk
RUN apt-get install --yes libsilo-dev
RUN pip3 install pytest
RUN pip3 install codecov
RUN pip3 install pytest-cov
RUN pip3 install pylint

# Pyne requirments
RUN pip3 install tables
RUN pip3 install setuptools
RUN pip3 install prettytable
RUN pip3 install sphinxcontrib_bibtex
RUN pip3 install numpydoc
RUN pip3 install nbconvert
RUN pip3 install nose

# Clone and install NJOY2016
RUN git clone https://github.com/njoy/NJOY2016 /opt/NJOY2016 && \
    cd /opt/NJOY2016 && \
    mkdir build && cd build && \
    cmake -Dstatic=on .. && make 2>/dev/null && make install

RUN rm /usr/bin/python
RUN ln -s /usr/bin/python3 /usr/bin/python


# installs OpenMc from source 
RUN cd opt && \
    # git clone https://github.com/openmc-dev/openmc.git && \  
    git clone https://github.com/eepeterson/openmc.git && \  
    cd openmc && \
    git checkout plot_xs_bugfix && \
    # git checkout develop && \
    mkdir build && cd build && \
    cmake .. && \
#    cmake -Ddebug=on .. && \
    make && \
    make install

#this python install method allows openmc source code changes to be trialed
RUN cd /opt/openmc && python3 setup.py develop
#this alternative install method makes changing source code and testing is a little harder 
#RUN cd /opt/openmc && pip3 install .

RUN git clone https://github.com/openmc-dev/plotter.git
RUN echo 'export PATH=$PATH:/plotter/' >> ~/.bashrc

RUN echo 'alias python="python3"' >> ~/.bashrc



# install endf nuclear data

# clone data repository
RUN git clone https://github.com/openmc-dev/data.git

# run script that converts ACE data to hdf5 data
RUN python3 data/convert_nndc71.py --cleanup

ENV OPENMC_CROSS_SECTIONS=/nndc-b7.1-hdf5/cross_sections.xml


RUN pip3 install streamlit
RUN pip3 install plotly

RUN echo redownloading 
RUN git clone https://github.com/Shimwell/material_xs_plotter.git

WORKDIR material_xs_plotter

EXPOSE 8080

ENTRYPOINT ["streamlit", "run", "index.py"]

