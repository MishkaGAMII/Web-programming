#!/usr/bin/env bash
set -e

mkdir -p nginx
mkdir -p app/blog/templates/blog
mkdir -p app/blog/static/blog

# ---------- .env ----------
cat > .env <<'EOF'
DJANGO_SECRET_KEY=change-me
DJANGO_DEBUG=1
ALLOWED_HOSTS=localhost,127.0.0.1

DB_NAME=blogdb
DB_USER=admin
DB_PASS=adminpass
DB_ROOT_PASS=rootpass
DB_HOST=db
DB_PORT=3306
EOF

# ---------- requirements.txt ----------
cat > requirements.txt <<'EOF'
Django>=5.0,<6.0
uvicorn[standard]>=0.30
PyMySQL>=1.1
EOF

# ---------- Dockerfile ----------
cat > Dockerfile <<'EOF'
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY app /app

CMD sh -c "python manage.py makemigrations && python manage.py migrate && python manage.py collectstatic --noinput && uvicorn blogsite.asgi:application --host 0.0.0.0 --port 8000"
EOF

# ---------- docker-compose.yml ----------
cat > docker-compose.yml <<'EOF'
services:
  db:
    image: mysql:8.0
    container_name: mysql_db
    restart: unless-stopped
    env_file: .env
    environment:
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASS}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASS}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  web:
    build: .
    container_name: django_web
    restart: unless-stopped
    env_file: .env
    depends_on:
      - db
    volumes:
      - static_volume:/app/staticfiles
      - media_volume:/app/media
    expose:
      - "8000"

  nginx:
    image: nginx:latest
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - static_volume:/static
      - media_volume:/media
    depends_on:
      - web

volumes:
  mysql_data:
  static_volume:
  media_volume:
EOF

# ---------- nginx/default.conf ----------
cat > nginx/default.conf <<'EOF'
server {
  listen 80;

  location /static/ {
    alias /static/;
  }

  location /media/ {
    alias /media/;
  }

  location / {
    proxy_pass http://web:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
EOF

# ---------- blog urls/views/templates/static ----------
cat > app/blog/urls.py <<'EOF'
from django.urls import path
from . import views

urlpatterns = [
    path("", views.index, name="blog_index"),
    path("articles/", views.article_list, name="article_list"),
    path("articles/<int:pk>/", views.article_detail, name="article_detail"),
    path("categories/", views.category_list, name="category_list"),
]
EOF

cat > app/blog/views.py <<'EOF'
from django.shortcuts import render, get_object_or_404, redirect
from django.utils import timezone
from .models import Article, Category, Comment

def index(request):
    articles = (Article.objects
                .filter(is_published=True, publication_date__lte=timezone.now())
                .order_by("-publication_date")[:3])
    return render(request, "blog/index.html", {"articles": articles})

def article_list(request):
    articles = (Article.objects
                .filter(is_published=True, publication_date__lte=timezone.now())
                .order_by("-publication_date"))
    return render(request, "blog/article_list.html", {"articles": articles})

def article_detail(request, pk: int):
    article = get_object_or_404(Article, pk=pk, is_published=True)
    if request.method == "POST":
        author = (request.POST.get("author") or "").strip()
        text = (request.POST.get("text") or "").strip()
        if author and text:
            Comment.objects.create(article=article, author=author, text=text)
        return redirect("article_detail", pk=article.pk)

    comments = article.comments.order_by("-publication_date")
    return render(request, "blog/article_detail.html", {"article": article, "comments": comments})

def category_list(request):
    categories = Category.objects.order_by("title")
    return render(request, "blog/category_list.html", {"categories": categories})
EOF

cat > app/blog/models.py <<'EOF'
from django.db import models

class Category(models.Model):
    title = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=80, blank=True)

    def __str__(self):
        return self.title

class Tag(models.Model):
    title = models.CharField(max_length=80, unique=True)

    def __str__(self):
        return self.title

class Article(models.Model):
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=120)
    text = models.TextField()
    image = models.URLField(blank=True)
    publication_date = models.DateTimeField()
    is_published = models.BooleanField(default=False)

    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name="articles")
    tags = models.ManyToManyField(Tag, blank=True, related_name="articles")

    def __str__(self):
        return self.title

class Comment(models.Model):
    text = models.TextField()
    author = models.CharField(max_length=120)
    publication_date = models.DateTimeField(auto_now_add=True)
    article = models.ForeignKey(Article, on_delete=models.CASCADE, related_name="comments")

    def __str__(self):
        return f"{self.author}: {self.text[:30]}"
EOF

cat > app/blog/admin.py <<'EOF'
from django.contrib import admin
from .models import Category, Tag, Article, Comment

admin.site.register(Category)
admin.site.register(Tag)
admin.site.register(Article)
admin.site.register(Comment)
EOF

cat > app/blog/templates/blog/base.html <<'EOF'
{% load static %}
<!DOCTYPE html>
<html lang="uk">
<head>
  <meta charset="UTF-8">
  <title>{% block title %}Blog{% endblock %}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
  <link rel="stylesheet" href="{% static 'blog/style.css' %}">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="/blog/"><i class="fa-solid fa-pen-nib"></i> Blog</a>
    <div class="navbar-nav">
      <a class="nav-link" href="/blog/">Home</a>
      <a class="nav-link" href="/blog/articles/">Articles</a>
      <a class="nav-link" href="/blog/categories/">Categories</a>
      <a class="nav-link" href="/admin/">Admin</a>
    </div>
  </div>
