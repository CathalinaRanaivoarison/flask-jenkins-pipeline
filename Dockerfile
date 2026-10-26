FROM python:3.14-slim

RUN useradd -u 1000 appuser

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

USER 1000

CMD ["gunicorn","-c","gunicorn.conf.py","main:app"]