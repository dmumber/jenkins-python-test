FROM python:3.7

#COPY requirements.txt /tmp/

RUN echo "#!/bin/bash" > /entrypoint.sh && \
    echo "source venv/bin/activate" >> /entrypoint.sh && \
    echo "exec \"$@\"" >> /entrypoint.sh &&

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]