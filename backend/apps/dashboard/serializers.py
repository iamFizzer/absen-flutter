from rest_framework import serializers


class DashboardSerializer(serializers.Serializer):

    employee = serializers.DictField()

    office = serializers.DictField()

    attendance = serializers.DictField()