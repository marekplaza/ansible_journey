# ansible_journey

## 1. Docker Build with Ansible

ansible_journey.dockerfile:

```dockerfile
# Install Arista All available collections: EOS, CVP and AVD on top
FROM python:3.9-slim
RUN pip install ansible
RUN ansible-galaxy collection install arista.eos arista.cvp
WORKDIR /ansible
CMD [ "ansible-playbook", "--version" ]
```

Build the docker:
```bash
docker build -t ansible_journey -f ansible_journey.dockerfile . 
```

Run docker with attached volumen - current folder as ansible workdir:

```bash
docker run -it --rm -v $(pwd):/ansible ansible_journey ansible-playbook your-playbook.yml
```