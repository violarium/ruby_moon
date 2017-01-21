// Register the serviceWorker script at /serviceworker.js from your server if supported
if (navigator.serviceWorker) {
    navigator.serviceWorker.register('/serviceworker.js')
        .then(function (reg) {
            console.log('Service worker change, registered the service worker');
        });

    if (window.vapidPublicKey) {
        navigator.serviceWorker.ready.then(function (serviceWorkerRegistration) {
            serviceWorkerRegistration.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: window.vapidPublicKey
            }).then(function(subscription) {
                console.log(subscription);
            });
        });
    }
} else {
    console.error('Service worker is not supported in this browser');
}
