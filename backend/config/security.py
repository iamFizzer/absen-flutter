class SecurityHeadersMiddleware:
    """Security headers for API responses that are not covered by Django defaults."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        response.setdefault(
            "Content-Security-Policy",
            "default-src 'none'; base-uri 'none'; object-src 'none'; "
            "frame-ancestors 'none'; form-action 'none'",
        )
        response.setdefault(
            "Permissions-Policy",
            "camera=(), geolocation=(), microphone=()",
        )
        return response
