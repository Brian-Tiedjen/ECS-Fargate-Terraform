FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY src /app/src

EXPOSE 8000

# CKV_DOCKER_2: add container healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')" || exit 1

# CKV_DOCKER_3: run as non-root user
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
