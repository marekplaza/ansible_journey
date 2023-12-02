# DEMO lab 
 
## Getting Started

We will use simple, two swtiches topology run based on conteneraized Arista EOS system - cEOS, orchestrated by containerlab software

 ### Prerequisites:
 
- ### Install a Containerlab

We :heart: containers,right? :) Go visit a https://containerlab.dev/ and install it on your host or use dockerized version, it's as simple as that:

```
docker run --rm -it --privileged \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /etc/hosts:/etc/hosts \
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    --pid="host" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ghcr.io/srl-labs/clab bash
```

Switch `bash` to `containerlab` or shortly `clab` to check what we get:


```bash
  ____ ___  _   _ _____  _    ___ _   _ _____ ____  _       _     
 / ___/ _ \| \ | |_   _|/ \  |_ _| \ | | ____|  _ \| | __ _| |__  
| |  | | | |  \| | | | / _ \  | ||  \| |  _| | |_) | |/ _` | '_ \ 
| |__| |_| | |\  | | |/ ___ \ | || |\  | |___|  _ <| | (_| | |_) |
 \____\___/|_| \_| |_/_/   \_\___|_| \_|_____|_| \_\_|\__,_|_.__/ 

    version: 0.48.1
     commit: 2184f2df
       date: 2023-11-13T18:02:22Z
     source: https://github.com/srl-labs/containerlab
 rel. notes: https://containerlab.dev/rn/0.48/#0481
 ```

 - ### Arista cEOS: dockeriazed EOS image

Please remember to download Arista cEOS image and import it to your local docker images repository. You need to have account on arista.com site. The most convient way is to install using... Yes, you are right! We surely use a dockeraized downloader. Firstly, please generate Download Token on your Arista account and export it as env variable `$ARISTA_TOKEN`, then use eos-downlader [eos-downlader](https://github.com/titom73/eos-downloader), as presented below:

```bash
docker run -it -w $(pwd) -v $(pwd):$(pwd) titom73/eos-downloader:dev --token $ARISTA_TOKEN get eos --image-type cEOS64 --release-type M --latest --log-level debug --output ./
🪐 eos-downloader is starting...
    - Image Type: cEOS64
    - Version: None
🔎  Searching file cEOS64-lab-4.30.4M.tar.xz
    -> Found file at /support/download/EOS-USA/Active Releases/4.30/EOS-4.30.4M/cEOS-lab/cEOS64-lab-4.30.4M.tar.xz
💾  Downloading cEOS64-lab-4.30.4M.tar.xz ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100.0% • 14.7 MB/s • 571.8/571.8 MB • 0:00:43 •
🚀  Running checksum validation
🔎  Searching file cEOS64-lab-4.30.4M.tar.xz.sha512sum
    -> Found file at /support/download/EOS-USA/Active Releases/4.30/EOS-4.30.4M/cEOS-lab/cEOS64-lab-4.30.4M.tar.xz.sha512sum
💾  Downloading cEOS64-lab-4.30.4M.tar.xz.sha512sum ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100.0% • ? • 155/155 bytes • 0:00:00 •
✅  Downloaded file is correct.
✅  processing done !
```

And import it:

```
docker import cEOS64-lab-4.30.4M.tar.xz ceos64:4.30.4M
sha256:488618b63f2c075496655babfea48341045bdfed3871ccd96af1ac38189bab7c
```



- ### Ansible: adjustment inventory.yml file

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

- ### Containerlab: DEMO.yml file

In terms of containerlab configuration itself, minimum configuration requirements to run our DEMO looks like:

```bash
name: DEMO
prefix: ""
mgmt:
  network: DEMO
  ipv4-subnet: 172.1.1.0/24
  ipv4-gw: 172.1.1.254
  external-access: true
topology:
  kinds:
    ceos:
      image: ceos64:4.30.4M
      startup-config: baseline.cfg
  nodes:
    SWITCH-1:
      kind: ceos
      mgmt-ipv4: 172.1.1.1
    SWITCH-2:
      kind: ceos
      mgmt-ipv4: 172.1.1.2
  links:      
  - endpoints:
    - SWITCH-1:eth1
    - SWITCH-2:eth1
```

And import it:

```
docker import cEOS64-lab-4.30.4M.tar.xz ceos64:4.30.4M
sha256:488618b63f2c075496655babfea48341045bdfed3871ccd96af1ac38189bab7c
```


 - ### Run DEMO lab

Issue just a `clab deploy -t DEMO.yml` to simply run DEMO topology:
```bash
cd contaiberlab_DEMO
docker run --rm -it --privileged \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /etc/hosts:/etc/hosts \
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    --pid="host" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ghcr.io/srl-labs/clab containerlab deploy -t DEMO.yml
```

Be patient, depending on performance of your machine it could take a while to make it running:

```bash
INFO[0000] Containerlab v0.48.1 started                 
INFO[0000] Parsing & checking topology file: DEMO.yml   
INFO[0000] Creating docker network: Name="DEMO", IPv4Subnet="172.1.1.0/24", IPv6Subnet="", MTU='ל' 
INFO[0000] Creating lab directory: /home/marpla/ansible_journey/containerlab_DEMO/clab-DEMO 
INFO[0000] Creating container: "SWITCH-2"               
INFO[0000] Creating container: "SWITCH-1"               
INFO[0001] Creating link: SWITCH-1:eth1 <--> SWITCH-2:eth1 
INFO[0001] Running postdeploy actions for Arista cEOS 'SWITCH-1' node 
INFO[0001] Running postdeploy actions for Arista cEOS 'SWITCH-2' node 
INFO[0097] Adding containerlab host entries to /etc/hosts file 
INFO[0097] Adding ssh config for containerlab nodes     
INFO[0097] 🎉 New containerlab version 0.48.6 is available! Release notes: https://containerlab.dev/rn/0.48/#0486
Run 'containerlab version upgrade' to upgrade or go check other installation options at https://containerlab.dev/install/ 
+---+----------+--------------+----------------+------+---------+--------------+--------------+
| # |   Name   | Container ID |     Image      | Kind |  State  | IPv4 Address | IPv6 Address |
+---+----------+--------------+----------------+------+---------+--------------+--------------+
| 1 | SWITCH-1 | 876c4a56ed7f | ceos64:4.30.4M | ceos | running | 172.1.1.1/24 | N/A          |
| 2 | SWITCH-2 | 11dc5353abec | ceos64:4.30.4M | ceos | running | 172.1.1.2/24 | N/A          |
+---+----------+--------------+----------------+------+---------+--------------+--------------+
```

- ### Clenup your lab

Finally, after deailing with ansible journey excersize, you can easly switch off your network lab by issuing command as follows (destroy):

```bash
docker run --rm -it --privileged \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /etc/hosts:/etc/hosts \
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    --pid="host" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ghcr.io/srl-labs/clab containerlab destroy -t DEMO.yml --cleanup
INFO[0000] Parsing & checking topology file: DEMO.yml   
INFO[0000] Destroying lab: DEMO                         
INFO[0002] Removed container: SWITCH-1                  
INFO[0002] Removed container: SWITCH-2                  
INFO[0002] Removing containerlab host entries from /etc/hosts file 
INFO[0002] Removing ssh config for containerlab nodes   
```