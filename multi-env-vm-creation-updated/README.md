Spin Up, Tear Down, Repeat: Multi-Environment Azure Made Easy
Multi-Environment Azure VM Creation Project


Problem Statement:
==================

Every real project outgrows a single Azure environment. Dev, SIT, UAT, staging, and prod all need their own infra, but most teams end up with manual, error-prone processes. Scripts get copied, portals get clicked, and naming conventions go out the window. Resource drift and unplanned costs are almost guaranteed. Cleaning up—especially when people leave—is a pain.

The risk is simple: without automation and clear controls, your Azure bill grows, infra gets messy, and onboarding new engineers becomes a game of “find the secret script and hope it works.” There’s no good way to see what’s running, what it’s costing, or even if you’re about to delete the wrong thing.

You need a way to guarantee consistency, safety, and cost visibility—across every environment, for every team member.


When to Use This:
=================

Use this system if you:

Need to manage multiple Azure environments (dev, sit, uat, staging, prod) with isolation and consistency

Want everything managed as code, not via Azure portal clicks or hand-written ad-hoc scripts

Care about easy, safe creation and deletion of VMs, resource groups, and shared infra—no more zombie resources

Want predictable naming and structure, so cleanup is fast and you never delete the wrong thing

Need real, environment-level cost estimation before deployment

Are tired of guessing who did what, or why something costs so much

Skip it if you run a single environment, never use Azure, or need heavily customized infra per environment.


Why It’s Needed
================


Here’s the thing: Azure gets chaotic fast if you’re not strict. Without a menu-driven, automated system that’s aware of every environment and resource, you end up with:

Inconsistent resource names and accidental collisions

Orphaned resources driving up your Azure bill

Engineers manually deleting infra and sometimes killing production accidentally

No clean mapping of what’s deployed, where, and why

Security risks from overly broad or forgotten NSG rules

No way to reliably onboard or offboard people

This project enforces sanity:

One place to manage all environments

Menu-driven, so anyone can use it without cloud voodoo

Every resource is traceable, deletable, and costed—before you deploy

If you care about operational discipline, this is the glue that holds your Azure infra together.


Project Overview:
================
This repo contains a full menu-driven shell tool (run.sh) and supporting scripts for managing Azure virtual machines and supporting infra across dev, SIT, UAT, staging, and prod environments.


Key features:
=============

Spin up or destroy VMs in any environment via a simple menu—no need to touch Terraform directly

Backend state is isolated per environment using Azure Storage

All naming is driven by project and environment prefixes, so infra is never orphaned or misnamed

Real-time display of all VMs, shared infra, and estimated monthly/daily costs per environment

Option to add/delete VMs, destroy all infra, or wipe backend state with full safety checks

Centralized logic—no secrets, no hidden magic, everything driven by scripts and config

The setup relies on Terraform for actual resource provisioning, with modularized code in /modules/azure-vm/. All environments use their own .tfvars file, and state is managed using remote Azure Storage.


Advantages and Disadvantages:
============================

Advantages:
===========

Repeatable: Same actions, same results, every time

Isolated: Each environment is cleanly separated, no cross-talk

Cost Visibility: See infra cost estimates before running anything

No Guesswork: Naming, deletion, and creation are predictable and menu-driven

No Drift: Central source of truth, easy onboarding/offboarding

Extendable: Easy to add more environments or VM types

Disadvantages:
=============

Opinionated: Naming and structure are enforced—some edge use cases will need customization

Not for Microservices: This is VM-centric, not for AKS or serverless patterns

Initial Setup: Requires careful setup of prefixes and backend config for safety

Basic Security: Out-of-the-box, admin creds are in tfvars; must be rotated or managed with a secrets tool for production


Pre-requisites:
===============

Before you run anything, read this and make sure you’ve set everything up properly.

If you skip these, you’ll either get errors or risk deploying resources to the wrong places.

Clone this repo and review all files.

Update these files as below:
============================

1. scripts/backend.sh

Edit these lines to match your standards.

LOCATION should match the location used in all your .tfvars files.

RESOURCE_GROUP="cbcmultienvvmrg1"      # Use a name starting with your project prefix, no dashes/spaces
LOCATION="eastus"                      # Should match the 'location' in all .tfvars files (case-insensitive)
STORAGE_ACCOUNT="cbcmultienvdisk1"     # Project prefix, lowercase, no dashes or spaces
CONTAINER="cbctfstatecontainer1"       # Same: project prefix, lowercase, no dashes/spaces

2. scripts/run.sh

Make sure this line is set and matches your naming:

PROJECT_PREFIX="cbc"

All backend resources and resource_prefix in your .tfvars should start with this.

