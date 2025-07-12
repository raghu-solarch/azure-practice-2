#!/bin/bash
set -e

ENV="$1"
ACTION="$2"
shift 2
PARAMS=("$@")

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

TFVARS_FILE="$PROJECT_ROOT/environments/$ENV.tfvars"
BACKEND_ENV="$PROJECT_ROOT/.backend-env"
BACKEND_CONFIG="$PROJECT_ROOT/.backend-config"

function ensure_backend() {
    if [[ ! -f "$BACKEND_ENV" ]]; then
        echo "No backend config found; run backend setup."
        exit 1
    fi
    source "$BACKEND_ENV"
}

function backend_setup() {
    bash "$PROJECT_ROOT/scripts/backend.sh"
}

function backend_delete() {
    bash "$PROJECT_ROOT/scripts/backend.sh" delete
}

function get_vm_numbers() {
    grep "vm_numbers" "$TFVARS_FILE" | sed 's/.*=//g' | tr -d '[]"' | tr ',' ' ' | xargs
}

function get_resource_prefix() {
    grep "resource_prefix" "$TFVARS_FILE" | sed 's/.*=//g' | tr -d '"' | xargs
}

function add_vms() {
    ensure_backend
    local ADD_COUNT="$1"
    if [[ ! "$ADD_COUNT" =~ ^[0-9]+$ ]]; then
        echo "Not a valid number: $ADD_COUNT"
        exit 1
    fi
    local CURRENT_VMS=($(get_vm_numbers))
    local LAST_NUM=0
    if [[ ${#CURRENT_VMS[@]} -gt 0 ]]; then
        LAST_NUM=$(printf "%s\n" "${CURRENT_VMS[@]}" | sort -n | tail -1)
    fi
    local NEW_VMS=()
    for ((i=1; i<=ADD_COUNT; i++)); do
        NEW_VMS+=($((LAST_NUM + i)))
    done
    local ALL_VMS=("${CURRENT_VMS[@]}" "${NEW_VMS[@]}")
    local VM_LIST=$(printf "\"%s\"," "${ALL_VMS[@]}" | sed 's/,$//')
    sed -i.bak "s/vm_numbers.*/vm_numbers = [${VM_LIST}]/" "$TFVARS_FILE"
    echo "Updated VM numbers: [${ALL_VMS[*]}]"
    terraform init -reconfigure -backend-config="$BACKEND_CONFIG" -backend-config="key=terraform.${ENV}.tfstate"
    terraform workspace select $ENV || terraform workspace new $ENV
    terraform apply -auto-approve -var-file="$TFVARS_FILE"
}

function delete_vms() {
    ensure_backend
    local TO_DELETE=("${PARAMS[@]}")
    local CURRENT_VMS=($(get_vm_numbers))
    if [[ ${#CURRENT_VMS[@]} -eq 0 ]]; then
        echo "No VMs to delete."
        exit 0
    fi
    local NEW_LIST=()
    for N in "${CURRENT_VMS[@]}"; do
        local SKIP=0
        for D in "${TO_DELETE[@]}"; do
            if [[ "$N" == "$D" ]]; then
                SKIP=1
                break
            fi
        done
        [[ $SKIP -eq 0 ]] && NEW_LIST+=($N)
    done
    local VM_LIST=$(printf "\"%s\"," "${NEW_LIST[@]}" | sed 's/,$//')
    sed -i.bak "s/vm_numbers.*/vm_numbers = [${VM_LIST}]/" "$TFVARS_FILE"
    echo "VMs remaining: [${NEW_LIST[*]}]"
    terraform init -reconfigure -backend-config="$BACKEND_CONFIG" -backend-config="key=terraform.${ENV}.tfstate"
    terraform workspace select $ENV || terraform workspace new $ENV
    terraform apply -auto-approve -var-file="$TFVARS_FILE"
}

function destroy_infra() {
    ensure_backend
    terraform init -reconfigure -backend-config="$BACKEND_CONFIG" -backend-config="key=terraform.${ENV}.tfstate"
    terraform workspace select $ENV || terraform workspace new $ENV
    terraform destroy -auto-approve -var-file="$TFVARS_FILE"
}

function show_vms() {
    local CURRENT_VMS=($(get_vm_numbers))
    local RESOURCE_PREFIX=$(get_resource_prefix)
    echo "$ENV: ${#CURRENT_VMS[@]} VM(s):"
    for VMN in "${CURRENT_VMS[@]}"; do
        echo "    ${RESOURCE_PREFIX}-vm-$VMN"
    done
}

function show_cost() {
    local VM_PRICE=14
    local IP_PRICE=3.65
    local STORAGE_PRICE=2.4
    local VM_COUNT=$(get_vm_numbers | wc -w)
    local VM_COST=$(awk "BEGIN {printf \"%.2f\", $VM_COUNT * $VM_PRICE}")
    local IP_COST=$(awk "BEGIN {printf \"%.2f\", $VM_COUNT * $IP_PRICE}")
    local TOTAL=$(awk "BEGIN {printf \"%.2f\", $VM_COST + $IP_COST + $STORAGE_PRICE}")
    echo "Estimated monthly cost for $ENV: VMs: \$$VM_COST, IPs: \$$IP_COST, Storage: \$$STORAGE_PRICE, Total: \$$TOTAL"
}

case "$ACTION" in
    backend-setup)
        backend_setup
        ;;
    backend-delete)
        backend_delete
        ;;
    add)
        add_vms "${PARAMS[0]}"
        ;;
    delete)
        delete_vms "${PARAMS[@]}"
        ;;
    destroy-infra)
        destroy_infra
        ;;
    show-vms)
        show_vms
        ;;
    cost)
        show_cost
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: bash automation.sh <env> <action> [params]"
        exit 1
        ;;
esac
