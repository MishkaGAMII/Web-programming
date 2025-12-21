from django.urls import path
from . import views

urlpatterns = [
    path("", views.index, name="blog_index"),
    path("articles/", views.article_list, name="article_list"),
    path("articles/<int:pk>/", views.article_detail, name="article_detail"),
    path("categories/", views.category_list, name="category_list"),
]
