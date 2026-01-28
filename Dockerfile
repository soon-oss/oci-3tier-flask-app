# STAGE 1: Builder
FROM python:3.9-slim as builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /build

# FIX: Removed "apt-get install" block.
# python-oracledb (Thin Mode) does not need GCC or libaio.
# Most modern python packages (Flask, SQLAlchemy) have pre-built "wheels" 
# so we do not need to compile them.

# Copy requirements from app folder
COPY app/requirements.txt .

# Install dependencies into a local user directory
RUN pip install --user --no-cache-dir -r requirements.txt

# STAGE 2: Runtime
FROM python:3.9-slim

WORKDIR /app

# Create a non-root user (Security Best Practice)
RUN useradd -m appuser

# Copy installed python packages from builder stage
COPY --from=builder /root/.local /home/appuser/.local

# Copy application code
COPY app/ .

# Update PATH so python can find the installed packages
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 5000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]