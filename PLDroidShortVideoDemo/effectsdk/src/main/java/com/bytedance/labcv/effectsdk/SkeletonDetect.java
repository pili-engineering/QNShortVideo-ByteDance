package com.bytedance.labcv.effectsdk;

import android.content.Context;
import android.util.Log;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.*;


import java.nio.ByteBuffer;

/**
 * 人体关键点入口
 * Skeleton detect interface
 */
public class SkeletonDetect {
  private long mNativePtr;

  private volatile boolean mInited = false;
  /**
   * 可检测的最大人体数
   * Maximum number of human beings that can be detected
   */
  private final int MaxSkeletonNum = 1;

  static {
    System.loadLibrary("effect_proxy");
  }

  /**
   * 初始化骨骼检测句柄
   * Initializes the skeleton detection handle
   * @param modelPath model file path 模型文件路径
   * @param licensePath license file path 授权文件路径
   * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码，参考{@link BytedEffectConstants}
   *    success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
   */

  public int init(Context context, String modelPath, String licensePath) {
    int ret = nativeInit(modelPath);
    if (ret != BEF_RESULT_SUC) {
      mInited = false;
      return ret;
    }
    if (ret != BEF_RESULT_SUC) {
      mInited = false;
    }

    ret = nativeCheckLicense(context, licensePath);
    if (ret != BEF_RESULT_SUC) {
      mInited = false;
      return ret;
    }

    ret = nativeTargetNum(MaxSkeletonNum);
    if (ret != BEF_RESULT_SUC) {
      mInited = false;
      return ret;
    }

    mInited = true;
    return ret;
  }

  /**
   * The skeleton detects whether the handle is initialized successfully
   * @return true or false
   */
  public boolean isInited() {
    return mInited;
  }

  /**
   * 骨骼检测
   * skeleton detect
   * @param buffer image data图片数据
   * @param pixel_format image format 图片数据格式
   * @param image_width image width 图片宽度
   * @param image_height image height 图片高度
   * @param image_stride image stride 图片数据行宽
   * @param orientation image orientation 图片方向
   * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
   *        success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
   */
  public BefSkeletonInfo detectSkeleton(ByteBuffer buffer, BytedEffectConstants.PixlFormat pixel_format, int image_width, int image_height, int image_stride, BytedEffectConstants.Rotation orientation) {
    if (!mInited) {
      return null;
    }

    BefSkeletonInfo skeletonInfo =  new BefSkeletonInfo();
    int result = nativeDetect(buffer, pixel_format.getValue(), image_width,
        image_height, image_stride, orientation.id, skeletonInfo);
    if (result != BEF_RESULT_SUC) {
      Log.e(BytedEffectConstants.TAG, "nativeDetect return "+result);
      return null;
    }
    return skeletonInfo;
  }

  /**
   * 设置可检测的最多人体个数
   * Set the maximum number of human beings that can be detected
   * @param num
   * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
   *        success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
   */
  public int setTargetNum(int num){
    return nativeTargetNum(num);
  }

  /**
   * 销毁骨骼检测句柄
   * Destroys the bone detection handle
   */
  public void release() {
    if (mInited) {
      nativeRelease();
    }
    mInited = false;
  }

  /**
   * 设置检测算法的输入
   * Set the input to the detection algorithm
   * 一般使用底层默认值即可，可以不用设置
   * Generally, the underlying default value is fine, but you don't have to set it
   * @param width image width 宽度
   * @param height image height 高度
   * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
   *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
   */
  public int setDetectionInput(int width , int height)
  {
    return nativeSetDetectionInput(width, height);
  }

  /**
   * 设置跟踪算法的输入
   * set the input to the tracking algorithm
   * 一般使用底层默认值即可，可以不用设置
   * Generally, the underlying default value is fine, but you don't have to set it
   * @param width image width 宽度
   * @param height image height 高度
   * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
   *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
   */
  public int setTrackingInput(int width , int height)
  {
    return nativeSetTrackingInput(width, height);
  }



  private native int nativeInit(String modelDir);
  private native int nativeCheckLicense(Context context, String license);
  private native int nativeSetDetectionInput(int width, int height);
  private native int nativeSetTrackingInput(int width, int height);
  private native int nativeTargetNum(int num);
  private native int nativeDetect(ByteBuffer buffer, int pixel_format,
                                  int image_width,
                                  int image_height,
                                  int image_stride,
                                  int orientation,
                                  BefSkeletonInfo faceInfo);
  private native void nativeRelease();
}
