// Register the serviceWorker script at /serviceworker.js from your server if supported
if (navigator.serviceWorker) {
    navigator.serviceWorker.register('/serviceworker.js', { scope: '/' });
    if (window.vapidPublicKey && window.webpush.active) {
        navigator.serviceWorker.ready.then(function (serviceWorkerRegistration) {
            serviceWorkerRegistration.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: window.vapidPublicKey
            }).then(function(subscription) {
                $.post(window.webpush.subscribePath, { subscription: subscription.toJSON() });
            });
        });
    }
}
