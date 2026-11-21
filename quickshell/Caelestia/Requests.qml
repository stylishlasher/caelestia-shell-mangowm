pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    function get(url, callback) {
        try {
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && callback)
                    callback(xhr.responseText, xhr.status);
            };
            xhr.open("GET", String(url));
            xhr.send();
        } catch(e) {
            if (callback) callback("", 0);
        }
    }
    function post(url, body, callback, contentType) {
        try {
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && callback)
                    callback(xhr.responseText, xhr.status);
            };
            xhr.open("POST", String(url));
            if (contentType) xhr.setRequestHeader("Content-Type", String(contentType));
            xhr.send(body);
        } catch(e) {
            if (callback) callback("", 0);
        }
    }
}
