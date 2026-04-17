# Stage 1: Build (The "Factory")
FROM python:3.9-slim AS builder

WORKDIR /app

# Install build tools
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirement.txt .
# Install dependencies into a specific folder
RUN pip install --user --no-cache-dir -r requirement.txt

# Stage 2: Run (The "Car")
FROM python:3.9-slim

WORKDIR /app

# Only install the tiny library needed to RUN, not the tools to build
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only the installed packages from the builder stage
COPY --from=builder /root/.local /root/.local
COPY . .

# Ensure the app can find the installed packages
ENV PATH=/root/.local/bin:$PATH

EXPOSE 5000
CMD ["python", "app.py"]