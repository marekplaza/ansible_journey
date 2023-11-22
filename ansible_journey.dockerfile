FROM python:3.9-slim
RUN pip install ansible
# Install Arista EOS collection
RUN ansible-galaxy collection install arista.eos
RUN ansible-galaxy collection install arista.cvp
WORKDIR /ansible
CMD [ "ansible-playbook", "--version" ]