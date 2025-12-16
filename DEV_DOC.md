### What prerequisites do I need to have in place to run this project?

1. Set up a Virtual Machine capable of running Docker and Docker Compose.
2. Add this repository to the Virtual Machine. Possibilities:
    - SCP to transfer files into the Virtual Machine.
    - Git Clone into the Virtual Machine.
    - Create a Shared Folder with the Virtual Machine.
3. Rename ```srcs/.env_mock``` to ```srcs/.env``` and fill out with desired values.


### How do I build and launch the project?

- You can build the project by simply running ```make``` at the root of this repository.
- Alternatively you can also call ```docker compose -f <path to docker-compose.yml at srcs/> up -d --build```.
- If you follow this alternative, be sure
    - To update ```/etc/hosts``` with the necessary DNS resolution for 127.0.0.1:
        - $DOMAIN_NAME
        - static.$DOMAIN_NAME
        - adminer.$DOMAIN_NAME
        - portainer.$DOMAIN_NAME
    - To create the necessary directories for the persistence of the Docker volumes:
        - /home/$(LOGIN)/data/wordpress
        - /home/$(LOGIN)/data/mariadb
        - /home/$(LOGIN)/data/redis
        - /home/$(LOGIN)/data/static_site
        - /home/${LOGIN}/data/portainer

### Are there any Docker commands that I would be better off knowing?

To access a container's bash shell: ```docker exec -it <container_name> bash ```

To check the logs of a container: ```docker logs <container_name>```  

---

```docker compose -f srcs/docker-compose.yml up -d --build```, part of ```make up```:
- ```--build```: Forces rebuilding of all custom images (mariadb, wordpress, nginx, etc.)
- ```-d```: Runs containers in detached (background) mode
- ```up```: Creates and starts all services defined in docker-compose.yml

---

```docker compose -f srcs/docker-compose.yml down```, a.k.a ```make down```
- Stops and removes all containers and the custom network (inception) defined in the compose file
- Does NOT remove volumes or images

---

```docker volume rm $(docker volume ls -q) 2>/dev/null || true```, part of ```make clean```:
- Remove **all** Docker volumes **on the system**
- Note that Docker volumes removal does not delete the persisted volumes at ```/home/$(LOGIN)/data/*```. To do so you can run ```make reset-data``` from the root of the project. 

---

```docker system prune -af --volumes```
- Agressively cleans Docker system:
    - ```-a```: removes all unused images
    - ```-f```: no confirmation
    - ```-volumes```: removes all unused volumes