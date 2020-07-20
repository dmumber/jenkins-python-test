FROM python:3.7

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ARG VENV_NAME
ADD ${VENV_NAME}.tar.gz /it4ad_e2e_base

ENTRYPOINT [ "/entrypoint.sh" ]