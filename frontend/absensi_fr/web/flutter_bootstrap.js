{{flutter_js}}
{{flutter_build_config}}

(async () => {
  // Flutter's generated service worker is deprecated and can keep an old
  // attendance bundle active after deployment. This app favours fresh code.
  if ('serviceWorker' in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations();
    await Promise.all(registrations.map((registration) => registration.unregister()));
  }

  await _flutter.loader.load();
})();
