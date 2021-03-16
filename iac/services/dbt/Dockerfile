FROM fishtownanalytics/dbt:0.17.2 
USER root
RUN pip install --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host files.pythonhosted.org dbt-exasol
COPY exasol_patch.patch /tmp/
RUN apt update && apt install patch git -y && apt clean
RUN patch -ruN -d /usr/local/lib/python3.8/site-packages/dbt < /tmp/exasol_patch.patch

# These args are passed in via docker-compose, which reads then from the .env file.
# On Linux, run `make .env` to create the .env file for the current user.
# On MacOS and Windows, these can stay unset.
ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        groupadd -g ${GROUP_ID} dbt_test_user && \
        useradd -m -l -u ${USER_ID} -g ${GROUP_ID} dbt_test_user; \
    else \
        useradd -mU -l dbt_test_user; \
    fi
RUN mkdir -p /usr/app && chown dbt_test_user /usr/app
RUN mkdir -p /home/tox && chown dbt_test_user /home/tox

WORKDIR /usr/app
VOLUME /usr/app

USER dbt_test_user

ENV PYTHONIOENCODING=utf-8
ENV LANG C.UTF-8
