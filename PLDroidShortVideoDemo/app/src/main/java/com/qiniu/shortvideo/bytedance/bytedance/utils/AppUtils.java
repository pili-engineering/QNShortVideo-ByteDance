package com.qiniu.shortvideo.bytedance.bytedance.utils;


import android.app.UiModeManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Configuration;

import static android.content.Context.UI_MODE_SERVICE;

public class AppUtils {

    // for test 使用yuv 不推荐启用，会有帧不同步问题
    private static boolean useYuv = false;

    // for test 使用yuv数据作为特效处理的输入 如果为false 使用yuv作为检测算法的输入
    private static boolean testEffectWithBuffer = false;

    public static boolean isTestEffectWithBuffer() {
        return testEffectWithBuffer;
    }

    // 加速glreadPixels 针对低性能GPU能加速，但不建议开启，会有帧不同步问题
    private static boolean accGlReadPixels = false;

    public static boolean isAccGlReadPixels(){
        return accGlReadPixels;
    }

    public static boolean isUseYuv(){
        return useYuv;
    }

    /**
     * 判断当前设备是否是电视
     *
     * @param context
     * @return 电视返回 True，手机返回 False
     */
    public static boolean isTv(Context context) {
        UiModeManager uiModeManager = (UiModeManager) context.getSystemService(UI_MODE_SERVICE);
        return (uiModeManager.getCurrentModeType() == Configuration.UI_MODE_TYPE_TELEVISION);
    }

}
