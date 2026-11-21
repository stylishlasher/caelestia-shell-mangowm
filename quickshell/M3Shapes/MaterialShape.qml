import QtQuick

Item {
    id: root
    enum Shape {
        Circle=0, Square=1, Slanted=2, Arch=3, Fan=4, Arrow=5, SemiCircle=6, Oval=7, Pill=8, Triangle=9, Diamond=10, ClamShell=11, Pentagon=12, Gem=13, Sunny=14, VerySunny=15, Cookie4Sided=16, Cookie6Sided=17, Cookie7Sided=18, Cookie9Sided=19, Cookie12Sided=20, Ghostish=21, Clover4Leaf=22, Clover8Leaf=23, Burst=24, SoftBurst=25, Flower=26, Puffy=27, PuffyDiamond=28, PixelCircle=29, PixelTriangle=30, Bun=31, Heart=32
    }
    property int shape: MaterialShape.Circle
    property color color: "transparent"
    property real implicitSize: 24
    implicitWidth: implicitSize
    implicitHeight: implicitSize

    function pathBounds() {
        return Qt.rect(0, 0, width, height);
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.color
        radius: {
            switch (root.shape) {
            case MaterialShape.Square: return width * 0.08;
            case MaterialShape.Slanted: return width * 0.18;
            case MaterialShape.Arch: return width * 0.35;
            case MaterialShape.Oval: return width * 0.45;
            case MaterialShape.Pill: return width / 2;
            case MaterialShape.Triangle:
            case MaterialShape.Diamond:
            case MaterialShape.Pentagon:
            case MaterialShape.Gem: return width * 0.16;
            case MaterialShape.Cookie4Sided:
            case MaterialShape.Cookie6Sided:
            case MaterialShape.Cookie7Sided:
            case MaterialShape.Cookie9Sided:
            case MaterialShape.Cookie12Sided: return width * 0.28;
            case MaterialShape.SoftBurst:
            case MaterialShape.Burst:
            case MaterialShape.Sunny:
            case MaterialShape.VerySunny: return width * 0.24;
            case MaterialShape.ClamShell: return width * 0.3;
            case MaterialShape.Ghostish: return width * 0.34;
            case MaterialShape.Clover4Leaf:
            case MaterialShape.Clover8Leaf: return width * 0.36;
            case MaterialShape.Heart: return width * 0.28;
            default: return width / 2;
            }
        }
        rotation: root.shape === MaterialShape.Diamond ? 45 : (root.shape === MaterialShape.Triangle ? 0 : 0)
        scale: root.shape === MaterialShape.Pill ? 1 : 1
    }
}
