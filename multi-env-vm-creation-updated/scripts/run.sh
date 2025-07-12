#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
cd "$PROJECT_ROOT"

PROJECT_PREFIX="cbc"

get_vm_numbers() {
    grep "vm_numbers" "$1" | sed 's/.*=//g' | tr -d '[]"' | tr ',' ' ' | xargs
}

ENVIRONMENTS=("dev" "sit" "uat" "staging" "prod" "All VM Details" "Go back" "Exit")

function ensure_backend() {
    if [[ ! -f "$PROJECT_ROOT/.backend-env" ]]; then
        echo "ERROR: No backend config found (.backend-env missing)."
        echo "You must setup backend storage before managing environments."
        read -p "Do you want to run backend setup now? (y/n): " CHOICE
        if [[ "$CHOICE" =~ ^[Yy]$ ]]; then
            bash "$SCRIPT_DIR/backend.sh"
            if [[ ! -f "$PROJECT_ROOT/.backend-env" ]]; then
                echo "ERROR: Backend setup failed. Exiting."
                exit 1
            fi
            source "$PROJECT_ROOT/.backend-env"
        else
            echo "Please setup backend first and rerun this script."
            exit 1
        fi
    fi
    source "$PROJECT_ROOT/.backend-env"
}

function show_all_vm_details() {
    echo ""
    echo "=========== All VM Details ==========="
    for E in dev sit uat staging prod; do
        TFVARS_FILE="$PROJECT_ROOT/environments/$E.tfvars"
        if [ ! -f "$TFVARS_FILE" ]; then
            echo "$E: tfvars file not found."
            continue
        fi
        VMS=$(get_vm_numbers "$TFVARS_FILE")
        VM_COUNT=$(echo $VMS | wc -w)
        RESOURCE_PREFIX=$(grep "resource_prefix" "$TFVARS_FILE" | sed 's/.*=//g' | tr -d '"' | xargs)
        RG_NAME="${RESOURCE_PREFIX}-rg"
        RG_EXISTS=$(az group exists --name "$RG_NAME" 2>/dev/null)
        if [ "$VM_COUNT" -eq 0 ]; then
            if [[ "$RG_EXISTS" == "true" ]]; then
                echo "$E: No VMs. Shared infra present."
            else
                echo "$E: No VMs. No shared infra present."
            fi
            continue
        fi
        echo "$E: $VM_COUNT VM(s):"
        for VMN in $VMS; do
            echo "    ${RESOURCE_PREFIX}-vm-$VMN"
        done
    done
    echo "======================================"
}

function show_all_backend_and_vm_details() {
    echo ""
    echo "========= Backend Storage Details ========="
    if [[ -f "$PROJECT_ROOT/.backend-env" ]]; then
        source "$PROJECT_ROOT/.backend-env"
        RG_EXISTS=$(az group exists -n "$RESOURCE_GROUP" 2>/dev/null)
        if [[ "$RG_EXISTS" == "true" ]]; then
            echo "- Resource Group exists in Azure: $RESOURCE_GROUP"
            SA_EXISTS=$(az storage account check-name --name "$STORAGE_ACCOUNT_NAME" --query 'nameAvailable' -o tsv 2>/dev/null)
            if [[ "$SA_EXISTS" == "false" ]]; then
                echo "- Storage Account exists in Azure: $STORAGE_ACCOUNT_NAME"
                CONTAINER_EXISTS=$(az storage container exists \
                    --account-name "$STORAGE_ACCOUNT_NAME" \
                    --name "$CONTAINER_NAME" \
                    --auth-mode login \
                    --query exists -o tsv 2>/dev/null || echo "false")
                if [[ "$CONTAINER_EXISTS" == "true" ]]; then
                    echo "- Storage Container exists in Azure: $CONTAINER_NAME"
                else
                    echo "- Storage Container NOT found in Azure"
                fi
            else
                echo "- Storage Account NOT found in Azure"
                echo "- Storage Container NOT found in Azure"
            fi
        else
            echo "- Resource Group NOT found in Azure"
            echo "- Storage Account NOT found in Azure"
            echo "- Storage Container NOT found in Azure"
        fi
    else
        echo "No backend resources present or backend not configured."
    fi
    echo "==========================================="
    show_all_vm_details
}

