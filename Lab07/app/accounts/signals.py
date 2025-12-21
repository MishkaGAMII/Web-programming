from django.apps import apps
from django.db.models.signals import post_migrate
from django.dispatch import receiver
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType

@receiver(post_migrate)
def create_groups_and_permissions(sender, **kwargs):
    comment_model = apps.get_model("blog", "Comment")
    ct = ContentType.objects.get_for_model(comment_model)

    author_group, _ = Group.objects.get_or_create(name="author")
    moderator_group, _ = Group.objects.get_or_create(name="moderator")

    perms = Permission.objects.filter(
        content_type=ct,
        codename__in=["add_comment", "change_comment", "delete_comment", "view_comment"],
    )

    author_group.permissions.add(*perms)
    moderator_group.permissions.add(*perms)
