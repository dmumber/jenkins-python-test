FROM python:3.7

#COPY requirements.txt /tmp/

RUN cat <<EOF >>/entrypoint.sh \
#!/bin/bash \
source venv/bin/activate \
exec "$@" \
EOF

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]