function estimate_vm_and_ip_costs() {
    VM_MONTHLY_PRICE=14
    PUBLIC_IP_MONTHLY_PRICE=3.65
    DAYS_IN_MONTH=30

    TOTAL_VM=0
    TOTAL_IP=0
    declare -gA ENV_VM_COUNTS
    for ENV in dev sit uat staging prod; do
        TFVARS_FILE="$PROJECT_ROOT/environments/$ENV.tfvars"
        if [ ! -f "$TFVARS_FILE" ]; then
            ENV_VM_COUNTS[$ENV]=0
            continue
        fi
        VMS=$(get_vm_numbers "$TFVARS_FILE")
        VM_COUNT=$(echo $VMS | wc -w)
        ENV_VM_COUNTS[$ENV]=$VM_COUNT
        TOTAL_VM=$((TOTAL_VM + VM_COUNT))
        TOTAL_IP=$((TOTAL_IP + VM_COUNT))
    done
}

function smart_storage_count() {
    STORAGE_COUNT=0
    if [[ -f "$PROJECT_ROOT/.backend-env" ]]; then
        source "$PROJECT_ROOT/.backend-env"
        RG_EXISTS=$(az group exists -n "$RESOURCE_GROUP" 2>/dev/null)
        SA_EXISTS="notfound"
        if [[ "$RG_EXISTS" == "true" ]]; then
            SA_EXISTS=$(az storage account check-name --name "$STORAGE_ACCOUNT_NAME" --query 'nameAvailable' -o tsv 2>/dev/null)
        fi
        if [[ "$RG_EXISTS" == "true" && "$SA_EXISTS" == "false" ]]; then
            STORAGE_COUNT=1
        fi
    fi
    echo "$STORAGE_COUNT"
}

function show_monthly_cost_estimates() {
    estimate_vm_and_ip_costs

    STORAGE_ACCOUNT_MONTHLY_PRICE=2.40
    TOTAL_STORAGE=$(smart_storage_count)

    echo ""
    echo "======= Infra Monthly Cost Estimates (per environment) ======="
    for ENV in dev sit uat staging prod; do
        VM_COUNT=${ENV_VM_COUNTS[$ENV]:-0}
        VM_COST=$(awk "BEGIN {printf \"%.2f\", $VM_COUNT * 14}")
        IP_COST=$(awk "BEGIN {printf \"%.2f\", $VM_COUNT * 3.65}")
        ENV_TOTAL=$(awk "BEGIN {printf \"%.2f\", $VM_COST + $IP_COST}")
        printf "%-8s: %2s VM(s) @ \$%.2f + %2s public IP(s) @ \$%.2f = \$%.2f/month\n" \
            "$ENV" "$VM_COUNT" "$VM_COST" "$VM_COUNT" "$IP_COST" "$ENV_TOTAL"
    done
    GRAND_VM_COST=$(awk "BEGIN {printf \"%.2f\", $TOTAL_VM * 14}")
    GRAND_IP_COST=$(awk "BEGIN {printf \"%.2f\", $TOTAL_IP * 3.65}")
    GRAND_STORAGE_COST=$(awk "BEGIN {printf \"%.2f\", $TOTAL_STORAGE * $STORAGE_ACCOUNT_MONTHLY_PRICE}")
    GRAND_TOTAL=$(awk "BEGIN {printf \"%.2f\", $GRAND_VM_COST + $GRAND_IP_COST + $GRAND_STORAGE_COST}")
    echo "-----------------------------------------------------"
    echo "Storage Account: $TOTAL_STORAGE @ \$${STORAGE_ACCOUNT_MONTHLY_PRICE}/month"
    echo "-----------------------------------------------------"
    echo "Total: $TOTAL_VM VM(s) (\$$GRAND_VM_COST) + $TOTAL_IP Public IP(s) (\$$GRAND_IP_COST) + $TOTAL_STORAGE Storage Account (\$$GRAND_STORAGE_COST) = \$$GRAND_TOTAL/month (approx)"
    echo "Note: Prices are for East US region, PAYG. Actual may vary with region, usage, and discount."
    echo "====================================================="
}

