import QtQuick
import Qt.labs.folderlistmodel

FolderListModel {
    id: root
    property string path: ""
    property var filter: 0
    property bool recursive: false
    property bool sortReverse: false
    property int sortMode: FolderListModel.Name
    showDirs: true
    showFiles: true
    showHidden: false
    nameFilters: ["*.jpg","*.jpeg","*.png","*.webp","*.gif","*.bmp","*.svg","*.mp4","*.mkv","*.webm"]
    onPathChanged: {
        const p = String(path || "");
        folder = p.startsWith("file://") ? p : (p ? "file://" + p : "");
    }
}
