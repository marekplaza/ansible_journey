
 ![apiuslab](https://marekplaza.github.io/apiuslab/apiuslab.png)


 # Welcome to ApiusLAB - ansible_journey project
 
 ## Project Overview
 
 `ansible_journey` is a project aimed at automating network configurations using Ansible within a Docker environment, specifically targeting Arista EOS switches. This project includes the creation of a Docker container with Ansible, installation of the Arista EOS galaxy collections, and execution of basic network configuration tasks such as setting hostnames and managing VLANs.
 
 ## Getting Started

 ### Project Structure
 
 - `docker/ansible_journey.docker`: Dockerfile that defines the Docker container with Ansible and Arista EOS galaxy collections.
 - `contanerlab_DEMO`: Guide how to setup network part of this project - Demo, simple topology based on Arista cEOS images.
 - `ansible/ansible.cfg`: Ansible main configuration file
 - `ansible/inventory.yml`: Ansible inventory, credential setup and hierarchy definition.
 - `ansible/group_vars`: Ansible group vars definitions, common for all NE.
 - `ansible/host_vars`: Ansible host specific vars for SWITCH-1 and SWITCH-2 independently.
 - `ansible/playbooks/set_MOTD.yml`: Ansible playbook to set Message of the Day banner.
 - `ansible/playbooks/change_hostname.yml`: Ansible playbook to change the hostname on an Arista switch.
 - `ansible/playbooks/add_vlans.yml`: Ansible playbook to add VLANs to an Arista switch.
 - `ansible/playbooks/revert_changes.yml`: Ansible playbook to revert changes made by the other playbooks.
 
 ### Prerequisites
 
 - Docker
 - Git (for cloning the repository)
 
 ## Installation
 
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
 
 ## Usage
 
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

 #### Running the Demo Lab Network

 To begin, please prepare at least two network devices. These could be set up using [https://containerlab.dev/](https://containerlab.dev/) tool.
 Guide how to set up sample DEMO enviroment, you will find in folder: [containerlab_DEMO](containerlab_DEMO)
 

 
 ## Playbooks
 
 1. **Setting a Hostname**
    The `change_hostname.yml` playbook sets a new hostname on the Arista switch. It first retrieves the current hostname and stores it for potential reversion.

    ```bash
    docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/set_motd.yml -i inventory.yml
    ```
 
2. **Creating VLANs**
    The `add_vlans.yml` playbook adds specified VLANs to the switch, demonstrating basic VLAN management.
   ```bash
   docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/add_vlans.yml -i inventory.yml
   ```
 
3. **Reverting Changes**
    The `revert_changes.yml` playbook can revert the hostname change and remove any VLANs that were added, showcasing the ability to rollback configurations.
   ```bash
   docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/revert_changes.yml -i inventory.yml
   ```

 
 ### Sample Executions
 
In this scenario, we will add to SWITCH-1 a list of VLANs resulting from the sum of VLANs defined in host_vars and the common part of group_vars. Please take a closer look on the files including mentioned items:

 - #### group_vars (all.yml):
 ```bash
 vlans:
  - id: 10
    name: "VLAN10__by_group_vars"
  - id: 20
    name: "VLAN20__by_group_vars"
 ```

 - #### host_vars (SWITCH-1.yml):
 ```bash
vlans:
  - id: 31
    name: "Admin_VLAN__by_host_vars"
  - id: 41
    name: "IoT_VLAN__by_host_vars"
 ```
Playbook `add_vlans.yml`, based on `eos_vlan` as a part of the eos collection and it presents itself as below:
   ```bash
   ---
     - hosts: SWITCH-1
       gather_facts: no
       tasks:
       - name: Add VLANs
         eos_vlans:
           config:
           - vlan_id: "{{ item.id }}"
             name: "{{ item.name }}"
           state: merged
         with_items: 
           - "{{ vlans }}"
   ```


   ```bash
   ❯ cd ansible
❯ docker run -it --rm --network host -v /etc/hosts:/etc/hosts -v $(pwd):/ansible ansible_journey ansible-playbook ./playbooks/add_vlans.yml -i inventory.yml -v
Using /ansible/ansible.cfg as config file

PLAY [SWITCH-1] ******************************************************************************************************************************************************************************************************

TASK [Add VLANs] *****************************************************************************************************************************************************************************************************
changed: [SWITCH-1] => (item={'id': 31, 'name': 'Admin_VLAN__by_host_vars'}) => {"after": [{"name": "VLAN10bygroupvars", "state": "active", "vlan_id": 10}, {"name": "VLAN20_by_group_vars", "state": "active", "vlan_id": 20}, {"name": "Admin_VLAN__by_host_vars", "state": "active", "vlan_id": 31}], "ansible_loop_var": "item", "before": [{"name": "VLAN10bygroupvars", "state": "active", "vlan_id": 10}, {"name": "VLAN20_by_group_vars", "state": "active", "vlan_id": 20}], "changed": true, "commands": ["vlan 31", "name Admin_VLAN__by_host_vars"], "item": {"id": 31, "name": "Admin_VLAN__by_host_vars"}}
changed: [SWITCH-1] => (item={'id': 41, 'name': 'IoT_VLAN__by_host_vars'}) => {"after": [{"name": "VLAN10bygroupvars", "state": "active", "vlan_id": 10}, {"name": "VLAN20_by_group_vars", "state": "active", "vlan_id": 20}, {"name": "Admin_VLAN__by_host_vars", "state": "active", "vlan_id": 31}, {"name": "IoT_VLAN__by_host_vars", "state": "active", "vlan_id": 41}], "ansible_loop_var": "item", "before": [{"name": "VLAN10bygroupvars", "state": "active", "vlan_id": 10}, {"name": "VLAN20_by_group_vars", "state": "active", "vlan_id": 20}, {"name": "Admin_VLAN__by_host_vars", "state": "active", "vlan_id": 31}], "changed": true, "commands": ["vlan 41", "name IoT_VLAN__by_host_vars"], "item": {"id": 41, "name": "IoT_VLAN__by_host_vars"}}

PLAY RECAP ***********************************************************************************************************************************************************************************************************
SWITCH-1                   : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
   ```

## Contributing
 
 Contributions to `ansible_journey` are welcome. Please ensure that your contributions adhere to best practices and include appropriate documentation and tests.
