FROM python:3.8.11-slim

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONPATH /app/src:/app/src/api
ENV PYTHONUNBUFFERED 1
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PORTABLE=1

# Install system dependencies
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y build-essential postgresql-client git libldap2-dev libsasl2-dev libpq-dev htop vim

# Install Python dependancies
WORKDIR /app/src
COPY ./pyproject.toml ./poetry.lock ./
ENV PATH=/root/.poetry/bin:$PATH
RUN pip install poetry dumb-init && poetry install --no-interaction --no-ansi --no-dev
COPY api .

EXPOSE 8000
WORKDIR /app/src/api

CMD ["dumb-init", "--", "poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000", "--noreload"]