FROM node:22-bookworm-slim AS frontend-build
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

FROM python:3.12-slim-bookworm AS runtime
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PAPA_WORK_DIR=/tmp/datasus-papa/work
ENV PAPA_OUTPUT_DIR=/tmp/datasus-papa/output
ENV MAX_MONTHS_PER_JOB=3
ENV MAX_UPLOAD_MB=512
ENV MAX_DOWNLOAD_AGE_HOURS=24

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . ./
COPY --from=frontend-build /app/frontend/dist ./frontend/dist

RUN mkdir -p /tmp/datasus-papa/work /tmp/datasus-papa/output

EXPOSE 8000

CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
