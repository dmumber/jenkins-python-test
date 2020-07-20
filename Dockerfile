FROM python:3.8

COPY requirements.txt /tmp/

RUN python -m venv it4ad_e2e_base_line && \
    . it4ad_e2e_base_line/bin/activate && \
    pip install --requirement /tmp/requirements.txt && \
    venv-pack -p it4ad_e2e_base_line -o it4ad_e2e_base_line.tar.gz

CMD . it4ad_e2e_base_line/bin/activate && exec python