3. environments/*.tfvars

Edit each file (dev.tfvars, sit.tfvars, etc.) and set consistent naming and location.

resource_prefix should start with your chosen project prefix and can use dashes (e.g., cbc-dev).

location must match the backend’s LOCATION exactly (e.g., "East US" if eastus in backend.sh).

Example (dev.tfvars):

env_name        = "dev"
vnet_cidr       = "10.1.0.0/16"
resource_prefix = "cbc-dev"
project_name    = "cbc-multi-env"
location        = "East US"         # Must match LOCATION in backend.sh (case-insensitive)
admin_username  = "learning"
admin_password  = "Redhat@12345"
vm_numbers      = []

Do the same for sit.tfvars, uat.tfvars, staging.tfvars, prod.tfvars (use different vnet_cidr for each).



What is backend.sh?
==================

backend.sh is the automation script that sets up your remote Terraform state backend in Azure. In any real-world team or multi-env setup, you want your Terraform state stored centrally and safely—not just on your laptop. That’s exactly what this script guarantees.

What does it actually do?
=========================
In one run, it:

* Creates an Azure resource group:
===================================
This is where all your backend (state management) resources live.

* Creates an Azure Storage Account:
==================================
This account is where the actual Terraform state files (the “truth” of what’s deployed) are stored. Using a remote backend like this is what lets multiple engineers safely collaborate and ensures you never lose track of your infra.

* Creates a Storage Container:
==============================
Inside the storage account, this container holds the actual .tfstate files, isolated from other data or blobs.

* Writes config files for the rest of the automation:
====================================================
It generates .backend-env (for shell scripts) and .backend-config (for Terraform itself). These files make sure every script and Terraform run in your repo always points to the right backend resources, every time.

* Echoes out all config and state info for audit/debug:
======================================================
So you can see exactly what was created, with no hidden state.

Why do you need it?
====================

Because without a remote backend, Terraform state gets lost, teams step on each other’s toes, and infra changes become risky. By automating backend setup, you avoid human error, guarantee consistency, and set up the foundation for safe multi-environment management.

In short:
=========
You run backend.sh once to set up your shared, safe, central state backend in Azure. All further infra changes (via run.sh or Terraform) automatically use this backend—no guesswork, no manual config, no state loss.


What is run.sh?
==============
run.sh is your single entry point for managing the entire lifecycle of multiple environments in Azure using Terraform—without having to remember any Terraform commands, state locations, or file structures.

It’s an interactive, menu-driven automation script. It’s written in Bash, and is designed to be run by engineers, SREs, or cloud admins who want a safe, repeatable, and idiot-proof way to spin up, modify, or tear down virtual machine environments in Azure.

What does it actually do?
=========================

* Centralizes all environment management:
==========================================
Instead of running terraform manually, you run run.sh and interact with a simple numbered menu. The script takes care of the details—like reading tfvars, working with the correct backend, selecting or creating the right workspace, and ensuring resources get created or destroyed as expected.

* *utomates backend validation:
==============================
It checks for the required backend resources and environment variables, and prompts the user to set them up (via backend.sh) if they’re missing. No manual error-prone config needed.

* Lets you manage VMs in different environments:
=================================================
You can add or delete VMs, environment by environment (dev, sit, uat, staging, prod). It tracks the current state and updates the .tfvars files, so every run reflects reality.

* Handles shared infrastructure:
===============================
Beyond just VMs, it also lets you clean up all shared resources (network, RG, etc) in each environment. This prevents orphaned resources and makes sure environments can be created/destroyed cleanly.

* Shows full backend and infra state:
======================================
It can show all current backend details, all VMs in every environment, and the status of shared infra at any time.

* Estimates and displays costs:
===============================
It can calculate and show daily/monthly Azure cost estimates for the entire infrastructure—across all environments—using hardcoded or parameterized prices.

* Protects you from dangerous actions:
======================================
For destructive actions (like deleting storage, shared infra, or all VMs), it prompts for confirmation and checks for dependencies—so you can’t accidentally wipe out the backend or infra without several checkpoints.

* Self-updating menus and state:
================================
It always works off the latest state in the tfvars files and backend config, so you never see stale data or make changes based on an out-of-date view.

Why use run.sh?
==============
You want to manage infra in a repeatable, auditable, and team-friendly way

You don’t want engineers to accidentally mess up state, resources, or config

You want one script to handle the whole workflow: setup, create, delete, tear down, cost visibility, and status checks

In short:
==========
run.sh is your control panel for safe, multi-environment Azure infrastructure management with Terraform, wrapped in a simple script.
It automates best practices, reduces mistakes, and saves everyone time.


Step-by-Step Implementation : 
=============================

Edit configs as above

Set resource group, storage, and container names in backend.sh.

Set PROJECT_PREFIX in run.sh.

Check all .tfvars files for consistent resource_prefix and location.

Run the tool

cd scripts/
./run.sh

If backend resources don’t exist, select the menu option to create them when prompted.

The tool will guide you through backend setup, environment selection, and all operations (add/delete VMs, infra, costs, etc).

Follow menu options

Create backend resources (if not present).

Select your environment.

Add or delete VMs.

Delete all infra for an environment (after deleting VMs).

Show all current VMs and backend state.

View cost estimates.

To cleanup everything

Use the “Delete backend storage account and container” menu option (be careful—this is permanent).

Conclusion:
============
If you want to stop babysitting your Azure infra and actually trust what’s running in every environment, use this project. It’s the difference between “works on my machine” and “anyone can manage this, safely.”

You get fast, visible control over all environments—no risk of zombies, no more surprise costs, no more onboarding horror stories. Everything is traceable, repeatable, and (if needed) deletable, with a single command.

Bottom line:
============
Predictable environments, safe changes, instant cost visibility, and real control—without the Azure portal ever getting in your way.

=========================
