// The serviceworker context can respond to 'push' events and trigger
// notifications on the registration property
self.addEventListener("push", function (event) {
    var title = (event.data && event.data.text()) || '';
    event.waitUntil(self.registration.showNotification(title));
});
