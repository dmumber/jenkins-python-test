ARG BASE_IMAGE
FROM ${BASE_IMAGE}

COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt