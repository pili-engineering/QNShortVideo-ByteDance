package com.qiniu.shortvideo.bytedance.bytedance.base;

public interface IPresenter {
    void attachView(IView view);
    void detachView();
}
