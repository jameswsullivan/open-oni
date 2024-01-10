# Open ONI (Customized)

## Original Project

- This repo is forked from the [open-oni](https://github.com/open-oni/open-oni) project.
- See the [original readme here](https://github.com/open-oni/open-oni/blob/dev/README.md)

## Improvements and Modifications

1. docker-compose.yml:
- Rename `docker-compose.yml` to `compose.yaml`.
- Delete docker-compose.override.yml and test-compose.yml.
- Add a "manager" service for troubleshooting without having to use the web container.
- Remove deprecated "--links", changed to "docker network" instead.
- Change from using local directories to using docker volumes for solr and mysql persistent data.
- Copy Open ONI files into the container (see web.dockerfile) during build time instead of directly mounting the repo directory to the web container.
- Remove MariaDB, change to ubuntu/mysql instead.
- Change from solr:8-slim to latest solr (solr 9).
- Rename images; add container names; rewrite dockerfiles: `web.dockerfile`, `mysql.dockerfile`, `manager.dockerfile`.
- Add two arguments `ENV OPENONI_SOURCE_DIR="/opt/openoni_source"` and `ENV OPENONI_INSTALL_DIR="/opt/openoni"` to `web.dockerfile`.

2. Embedded sample batches into the project:
- Repo: https://github.com/open-oni/sample-data .
- Place "batch_dlc_manyyears_ver01, batch_mnhi_german_ver01, batch_nbu_manyissues_ver01" into "/opt/openoni/data/batches" directory.

3. Changes to scripts:
- Add two variables to represent installation source and destination paths: `OPENONI_SOURCE_DIR = "/opt/openoni_source"` and `OPENONI_INSTALL_DIR = "/opt/openoni"`.
- Add `cp -a ${OPENONI_SOURCE_DIR}/* ${OPENONI_INSTALL_DIR}` to `entrypoint.sh` .
- Create `batch_load_batches.sh` script to automate the batches loading process. A text file (batch_names.txt) that containers a list of batch names need to be created for the script to work.
- Fix "Unexpected Error" issue (due to change of permissions on the django cache tmp files at `/var/tmp/django_cache`) after loading batches.
- In "_startup_lib.sh":
    - Reduce database retries (MAX_TRIES=2) from 30 to 2.
    - Remove setting up a test database.
    - Modify database connection string in `setup_database()` function to use environment variables: `! mysql -u${ONI_DB_USER} -h${ONI_DB_HOST} -p${ONI_DB_PASSWORD}`.
- Add `configure_permissions.sh` script to modify permissions on the `solr` and `data` directories and the `entrypoint.sh` file, and verify permissions with `ls`.
- Add four environment variables `YOUR_CUSTOM_SITE_TITLE`, `YOUR_CUSTOM_PROJECT_NAME`, `YOUR_CUSTOM_FROM_EMAIL`, `YOUR_CUSTOM_EMAIL_SUBJECT_PREFIX`.
- Modify `./onisite/settings_local_example.py` to use the the four environment variables for site customization.
```
YOUR_CUSTOM_THEME = os.getenv('YOUR_CUSTOM_THEME_NAME', 'default')

if YOUR_CUSTOM_THEME != 'default':
    INSTALLED_APPS = (
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        'django.contrib.humanize',
        f'themes.{YOUR_CUSTOM_THEME}',
        'themes.default',
        'core',
    )
else:
    INSTALLED_APPS = (
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        'django.contrib.humanize',
        'themes.default',
        'core',
    )

DEFAULT_FROM_EMAIL = os.getenv('YOUR_CUSTOM_FROM_EMAIL', 'no-reply@mydomain.com')
EMAIL_SUBJECT_PREFIX = os.getenv('YOUR_CUSTOM_EMAIL_SUBJECT_PREFIX', 'YOUR_EMAIL_SUBJECT_PREFIX')

SITE_TITLE = os.getenv('YOUR_CUSTOM_SITE_TITLE', 'YOUR_PROJECT_NAME')
PROJECT_NAME = os.getenv('YOUR_CUSTOM_PROJECT_NAME', 'YOUR_PROJECT_NAME')
```

4. File removals:
- Deleted "./docker/mysql/" and "./docker/mysql/openoni.dev.cnf".

## Start and stop an Open ONI instance with "docker compose"

**Start Instance**
```
docker compose up -d
```

**Stop Instance**
```
docker compose down
or
docker compose down -v
```

**Auto load batches**
```
docker exec -it openoni-web bash
source ENV/bin/activate
./batch_load_batches.sh
```

## Contact
I'm in the Open ONI Slack Channel.