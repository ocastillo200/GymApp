# Proyecto semestral Ingenieria de Software 2

Consiste en una aplicación móvil desarrollada con Flutter y backend en FastAPI con base de dato no relacional en MongoDB. Tiene una vista de entrenador (gestión de rutinas y clientes), y una vista de administrador (gestión de máquinas disponibles, usuarios, etc.).

## Integrantes:
- Oscar Castillo
- Vicente Cser
- Martin Garces
- Pablo Saravia
- Matias Tirado

## Instrucciones de uso
1. Clonar repositorio
```bash
git clone https://github.com/ocastillo200/ProyectoIS.git
```

2. Crear virtual environment
```bash
cd fastapi_mongo_project
python -m venv venv
./venv/Scripts/activate
```

3. Instalar requirements
```bash
pip install -r requirements.txt
```

4. Iniciar backend
```bash
cd fastapi_mongo_project
fastapi dev main.py
```

5. Iniciar app en flutter
