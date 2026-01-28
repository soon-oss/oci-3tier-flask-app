# ==========================================
# STAGE 1: Builder (Compile and Install)
# ==========================================
FROM python:3.9-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /build

# Create a virtual environment in a neutral location
RUN python -m venv /opt/venv

# Activate the venv and upgrade pip
# We use the full path to ensure we use the venv's pip
ENV PATH="/opt/venv/bin:$PATH"

COPY app/requirements.txt .

# Install dependencies into the virtual environment
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ==========================================
# STAGE 2: Runtime (Minimal Image)
# ==========================================
FROM python:3.9-slim

WORKDIR /app

# Create the non-root user
RUN useradd -m appuser

# COPY the entire virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Enable the virtual environment by adding it to the PATH
# This means "python" and "gunicorn" will run from /opt/venv/bin automatically
ENV PATH="/opt/venv/bin:$PATH"

# Copy the application code
COPY app/ .

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 5000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]