function show_daily_cost_estimates() {
    estimate_vm_and_ip_costs

    STORAGE_ACCOUNT_MONTHLY_PRICE=2.40
    DAYS_IN_MONTH=30
    TOTAL_STORAGE=$(smart_storage_count)
    STORAGE_DAY=$(awk "BEGIN {printf \"%.2f\", $TOTAL_STORAGE * ($STORAGE_ACCOUNT_MONTHLY_PRICE / $DAYS_IN_MONTH)}")

    echo ""
    echo "======= Infra Daily Cost Estimates (per environment) ======="
    for ENV in dev sit uat staging prod; do
        VM_COUNT=${ENV_VM_COUNTS[$ENV]:-0}
        VM_COST_DAY=$(awk "BEGIN {printf \"%.2f\", ($VM_COUNT * 14) / $DAYS_IN_MONTH}")
        IP_COST_DAY=$(awk "BEGIN {printf \"%.2f\", ($VM_COUNT * 3.65) / $DAYS_IN_MONTH}")
        ENV_TOTAL_DAY=$(awk "BEGIN {printf \"%.2f\", $VM_COST_DAY + $IP_COST_DAY}")
        printf "%-8s: %2s VM(s) @ \$%.2f + %2s public IP(s) @ \$%.2f = \$%.2f/day\n" \
            "$ENV" "$VM_COUNT" "$VM_COST_DAY" "$VM_COUNT" "$IP_COST_DAY" "$ENV_TOTAL_DAY"
    done
    GRAND_VM_COST_DAY=$(awk "BEGIN {printf \"%.2f\", ($TOTAL_VM * 14) / $DAYS_IN_MONTH}")
    GRAND_IP_COST_DAY=$(awk "BEGIN {printf \"%.2f\", ($TOTAL_IP * 3.65) / $DAYS_IN_MONTH}")
    GRAND_TOTAL_DAY=$(awk "BEGIN {printf \"%.2f\", $GRAND_VM_COST_DAY + $GRAND_IP_COST_DAY + $STORAGE_DAY}")
    echo "-----------------------------------------------------"
    echo "Storage Account: $TOTAL_STORAGE @ \$$STORAGE_DAY/day"
    echo "-----------------------------------------------------"
    echo "Total: $TOTAL_VM VM(s) (\$$GRAND_VM_COST_DAY) + $TOTAL_IP Public IP(s) (\$$GRAND_IP_COST_DAY) + $TOTAL_STORAGE Storage Account (\$$STORAGE_DAY) = \$$GRAND_TOTAL_DAY/day (approx)"
    echo "Note: Prices are for East US region, PAYG. Actual may vary with region, usage, and discount."
    echo "====================================================="
}

function plan_and_apply() {
    local tfvars_file="$1"
    echo ""
    echo "Running terraform plan..."
    terraform plan -var-file="$tfvars_file"
    echo ""
    read -p "Do you want to proceed with terraform apply? (y/n): " PROCEED
    if [[ "$PROCEED" =~ ^[Yy]$ ]]; then
        terraform apply -var-file="$tfvars_file"
    else
        echo "Apply cancelled."
    fi
}

function plan_and_destroy() {
    local tfvars_file="$1"
    echo ""
    echo "Running terraform plan (destroy)..."
    terraform plan -destroy -var-file="$tfvars_file"
    echo ""
    read -p "Do you want to proceed with terraform destroy? (y/n): " PROCEED
    if [[ "$PROCEED" =~ ^[Yy]$ ]]; then
        terraform destroy -var-file="$tfvars_file"
    else
        echo "Destroy cancelled."
    fi
}

