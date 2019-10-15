package com.qiniu.shortvideo.bytedance.ar;

public interface AsyncCallback<T> {
    void onSuccess(T result);

    void onFail(Throwable t);

    void onProgress(String taskName, float progress);
}
