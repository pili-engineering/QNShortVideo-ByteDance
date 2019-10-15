package com.qiniu.shortvideo.bytedance.bytedance.utils;

import android.content.Context;
import android.widget.Toast;

import com.qiniu.shortvideo.bytedance.bytedance.library.LogUtils;


public class ToasUtils {
    private static Context mAppContext = null;

    public static void init(Context context) {
        mAppContext = context;
    }


    public static void show(String msg) {
        if (null == mAppContext) {
            LogUtils.d("ToasUtils not inited with Context");
            return;
        }
        Toast.makeText(mAppContext, msg, Toast.LENGTH_SHORT).show();
    }



}
