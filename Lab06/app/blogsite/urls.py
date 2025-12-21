from django.contrib import admin
from django.urls import path, include
from django.views.generic import RedirectView

urlpatterns = [
    path("", RedirectView.as_view(url="/blog/", permanent=False)),
    path("admin/", admin.site.urls),
    path("blog/", include("blog.urls")),
]
