package com.bytedance.labcv.effectsdk;

import android.graphics.PointF;

import java.util.Arrays;

/**
 * 人体关键点检测结果
 * Key detection results of skeleton
 */
public class BefSkeletonInfo {

  /**
   * 人体关键点
   * Key points of skeleton
   */
  private Skeleton[] skeletons;

  /**
   * 人体数量
   * Amount of human
   */

  private int skeletonNum;

  /**
   * 获取人体个数
   * Get amount of human
   * @return 人体数目 amount of human
   */
  public int getSkeletonNum() {
    return skeletonNum;
  }

  /**
   * 设置人体数目
   * Set amount of human
   * @param skeletonNum
   */
  public void setSkeletonNum(int skeletonNum) {
    this.skeletonNum = skeletonNum;
  }

  /**
   * 获取全部的关键点数组
   * Get the array of skeleton key points
   * @return 人体关键点数组 array of skeleton key points
   */
  public Skeleton[] getSkeletons() {
    if(skeletons == null)
      return new Skeleton[0];
    return skeletons;
  }

  @Override
  public String toString() {
    return "Skeleton Num: " + skeletonNum + ", Skeletons: " + Arrays.toString(skeletons);
  }

  /**
   * 单个人体关键点数据
   * Key points data of Individual skeleton
   */
  public static class Skeleton
  {
    SkeletonPoint[] keypoints;
    BefFaceInfo.FaceRect skeletonRect;

    public SkeletonPoint[] getKeypoints() {
      if(keypoints == null)
        return new SkeletonPoint[0];
      return keypoints;
    }

    public BefFaceInfo.FaceRect getSkeletonRect() {
      return skeletonRect;
    }

    @Override
    public String toString() {
      return Arrays.toString(keypoints);
    }
  }

  public static class SkeletonPoint
  {
    float x;
    float y;
    boolean is_detect;


    public SkeletonPoint(float x, float y, boolean is_detect)
    {
      this.x = x;
      this.y = y;
      this.is_detect = is_detect;
    }

    public void setIs_detect(boolean is_detect) {
      this.is_detect = is_detect;
    }

    public boolean isDetect() {
      return is_detect;
    }

    public float getX() {
      return x;
    }

    public void setX(float x) {
      this.x = x;
    }

    public float getY() {
      return y;
    }

    public void setY(float y) {
      this.y = y;
    }

    public PointF asPoint() {
      return new PointF(x, y);
    }

    @Override
    public String toString() {
      return "FacePoint{" +
          "x=" + x +
          ", y=" + y +
          ", isdetect=" + String.valueOf(is_detect) +
          '}';
    }
  }

}
