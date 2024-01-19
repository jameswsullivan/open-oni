## Updates to `docker-compose.yml`
- Renamed `docker-compose.yml` to `compose.yaml`.
- Deleted `docker-compose.override.yml` and `test-compose.yml`.
- Added `manager` service for files and directories preparation and troubleshooting, without having to use the `web` container. See `manager.dockerfile` and `manager-entrypoint.sh`.
- Removed deprecated `--links`, changed to `docker network` instead.
- Changed from mounting local directories to using `docker volumes` for persistent data.
    - solr_data: solr
    - mysql_data: mysql
    - web_appdata: `/opt/openoni`
    - web_batches: `/opt/openoni/data/batches`
    - web_themes: `/opt/openoni/themes`
    - web_featured_content: `/opt/openoni/onisite/plugins/featured_content`
- Copied Open ONI files into the container (see `manager.dockerfile`) during build time instead of directly mounting the repo directory to the `web` container.
- Removed `MariaDB`, changed to `ubuntu/mysql` instead.
- Changed from `solr:8-slim` to use latest solr.
- Renamed images; added container names; rewrote dockerfiles: `web.dockerfile`, `mysql.dockerfile`, `manager.dockerfile`.
- Added the following environment varialbes to `web.dockerfile`:
    - `ENV OPENONI_INSTALL_DIR="/opt/openoni"`
    - `ENV ENTRYPOINT_SCRIPT_PATH="${OPENONI_INSTALL_DIR}/web-entrypoint.sh"`
- Added the following environment variables to the `web` service for quick site customization:
    - `YOUR_CUSTOM_SITE_TITLE`
    - `YOUR_CUSTOM_PROJECT_NAME`
    - `YOUR_CUSTOM_FROM_EMAIL`
    - `YOUR_CUSTOM_EMAIL_SUBJECT_PREFIX`
    - `YOUR_CUSTOM_THEME_NAME`
- Added `YOUR_CUSTOM_THUMBNAIL_SIZE` environment variable to quickly change thumbnail size in `/opt/openoni/onisite/settings_local_example.py`.

## Embedded Sample Batches
- Repo: https://github.com/open-oni/sample-data .
- Placed `batch_dlc_manyyears_ver01`, `batch_mnhi_german_ver01`, `batch_nbu_manyissues_ver01` into `/opt/openoni/data/batches` directory.

## Embedded Featured Content Plugin
- Plugin Repo: https://github.com/open-oni/plugin_featured_content
- The `v0.7.0` (commit: `72003cc`) is currently used.
- Added the generic home page welcome text to `templates/featured_example.html`.

### Featured Content

#### Plugin Instalation (The plugin has already been included and configured. The steps are for reference only).
```
cd /opt/openoni/onisite/plugins
git clone https://github.com/open-oni/plugin_featured_content.git featured_content

cd featured_content/
git checkout v0.7.0

cp config_example.py config.py

cp templates/featured_example.html templates/featured.html
```

#### Plugin Configuration (`/opt/openoni/onisite/plugins/featured_content/config.py`)

**Random Selection (Configured by default)**
```
RANDOM = True
NUMBER = 4      # number of results that will be returned
```


**On This Day (Requires `RANDOM` to be set to `False`.)**
```
RANDOM = False
THISDAY = True
MINYEAR = 1750   # earliest year to search for "on this day"
MAXYEAR = 2000   # latest year to search for "on this day"
NUMBER = 4       # number of results that will be returned
```

**User Selection** (Requires `RANDOM` and `THISDAY` to be set to `False`.)
```
RANDOM = False
THISDAY = False
NUMBER = 4
PAGES = (
  {
      'lccn': 'sn83045350',
      'date': '1878-01-03',
      'edition': 1,
      'sequence': 1,
      'caption': 'Put a caption for your newspaper here'
  },
  {
      'lccn': 'sn83045350',
      'date': '1878-01-03',
      'edition': 1,
      'sequence': 2,
      'caption': 'This is the second page of an issue'
  },
)
```

If you enter more `PAGES` than your max `NUMBER`, a subset will be selected randomly (each day) from your featured set. You can get the information for lccn, date, edition, and sequence from the URL for an individual page (e.g. http://newspapers.uni.edu/lccn/sn83045350/1878-01-03/ed-1/seq-1/).

- `edition` will typically always be 1, unless if the paper has morning and evening runs, etc.
- `sequence` refers to the page number, so 1 is also a good choice if you want the front page of a particular day.

#### Open ONI Site Configuration

Modify the `/opt/openoni/onisite/urls.py` as follows:

**Before**
```
from django.urls import include, path, re_path

urlpatterns = [
  path('', include("core.urls")),
]
```

**After**
```
from django.urls import include, path, re_path
from onisite.plugins.featured_content import views as fc_views

urlpatterns = [
  re_path(r'^$', fc_views.featured, name="featured_home"),
  re_path(r'^featured_content/', include("onisite.plugins.featured_content.urls")),
  path('', include("core.urls")),
]
```

Modifications to the `/opt/openoni/onisite/settings_local.py` file is detailed in the next section below.

## Changes to Scripts
- Changes to `entrypoint.sh`:
    - Renamed `entrypoint.sh` to `web-entrypoint.sh`.
    - Defined variable `OPENONI_INSTALL_DIR="/opt/openoni"`.
- Created `batch_load_batches.sh` script to automatically load newspaper batches. A text file (`batch_names.txt`) that contains a list of batch names needs to be created for the script to work properly.
- Added `compile_themes.sh` to quickly compile themes into static files.
- Fixed `Unexpected Error` issue (due to change of permissions on the django cache tmp files at `/var/tmp/django_cache`) after loading batches.
- Changes to `_startup_lib.sh`:
    - Reduced database retries (`MAX_TRIES=2`) from 30 to 2.
    - Removed test database setup.
    - Modified database connection string in `setup_database()` function to use environment variables: `! mysql -u${ONI_DB_USER} -h${ONI_DB_HOST} -p${ONI_DB_PASSWORD}`.
- Changes have been made in `/opt/openoni/onisite/settings_local_example.py`, `/opt/openoni/onisite/urls.py`, and `/opt/openoni/onisite/plugins/featured_content/config_example.py` to include configurations for the `Featured Content` plugin.

#### Changes to `/opt/openoni/onisite/settings_local_example.py`:
```
YOUR_CUSTOM_THEME = os.getenv('YOUR_CUSTOM_THEME_NAME', 'default')
THUMBNAIL_WIDTH = os.getenv('YOUR_CUSTOM_THUMNAIL_SIZE', 240)

if YOUR_CUSTOM_THEME != 'default':
    INSTALLED_APPS = (
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        'django.contrib.humanize',
        'onisite.plugins.featured_content',
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
        'onisite.plugins.featured_content',
        'themes.default',
        'core',
    )

DEFAULT_FROM_EMAIL = os.getenv('YOUR_CUSTOM_FROM_EMAIL', 'no-reply@mydomain.com')
EMAIL_SUBJECT_PREFIX = os.getenv('YOUR_CUSTOM_EMAIL_SUBJECT_PREFIX', 'YOUR_EMAIL_SUBJECT_PREFIX')

SITE_TITLE = os.getenv('YOUR_CUSTOM_SITE_TITLE', 'YOUR_PROJECT_NAME')
PROJECT_NAME = os.getenv('YOUR_CUSTOM_PROJECT_NAME', 'YOUR_PROJECT_NAME')
```

## Removed Files
- Deleted `./docker/mysql/` and `./docker/mysql/openoni.dev.cnf`.