Static Pages ONI plugin
===

Provides the ability to drop HTML files into a special directory and have ONI
serve them up at an arbitrary URL

Compatibility
---

The "main" branch should not be considered stable.  Unlike the core Open ONI
repository, plugins don't warrant the extra overhead of having separate
development branches, release branches, etc.  Instead, it is best to find a tag
that works and stick with that tag.

- Static Pages v2.0.2 and prior only work with Python 2 and Django 1.11 and
  prior
  - Therefore these versions of the Static Pages plugin are only compatible up
    to (and including) ONI v0.11.0
- Static Pages releases starting at v3.0.0 require Python 3 and Django 2.2.  If you
  need this plugin to work with ONI v0.11.0 or prior, stick with v2.0.2.

Usage
---

Download the repository into the Open ONI's `onisite/plugins` directory as `staticpages`:

    git clone https://github.com/open-oni/plugin_staticpages.git onisite/plugins/staticpages

Add the plugin to your `INSTALLED_APPS` list:

```python
# onisite/settings_local.py

INSTALLED_APPS = (
    'django.contrib.humanize',
    'django.contrib.staticfiles',

    'onisite.plugins.staticpages',
    'themes.default',
    'core',
)

```

And add the plugin's URLs to your urlpatterns.  You can choose any prefix you
like, but we use `static/` below:

```python
# onisite/urls.py

from django.urls import include, path, re_pathfrom django.conf.urls import url, include

urlpatterns = [
  re_path(r'^static/', include("onisite.plugins.staticpages.urls")),

  # keep this last or else urls from core may override custom urls
  path('', include("core.urls")),
]
```

Drop static HTML into staticpages/pages, formatted similarly to [pages/example.html](pages/example.html).

You can add links to any page in your templates with this named path:

```python
<a href="{% url 'static_pages_page' 'example' %}">Example Static Page</a>
```

Settings
---

If you need your HTML files to come from a different location, you can alter
your settings file (`onisite/settings_local.py`) to include a path to the new
location, e.g.:

    STATIC_PAGES_PATH="/opt/openoni/themes/oregon/staticpages"
