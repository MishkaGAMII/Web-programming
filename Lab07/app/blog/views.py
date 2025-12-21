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
