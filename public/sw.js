function messageToClient(client, data){
    return new Promise((resolve, reject) => {
        const channel = new MessageChannel();

        channel.port1.onmessage = (event) => {
            if(event.data.error){ reject(event.data.error) } 
            else { resolve(event.data) }
        }
    });

    client.postMessage(JSON.stringify(data), [channel.port2]);
}

self.addEventListener('push', (event) => {
    const data = event.data.json();
    event.waitUntil(
        self.registration.showNotification(data.title, {
            body: data.body,
            icon: data.icon
        })
    );
});

self.addEventListener('notificationclick', (event) => {
    let notification = event.notification;
    event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {  
        for (var i = 0; i < clientList.length; i++) {  
            var client = clientList[i];  
            if (client.url == notification.url && 'focus' in client)  
                return client.focus();
            }  
            if (clients.openWindow) {
                return clients.openWindow(notification.url);  
            }
        })
    );
    notification.close();
});