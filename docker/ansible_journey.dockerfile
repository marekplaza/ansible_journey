# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /ansible

# Install Ansible and necessary libraries
RUN pip install ansible pyyaml requests paramiko jsonschema ansible-pylibssh

# Install Arista collections
RUN ansible-galaxy collection install arista.eos arista.cvp

# Install SSH client
RUN apt-get update && apt-get install -y ssh-client

# Optional tools
RUN apt-get install -y git

# Command to run when starting the container
CMD [ "ansible-playbook", "--version" ]