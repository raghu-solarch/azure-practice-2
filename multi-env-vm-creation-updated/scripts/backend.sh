#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

RESOURCE_GROUP="cbcmultienvvmrg1"
LOCATION="eastus"
STORAGE_ACCOUNT="cbcmultienvdisk1"
CONTAINER="cbctfstatecontainer1"

if [[ "$1" == "delete" ]]; then
    echo "Deleting storage container..."
    az storage container delete --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER" --auth-mode login || echo "Container may not exist"

    echo "Deleting storage account..."
    az storage account delete --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --yes || echo "Storage account may not exist"

    echo "Deleting resource group..."
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait || echo "Resource group may not exist or already deleting"

    # Optionally remove backend config files
    rm -f "$PROJECT_ROOT/.backend-env" "$PROJECT_ROOT/.backend-config"

    echo "Backend resources deleted."
    exit 0
fi

# ==== Create resources ====
echo "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "Creating storage account..."
az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --sku Standard_LRS

echo "Creating storage container..."
az storage container create --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER" --auth-mode login

# ==== Write .backend-env ====
cat > "$PROJECT_ROOT/.backend-env" <<EOF
export STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT"
export CONTAINER_NAME="$CONTAINER"
export RESOURCE_GROUP="$RESOURCE_GROUP"
EOF

# ==== Write .backend-config ====
cat > "$PROJECT_ROOT/.backend-config" <<EOF
resource_group_name  = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT"
container_name       = "$CONTAINER"
key                  = "terraform.tfstate"
EOF

echo ""
echo "Azure backend is ready."
echo ""
echo "===== BACKEND DETAILS ====="
echo "Resource Group:      $RESOURCE_GROUP"
echo "Storage Account:     $STORAGE_ACCOUNT"
echo "Storage Container:   $CONTAINER"
echo "Location:            $LOCATION"
echo "=========================="
echo ""
echo "DEBUG: .backend-env content:"
cat "$PROJECT_ROOT/.backend-env"
echo "DEBUG: .backend-config content:"
cat "$PROJECT_ROOT/.backend-config"
