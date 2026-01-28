# STAGE 1: Builder
FROM python:3.9-slim as builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /build

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

# --- FIX  ---
# Copy from local "app/requirements.txt" to the container's "/build/" dir
COPY app/requirements.txt .

# Install python dependencies into /root/.local
RUN pip install --user --no-cache-dir -r requirements.txt

# STAGE 2: Runtime
FROM python:3.9-slim

WORKDIR /app

# Create a non-root user
RUN useradd -m appuser

# Install runtime system libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# --- SECOND FIX ---
# Copy actual application code from local "app/" folder to container
COPY app/ .

# Ensure scripts in .local are usable
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 5000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]