*This project has been created as part of the 42 curriculum by tjorge-l.*

## Description

This project comprises a System Administration exercise on Docker: virtualizing several Docker images, orchestrating them with Docker Compose and running them in a personal virtual machine.  
Services orchestrated:
 - Wordpress website
 - MariaDB: Wordpress database
 - Redis: Wordpress caching
 - FTP Server: access to Wordpress content
 - Static Website
 - Adminer: UI MariaDB control
 - Portainer: UI Docker 
 - NGINX Server

## Instructions

1. Configure a Ubuntu 22.04 LTS Virtual Machine.
2. Install Docker and Docker Compose. 
3. Clone this repository.
4. Run ```make setup-env``` from the root of this repository to setup the necesary environemnt variables and secret files.
5. Run ```make``` from the root of this repository.
6. You're done! :)

## Resources

### Docker
- [Network Chuck - Docker Tutorials](https://www.youtube.com/watch?v=dH3DdLy574M&list=PLIhvC56v63IJlnU4k60d0oFIrsbXEivQo)  
- [TechWorld with Nana - Docker Tutorial for Beginners](https://www.youtube.com/watch?v=3c-iBn73dDE&t=2886s&pp=ygUGZG9ja2Vy)    
- [Codecademy - Working with Containers: Introduction to Docker](https://www.codecademy.com/learn/ext-courses/working-with-containers-introduction-to-docker)  
- [DockerDocs](https://docs.docker.com/)  

### Services
- [VSFTPD Documentation](https://security.appspot.com/vsftpd/vsftpd_conf.html)  
- [MariaDB Documentation](https://mariadb.com/docs)  
- [NGINX Documentation](https://nginx.org/en/docs/index.html)  
- [Portainer Documentation](https://docs.portainer.io/)  
- [Redis Open Source Documentation](https://redis.io/docs/latest/operate/oss_and_stack/)  
- [Hugo Documentation](https://gohugo.io/documentation/)  
- [Wordpress CLI Documentation](https://developer.wordpress.com/docs/developer-tools/wp-cli/overview/)  

AI was used at different stages in this project. First, to get an introduction of the relevant concepts and technologies. Second, to search for relevant existing online resources. Third, to help solve concrete implementation issues.

## Project Description

### What is Docker?

- Docker is an open-source platform that allows one to package, distribute and run applications in isolated environments called containers. It makes it easy to build consistent setups that work the same on any machine.

### What are Docker Containers?

- Docker Containers are lightweight, standalone, executable packages that include everything an application needs to run: code, runtime, libraries and configuration. They run in isolation but share the host machine's kernel, making them much faster and more efficient than Virtual Machines.

### What are Docker Images and how do they relate to Docker Containers?

- **Docker Images** are **static, immutable blueprint (like a recipe)**. It's a lightweight, standalone package containing the application code, runtime, libraries, dependencies, and configuration needed to run a container. Images are built from a Dockerfile and stored in registries (e.g. Docker Hub). They are read-only and don't change once built.
- **Docker Containers** are a **running or stopped instance of an image**. When one runs ```docker run <image>```, Docker creates a container by adding a writable layer on top of the image's read-only layers. This allows the app to execute, store temporary data and interact with the system. 

### What is Docker Compose?

- Docker Compose is a tool that enables one to define and manage multi-container applications using a single YAML file (e.g. ```srcs/docker-compose.yml```). It describes all services (containers), their networks, volumes, environment variables, dependencies and starts/stops everything with simple commands like ```docker compose up```.

### What are Docker Volumes?

- Persistent storage for containers. Containers are ephemeral by default (data disappears when they stop), but volumes allow data to survive container restarts or removals.
- In this project **bind mounts** (a type of volume) link host directories (e.g. ```/home/${LOGIN}/data/wordpress```) to paths inside containers so files like Wordpress content or database files persist on the host.
- Bind mounts differ from **default Docker volumes** in that they directly map a host path/file into the container. This allows more explicit control (one can see/edit files directly on the host), enables a quick access to said files, but it is also less portable, in that it is host-path dependent. Thus prone to potential permission and security issues if paths are misconfigured. 

### But can you give me an overview of all the Docker Volume types?

- **Volume**: Docker creates and manages storage in ```/var/lib/docker/volumes/```. Portable, easy to backup/share between containers and independent of host paths.
- **Bind mount**: directly maps a specific host file/directory into the container. Gives direct host access, but less portable and can have permission issues.
- **tmpfs mount**: stores data in host memory (not disk). Ephemeral, fast and secure for temporary/sensitive data (e.g. Docker secrets). Data vanishes when container stops.
- **Anonymous volumes**: unnamed, auto-created volumes (e.g. via ```-v /path``` without name). Useful for temporary persistence but harder to manage.

### What are Docker Networks?

- Virtual networks that allow containers to communicate securely with each other while isolating them from the outside world (unless exposed). In this project a **bridge network** was used to let services like Wordpress talk to MariaDB by hostname, without exposing ports to the host unless where strictly necessary.
- This is different, say, from using a **host network**, where there would be no isolation, containers would listen on host ports/IP directly.

### But can you give me an overview of all the Docker Network types?

- **Bridge** (default): creates an isolated virtual network on a single host. Containers on the same bridge network can communicate via IP or service names. Ideal for multi-container apps on one machine. Provides NAT for external access via port publishing

- **Host**: removes network isolation - the container uses the host's network directly. No port mapping needed, better performance, but less secure. Port conflicts possible. Good for maximum performance on a single host.

- **None**: disables all networking for the container (loopback only). Useful for standalone or highly isolated processes.

- **Overlay**: for multi-host networking in Docker Swarm or Kubernetes. Allows containers on different hosts to communicate securely as if on the same network.

- **Macvlan**: assigns a unique MAC address to the container, making it appear as a physical device on the network. Containers get direct access to the underlying network (bypasses host NAT). Suited for apps needing direct LAN integration.

- **IPvlan**: Similar to Macvlan but shares the parent's MAC address while isolating at IP level. Better for scenarios needing many containers with IP control.

### Why Docker Containers and not multiple Virtual Machines?

1. Resource Efficiency

- Containers share the host operating system's kernel and only package the application, its dependencies and minimal libraries.
- They don't include a full guest OS like Virtual Machines do. 
- This means far less CPU, RAM and disk usage compared to spinning up the same services on different Virtual Machines, each with its own Operating System.

2. Faster Startup, Deployment and Scaling

- Containers boot in seconds - unlike Virtual Machines - because there's no full Operating System to initialize.
- With Docker Compose: a single ```docker compose up``` command builds, networks and starts everything in the correct order. Rebuilding is trivial.
- Virtual Machines require manual provisioning, networking setup and orchestration tools (e.g. separate scripts), making deployments slower and more error-prone.


3. Easier Management and Portability

- With Docker Compose: an entire stack (services, volumes, networks, env variables) are defined in one declarative file.
- This makes the setup reproducible across machines - one just has to share the YAML and .env, and anyone can replicate the declared environment.
- Volumes (bind-mounted to host paths like ```/home/${LOGIN}/data/...```) persist data efficiently without VM disk images.
- With Virtual Machines: one would need to manage multiple machine images, guest OS updates, SSH access and inter-VM networking separately.

4. Easier Inter-Service Communication

- Services communicate over a shared Docker network with low-latency and direct container-to-container links.
- Virtual Machines often require complex virtual networking, adding, if not latency, configuration hassle, in the least.

5. Development and Testing Advantages

- Quick iteration: change a Dockerfile, rebuild one service without affecting others.
- Isolation per service without VM sepration.

### When would Virtual Machines still be preferable?

- When the applications need different kernels.
- When maximum, kernel-level isolation is required.

### Can you give me an overview of this project?

- ```Makefile``` to easily deploy or remove Docker containers through ```srcs/docker-compose.yml```.
- ```srcs/docker-compose.yml```: Docker Compose file describing all services (containers), their networks, volumes, environment variables, secrets and dependencies.
- ```srcs/tools/``` containing scripts to change host's ```/etc/hosts``` and programatiicaly setup the necessary secret files and environment variables.
- ```.env_mock```: template ```.env``` file designed to store all necessary environment variables passed into Docker Containers through ```srcs/docker-compose.yml```.
- Each services's folder under ```srcs/requirements```, for clarity and modularity, containing:
    - Dockerfile.
    - Config files, if applicable, under ```conf/```
    - Scripts, if applicable, under ```tools/```
    - ```static-website``` also contains ```public```: a ready to serve HUGO static website.
- Existing services:
    - Mandatory:
        - ```wordpress```: PHP-FPM and Wordpress
        - ```mariadb```: MariaDB
        - ```nginx```: NGINX with TLS
    - Bonus:
        - ```redis```: Redis for Wordpress caching
        - ```adminer```: UI Maria DB control
        - ```ftp```: FTP Server to Wordpress content
        - ```static-site```: Static HUGO portfolio website
        - ```portainer```: UI Docker control
- Docker bind mounts to be created at ```/home/$(LOGIN)/data/<service>``` for the volumes wp_data, db_data, redis_data, static_site, portainer_data. Directories automatically created, if not existent, through ```make```.
- Containers linked through a Docker bridge network (named ```inception```). Only the ports 443 (HTTPS), 21 and 40000-40099 (FTP) are exposed to the host.


### Why use Environment Variables and not Secrets?

- **Environment variables** (set via environment or env_file) are injected directly into the container's environment. They are suitable for non-sensitive configuration (e.g., debug flags or ports) but risky for sensitive data like passwords or API keys, as they are visible in docker inspect, process listings (ps aux), and can accidentally leak into logs.
- **Secrets**, however, are designed for sensitive data: they are mounted as temporary in-memory files (typically at /run/secrets/<secret_name>) rather than environment variables, reducing exposure to other processes and avoiding leaks in logs or inspections.

