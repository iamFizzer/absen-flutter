from math import radians
from math import sin
from math import cos
from math import sqrt
from math import atan2


class GeoLocation:

    EARTH_RADIUS = 6371000  # meter

    @staticmethod
    def calculate_distance(
        lat1,
        lon1,
        lat2,
        lon2
    ):
        """
        Menghitung jarak dua titik koordinat menggunakan rumus Haversine.
        Return: meter
        """

        lat1 = float(lat1)
        lon1 = float(lon1)
        lat2 = float(lat2)
        lon2 = float(lon2)

        dlat = radians(lat2 - lat1)
        dlon = radians(lon2 - lon1)

        a = (
            sin(dlat / 2) ** 2
            + cos(radians(lat1))
            * cos(radians(lat2))
            * sin(dlon / 2) ** 2
        )

        c = 2 * atan2(
            sqrt(a),
            sqrt(1 - a)
        )

        return GeoLocation.EARTH_RADIUS * c

    @staticmethod
    def check_radius(
        office_lat,
        office_lon,
        user_lat,
        user_lon,
        radius
    ):

        distance = GeoLocation.calculate_distance(
            office_lat,
            office_lon,
            user_lat,
            user_lon
        )

        return {
            "distance": round(distance, 2),
            "radius": radius,
            "allowed": distance <= radius
        }