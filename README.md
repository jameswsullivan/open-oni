# Open ONI (Customized)

## Original Project

- This repo is forked from the [open-oni](https://github.com/open-oni/open-oni) project.
- See the [original readme here](https://github.com/open-oni/open-oni/blob/dev/README.md)

## Improvements and Modifications

1. docker-compose.yml:
- Rename `docker-compose.yml` to `compose.yaml`.
- Delete docker-compose.override.yml and test-compose.yml.
- Add `manager` service for files and directories preparation and troubleshooting, without having to use the web container. See `manager.dockerfile` and `manager-entrypoint.sh`.
- Remove deprecated `--links`, changed to `docker network` instead.
- Change from using local directories to using docker volumes for persistent data.
    - solr_data: solr
    - mysql_data: mysql
    - web_appdata: `/opt/openoni`
    - web_batches: `/opt/openoni/data/batches`
    - web_themes: `/opt/openoni/themes`
- Copy Open ONI files into the container (see manager.dockerfile) during build time instead of directly mounting the repo directory to any containers.
- Remove MariaDB, change to ubuntu/mysql instead.
- Change from solr:8-slim to latest solr (solr 9).
- Rename images; add container names; rewrite dockerfiles: `web.dockerfile`, `mysql.dockerfile`, `manager.dockerfile`.
- Add Environment Varialbes to `web.dockerfile`:
    - `ENV OPENONI_INSTALL_DIR="/opt/openoni"`
    - `ENV ENTRYPOINT_SCRIPT_PATH="${OPENONI_INSTALL_DIR}/web-entrypoint.sh"`
- Add environment variables for site customization:
    - `YOUR_CUSTOM_SITE_TITLE`
    - `YOUR_CUSTOM_PROJECT_NAME`
    - `YOUR_CUSTOM_FROM_EMAIL`
    - `YOUR_CUSTOM_EMAIL_SUBJECT_PREFIX`
    - `YOUR_CUSTOM_THEME_NAME: `

2. Embedded sample batches into the project:
- Repo: https://github.com/open-oni/sample-data .
- Place "batch_dlc_manyyears_ver01, batch_mnhi_german_ver01, batch_nbu_manyissues_ver01" into "/opt/openoni/data/batches" directory.

3. Changes to scripts:
- Changes to `entrypoint.sh`:
    - Rename `entrypoint.sh` to `web-entrypoint.sh`.
    - Define variable `OPENONI_INSTALL_DIR="/opt/openoni"`.
- Create `batch_load_batches.sh` script to automate the batches loading process. A text file (batch_names.txt) that containers a list of batch names need to be created for the script to work.
- Add `configure_permissions.sh` script to modify permissions on the `solr` and `data` directories and the `entrypoint.sh` file, and verify permissions with `ls`.
- Add `compile_themes.sh` to quickly compile themes into static files.
- Fix "Unexpected Error" issue (due to change of permissions on the django cache tmp files at `/var/tmp/django_cache`) after loading batches.
- In "_startup_lib.sh":
    - Reduce database retries (MAX_TRIES=2) from 30 to 2.
    - Remove setting up a test database.
    - Modify database connection string in `setup_database()` function to use environment variables: `! mysql -u${ONI_DB_USER} -h${ONI_DB_HOST} -p${ONI_DB_PASSWORD}`.
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

## Working directory setup

- Mount volumes to paths (multiple read/write):
    - `/opt/openoni`
    - `/opt/openoni/data/batches`
    - `/opt/openoni/themes`
- When not using `docker compose`, the `manager` service has to be started first for necessary files to be copied into the `/opt/openoni` folder before the `web` service can successfully start.

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
cd /opt/openoni
source ENV/bin/activate
./batch_load_batches.sh
```

## Contact
I'm in the Open ONI Slack Channel.