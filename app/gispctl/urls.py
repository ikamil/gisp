"""ecom-queue URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path, re_path
from django.views.static import serve
from django.conf import settings
from django.views.generic.base import RedirectView
from django.http import HttpResponseRedirect
from main.views import *


favicon_view = RedirectView.as_view(url='/static/main/favicon.ico', permanent=True)
admin.site.site_header = 'ГИСП Панель управления'
admin.site.index_title = ('ГИСП')
admin.site.site_title = ('ГИСП администрирование')


def home(request):
    return HttpResponseRedirect('/admin')


urlpatterns = [
    # path('grappelli/', include('grappelli.urls')), # grappelli URLS
    path('admin/', admin.site.urls),
    re_path(r'^favicon\.ico$', favicon_view),
    path('', home),
    re_path(r'^set/[a-z]+$', setdata),
    re_path(r'^uploads/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT}),
]
