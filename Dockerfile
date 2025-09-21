# ==========================================================
# Dockerfile para el sistema de conteo de vehículos
# ==========================================================

# --- Etapa base: Python slim + dependencias mínimas ---
FROM python:3.12-slim AS base

# Evitar prompts interactivos de apt
ENV DEBIAN_FRONTEND=noninteractive

# Instalamos solo las dependencias del sistema necesarias para OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar requerimientos primero (para aprovechar cache de Docker)
COPY requirements-web.txt .

# Actualizar pip y herramientas base, luego instalar dependencias de Python
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements-web.txt

# --- Etapa final ---
FROM base AS final

# Copiar solo el código necesario para la versión web
COPY src/ src/

# Directorio para reportes CSV
RUN mkdir -p /app/reports

# Variables de entorno por defecto
ENV PYTHONUNBUFFERED=1 \
    CSV_DIR=/app/reports \
    MODEL_NAME=yolo11n.pt

# Puerto para Streamlit
EXPOSE 8501

# Comando por defecto: aplicación Streamlit
CMD ["streamlit", "run", "src/app.py"]
