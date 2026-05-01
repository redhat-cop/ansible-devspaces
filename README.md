# Ansible Development Workspace Sample

Welcome to the Ansible Development Workspace sample repository! This repository provides a ready-to-use, containerized development environment for Ansible content creation, testing, and debugging using Red Hat OpenShift Dev Spaces.

By importing this repository into Dev Spaces, you instantly get a pre-configured, browser-based IDE equipped with all the essential tools you need to build high-quality automation—without installing anything on your local machine.

## What's Included

This environment is configured via the included `devfile.yaml` and `.code-workspace` files. These files setup your workspace to run an Ansible specific Dev Spaces image and configure the IDE with recommended extensions and settings specific to Ansible development.

Out of the box, your workspace includes:
* **Visual Studio Code - Open Source ("Code - OSS") Environment**: A web-based VS Code experience tailored for automation developers.
* **Ansible VS Code Extension**: Provides auto-completion, syntax highlighting, integrated documentation, and AI-assisted code completion via Ansible Lightspeed.
* **Core Dependencies**: Python and `ansible-core`.
* **Ansible Development Tools (ADT)**:
The Ansible Development Tools (ADT) package provides a curated suite of utilities designed to easily install and discover the best tools for creating and testing Ansible content

    * **ansible-core**: A radically simple IT automation platform that simplifies deploying and maintaining applications and systems, automating everything from code deployment to network configuration using a language that approaches plain English

    * **ansible-builder**: A utility used for building Ansible execution environments

    * **ansible-creator**: A utility for rapidly scaffolding Ansible projects and content according to leading practices

    * **ansible-lint**: A tool designed to identify and correct stylistic errors and anti-patterns within Ansible playbooks and roles

    * **ansible-navigator**: A text-based user interface (TUI) used to develop and troubleshoot Ansible content within execution environments

    * **ansible-sign**: A utility for signing and verifying your Ansible content

    * **molecule**: An Ansible-native testing framework that aids in the development and testing of Ansible collections, playbooks, and roles

    * **pytest-ansible**: A pytest testing framework extension that provides extra functionality for testing Ansible module and plugin Python code

    * **tox-ansible**: An extension to the tox testing utility that adds functionality to check Ansible module and plugin Python code under various Python interpreters and Ansible core versions

    * **ansible-dev-environment (ADE)**: A utility for building and managing isolated virtual workspaces specifically tailored for Ansible content development


## Getting Started

To launch this environment, you can create a workspace with this Git repository directly from your OpenShift Dev Spaces dashboard.

**Launch Instructions:**
1. In your browser, navigate to your organization's OpenShift Dev Spaces dashboard and log in.
1. Select **Create Workspace** in the navigation pane.
1. In the **Import from Git** field, enter the URL for this Git repository.
1. Click **Create & Open**.

Once the provisioning process completes, a VS Code environment will open in your browser, ready for development.

There is a sample `ansible-navigator.yaml` file in the root of this project.

1. Rename `ansible-navigator.yaml.sample` to `ansible-navigator.yaml`
1. Make any desired modifications to the file.
1. Launch the environment from a teminal by running `ansible-navigator`

## Best Practices

* **Idempotency**: Use Molecule to ensure your tasks are idempotent—meaning they can be applied multiple times without making unintended changes after the first successful run.
* **Linting**: Keep an eye on the VS Code terminal for `ansible-lint` suggestions to ensure your YAML structure aligns with Ansible community standards.
* **Role Structure**: Keep your content modular. Focus your roles on a specific functionality rather than specific environment implementations.