</nav>
<div class="container my-4">
  {% block content %}{% endblock %}
</div>
</body>
</html>
EOF

cat > app/blog/templates/blog/index.html <<'EOF'
{% extends "blog/base.html" %}
{% block title %}Home{% endblock %}
{% block content %}
<h2 class="mb-3">Останні 3 статті</h2>
{% if articles %}
  <div class="row g-3">
    {% for a in articles %}
      <div class="col-12 col-md-6 col-lg-4">
        <div class="card h-100">
          {% if a.image %}
            <img src="{{ a.image }}" class="card-img-top" alt="img">
          {% endif %}
          <div class="card-body">
            <div class="small text-muted">{{ a.publication_date }}</div>
            <h5 class="card-title">{{ a.title }}</h5>
            <div class="small">by {{ a.author }}</div>
            <a class="btn btn-primary mt-2" href="/blog/articles/{{ a.id }}/">Read</a>
          </div>
        </div>
      </div>
    {% endfor %}
  </div>
{% else %}
  <div class="alert alert-warning">Немає опублікованих статей.</div>
{% endif %}
{% endblock %}
EOF

cat > app/blog/templates/blog/article_list.html <<'EOF'
{% extends "blog/base.html" %}
{% block title %}Articles{% endblock %}
{% block content %}
<h2 class="mb-3">Усі опубліковані статті</h2>
{% if articles %}
  <div class="list-group">
    {% for a in articles %}
      <a class="list-group-item list-group-item-action" href="/blog/articles/{{ a.id }}/">
        <div class="d-flex justify-content-between">
          <div>
            <div class="fw-bold">{{ a.title }}</div>
            <div class="small text-muted">by {{ a.author }}</div>
          </div>
          <div class="small text-muted">{{ a.publication_date }}</div>
        </div>
      </a>
    {% endfor %}
  </div>
{% else %}
  <div class="alert alert-warning">Список порожній.</div>
{% endif %}
{% endblock %}
EOF

cat > app/blog/templates/blog/article_detail.html <<'EOF'
{% extends "blog/base.html" %}
{% block title %}Article{% endblock %}
{% block content %}
<div class="mb-3">
  <div class="small text-muted">{{ article.publication_date }} • by {{ article.author }}</div>
  <h2 class="mb-2">{{ article.title }}</h2>

  {% if article.category %}
    <div class="badge bg-secondary mb-2">
      {% if article.category.icon %}<i class="{{ article.category.icon }}"></i>{% endif %}
      {{ article.category.title }}
    </div>
  {% endif %}

  {% if article.image %}
    <img src="{{ article.image }}" class="img-fluid rounded mb-3" alt="img">
  {% endif %}

  <div class="article-text">{{ article.text|linebreaks }}</div>

  {% if article.tags.all %}
    <div class="mt-3">
      {% for t in article.tags.all %}
        <span class="badge bg-info text-dark me-1">{{ t.title }}</span>
      {% endfor %}
    </div>
  {% endif %}
</div>

<hr>

<h4>Коментарі ({{ comments|length }})</h4>
{% if comments %}
  <div class="mb-3">
    {% for c in comments %}
      <div class="border rounded p-2 mb-2">
        <div class="small text-muted">{{ c.publication_date }} • {{ c.author }}</div>
        <div>{{ c.text|linebreaks }}</div>
      </div>
    {% endfor %}
  </div>
{% else %}
  <div class="alert alert-secondary">Коментарів ще немає.</div>
{% endif %}

<h5 class="mt-3">Додати коментар</h5>
<form method="post" class="row g-2">
  {% csrf_token %}
  <div class="col-12 col-md-4">
    <input class="form-control" name="author" placeholder="Your name">
  </div>
  <div class="col-12 col-md-8">
    <input class="form-control" name="text" placeholder="Comment text">
  </div>
  <div class="col-12">
    <button class="btn btn-success">Send</button>
  </div>
</form>
{% endblock %}
EOF

cat > app/blog/templates/blog/category_list.html <<'EOF'
{% extends "blog/base.html" %}
{% block title %}Categories{% endblock %}
{% block content %}
<h2 class="mb-3">Категорії</h2>
{% if categories %}
  <div class="list-group">
    {% for c in categories %}
      <div class="list-group-item">
        <div class="fw-bold">
          {% if c.icon %}<i class="{{ c.icon }}"></i>{% endif %}
          {{ c.title }}
        </div>
        {% if c.description %}
          <div class="text-muted small">{{ c.description }}</div>
        {% endif %}
      </div>
    {% endfor %}
  </div>
{% else %}
  <div class="alert alert-warning">Категорій немає.</div>
{% endif %}
{% endblock %}
EOF

cat > app/blog/static/blog/style.css <<'EOF'
.article-text { font-size: 1.05rem; }
EOF

echo "OK: files generated"
