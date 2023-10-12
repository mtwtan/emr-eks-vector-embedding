FROM 755674844232.dkr.ecr.us-east-1.amazonaws.com/notebook-spark/emr-6.13.0:latest
 
USER root
 
### Add customization commands here ####
ARG PYTHON_VERSION=3.10.11
 
RUN yum -y remove openssl-devel && \
    yum install -y gcc openssl11-devel bzip2-devel \
    libffi-devel tar gzip wget make python3-Cython \
    xz-lzma-compat xz-devel && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make install
 
# Create our virtual environment
# we need both --copies for python executables for cp for libraries
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV --copies
RUN cp -r /usr/local/lib/python3.10/* $VIRTUAL_ENV/lib/python3.10
 
# Ensure our python3 executable references the virtual environment
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
 
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install dlt \
    datasets && \
    python3 -m pip install anyio==3.6.2 \
    argon2-cffi==21.3.0 \
    argon2-cffi-bindings==21.2.0 \
    attrs==23.1.0 \
    backcall==0.2.0 \
    beautifulsoup4==4.12.2 \
    bleach==6.0.0 \
    brewer2mpl==1.4.1 \
    certifi==2022.12.7 \
    cffi==1.15.1 \
    charset-normalizer==3.1.0 \
    cycler==0.11.0 \
    debugpy==1.6.7 \
    decorator==5.1.1 \
    defusedxml==0.7.1 \
    entrypoints==0.4 \
    fastjsonschema==2.16.3 \
    fonttools==4.38.0 \
    future==0.18.3 \
    ggplot==0.11.5 \
    idna==3.4 \
    importlib-metadata==6.5.0 \
    importlib-resources==5.12.0 \
    ipykernel==6.16.2 \
    ipython==7.34.0 \
    ipython-genutils==0.2.0 \
    ipywidgets==8.0.6 \
    jedi==0.18.2 \
    Jinja2==3.1.2 \
    joblib==1.2.0 \
    jsonschema==4.17.3 \
    jupyter==1.0.0 \
    jupyter-client==7.4.9 \
    jupyter-console==6.6.3 \
    jupyter-core==4.12.0 \
    jupyter-server==1.24.0 \
    jupyterlab-pygments==0.2.2 \
    jupyterlab-widgets==3.0.7 \
    kiwisolver==1.4.4 \
    MarkupSafe==2.1.2 \
    matplotlib==3.5.3 \
    matplotlib-inline==0.1.6 \
    mistune==2.0.5 \
    nbclassic==0.5.5 \
    nbclient==0.7.3 \
    nbconvert==7.3.1 \
    nbformat==5.8.0 \
    nest-asyncio==1.5.6 \
    notebook==6.5.4 \
    notebook-shim==0.2.2 \
    packaging==23.1 \
    pandocfilters==1.5.0 \
    parso==0.8.3 \
    patsy==0.5.3 \
    pexpect==4.8.0 \
    pickleshare==0.7.5 \
    Pillow==9.5.0 \
    pkgutil-resolve-name==1.3.10 \
    plotly==5.14.1 \
    prometheus-client==0.16.0 \
    prompt-toolkit==3.0.38 \
    psutil==5.9.5 \
    ptyprocess==0.7.0 \
    py4j==0.10.9.7 \
    pycparser==2.21 \
    pycryptodomex==3.17 \
    Pygments==2.15.1 \
    pyparsing==3.0.9 \
    pyrsistent==0.19.3 \
    python-dateutil==2.8.2 \
    pytz==2023.3 \
    pyzmq==25.0.2 \
    qtconsole==5.4.2 \
    QtPy==2.3.1 \
    requests==2.28.2 \
    scipy==1.7.3 \
    seaborn==0.12.2 \
    Send2Trash==1.8.0 \
    setuptools==49.1.3 \
    six==1.16.0 \
    sniffio==1.3.0 \
    soupsieve==2.4.1 \
    statsmodels==0.13.5 \
    tenacity==8.2.2 \
    terminado==0.17.1 \
    threadpoolctl==3.1.0 \
    tinycss2==1.2.1 \
    tornado==6.2 \
    traitlets==5.9.0 \
    typing-extensions==4.5.0 \
    urllib3==1.26.15 \
    wcwidth==0.2.6 \
    webencodings==0.5.1 \
    websocket-client==1.5.1 \
    widgetsnbextension==4.0.7 \
    zipp==3.15.0 \
    pandas \
    pyarrow \
    venv-pack==0.2.0 \
    s3fs \
    fsspec \
    scikit-learn \
    boto3 \
    tensorflow-cpu \
    torch \
    transformers \
    sentencepiece
 
ENV PYSPARK_PYTHON="/opt/venv/bin/python3"
ENV PYSPARK_DRIVER_PYTHON="/opt/venv/bin/python3"
 
USER hadoop:Hadoop

