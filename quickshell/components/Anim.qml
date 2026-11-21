import QtQuick
import Caelestia.Config

NumberAnimation {
    enum Type {
        StandardSmall = 0,
        Standard,
        StandardLarge,
        StandardExtraLarge,
        EmphasizedSmall,
        Emphasized,
        EmphasizedLarge,
        EmphasizedExtraLarge,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial,
        FastEffects,
        DefaultEffects,
        SlowEffects
    }

    property int type: Anim.DefaultSpatial

    duration: {
        let d = Tokens.anim.durations.normal;
        if (type === Anim.FastSpatial) d = Tokens.anim.durations.expressiveFastSpatial;
        else if (type === Anim.DefaultSpatial) d = Tokens.anim.durations.expressiveDefaultSpatial;
        else if (type === Anim.SlowSpatial) d = Tokens.anim.durations.expressiveSlowSpatial;
        else if (type === Anim.FastEffects) d = Tokens.anim.durations.expressiveFastEffects;
        else if (type === Anim.DefaultEffects) d = Tokens.anim.durations.expressiveDefaultEffects;
        else if (type === Anim.SlowEffects) d = Tokens.anim.durations.expressiveSlowEffects;
        else if (type >= Anim.StandardSmall && type <= Anim.EmphasizedExtraLarge) {
            const types = ["small", "normal", "large", "extraLarge"];
            d = Tokens.anim.durations[types[type % 4]];
        }
        return Math.max(50, Math.round(d * 0.7));
    }
    easing: {
        if (type === Anim.FastSpatial)
            return Tokens.anim.expressiveFastSpatial;
        if (type === Anim.DefaultSpatial)
            return Tokens.anim.expressiveDefaultSpatial;
        if (type === Anim.SlowSpatial)
            return Tokens.anim.expressiveSlowSpatial;
        if (type === Anim.FastEffects)
            return Tokens.anim.expressiveFastEffects;
        if (type === Anim.DefaultEffects)
            return Tokens.anim.expressiveDefaultEffects;
        if (type === Anim.SlowEffects)
            return Tokens.anim.expressiveSlowEffects;

        if (type >= Anim.EmphasizedSmall && type <= Anim.EmphasizedExtraLarge)
            return Tokens.anim.emphasized;
        return Tokens.anim.standard;
    }
}
