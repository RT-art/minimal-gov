# syntax=docker/dockerfile:1

# Stage 1: Build dependencies
FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

# Upgrade pip and install dependencies
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt


# Stage 2: Final image
FROM python:3.12-slim-bookworm

WORKDIR /app

# Create a non-root user and group
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 appuser

# Copy installed dependencies from builder stage
COPY --from=builder /wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir /wheels/*

# Copy application code
COPY --chown=appuser:appgroup app.py .

# Switch to non-root user
USER appuser

# Expose the port gunicorn will run on
EXPOSE 8000

# Run the application using Gunicorn
# -w 4: ワーカープロセス数 (CPUコア数に応じて調整)
# -b 0.0.0.0:8000: すべてのインターフェースのポート8000で待機
# app:app: app.py ファイル内の app という名前のFlaskインスタンスを実行
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]