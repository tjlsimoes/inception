### What prerequisites do I need to have in place to run this project?

1. Set up a Virtual Machine capable of running Docker and Docker Compose.
2. Add this repository to the Virtual Machine. Possibilities:
    - SCP to transfer files into the Virtual Machine.
    - Git Clone into the Virtual Machine.
    - Create a Shared Folder with the Virtual Machine.
3. Rename ```srcs/.env_mock``` to ```srcs/.env``` and fill out with desired values. Create all the necessary secret files under  a directory at the root of the project named ```secrets```. The files ought to be named (see more information on [managing credentials](./USER_DOC.md#where-are-all-the-credentials-defined)):
- ftp_password.txt
- mysql_user.txt
- ftp_user.txt
- portainer_admin_password.txt
- mysql_database.txt
- wp_secondary_user_email.txt
- mysql_email.txt
- wp_secondary_user_password.txt
- mysql_password.txt
- wp_secondary_user.txt
- mysql_root_password.txt


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

### Where can I find more information on the multiple services' configurations?

[Here](https://common-pansy-255.notion.site/Inception-Services-2d7d125662db801699dbe06217f7a5ba?pvs=74)!

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

```make setup```, part of ```make all```
- Configures the necessary entries on ```/etc/hosts``` for custom DNS resolution .

---

```make reset-data```
- Deletes the persisted volumes on the host.

---

```make setup-env```
- Adds the necessary .env and secrets' files from environment variables or default values.

---

```docker system prune -af --volumes```
- Agressively cleans Docker system:
    - ```-a```: removes all unused images
    - ```-f```: no confirmation
    - ```-volumes```: removes all unused volumes