while true; do
    echo ""
    echo "1) Setup backend storage (create backend resources)"
    echo "2) Work with an environment (add/delete VMs, delete infra, etc)"
    echo "3) Delete backend storage account and container (dangerous! global!)"
    echo "4) All Backend and VM Details"
    echo "5) Show Infra Cost Estimates"
    echo "6) Exit"
    read -p "Select an option: " MAIN_ACTION

    case $MAIN_ACTION in
    1)
        bash "$SCRIPT_DIR/backend.sh"
        if [[ -f "$PROJECT_ROOT/.backend-env" ]]; then
            source "$PROJECT_ROOT/.backend-env"
        fi
        ;;
    2)
        ensure_backend
        while true; do
            echo ""
            echo "Note: Always select the workspace for your current environment (not 'default') unless you know you are using the default workspace intentionally."
            PS3="Select environment by number: "
            select ENV in "${ENVIRONMENTS[@]}"; do
                if [[ "$ENV" == "Go back" ]]; then
                    break 2
                elif [[ "$ENV" == "Exit" ]]; then
                    echo "Exiting."
                    exit 0
                elif [[ "$ENV" == "All VM Details" ]]; then
                    show_all_vm_details
                    continue 2
                elif [[ -n "$ENV" ]]; then
                    break
                else
                    echo "Invalid selection. Enter the number corresponding to your environment."
                fi
            done

            if [[ "$ENV" == "Go back" ]] || [[ "$ENV" == "Exit" ]] || [[ "$ENV" == "All VM Details" ]]; then
                continue
            fi

            TFVARS="$PROJECT_ROOT/environments/$ENV.tfvars"
            STATE_KEY="terraform.${ENV}.tfstate"

            if [ ! -f "$TFVARS" ]; then
                echo "No tfvars file found for $ENV. Exiting."
                break
            fi

            if [[ ! -f "$PROJECT_ROOT/.backend-config" ]]; then
                echo "ERROR: Backend config (.backend-config) missing. Run backend setup first."
                exit 1
            fi

            terraform init -reconfigure \
              -backend-config="$PROJECT_ROOT/.backend-config" \
              -backend-config="key=$STATE_KEY"

            terraform workspace select $ENV || terraform workspace new $ENV

            CURRENT=$(get_vm_numbers "$TFVARS")
            CURRENT_ARRAY=($CURRENT)

            # Get resource_prefix for VM name display
            RESOURCE_PREFIX=$(grep "resource_prefix" "$TFVARS" | sed 's/.*=//g' | tr -d '"' | xargs)

            while true; do
                echo "Current VMs in $ENV: ${#CURRENT_ARRAY[@]}"
                echo "What do you want to do?"
                echo "1) Add VMs"
                echo "2) Delete VMs"
                echo "3) Check shared infra status"
                echo "4) Delete all shared infra (network, RG, etc)"
                echo "5) Go back to previous menu"
                echo "6) Exit script"
                read -p "Enter option (1/2/3/4/5/6): " ACTION

                case $ACTION in
                1)
                    read -p "How many VMs do you want to ADD? " ADD_COUNT
                    if [[ ! $ADD_COUNT =~ ^[0-9]+$ ]]; then
                        echo "Not a valid number"
                        continue
                    fi
                    if [ ${#CURRENT_ARRAY[@]} -eq 0 ]; then
                        LAST_NUM=0
                    else
                        LAST_NUM=$(printf "%s\n" "${CURRENT_ARRAY[@]}" | sort -n | tail -1)
                    fi
                    NEW_VMS=""
                    for ((i=1; i<=ADD_COUNT; i++)); do
                        NEXT_NUM=$((LAST_NUM + i))
                        NEW_VMS="$NEW_VMS $NEXT_NUM"
                    done
                    ALL_VMS="$CURRENT ${NEW_VMS}"
                    VM_LIST=$(echo $ALL_VMS | tr ' ' '\n' | grep -v '^$' | sort -n | uniq | awk '{print "\"" $1 "\""}' | tr '\n' ',' | sed 's/,$//')
                    sed -i.bak "s/vm_numbers.*/vm_numbers = [${VM_LIST}]/" "$TFVARS"
                    echo "Updated VM numbers: [${VM_LIST}]"
                    plan_and_apply "$TFVARS"
                    CURRENT=$(get_vm_numbers "$TFVARS")
                    CURRENT_ARRAY=($CURRENT)
                    ;;
                2)
                    if [ -z "$CURRENT" ]; then
                        echo "No VMs exist to delete."
                        continue
                    fi
                    echo "Delete all VMs or specific VM(s)?"
                    echo "a) All"
                    echo "s) Specific"
                    read -p "Enter option (a/s): " DEL_MODE
                    if [ "$DEL_MODE" = "a" ]; then
                        sed -i.bak "s/vm_numbers.*/vm_numbers = []/" "$TFVARS"
                        echo "All VMs will be deleted in next apply."
                        plan_and_apply "$TFVARS"
                        CURRENT=""
                        CURRENT_ARRAY=()
                        read -p "No VMs left in $ENV. Delete all shared infra (network, RG, etc) for $ENV? (y/n): " DEL_INFRA
                        if [[ "$DEL_INFRA" =~ ^[Yy]$ ]]; then
                            plan_and_destroy "$TFVARS"
                            echo "All shared infra for $ENV has been deleted."
                        else
                            echo "Shared infra is retained for $ENV."
                        fi
                    else
                        # Show VM names
                        VM_NAME_LIST=()
                        for N in "${CURRENT_ARRAY[@]}"; do
                            VM_NAME_LIST+=("${RESOURCE_PREFIX}-vm-$N")
                        done
                        echo "Current VMs: ${VM_NAME_LIST[*]}"
                        read -p "Enter VM number(s) to delete (space-separated): " TO_DELETE
                        TO_DELETE_ARRAY=($TO_DELETE)
                        NEW_LIST=()
                        for N in "${CURRENT_ARRAY[@]}"; do
                            SKIP=0
                            for D in "${TO_DELETE_ARRAY[@]}"; do
                                if [ "$N" = "$D" ]; then
                                    SKIP=1
                                    break
                                fi
                            done
                            [ $SKIP -eq 0 ] && NEW_LIST+=($N)
                        done
                        if [ ${#NEW_LIST[@]} -eq 0 ]; then
                            sed -i.bak "s/vm_numbers.*/vm_numbers = []/" "$TFVARS"
                            echo "All VMs have been removed from the list."
                            plan_and_apply "$TFVARS"
                            read -p "No VMs left in $ENV. Delete all shared infra (network, RG, etc) for $ENV? (y/n): " DEL_INFRA
                            if [[ "$DEL_INFRA" =~ ^[Yy]$ ]]; then
                                plan_and_destroy "$TFVARS"
                                echo "All shared infra for $ENV has been deleted."
                            else
                                echo "Shared infra is retained for $ENV."
                            fi
                            CURRENT=""
                            CURRENT_ARRAY=()
                        else
                            VM_LIST=$(printf "%s\n" "${NEW_LIST[@]}" | sort -n | uniq | awk '{print "\"" $1 "\""}' | tr '\n' ',' | sed 's/,$//')
                            sed -i.bak "s/vm_numbers.*/vm_numbers = [${VM_LIST}]/" "$TFVARS"
                            echo "Updated VM numbers: [${VM_LIST}]"
                            plan_and_apply "$TFVARS"
                            CURRENT=$(get_vm_numbers "$TFVARS")
                            CURRENT_ARRAY=($CURRENT)
                        fi
                    fi
                    ;;
                3)
                    RG_NAME="${RESOURCE_PREFIX}-rg"
                    RG_EXISTS=$(az group exists --name "$RG_NAME" 2>/dev/null)
                    if [[ "$RG_EXISTS" == "true" ]]; then
                        echo "Shared infra exists for $ENV (resource group: $RG_NAME)."
                    else
                        echo "No shared infra present for $ENV."
                    fi
                    ;;
                4)
                    if [ -z "$CURRENT" ]; then
                        read -p "Are you sure you want to delete all shared infra (network, RG, etc) in $ENV? (y/n): " REALLY_DESTROY
                        if [[ "$REALLY_DESTROY" =~ ^[Yy]$ ]]; then
                            plan_and_destroy "$TFVARS"
                            sed -i.bak "s/vm_numbers.*/vm_numbers = []/" "$TFVARS"
                            echo "All shared infra for $ENV deleted."
                        else
                            echo "No changes made."
                        fi
                    else
                        echo "ERROR: There are still VMs present in $ENV. Please delete all VMs before deleting shared infra."
                    fi
                    ;;
                5)
                    echo "User selected to go back"
                    break
                    ;;
                6)
                    echo "Exiting script."
                    exit 0
                    ;;
                *)
                    echo "Invalid option."
                    ;;
                esac
            done
        done
        ;;
    3)
        ensure_backend
        ENVS_WITH_RESOURCES=()
        for E in dev sit uat staging prod; do
            TFVARS="$PROJECT_ROOT/environments/$E.tfvars"
            if [ -f "$TFVARS" ]; then
                RESOURCE_PREFIX=$(grep "resource_prefix" "$TFVARS" | sed 's/.*=//g' | tr -d '"' | xargs)
                RG_NAME="${RESOURCE_PREFIX}-rg"
                RG_EXISTS=$(az group exists --name "$RG_NAME" 2>/dev/null)
                if [[ "$RG_EXISTS" == "true" ]]; then
                    ENVS_WITH_RESOURCES+=("$E")
                fi
            fi
        done
        if [ ${#ENVS_WITH_RESOURCES[@]} -ne 0 ]; then
            echo "ERROR: Shared infra (resource groups) still present in the following environments: ${ENVS_WITH_RESOURCES[*]}. Delete all shared infra before deleting backend storage."
            exit 1
        fi
        echo "WARNING: This will permanently delete the storage account $STORAGE_ACCOUNT_NAME, ALL tfstate files, and the resource group $RESOURCE_GROUP."
        echo "This cannot be undone!"
        read -p "Are you sure you want to continue? (y/n): " REALLY_DELETE_STORAGE
        if [[ "$REALLY_DELETE_STORAGE" =~ ^[Yy]$ ]]; then
            echo "Deleting blob container $CONTAINER_NAME from storage account $STORAGE_ACCOUNT_NAME..."
            az storage container delete --account-name "$STORAGE_ACCOUNT_NAME" --name "$CONTAINER_NAME" --auth-mode login
            echo "Deleting storage account $STORAGE_ACCOUNT_NAME..."
            az storage account delete --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --yes
            echo "Deleting resource group $RESOURCE_GROUP..."
            az group delete --name "$RESOURCE_GROUP" --yes --no-wait
            rm -f "$PROJECT_ROOT/.backend-env" "$PROJECT_ROOT/.backend-config"
            echo "Storage account, container, and resource group deletion initiated."
        else
            echo "No changes made."
        fi
        ;;
    4)
        show_all_backend_and_vm_details
        ;;
    5)
        while true; do
            echo ""
            echo "---- Infra Cost Estimates ----"
            echo "1) Monthly estimates"
            echo "2) Daily estimates"
            echo "3) Go back"
            read -p "Select an option: " COST_ACTION
            case $COST_ACTION in
                1)
                    show_monthly_cost_estimates
                    ;;
                2)
                    show_daily_cost_estimates
                    ;;
                3)
                    break
                    ;;
                *)
                    echo "Invalid option."
                    ;;
            esac
        done
        ;;
    6)
        echo "No changes made."
        exit 0
        ;;
    *)
        echo "Invalid option"
        ;;
    esac
done
