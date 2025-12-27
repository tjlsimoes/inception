### What services are provided?

 - Wordpress website
 - MariaDB: Wordpress database
 - Redis: Wordpress caching
 - FTP Server: access to Wordpress content
 - Static Website
 - Adminer: UI MariaDB control
 - Portainer: UI Docker control
 - NGINX Server

### How can I start the project?

0. Be sure to have a valid ```srcs/.env``` file built from the template ```srcs/.env_mock``` and to have all the necessary secrets under ```./secrets```. See more information below on [managing credentials](#where-are-all-the-credentials-defined).
1. Access the root of the project repository.
2. Run ```make```.
3. Enter sudo password if necessary.

### How can I check if the containers are running correctly?

- After having started the project, you can check if the containers are running as intended by running ```docker ps```.
- This will list all live containers. Their respective status should be ```healthy```. There should be one container per service.

### How can I stop the project? 

- Access the root of the project repository.
- Run ```make down```.
- This will stop all running services.
- It will **not** delete persisted Docker volumes or images.

### How can I access the relevant services through the browser?

- Ensure the project is started.
- Browser accessible services will be accessible at:
    - Wordpress website: <https://${DOMAIN_NAME}>, e.g. <https://tjorge-l.42.fr>
	- Wordpress administration website: <https://${DOMAIN_NAME}/wp-admin.php>
    - Portainer: <https://portainer.${DOMAIN_NAME}>
    - Adminer: <https://adminer.${DOMAIN_NAME}>
    - Static portfolio: <https://static.${DOMAIN_NAME}>

### Where are all the credentials defined?

- All credentials are defined on ```srcs/.env``` and under individual files under ```./secrets```.
- You can create or manage the necessary credentials with the script ```./srcs/tools/setup-env.sh```. This uses environment variables or default values to setup the necessary configurations.
- You can run ```make setup-env``` **prior to any make** to setup the necessary configurations.
- This is the list of environment variables you can specify to manage the necessary credentials:

	- LOGIN e.g. tjorge-l
	- DOMAIN_NAME e.g. tjorge-l.42.fr  

	--- 

	- MYSQL_DATABASE e.g. inception_db
	- MYSQL_ROOT_PASSWORD e.g. even_longer_root_password_42
	- MYSQL_USER e.g. wp_user
	- MYSQL_PASSWORD e.g. this_is_a_very_long_password_42
	- MYSQL_EMAIL e.g. tjorge-l@gmail.com

	---

	- WP_SECONDARY_USER e.g.commenter
	- WP_SECONDARY_USER_EMAIL e.g. commenter@example.com
	- WP_SECONDARY_USER_PASSWORD e.g. another_secure_pass456

	---

	- FTP_USER e.g. ftpuser
	- FTP_PASS e.g. strongpasswordhere

	---
	- *Portainer user is set to **admin***
	- PORTAINER_ADMIN_PASSWORD e.g. YourSecurePassword123!
- It goes without saying that if you change any of these configurations, they will only take place if you rebuild the containers and their respective volumes. This includes removing the persisted volumes under /```home/<LOGIN>/data/```.

