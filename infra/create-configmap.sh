#!/bin/bash

# Script para criar ConfigMap a partir do arquivo .env.api
# Usage: ./create-configmap.sh

NAMESPACE="core"
CONFIGMAP_NAME="api-config"
ENV_FILE=".env.api"

if [ ! -f "$ENV_FILE" ]; then
    echo "Erro: Arquivo $ENV_FILE não encontrado!"
    echo "Crie o arquivo .env.api com suas variáveis de ambiente."
    exit 1
fi

echo "Criando ConfigMap $CONFIGMAP_NAME no namespace $NAMESPACE..."

# Remove o ConfigMap existente se houver
kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE 2>/dev/null || true

# Cria o novo ConfigMap
kubectl create configmap $CONFIGMAP_NAME --from-env-file=$ENV_FILE -n $NAMESPACE

if [ $? -eq 0 ]; then
    echo "ConfigMap $CONFIGMAP_NAME criado com sucesso!"
else
    echo "Erro ao criar ConfigMap!"
    exit 1
fi
