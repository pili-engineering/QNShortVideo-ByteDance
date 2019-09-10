package com.qiniu.shortvideo.bytedance.bytedance.record;

public interface IVideoRecord {
    void start(String videoPath, boolean isTV);
    void stop();
    void release();
}
