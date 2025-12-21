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
