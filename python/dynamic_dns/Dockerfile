# Use an official Python runtime as the base image
FROM python:3.12-alpine

WORKDIR /app

COPY script.py requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt && \
    apk add --no-cache dcron && \
    echo "*/5 * * * * python /app/script.py >> /var/log/cron.log 2>&1" > /etc/crontabs/root && \
    touch /var/log/cron.log

CMD crond -l 2 -f && tail -f /var/log/cron.log
