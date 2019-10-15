package com.qiniu.shortvideo.bytedance.bytedance.fragment;


import com.qiniu.shortvideo.bytedance.bytedance.base.BaseFragment;
import com.qiniu.shortvideo.bytedance.bytedance.base.IPresenter;

/**
 * 每个功能fragemnt的基类
 *
 * @param <T>
 */
public abstract class BaseFeatureFragment<T extends IPresenter, Callback> extends BaseFragment<T> {
    private Callback mCallback;

    public BaseFeatureFragment setCallback(Callback t) {
        this.mCallback = t;
        return this;
    }

    public Callback getCallback() {
        return mCallback;
    }
}
