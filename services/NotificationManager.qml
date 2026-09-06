pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    // Model structure: { appName: string, appIcon: string, expanded: bool, notifications: array_of_objects }
    property var groupedNotifications: []
    
    // For popup
    signal incomingNotification(var notif)

    property NotificationServer server: NotificationServer {
        onNotification: (notif) => {
            let appName = notif.appName || "Unknown";
            let appIcon = notif.appIcon || "";
            let summary = notif.summary || "";
            let body = notif.body || "";
            let id = notif.id;
            let image = notif.image || "";
            let icon = notif.icon || "";
            
            let nObj = {
                id: id,
                summary: summary,
                body: body,
                image: image,
                icon: icon,
                timestamp: new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
            };

            // Copy array to trigger property change
            let groups = root.groupedNotifications.slice();
            let found = false;
            
            for (let i = 0; i < groups.length; i++) {
                if (groups[i].appName === appName) {
                    // Prepend to existing group
                    groups[i].notifications.unshift(nObj);
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                // Create new group at top
                groups.unshift({
                    appName: appName,
                    appIcon: appIcon,
                    expanded: false,
                    notifications: [nObj]
                });
            }
            
            root.groupedNotifications = groups;
            
            // Trigger popup
            root.incomingNotification({
                id: id,
                appName: appName,
                appIcon: appIcon,
                summary: summary,
                body: body,
                image: image,
                icon: icon
            });
        }
    }
    
    function toggleGroup(index) {
        let groups = root.groupedNotifications.slice();
        groups[index].expanded = !groups[index].expanded;
        root.groupedNotifications = groups;
    }
    
    function dismissGroup(index) {
        let groups = root.groupedNotifications.slice();
        groups.splice(index, 1);
        root.groupedNotifications = groups;
    }
    
    function clearAll() {
        root.groupedNotifications = [];
    }
}
