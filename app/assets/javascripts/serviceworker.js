// The serviceworker context can respond to 'push' events and trigger
// notifications on the registration property
self.addEventListener("push", function (event) {
    var data = {};
    if (event.data) {
        data = event.data.json();
    }

    var title = data.title;
    var message = data.message;
    var link = data.link;

    event.waitUntil(
        self.registration.showNotification(title, {body: message})
    );

    self.addEventListener('notificationclick', function (event) {
        clients.openWindow(link);
        event.notification.close();
    });
});
