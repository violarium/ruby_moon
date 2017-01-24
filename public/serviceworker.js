/**
 * Get notification options.
 * @param event
 * @returns {{title: *, parameters: *}}
 */
var getNotificationOptions = function (event) {
    var data, title, parameters;
    if (event.data) {
        try {
            data = event.data.json();
        } catch (err) {
            data = event.data.text();
        }
    }

    if (data.type == 'critical_period') {
        title = data.title;
        parameters = {
            body: data.message,
            icon: '/icons/notifications/critical_period.png',
            data: data,
            actions: [{action: 'open_link', title: data.link_title}]
        };
    } else {
        title = null;
        parameters = {};
    }

    return {title: title, parameters: parameters};
};


/**
 * Perform notification click.
 * @param event
 */
var performNotificationClick = function (event) {
    var data = {};
    if (event.notification.data) {
        data = event.notification.data;
    }

    if (event.action === 'open_link') {
        event.waitUntil(
            clients.matchAll({
                includeUncontrolled: true,
                type: 'window'
            }).then(function (activeClients) {
                if (activeClients.length > 0) {
                    activeClients[0].navigate(data.link);
                    activeClients[0].focus();
                } else {
                    clients.openWindow(data.link);
                }
            })
        );
    }
};


// Handle push event
self.addEventListener("push", function (event) {
    var options = getNotificationOptions(event);
    if (options.title != null) {
        event.waitUntil(self.registration.showNotification(options.title, options.parameters));
    }
});


// Open link if it exists
self.addEventListener('notificationclick', function (event) {
    event.notification.close();
    performNotificationClick(event);
});
