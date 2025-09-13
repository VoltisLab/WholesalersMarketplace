import graphene
from graphene_django import DjangoObjectType
from django.contrib.auth.models import User

class UserType(DjangoObjectType):
    class Meta:
        model = User
        fields = ("id", "username", "email", "first_name", "last_name")

class Query(graphene.ObjectType):
    users = graphene.List(UserType)
    
    def resolve_users(self, info):
        return User.objects.all()

class Mutation(graphene.ObjectType):
    pass

schema = graphene.Schema(query=Query, mutation=Mutation)
