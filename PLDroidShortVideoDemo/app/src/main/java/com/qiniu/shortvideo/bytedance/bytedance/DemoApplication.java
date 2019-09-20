// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
package com.qiniu.shortvideo.bytedance.bytedance;

import android.app.Application;

import com.qiniu.shortvideo.bytedance.bytedance.utils.ToasUtils;


public class DemoApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        ToasUtils.init(this);
    }
}
