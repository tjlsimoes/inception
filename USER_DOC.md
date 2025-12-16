### What services are provided?

 - Wordpress website
 - MariaDB: Wordpress database
 - Redis: Wordpress caching
 - FTP Server: access to Wordpress content
 - Static Website
 - Adminer: UI MariaDB control
 - Portainer: UI Docker 
 - NGINX Server

### How can I start the project?

0. Be sure to have a vaild ```srcs/.env``` file built from the template ```srcs/.env_mock```.
1. Access the root of the project repository.
2. Run ```make```.
3. Enter sudo password if necessary.

### How can I check if the containers are running correctly?

- After having started the project, you can check if the containers are running as intended by running ```docker ps```.
- This will list all live containers. Their respective status should be ```healthy```.

### How can I stop the project? 

- Access the root of the project repository.
- Run ```make down```.
- This will stop all running services.
- It will **not** delete persisted Docker volumes or images.

### How can I access the relevant services through the browser?

- Ensure the project is started.
- Browser accessible services will be accessible at:
    - Wordpress website: <https://${DOMAIN_NAME}>, e.g. <https://tjorge-l.42.fr>
    - Portainer: <https://portainer.${DOMAIN_NAME}>
    - Adminer: <https://adminer.${DOMAIN_NAME}>
    - Static portfolio: <https://static.${DOMAIN_NAME}>

### Where are all the credentials defined?

- All credentials are defined on ```srcs/.env```.
