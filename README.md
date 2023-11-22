
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
    docker build -t ansible_journey -f ansible_journey.docker .
    ```
 
    This command builds a Docker image named `ansible_journey` based on the `ansible_journey.docker` file in the repository, which includes Ansible and the necessary Arista collections.
 
 ### Usage
 
 #### Running the Docker Container
 
 To run the Docker container and access the Ansible environment:
 
 ```bash
 docker run -it --rm ansible_journey
 ```
 
 #### Executing Playbooks
 
 - **Change Hostname:**
   ```bash
   docker run -it --rm -v $(pwd):/ansible ansible_journey ansible-playbook change_hostname.yml
   ```
 
 - **Add VLANs:**
   ```bash
   docker run -it --rm -v $(pwd):/ansible ansible_journey ansible-playbook add_vlans.yml
   ```
 
 - **Revert Changes:**
   ```bash
   docker run -it --rm -v $(pwd):/ansible ansible_journey ansible-playbook revert_changes.yml
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
