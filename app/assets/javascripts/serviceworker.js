// The serviceworker context can respond to 'push' events and trigger
// notifications on the registration property
self.addEventListener("push", function (event) {
    if (!(self.Notification && self.notification.permission === 'granted')) {
        return;
    }

    var data = {};
    if (event.data) {
        data = event.data.json();
    }

    var title = data.title;
    var message = data.message;
    var link = data.link;

    var notification = new Notification(title, {body: message});

    notification.addEventListener('click', function() {
        if (clients.openWindow) {
            clients.openWindow(link);
        }
    });
});
