
 ![apiuslab](https://marekplaza.github.io/apiuslab/apiuslab.png)


 # Welcome to ApiusLAB - ansible_journey project
 
 ## Project Overview
 
 `ansible_journey` is a project aimed at automating network configurations using Ansible within a Docker environment, specifically targeting Arista EOS switches. This project includes the creation of a Docker container with Ansible, installation of the Arista EOS galaxy collections, and execution of basic network configuration tasks such as setting hostnames and managing VLANs.
 
 ## Getting Started
 
 ### Prerequisites
 
 - Docker
 - Git (for cloning the repository)
 
 ### Installation
 
 1. **Clone the Repository:**
    ```bash
    git clone https://github.com/marekplaza/ansible_journey.git
    cd ansible_journey
    ```
 
 2. **Build the Docker Image:**
    ```bash
    cd docker
    docker build -t ansible_journey -f ansible_journey.docker .
    ```
 
    This command builds a Docker image named `ansible_journey` based on the `ansible_journey.docker` file in the repository, which includes Ansible and the necessary Arista collections:

    ```bash
    # Use an official Python runtime as a parent image
    FROM python:3.9-slim
    # Set the working directory in the container
    WORKDIR /ansible
    # Install Ansible and necessary libraries
    RUN pip install ansible pyyaml requests paramiko jsonschema ansible-pylibssh
    # Install Arista collections
    RUN ansible-galaxy collection install arista.eos arista.cvp
    # Install SSH clients
    RUN apt-get update && apt-get install -y ssh-client sshpass
    # Optional tools
    RUN apt-get install -y git
    # Command to run when starting the container
    CMD [ "ansible-playbook", "--version" ]
    ```
 
 ### Usage
 
 #### Running the Docker Container
 
 To run the Docker container and access the Ansible environment:
 
 ```bash
 docker run -it --rm ansible_journey
 ```
 
 To gain access to your configuration and playbook localized on host mount your host workdir as container workdir, and then run docker:

```bash
 docker run -it --rm -v $(pwd):/ansible ansible_journey [CMD]
```

For example you can check if everthinig has been installed properly:
```bash
sudo docker run -it --rm -v $(pwd):/ansible ansible_journey ansible-galaxy collection list |grep arista
arista.cvp                    3.8.0  ✅
arista.eos                    6.2.1  ✅
```

 #### Demo Lab Network

 To begin, please prepare at least two network devices. These could be set up using [https://containerlab.dev/](https://containerlab.dev/) tool.
 Guide how to set up certain DEMO enviroment, you will find in `containerlab_DEMO`` folder: [contaiberlab_DEMO](contaiberlab_DEMO)
 
 Follow these steps:
  - Name the devices SWITCH-1 and SWITCH-2. 
  - Adopt your `inventory.yml` file by changing the IP addresses, as well as username and password acourdingly, My starting configuration is as follows:

 ```bash
---
all:
  vars: 
    ansible_connection: network_cli
    ansible_network_os: eos
    ansible_become: yes
    ansible_become_method: enable
    ansible_user: admin
    ansible_ssh_pass: admin
  children:
    SWITCHES:
    hosts:
      SWITCH-1:
        ansible_host: 172.1.1.1
      SWITCH-2:
        ansible_host: 172.1.1.2
 ```



 #### Executing Playbooks
 
 - **Set MOTD:**
   ```bash
   docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/set_motd.yml -i inventory.yml
   ```
 
 - **Add VLANs:**
   ```bash
   docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/add_vlans.yml -i inventory.yml
   ```
 
 - **Revert Changes:**
   ```bash
   docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/revert_changes.yml -i inventory.yml
   ```
 
 ## Project Structure
 
 - `ansible_journey.docker`: Dockerfile that defines the Docker container with Ansible and Arista EOS galaxy collections.
 - `change_hostname.yml`: Ansible playbook to change the hostname on an Arista switch.
 - `add_vlans.yml`: Ansible playbook to add VLANs to an Arista switch.
 - `revert_changes.yml`: Ansible playbook to revert changes made by the other playbooks.
 
 ## Examples
 
 1. **Setting a Hostname**
    The `change_hostname.yml` playbook sets a new hostname on the Arista switch. It first retrieves the current hostname and stores it for potential reversion.
 
2. **Creating VLANs**
    The `add_vlans.yml` playbook adds specified VLANs to the switch, demonstrating basic VLAN management.
 
3. **Reverting Changes**
    The `revert_changes.yml` playbook can revert the hostname change and remove any VLANs that were added, showcasing the ability to rollback configurations.
 
## Contributing
 
 Contributions to `ansible_journey` are welcome. Please ensure that your contributions adhere to best practices and include appropriate documentation and tests.

 #Project Link: [https://github.com/marekplaza/ansible_journey](https://github.com/marekplaza/ansible_journey)
