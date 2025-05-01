#!/bin/bash

echo "🚀 Bienvenido al instalador interactivo de Node-RED"

# Preguntar antes de crear carpetas
read -p "👉 ¿Querés crear la estructura del proyecto (carpetas y archivos)? [s/N]: " crear
if [[ "$crear" =~ ^[sS]$ ]]; then
  mkdir -p nodered-flujos/.node-red
  mkdir -p nodered-flujos/.devcontainer
  cd nodered-flujos || exit 1

  echo "📄 Creando README.md..."
  cat <<EOF > README.md
# Proyecto Node-RED

Este proyecto contiene flujos y configuración de Node-RED para usar localmente o en GitHub Codespaces.
EOF

  echo "📄 Creando flows.json de ejemplo..."
  cat <<EOF > flows.json
[
  {
    "id": "inject1",
    "type": "inject",
    "name": "Hola Mundo",
    "props": [],
    "repeat": "",
    "crontab": "",
    "once": true,
    "onceDelay": 0.1,
    "wires": [["debug1"]]
  },
  {
    "id": "debug1",
    "type": "debug",
    "name": "Salida",
    "active": true,
    "tosidebar": true,
    "wires": []
  }
]
EOF

  echo "📄 Creando .gitignore..."
  cat <<EOF > .gitignore
node_modules/
.npm/
*.log
EOF

  echo "📄 Creando .devcontainer/devcontainer.json..."
  cat <<EOF > .devcontainer/devcontainer.json
{
  "name": "Node-RED Dev",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    }
  },
  "postCreateCommand": "./setup.sh"
}
EOF

  # Inicializar entorno Node.js local en .node-red
  echo "📦 Inicializando entorno Node.js local en .node-red..."
  cd .node-red || exit 1
  npm init -y
  npm install node-red
  cd ../..

else
  echo "❌ Salteando creación de estructura."
fi

# Confirmar instalación de Node-RED globalmente
read -p "👉 ¿Querés instalar Node-RED globalmente con npm? [s/N]: " instalar
if [[ "$instalar" =~ ^[sS]$ ]]; then
  echo "📦 Instalando Node-RED..."
  npm install -g --unsafe-perm node-red
else
  echo "❌ Node-RED no será instalado."
fi

# Confirmar copiar el flujo a ~/.node-red
read -p "👉 ¿Querés copiar el flujo de ejemplo a ~/.node-red/flows.json? [s/N]: " copiar
if [[ "$copiar" =~ ^[sS]$ ]]; then
  echo "📁 Copiando flujo..."
  mkdir -p ~/.node-red
  cp nodered-flujos/flows.json ~/.node-red/flows.json
else
  echo "❌ No se copiará el flujo."
fi

read -p "👉 ¿Querés habilitar el modo 'proyectos' en settings.js? [s/N]: " habilitar_proyectos
if [[ "$habilitar_proyectos" =~ ^[sS]$ ]]; then
  echo "🛠 Configurando Node-RED para habilitar modo 'proyectos'..."

  SETTINGS_FILE="$HOME/.node-red/settings.js"

  if [[ -f "$SETTINGS_FILE" ]]; then
    if grep -q "projects:" "$SETTINGS_FILE"; then
      # Reemplaza 'enabled: false' por 'enabled: true' dentro del bloque 'projects'
      sed -i '/projects: *{/,/},/s/enabled: *false/enabled: true/' "$SETTINGS_FILE"
      echo "✅ Modo 'proyectos' habilitado en settings.js."
    else
      echo "⚠️ No se encontró un bloque 'projects' en settings.js."
    fi
  else
    echo "❌ settings.js no encontrado en ~/.node-red"
    echo "🔁 Iniciá Node-RED al menos una vez para generar la configuración inicial."
  fi
else
  echo "❌ No se modificará settings.js."
fi

echo "✅ Proceso finalizado. Ejecutá 'node-red' para iniciar si lo instalaste."
# Confirmar inicializar repo Git
read -p "👉 ¿Querés inicializar repositorio Git localmente? [s/N]: " gitinit
if [[ "$gitinit" =~ ^[sS]$ ]]; then
  cd nodered-flujos || exit 1
  git init
  git add .
  git commit -m "🚀 Proyecto inicial de Node-RED"
  cd ..
else
  echo "❌ No se inicializa Git."
fi
