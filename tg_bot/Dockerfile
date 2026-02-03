FROM python:3.10-slim
WORKDIR /app
RUN pip install --no-cache-dir python-telegram-bot[socks] flask
COPY main.py .
EXPOSE xxxx
CMD ["python", "main.py"]