import os
import re
import warnings

from django.shortcuts import render
from django import template
from django.http import Http404, HttpResponse
from django.conf import settings

# Prefix and Suffix define constant strings we use when rendering any static page
Prefix = "{% extends '__l_main.html' %}{% load static %}{% block subcontent %}<div id=\"std_box\">"
Suffix = "</div><!-- end id:std_box -->\n{% endblock subcontent %}"

def page(request, pagename):
    return subpage(request, None, pagename)

def subpage(request, subdir, pagename):
    # Strip off pagename's optional slash
    if pagename[-1] == "/":
        pagename = pagename[:-1]

    # Check for the existence of, and then read, the requested template
    if hasattr(settings, "STATIC_PAGES_PATH"):
        pagespath = settings.STATIC_PAGES_PATH
    else:
        pagespath = os.path.dirname(os.path.abspath(__file__))
        pagespath = os.path.join(pagespath, "pages")

    if subdir is not None:
        pagefile = os.path.join(pagespath, subdir, pagename + ".html")
    else:
        pagefile = os.path.join(pagespath, pagename + ".html")

    if not os.path.exists(pagefile):
        warnings.warn("Attempt to render nonexistent page %s (file: %s)" % (pagename, pagefile))
        raise Http404

    text = open(pagefile, "rb").read().decode('utf8').split("\n")
    page_title = text[0]
    body = "\n".join(text[2:])

    tmpl = template.Template(Prefix + body + Suffix)
    c = template.RequestContext(request, {"page_title": page_title})
    return HttpResponse(tmpl.render(c))
