from django.urls import include, path, re_path
from onisite.plugins.staticpages import views

urlpatterns = [
    re_path(r'^(?P<pagename>[\w-]+/?)$', views.page, name="static_pages_page"),
    re_path(r'^(?P<subdir>[\w-]+)/(?P<pagename>[\w-]+/?)$', views.subpage, name="static_pages_subpage"),
]
