package com.qiniu.shortvideo.bytedance.bytedance.contract.presenter;

import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.util.Log;

import com.qiniu.shortvideo.bytedance.bytedance.ResourceHelper;
import com.qiniu.shortvideo.bytedance.bytedance.contract.WelcomeContract;
import com.qiniu.shortvideo.bytedance.bytedance.library.FileUtils;
import com.qiniu.shortvideo.bytedance.bytedance.task.UnzipTask;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;


/**
 * Created by QunZhang on 2019-07-20 17:30
 */
public class WelcomePresenter extends WelcomeContract.Presenter implements UnzipTask.IUnzipViewCallback {

    int alreadyUnzipNum = 0;

    @Override
    public void startTask() {
        UnzipTask mTask = new UnzipTask(this);
        mTask.execute(ResourceHelper.StickerResourceZip);
    }

    @Override
    public int getVersionCode() {
        Context context = getView().getContext();
        try {
            return context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return -1;
        }
    }

    @Override
    public String getVersionName() {
        Context context = getView().getContext();
        try {
            return "v " + context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return "";
        }
    }

    @Override
    public boolean resourceReady() {
        return ResourceHelper.isResourceReady(getView().getContext(), getVersionCode());
    }

    @Override
    public Context getContext() {
        return getView().getContext();
    }

    @Override
    public void onStartTask() {
        if (isAvailable()) {
            getView().onStartTask();
        }
    }

    @Override
    public void onEndTask(boolean result) {
        if (result && alreadyUnzipNum == 0) {
            alreadyUnzipNum++;
            UnzipTask mTask = new UnzipTask(this);
            mTask.execute(ResourceHelper.OtherResourceZip);
        }
        if (result) {
            ResourceHelper.setResourceReady(getView().getContext(), result, getVersionCode());
        }
        if (isAvailable()) {
            getView().onEndTask(result);
        }
    }
}
