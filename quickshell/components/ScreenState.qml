import Quickshell

PersistentProperties {
    required property var modelData

    // Drawer visibilities
    property bool bar: true
    property bool osd
    property bool session
    property bool launcher
    property bool dashboard
    property bool utilities
    property bool sidebar

    // Dashboard state
    property int dashboardTab
    property date dashboardDate: new Date()
}
