# Detección, Seguimiento y Conteo de Vehículos en Tiempo Real (YOLOv11 + Supervision)

Este proyecto detecta, sigue y cuenta vehículos (carros y motos) en tiempo real a partir de un video cargado manualmente o la webcam. Mantiene un inventario por tipo de vehículo con capacidades configurables y genera una alarma visual y auditiva cuando se excede la capacidad definida para cada tipo.  

Incluye:
- **YOLOv8, YOLOv11 y YOLOv12** como modelos de detección.
- **Reportes CSV configurables**.
- **Modo CLI headless** y **UI (Tkinter / Streamlit)**.
- **Pruebas automáticas con pytest** y **coverage**.
- **Servicios separados vía gRPC** (inferencia y UI/cliente).
- Compatibilidad con **Docker** y automatización vía **Makefile**.

---

## 🚀 Tecnologías principales
- **Ultralytics YOLO v8/v11/v12** – detección de objetos
- **Supervision (ByteTrack)** – seguimiento y anotación
- **OpenCV** – lectura de video y visualización
- **Tkinter / Streamlit** – interfaces gráficas
- **Pytest / Coverage** – pruebas y reportes
- **gRPC / Protobuf** – comunicación entre servicios
- **Docker / Makefile** – despliegue y automatización

---

## ✨ Características
- Detección y conteo de vehículos en tiempo real.
- Seguimiento multi-objeto con IDs únicos.
- Inventario dinámico con alarmas visuales/sonoras.
- Exportación de reportes CSV (IN/OUT y SUMMARY).
- Modo CLI headless para entornos sin interfaz gráfica.
- Interfaz gráfica con Tkinter y **Streamlit (cliente web)**.
- Servicios desacoplados:
  - `inference_server` (procesamiento YOLO).
  - `streamlit_app` (UI web que consume vía gRPC).
- Pruebas unitarias e integración con pytest.
- Dockerfile listo para build/run.

---

## 💻 Requisitos
- Python **3.11+**
- [UV](https://github.com/astral-sh/uv) o pip para dependencias
- Windows, Linux o macOS
- Webcam opcional
- GPU NVIDIA opcional (CUDA/cuDNN)

---

## 📦 Instalación
```bash
# Crear entorno virtual
uv venv .venv
.\.venv\Scripts\activate

# Instalar dependencias
uv pip install -r requirements.txt
uv pip install -r requirements-dev.txt   # dependencias de desarrollo
```

---

## ▶️ Ejecución con interfaz Tkinter
```powershell
# Con UV
uv run -p .venv python src/app.py

# Con pip tradicional
.\.venv\Scripts\activate.bat
python src/app.py
```

---

## 🌐 Ejecución con interfaz Streamlit
```powershell
streamlit run streamlit_app.py
```
Esto abre una página web en http://localhost:8501 donde puedes:
- Subir un video o usar webcam.
- Configurar modelo, confianza, línea de conteo y capacidades.
- Ver los frames procesados en tiempo real.
- Descargar el CSV generado.

---

## ⚡ Modo CLI (headless)
Ejemplo con webcam:
```powershell
python src/app.py --cli --webcam --model yolo12n.pt --conf 0.30 ^
  --orientation vertical --line-pos 0.50 ^
  --cap-car 50 --cap-moto 50 ^
  --csv --csv-dir reports --csv-name "turno_noche" --no-display
```

Ejemplo con archivo de video:
```powershell
python src/app.py --cli --source "C:\Videos\ejemplo.mp4" --model yolo11n.pt ^
  --orientation horizontal --line-pos 0.25 --invert ^
  --csv --csv-dir "C:\Users\CAMILO\Desktop\reports" --csv-name "parqueadero_sabado" --no-display
```

---

## 🧰 Uso de Makefile
El proyecto incluye un `Makefile` para simplificar tareas comunes:
```bash
# Ejecutar en modo CLI con video de ejemplo
make run-cli SRC="videos/prueba1.MP4" MODEL=yolo12n.pt CONF=0.3 ORIENT=vertical LINE_POS=0.5

# Ejecutar en Docker en modo CLI
make docker-run-cli SRC="videos/prueba1.MP4"

# Ejecutar pruebas
make test

# Generar reporte de coverage
make coverage
```

---

## 🐳 Docker
Construir imagen:
```bash
docker build -t contador-vehiculos .
```

Ejecutar contenedor (procesar un video):
```bash
docker run --rm -it ^
  -v "%cd%\reports:/app/reports" ^
  -v "%cd%\videos\prueba1.MP4:/data/input.mp4:ro" ^
  contador-vehiculos python src/app.py --cli --source /data/input.mp4 --no-display
```

---

## 📄 Reporte CSV
Columnas:
```
timestamp;evento;clase;car_in;car_out;moto_in;moto_out;car_inv;moto_inv;modelo;conf;orientacion;pos_linea;invertido;fuente
```

Ejemplo:
```
2025-09-17T12:34:56;IN;car;1;0;0;0;1;0;yolo12n.pt;0.30;vertical;0.50;False;ejemplo.mp4
2025-09-17T12:40:00;SUMMARY;-;15;10;4;5;5;-1;yolo12n.pt;0.30;vertical;0.50;False;ejemplo.mp4
```

---

## 🧪 Pruebas
```bash
# Instalar dependencias de desarrollo
pip install -r requirements-dev.txt

# Correr pruebas
pytest -q

# Reporte de coverage
coverage run -m pytest
coverage report -m
coverage html
```
Abre `htmlcov/index.html` en tu navegador para ver cobertura.

---

## 🔌 Arquitectura gRPC
El sistema se divide en dos servicios:

```
┌───────────────┐     gRPC (protobuf)     ┌──────────────────┐
│   Cliente      │ <────────────────────> │   Servidor        │
│ (Streamlit o  │                        │ (inference_server)│
│  grpc_client) │                        │                  │
└───────────────┘                        └──────────────────┘
         ▲                                         │
         │                                         ▼
   Usuario/Front                                YOLO + CSV
```

### Servidor de inferencia
Levantar el servidor:
```bash
python services/inference_server.py
```
Escucha en `localhost:50051`.

### Cliente CLI
```bash
python clients/grpc_client.py "videos/prueba1.MP4"
```
Muestra progreso y devuelve el CSV.

### Cliente Streamlit
Próxima etapa: el `streamlit_app.py` se conecta al servidor gRPC y muestra los frames enviados.

---

## 📌 Próximos pasos
- Integración con **MLflow** para registrar parámetros, métricas y artefactos (CSV).  
- Configuración de **docker-compose** para levantar `inference` (gRPC) + `ui` (Streamlit).  
- Añadir **CI/CD** con GitHub Actions (pytest + coverage).  
- Documentar **flujo Gitflow y Kanban** en el repo.

---
