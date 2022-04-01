# preview

* This project is a dockerized version of Laravel, which tries to solve problems related to permissions, queues, and cronjobs.

# run & installation

1. Rename .env.example to .env, then fill it. For getting UID and GID, run the following commands.
```shell
    id -u #UID
    id -g #GID
```

2. Run this command to install the dependencies:
```shell
    docker-compose run --rm composer install
    docker-compose run --rm composer run-script post-root-package-install
    docker-compose run --rm composer run-script post-create-project-cmd
```

3. Use the following command to execute artisan commands
```shell
    docker-compose run --rm artisan 
```

3. To add a queue, change `docker/configs/supervisord.conf` like the example.

4. Use the following command to launch the project:

```shell
    docker-compose up --build -d
```
