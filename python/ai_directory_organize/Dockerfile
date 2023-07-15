FROM python:3.8-slim-buster

WORKDIR /app

ADD . /app

RUN pip install --no-cache-dir -r requirements.txt

ENV OPENAI_API_KEY your-api-key
ENV OPENAI_MODEL gpt-3.5-turbo
ENV PATH_TO_ANALYZE /data

CMD ["python", "-u", "main.py", "-f", "--path", "${PATH_TO_ANALYZE}", "--model", "${OPENAI_MODEL}"]
