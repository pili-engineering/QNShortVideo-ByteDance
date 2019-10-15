package com.qiniu.shortvideo.bytedance.bytedance.opengl;

import android.content.Context;

public class HairMaskProgram extends MaskProgram {
    public HairMaskProgram(Context context, int width, int height) {
        super(context, width, height, FRAGMENT_HAIR);
    }
}
