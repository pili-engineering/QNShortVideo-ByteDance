package com.qiniu.shortvideo.bytedance.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.hardware.SensorManager;
import android.media.AudioFormat;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.OrientationEventListener;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.bytedance.labcv.effectsdk.BefDistanceInfo;
import com.bytedance.labcv.effectsdk.BefFaceInfo;
import com.bytedance.labcv.effectsdk.BefHandInfo;
import com.bytedance.labcv.effectsdk.BefPetFaceInfo;
import com.bytedance.labcv.effectsdk.BytedEffectConstants;
import com.google.zxing.Result;
import com.qiniu.pili.droid.shortvideo.PLAudioEncodeSetting;
import com.qiniu.pili.droid.shortvideo.PLCameraSetting;
import com.qiniu.pili.droid.shortvideo.PLCaptureFrameListener;
import com.qiniu.pili.droid.shortvideo.PLDraft;
import com.qiniu.pili.droid.shortvideo.PLDraftBox;
import com.qiniu.pili.droid.shortvideo.PLFaceBeautySetting;
import com.qiniu.pili.droid.shortvideo.PLFocusListener;
import com.qiniu.pili.droid.shortvideo.PLMicrophoneSetting;
import com.qiniu.pili.droid.shortvideo.PLRecordSetting;
import com.qiniu.pili.droid.shortvideo.PLRecordStateListener;
import com.qiniu.pili.droid.shortvideo.PLShortVideoRecorder;
import com.qiniu.pili.droid.shortvideo.PLVideoEncodeSetting;
import com.qiniu.pili.droid.shortvideo.PLVideoFilterListener;
import com.qiniu.pili.droid.shortvideo.PLVideoFrame;
import com.qiniu.pili.droid.shortvideo.PLVideoSaveListener;

import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.bytedance.EffectRenderHelper;
import com.qiniu.shortvideo.bytedance.bytedance.ResourceHelper;
import com.qiniu.shortvideo.bytedance.bytedance.fragment.EffectFragment;
import com.qiniu.shortvideo.bytedance.bytedance.fragment.FaceInfoFragment;
import com.qiniu.shortvideo.bytedance.bytedance.fragment.IdentifyFragment;
import com.qiniu.shortvideo.bytedance.bytedance.fragment.StickerFragment;
import com.qiniu.shortvideo.bytedance.bytedance.library.LogUtils;
import com.qiniu.shortvideo.bytedance.bytedance.library.OrientationSensor;
import com.qiniu.shortvideo.bytedance.bytedance.model.CaptureResult;
import com.qiniu.shortvideo.bytedance.bytedance.model.ComposerNode;
import com.qiniu.shortvideo.bytedance.bytedance.model.FaceVerifyResult;
import com.qiniu.shortvideo.bytedance.bytedance.task.decode.RepeatedScannerHandler;
import com.qiniu.shortvideo.bytedance.bytedance.task.faceverify.RepeatedVerifyHandler;
import com.qiniu.shortvideo.bytedance.bytedance.utils.BitmapUtils;
import com.qiniu.shortvideo.bytedance.bytedance.utils.CommonUtils;
import com.qiniu.shortvideo.bytedance.bytedance.utils.DownloadStickerManager;
import com.qiniu.shortvideo.bytedance.bytedance.utils.DownloadUtil;
import com.qiniu.shortvideo.bytedance.bytedance.utils.NetworkUtil;
import com.qiniu.shortvideo.bytedance.bytedance.utils.StickerCodeParser;
import com.qiniu.shortvideo.bytedance.bytedance.utils.TextureProcessor;
import com.qiniu.shortvideo.bytedance.bytedance.utils.ToasUtils;
import com.qiniu.shortvideo.bytedance.bytedance.view.TipManager;
import com.qiniu.shortvideo.bytedance.bytedance.view.ViewfinderView;
import com.qiniu.shortvideo.bytedance.utils.Config;
import com.qiniu.shortvideo.bytedance.utils.GetPathFromUri;
import com.qiniu.shortvideo.bytedance.utils.RecordSettings;
import com.qiniu.shortvideo.bytedance.utils.ToastUtils;
import com.qiniu.shortvideo.bytedance.view.CustomProgressDialog;
import com.qiniu.shortvideo.bytedance.view.FocusIndicator;
import com.qiniu.shortvideo.bytedance.view.SectionProgressBar;
import com.qiniu.shortvideo.bytedance.view.SquareGLSurfaceView;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.util.Arrays;
import java.util.Stack;

import static com.bytedance.labcv.effectsdk.FaceVerify.SAME_FACE_SCORE;
import static com.qiniu.shortvideo.bytedance.utils.RecordSettings.RECORD_SPEED_ARRAY;
import static com.qiniu.shortvideo.bytedance.utils.RecordSettings.chooseCameraFacingId;


public class VideoRecordActivity extends FragmentActivity implements PLRecordStateListener, PLVideoSaveListener, PLFocusListener, View.OnClickListener, DownloadUtil.DownloadListener, RepeatedScannerHandler.RepeatedScannerCallback, RepeatedVerifyHandler.RepeatedVerifyCallback {
    private static final String TAG = "VideoRecordActivity";

    public static final String PREVIEW_SIZE_RATIO = "PreviewSizeRatio";
    public static final String PREVIEW_SIZE_LEVEL = "PreviewSizeLevel";
    public static final String ENCODING_MODE = "EncodingMode";
    public static final String ENCODING_SIZE_LEVEL = "EncodingSizeLevel";
    public static final String ENCODING_BITRATE_LEVEL = "EncodingBitrateLevel";
    public static final String AUDIO_CHANNEL_NUM = "AudioChannelNum";
    public static final String DRAFT = "draft";

    private static final int REQUEST_CODE_ADD_MIX_MUSIC = 0;

    /**
     * NOTICE: TUSDK needs extra cost
     */
    private static final boolean USE_TUSDK = true;

    private PLShortVideoRecorder mShortVideoRecorder;

    private SectionProgressBar mSectionProgressBar;
    private CustomProgressDialog mProcessingDialog;
    private View mRecordBtn;
    private View mDeleteBtn;
    private View mConcatBtn;
    private LinearLayout mButtons;
    private View mSwitchCameraBtn;
    private View mSwitchFlashBtn;
    private FocusIndicator mFocusIndicator;
    private SeekBar mAdjustBrightnessSeekBar;

    private TextView mRecordingPercentageView;
    private long mLastRecordingPercentageViewUpdateTime = 0;

    private boolean mFlashEnabled;
    private boolean mIsEditVideo = false;

    private GestureDetector mGestureDetector;

    private PLCameraSetting mCameraSetting;
    private PLMicrophoneSetting mMicrophoneSetting;
    private PLRecordSetting mRecordSetting;
    private PLVideoEncodeSetting mVideoEncodeSetting;
    private PLAudioEncodeSetting mAudioEncodeSetting;
    private PLFaceBeautySetting mFaceBeautySetting;
    private ViewGroup mBottomControlPanel;

    private int mFocusIndicatorX;
    private int mFocusIndicatorY;

    private double mRecordSpeed;
    private TextView mSpeedTextView;

    private Stack<Long> mDurationRecordStack = new Stack();
    private Stack<Double> mDurationVideoStack = new Stack();

    private OrientationEventListener mOrientationListener;
    private boolean mSectionBegan;

    //字节跳动相关
    // 标志面板类型，分别是 识别、特效、贴纸
    public static final String TAG_IDENTIFY = "identify";
    public static final String TAG_EFFECT = "effect";
    public static final String TAG_STICKER = "sticker";

    public static final int ANIMATOR_DURATION = 400;

    private IdentifyFragment mIdentifyFragment;
    private EffectFragment mEffectFragment;
    private StickerFragment mStickerFragment;
    // 正在处于功能可用状态的面板
    private OnCloseListener mWorkingFragment;

    private FaceInfoFragment faceInfoFragment;

    private SquareGLSurfaceView mSurfaceView;
    private EffectRenderHelper mEffectRenderHelper;

    private TipManager mTipManager = new TipManager();

    private FrameLayout mTipContainer;

    // 展示人脸检测结果的控件
    private LinearLayout llFaceVerify;
    private TextView tvSimilarityFaceVerify;
    private TextView tvCostFaceVerify;
    private TextView tvResultFaceVerify;

    private ViewfinderView mFinderView;

    private RepeatedScannerHandler mQrScannerHandler;
    private RepeatedVerifyHandler mFaceVerifyHandler;


    private ProgressDialog progressDialog;

    private DecimalFormat df = new DecimalFormat("0.00");


    private LinearLayout llFeature;
    private LinearLayout llIdentify;
    private LinearLayout llEffect;
    private LinearLayout llSticker;
    private ImageView ivFaceVerifyShow;

    private boolean isShowQr = false;

    //  below UI elements are for debug

    // 文件下载成功
    private static final int DOWNLOAD_SUCCESS = 2;
    // 文件下载失败
    private static final int DOWNLOAD_FAIL = 3;
    // 文件解压失败
    private static final int UNZIP_FAIL = 4;
    // 文件校验失败 主要检测是否有license
    private static final int FILE_CHECK_FAIL = 5;
    // 授权失败
    private static final int LICENSE_CHECK_FAIL = 6;
    // 贴纸加载成功
    private static final int STICKER_LOAD_SUCCESS = 7;
    // 贴纸加载失败
    private static final int STICKER_LOAD_FAIL = 8;
    // 拍照失败
    private static final int CAPTURE_FAIL = 9;
    // 拍照成功
    private static final int CAPTURE_SUCCESS = 10;

    public InnerHandler getHandler() {
        return mHandler;
    }

    private InnerHandler mHandler = new InnerHandler(this);

    private volatile boolean mIsSet = false;

    private int mSurfaceWidth;
    private int mSurfaceHeight;
    private int mCameraWidth;
    private int mCameraHeight;

    private TextureProcessor mTextureProcessor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_record);

        mSectionProgressBar = (SectionProgressBar) findViewById(R.id.record_progressbar);
        mSurfaceView = findViewById(R.id.preview);
        mRecordBtn = findViewById(R.id.record);
        mDeleteBtn = findViewById(R.id.delete);
        mConcatBtn = findViewById(R.id.concat);
        mButtons = findViewById(R.id.btns);
        mSwitchCameraBtn = findViewById(R.id.switch_camera);
        mSwitchFlashBtn = findViewById(R.id.switch_flash);
        mFocusIndicator = (FocusIndicator) findViewById(R.id.focus_indicator);
        mAdjustBrightnessSeekBar = (SeekBar) findViewById(R.id.adjust_brightness);
        mBottomControlPanel = (ViewGroup) findViewById(R.id.bottom_control_panel);
        mRecordingPercentageView = (TextView) findViewById(R.id.recording_percentage);

        mProcessingDialog = new CustomProgressDialog(this);
        mProcessingDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                mShortVideoRecorder.cancelConcat();
            }
        });

        mShortVideoRecorder = new PLShortVideoRecorder();
        mShortVideoRecorder.setRecordStateListener(this);

        mRecordSpeed = RECORD_SPEED_ARRAY[2];
        mSpeedTextView = (TextView) findViewById(R.id.normal_speed_text);

        String draftTag = getIntent().getStringExtra(DRAFT);
        if (draftTag == null) {
            int previewSizeRatioPos = getIntent().getIntExtra(PREVIEW_SIZE_RATIO, 0);
            int previewSizeLevelPos = getIntent().getIntExtra(PREVIEW_SIZE_LEVEL, 0);
            int encodingModePos = getIntent().getIntExtra(ENCODING_MODE, 0);
            int encodingSizeLevelPos = getIntent().getIntExtra(ENCODING_SIZE_LEVEL, 0);
            int encodingBitrateLevelPos = getIntent().getIntExtra(ENCODING_BITRATE_LEVEL, 0);
            int audioChannelNumPos = getIntent().getIntExtra(AUDIO_CHANNEL_NUM, 0);

            mCameraSetting = new PLCameraSetting();
            PLCameraSetting.CAMERA_FACING_ID facingId = chooseCameraFacingId();
            mCameraSetting.setCameraId(facingId);
            mCameraSetting.setCameraPreviewSizeRatio(RecordSettings.PREVIEW_SIZE_RATIO_ARRAY[previewSizeRatioPos]);
            mCameraSetting.setCameraPreviewSizeLevel(RecordSettings.PREVIEW_SIZE_LEVEL_ARRAY[previewSizeLevelPos]);

            mMicrophoneSetting = new PLMicrophoneSetting();
            mMicrophoneSetting.setChannelConfig(RecordSettings.AUDIO_CHANNEL_NUM_ARRAY[audioChannelNumPos] == 1 ? AudioFormat.CHANNEL_IN_MONO : AudioFormat.CHANNEL_IN_STEREO);

            mVideoEncodeSetting = new PLVideoEncodeSetting(this);
            mVideoEncodeSetting.setEncodingSizeLevel(RecordSettings.ENCODING_SIZE_LEVEL_ARRAY[encodingSizeLevelPos]);
            mVideoEncodeSetting.setEncodingBitrate(RecordSettings.ENCODING_BITRATE_LEVEL_ARRAY[encodingBitrateLevelPos]);
            mVideoEncodeSetting.setHWCodecEnabled(encodingModePos == 0);
            mVideoEncodeSetting.setConstFrameRateEnabled(true);

            mAudioEncodeSetting = new PLAudioEncodeSetting();
            mAudioEncodeSetting.setHWCodecEnabled(encodingModePos == 0);
            mAudioEncodeSetting.setChannels(RecordSettings.AUDIO_CHANNEL_NUM_ARRAY[audioChannelNumPos]);

            mRecordSetting = new PLRecordSetting();
            mRecordSetting.setMaxRecordDuration(RecordSettings.DEFAULT_MAX_RECORD_DURATION);
            mRecordSetting.setRecordSpeedVariable(true);
            mRecordSetting.setVideoCacheDir(Config.VIDEO_STORAGE_DIR);
            mRecordSetting.setVideoFilepath(Config.RECORD_FILE_PATH);

            mFaceBeautySetting = new PLFaceBeautySetting(1.0f, 0.5f, 0.5f);

            mShortVideoRecorder.prepare(mSurfaceView, mCameraSetting, mMicrophoneSetting, mVideoEncodeSetting, mAudioEncodeSetting, USE_TUSDK ? null : mFaceBeautySetting, mRecordSetting);
            mSectionProgressBar.setFirstPointTime(RecordSettings.DEFAULT_MIN_RECORD_DURATION);
            onSectionCountChanged(0, 0);
        } else {
            PLDraft draft = PLDraftBox.getInstance(this).getDraftByTag(draftTag);
            if (draft == null) {
                ToastUtils.s(this, getString(R.string.toast_draft_recover_fail));
                finish();
            }

            mCameraSetting = draft.getCameraSetting();
            mMicrophoneSetting = draft.getMicrophoneSetting();
            mVideoEncodeSetting = draft.getVideoEncodeSetting();
            mAudioEncodeSetting = draft.getAudioEncodeSetting();
            mRecordSetting = draft.getRecordSetting();
            mFaceBeautySetting = draft.getFaceBeautySetting();

            if (mShortVideoRecorder.recoverFromDraft(mSurfaceView, draft)) {
                long draftDuration = 0;
                for (int i = 0; i < draft.getSectionCount(); ++i) {
                    long currentDuration = draft.getSectionDuration(i);
                    draftDuration += draft.getSectionDuration(i);
                    onSectionIncreased(currentDuration, draftDuration, i + 1);
                    if (!mDurationRecordStack.isEmpty()) {
                        mDurationRecordStack.pop();
                    }
                }
                mSectionProgressBar.setFirstPointTime(draftDuration);
                ToastUtils.s(this, getString(R.string.toast_draft_recover_success));
            } else {
                onSectionCountChanged(0, 0);
                mSectionProgressBar.setFirstPointTime(RecordSettings.DEFAULT_MIN_RECORD_DURATION);
                ToastUtils.s(this, getString(R.string.toast_draft_recover_fail));
            }
        }
        mShortVideoRecorder.setRecordSpeed(mRecordSpeed);
        mSectionProgressBar.setProceedingSpeed(mRecordSpeed);
        mSectionProgressBar.setTotalTime(this, mRecordSetting.getMaxRecordDuration());

        mRecordBtn.setOnTouchListener(new View.OnTouchListener() {
            private long mSectionBeginTSMs;

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                int action = event.getAction();
                if (action == MotionEvent.ACTION_DOWN) {
                    if (!mSectionBegan && mShortVideoRecorder.beginSection()) {
                        mSectionBegan = true;
                        mSectionBeginTSMs = System.currentTimeMillis();
                        mSectionProgressBar.setCurrentState(SectionProgressBar.State.START);
                        updateRecordingBtns(true);
                    } else {
                        ToastUtils.s(VideoRecordActivity.this, "无法开始视频段录制");
                    }
                } else if (action == MotionEvent.ACTION_UP) {
                    if (mSectionBegan) {
                        long sectionRecordDurationMs = System.currentTimeMillis() - mSectionBeginTSMs;
                        long totalRecordDurationMs = sectionRecordDurationMs + (mDurationRecordStack.isEmpty() ? 0 : mDurationRecordStack.peek().longValue());
                        double sectionVideoDurationMs = sectionRecordDurationMs / mRecordSpeed;
                        double totalVideoDurationMs = sectionVideoDurationMs + (mDurationVideoStack.isEmpty() ? 0 : mDurationVideoStack.peek().doubleValue());
                        mDurationRecordStack.push(new Long(totalRecordDurationMs));
                        mDurationVideoStack.push(new Double(totalVideoDurationMs));
                        if (mRecordSetting.IsRecordSpeedVariable()) {
                            Log.d(TAG, "SectionRecordDuration: " + sectionRecordDurationMs + "; sectionVideoDuration: " + sectionVideoDurationMs + "; totalVideoDurationMs: " + totalVideoDurationMs + "Section count: " + mDurationVideoStack.size());
                            mSectionProgressBar.addBreakPointTime((long) totalVideoDurationMs);
                        } else {
                            mSectionProgressBar.addBreakPointTime(totalRecordDurationMs);
                        }

                        mSectionProgressBar.setCurrentState(SectionProgressBar.State.PAUSE);
                        mShortVideoRecorder.endSection();
                        mSectionBegan = false;
                    }
                }

                return false;
            }
        });
        mGestureDetector = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                mFocusIndicatorX = (int) e.getX() - mFocusIndicator.getWidth() / 2;
                mFocusIndicatorY = (int) e.getY() - mFocusIndicator.getHeight() / 2;
                mShortVideoRecorder.manualFocus(mFocusIndicator.getWidth(), mFocusIndicator.getHeight(), (int) e.getX(), (int) e.getY());
                closeFeature();
                mButtons.setVisibility(View.VISIBLE);
                return false;
            }
        });
        mSurfaceView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                mGestureDetector.onTouchEvent(motionEvent);
                return true;
            }
        });

        mOrientationListener = new OrientationEventListener(this, SensorManager.SENSOR_DELAY_NORMAL) {
            @Override
            public void onOrientationChanged(int orientation) {
                int rotation = getScreenRotation(orientation);
                if (!mSectionProgressBar.isRecorded() && !mSectionBegan) {
                    mVideoEncodeSetting.setRotationInMetadata(rotation);
                }
            }
        };
        if (mOrientationListener.canDetectOrientation()) {
            mOrientationListener.enable();
        }

        //字节跳动相关
        OrientationSensor.start(this);
        initViews();
        initEffectHelper();
    }

    private int getScreenRotation(int orientation) {
        int screenRotation = 0;
        boolean isPortraitScreen = getResources().getConfiguration().orientation == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
        if (orientation >= 315 || orientation < 45) {
            screenRotation = isPortraitScreen ? 0 : 90;
        } else if (orientation >= 45 && orientation < 135) {
            screenRotation = isPortraitScreen ? 90 : 180;
        } else if (orientation >= 135 && orientation < 225) {
            screenRotation = isPortraitScreen ? 180 : 270;
        } else if (orientation >= 225 && orientation < 315) {
            screenRotation = isPortraitScreen ? 270 : 0;
        }
        return screenRotation;
    }

    private void updateRecordingBtns(boolean isRecording) {
        mSwitchCameraBtn.setEnabled(!isRecording);
        mRecordBtn.setActivated(isRecording);
    }

    public void onScreenRotation(View v) {
        if (mDeleteBtn.isEnabled()) {
            ToastUtils.s(this, "已经开始拍摄，无法旋转屏幕。");
        } else {
            setRequestedOrientation(getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT ? ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE : ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    public void onCaptureFrame(View v) {
        mShortVideoRecorder.captureFrame(new PLCaptureFrameListener() {
            @Override
            public void onFrameCaptured(PLVideoFrame capturedFrame) {
                if (capturedFrame == null) {
                    Log.e(TAG, "capture frame failed");
                    return;
                }

                Log.i(TAG, "captured frame width: " + capturedFrame.getWidth() + " height: " + capturedFrame.getHeight() + " timestamp: " + capturedFrame.getTimestampMs());
                try {
                    FileOutputStream fos = new FileOutputStream(Config.CAPTURED_FRAME_FILE_PATH);
                    capturedFrame.toBitmap().compress(Bitmap.CompressFormat.JPEG, 100, fos);
                    fos.close();
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ToastUtils.s(VideoRecordActivity.this, "截帧已保存到路径：" + Config.CAPTURED_FRAME_FILE_PATH);
                        }
                    });
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }


    @Override
    protected void onResume() {
        super.onResume();
        mSurfaceView.onResume();
        mRecordBtn.setEnabled(false);
        mShortVideoRecorder.resume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        //字节跳动相关
        mHandler.removeCallbacksAndMessages(null);
        mSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                mEffectRenderHelper.destroySDKModules();
            }
        });
        mSurfaceView.onPause();

        updateRecordingBtns(false);
        mShortVideoRecorder.pause();
    }

    @Override
    protected void onDestroy() {
        //字节跳动相关
        OrientationSensor.stop();
        mSurfaceView = null;
        mEffectFragment = null;
        mIdentifyFragment = null;
        mStickerFragment = null;
        mQrScannerHandler.release();
        mFaceVerifyHandler.release();

        mShortVideoRecorder.destroy();
        mOrientationListener.disable();
        super.onDestroy();
    }

    public void onClickDelete(View v) {
        if (!mShortVideoRecorder.deleteLastSection()) {
            ToastUtils.s(this, "回删视频段失败");
        }
    }

    public void onClickConcat(View v) {
        mProcessingDialog.show();
        showChooseDialog();
    }

    public void onClickBrightness(View v) {
        boolean isVisible = mAdjustBrightnessSeekBar.getVisibility() == View.VISIBLE;
        mAdjustBrightnessSeekBar.setVisibility(isVisible ? View.GONE : View.VISIBLE);
    }

    public void onClickSwitchCamera(View v) {
        mSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                mEffectRenderHelper.destroySDKModules();
            }
        });
        mSurfaceView.onPause();
        mShortVideoRecorder.switchCamera();
        mFocusIndicator.focusCancel();
        mSurfaceView.onResume();
    }

    public void onClickSwitchFlash(View v) {
        mFlashEnabled = !mFlashEnabled;
        mShortVideoRecorder.setFlashEnabled(mFlashEnabled);
        mSwitchFlashBtn.setActivated(mFlashEnabled);
    }

    public void onClickQRCode(View view) {
        hideAndShowQr(!isShowQr);
    }

    public void onClickAddMixAudio(View v) {
        Intent intent = new Intent();
        if (Build.VERSION.SDK_INT < 19) {
            intent.setAction(Intent.ACTION_GET_CONTENT);
            intent.setType("audio/*");
        } else {
            intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.setType("audio/*");
        }
        startActivityForResult(Intent.createChooser(intent, "请选择混音文件："), REQUEST_CODE_ADD_MIX_MUSIC);
    }

    public void onClickSaveToDraft(View v) {
        final EditText editText = new EditText(this);
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(this).setView(editText).setTitle(getString(R.string.dlg_save_draft_title)).setPositiveButton(getString(R.string.dlg_save_draft_yes), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                ToastUtils.s(VideoRecordActivity.this, mShortVideoRecorder.saveToDraftBox(editText.getText().toString()) ? getString(R.string.toast_draft_save_success) : getString(R.string.toast_draft_save_fail));
            }
        });
        alertDialog.show();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_ADD_MIX_MUSIC && resultCode == Activity.RESULT_OK) {
            String selectedFilepath = GetPathFromUri.getPath(this, data.getData());
            Log.i(TAG, "Select file: " + selectedFilepath);
            if (selectedFilepath != null && !"".equals(selectedFilepath)) {
                mShortVideoRecorder.setMusicFile(selectedFilepath);
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onReady() {
        mShortVideoRecorder.setFocusListener(this);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mSwitchFlashBtn.setVisibility(mShortVideoRecorder.isFlashSupport() ? View.VISIBLE : View.GONE);
                mFlashEnabled = false;
                mSwitchFlashBtn.setActivated(mFlashEnabled);
                mRecordBtn.setEnabled(true);
                refreshSeekBar();
                ToastUtils.s(VideoRecordActivity.this, "可以开始拍摄咯");
            }
        });
    }

    @Override
    public void onError(final int code) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ToastUtils.toastErrorCode(VideoRecordActivity.this, code);
            }
        });
    }

    @Override
    public void onDurationTooShort() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ToastUtils.s(VideoRecordActivity.this, "该视频段太短了");
            }
        });
    }

    @Override
    public void onRecordStarted() {
        Log.i(TAG, "record start time: " + System.currentTimeMillis());
    }

    @Override
    public void onRecordStopped() {
        Log.i(TAG, "record stop time: " + System.currentTimeMillis());
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateRecordingBtns(false);
            }
        });
    }

    @Override
    public void onSectionRecording(long sectionDurationMs, long videoDurationMs, int sectionCount) {
        Log.d(TAG, "sectionDurationMs: " + sectionDurationMs + "; videoDurationMs: " + videoDurationMs + "; sectionCount: " + sectionCount);
        updateRecordingPercentageView(videoDurationMs);
    }

    @Override
    public void onSectionIncreased(long incDuration, long totalDuration, int sectionCount) {
        double videoSectionDuration = mDurationVideoStack.isEmpty() ? 0 : mDurationVideoStack.peek().doubleValue();
        if ((videoSectionDuration + incDuration / mRecordSpeed) >= mRecordSetting.getMaxRecordDuration()) {
            videoSectionDuration = mRecordSetting.getMaxRecordDuration();
        }
        Log.d(TAG, "videoSectionDuration: " + videoSectionDuration + "; incDuration: " + incDuration);
        onSectionCountChanged(sectionCount, (long) videoSectionDuration);
    }

    @Override
    public void onSectionDecreased(long decDuration, long totalDuration, int sectionCount) {
        mSectionProgressBar.removeLastBreakPoint();
        if (!mDurationVideoStack.isEmpty()) {
            mDurationVideoStack.pop();
        }
        if (!mDurationRecordStack.isEmpty()) {
            mDurationRecordStack.pop();
        }
        double currentDuration = mDurationVideoStack.isEmpty() ? 0 : mDurationVideoStack.peek().doubleValue();
        onSectionCountChanged(sectionCount, (long) currentDuration);
        updateRecordingPercentageView((long) currentDuration);
    }

    @Override
    public void onRecordCompleted() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ToastUtils.s(VideoRecordActivity.this, "已达到拍摄总时长");
            }
        });
    }

    @Override
    public void onProgressUpdate(final float percentage) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mProcessingDialog.setProgress((int) (100 * percentage));
            }
        });
    }

    @Override
    public void onSaveVideoFailed(final int errorCode) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mProcessingDialog.dismiss();
                ToastUtils.s(VideoRecordActivity.this, "拼接视频段失败: " + errorCode);
            }
        });
    }

    @Override
    public void onSaveVideoCanceled() {
        mProcessingDialog.dismiss();
    }

    @Override
    public void onSaveVideoSuccess(final String filePath) {
        Log.i(TAG, "concat sections success filePath: " + filePath);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mProcessingDialog.dismiss();
                int screenOrientation = (ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE == getRequestedOrientation()) ? 0 : 1;
                if (mIsEditVideo) {
                    VideoEditActivity.start(VideoRecordActivity.this, filePath, screenOrientation);
                } else {
                    PlaybackActivity.start(VideoRecordActivity.this, filePath, screenOrientation);
                }
            }
        });
    }

    private void updateRecordingPercentageView(long currentDuration) {
        final int per = (int) (100 * currentDuration / mRecordSetting.getMaxRecordDuration());
        final long curTime = System.currentTimeMillis();
        if ((mLastRecordingPercentageViewUpdateTime != 0) && (curTime - mLastRecordingPercentageViewUpdateTime < 100)) {
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mRecordingPercentageView.setText((per > 100 ? 100 : per) + "%");
                mLastRecordingPercentageViewUpdateTime = curTime;
            }
        });
    }

    private void refreshSeekBar() {
        final int max = mShortVideoRecorder.getMaxExposureCompensation();
        final int min = mShortVideoRecorder.getMinExposureCompensation();
        boolean brightnessAdjustAvailable = (max != 0 || min != 0);
        Log.e(TAG, "max/min exposure compensation: " + max + "/" + min + " brightness adjust available: " + brightnessAdjustAvailable);

        findViewById(R.id.brightness_panel).setVisibility(brightnessAdjustAvailable ? View.VISIBLE : View.GONE);
        mAdjustBrightnessSeekBar.setOnSeekBarChangeListener(!brightnessAdjustAvailable ? null : new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                if (i <= Math.abs(min)) {
                    mShortVideoRecorder.setExposureCompensation(i + min);
                } else {
                    mShortVideoRecorder.setExposureCompensation(i - max);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        mAdjustBrightnessSeekBar.setMax(max + Math.abs(min));
        mAdjustBrightnessSeekBar.setProgress(Math.abs(min));
    }

    private void onSectionCountChanged(final int count, final long totalTime) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mDeleteBtn.setEnabled(count > 0);
                mConcatBtn.setEnabled(totalTime >= (RecordSettings.DEFAULT_MIN_RECORD_DURATION));
            }
        });
    }

    private void showChooseDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.if_edit_video));
        builder.setPositiveButton(getString(R.string.dlg_yes), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                mIsEditVideo = true;
                mShortVideoRecorder.concatSections(VideoRecordActivity.this);
            }
        });
        builder.setNegativeButton(getString(R.string.dlg_no), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                mIsEditVideo = false;
                mShortVideoRecorder.concatSections(VideoRecordActivity.this);
            }
        });
        builder.setCancelable(false);
        builder.create().show();
    }

    public void onSpeedClicked(View view) {
        if (!mVideoEncodeSetting.IsConstFrameRateEnabled() || !mRecordSetting.IsRecordSpeedVariable()) {
            if (mSectionProgressBar.isRecorded()) {
                ToastUtils.s(this, "变帧率模式下，无法在拍摄中途修改拍摄倍数！");
                return;
            }
        }

        if (mSpeedTextView != null) {
            mSpeedTextView.setTextColor(getResources().getColor(R.color.speedTextNormal));
        }

        TextView textView = (TextView) view;
        textView.setTextColor(getResources().getColor(R.color.colorAccent));
        mSpeedTextView = textView;

        switch (view.getId()) {
            case R.id.super_slow_speed_text:
                mRecordSpeed = RECORD_SPEED_ARRAY[0];
                break;
            case R.id.slow_speed_text:
                mRecordSpeed = RECORD_SPEED_ARRAY[1];
                break;
            case R.id.normal_speed_text:
                mRecordSpeed = RECORD_SPEED_ARRAY[2];
                break;
            case R.id.fast_speed_text:
                mRecordSpeed = RECORD_SPEED_ARRAY[3];
                break;
            case R.id.super_fast_speed_text:
                mRecordSpeed = RECORD_SPEED_ARRAY[4];
                break;
            default:
                break;
        }

        mShortVideoRecorder.setRecordSpeed(mRecordSpeed);
        if (mRecordSetting.IsRecordSpeedVariable() && mVideoEncodeSetting.IsConstFrameRateEnabled()) {
            mSectionProgressBar.setProceedingSpeed(mRecordSpeed);
            mRecordSetting.setMaxRecordDuration(RecordSettings.DEFAULT_MAX_RECORD_DURATION);
            mSectionProgressBar.setFirstPointTime(RecordSettings.DEFAULT_MIN_RECORD_DURATION);
        } else {
            mRecordSetting.setMaxRecordDuration((long) (RecordSettings.DEFAULT_MAX_RECORD_DURATION * mRecordSpeed));
            mSectionProgressBar.setFirstPointTime((long) (RecordSettings.DEFAULT_MIN_RECORD_DURATION * mRecordSpeed));
        }

        mSectionProgressBar.setTotalTime(this, mRecordSetting.getMaxRecordDuration());
    }

    @Override
    public void onManualFocusStart(boolean result) {
        if (result) {
            Log.i(TAG, "manual focus begin success");
            FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) mFocusIndicator.getLayoutParams();
            lp.leftMargin = mFocusIndicatorX;
            lp.topMargin = mFocusIndicatorY;
            mFocusIndicator.setLayoutParams(lp);
            mFocusIndicator.focus();
        } else {
            mFocusIndicator.focusCancel();
            Log.i(TAG, "manual focus not supported");
        }
    }

    @Override
    public void onManualFocusStop(boolean result) {
        Log.i(TAG, "manual focus end result: " + result);
        if (result) {
            mFocusIndicator.focusSuccess();
        } else {
            mFocusIndicator.focusFail();
        }
    }

    @Override
    public void onManualFocusCancel() {
        Log.i(TAG, "manual focus canceled");
        mFocusIndicator.focusCancel();
    }

    @Override
    public void onAutoFocusStart() {
        Log.i(TAG, "auto focus start");
    }

    @Override
    public void onAutoFocusStop() {
        Log.i(TAG, "auto focus stop");
    }

    /**
     * 字节跳动相关
     *
     * @param title
     */
    public void showProgressDialog(String title) {
        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage(title);
        progressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        progressDialog.setIndeterminate(false);
        progressDialog.setProgress(0);
        progressDialog.show();

    }

    public void hideProressDialog() {
        if (null != progressDialog) {
            progressDialog.dismiss();
        }
    }

    public void updateProgressDialog(int progress) {

        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.setProgress(progress);
        }
    }

    private void initViews() {
        llFeature = findViewById(R.id.ll_feature);
        llIdentify = findViewById(R.id.ll_identify);
        llEffect = findViewById(R.id.ll_effect);
        llSticker = findViewById(R.id.ll_sticker);
        ivFaceVerifyShow = findViewById(R.id.iv_face_verify_show);

        llFaceVerify = findViewById(R.id.ll_face_verify);
        tvSimilarityFaceVerify = findViewById(R.id.tv_similarity_face_verify);
        tvCostFaceVerify = findViewById(R.id.tv_cost_face_verify);
        tvResultFaceVerify = findViewById(R.id.tv_result_face_verify);

        mFinderView = findViewById(R.id.qrcode_finder);

        mTipContainer = findViewById(R.id.tip_container);
        mTipManager.init(VideoRecordActivity.this, mTipContainer);

        llIdentify.setOnClickListener(this);
        llEffect.setOnClickListener(this);
        llSticker.setOnClickListener(this);

        // 初始化扫码管理器
        mQrScannerHandler = new RepeatedScannerHandler(this);
        mFaceVerifyHandler = new RepeatedVerifyHandler(this, 10, ResourceHelper.getLicensePath(VideoRecordActivity.this), this);
    }


    /**
     * 根据 TAG 创建对应的 Fragment
     *
     * @param tag Fragment 对应的 tag
     * @return 创建的 Fragment
     */
    private Fragment generateFragment(String tag) {
        switch (tag) {
            case TAG_IDENTIFY:
                IdentifyFragment identifyFragment = new IdentifyFragment();
                identifyFragment.setCallback(new IdentifyFragment.IIdentifyCallback() {
                    @Override
                    public void petFaceOn(boolean flag) {
                        mEffectRenderHelper.setPetDetectOn(flag);
                        if (null != mTipManager) {
                            if (flag) {
                                mTipManager.addPetFaceTip();

                            } else {
                                mTipManager.removePetFaceTip();
                            }
                        }
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        } else {
                            if (faceInfoFragment != null) {
                                faceInfoFragment.onClose();
                            }
                        }
                    }

                    @Override
                    public void face106On(boolean flag) {
                        hideAndShowFaceAction(!flag);
                        mEffectRenderHelper.setFaceDetectOn(flag);
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        } else {
                            if (faceInfoFragment != null) {
                                faceInfoFragment.onClose();
                            }
                        }
                    }

                    @Override
                    public void faceAttrOn(boolean flag) {
                        mEffectRenderHelper.setFaceAttriOn(flag);
                    }

                    @Override
                    public void faceExtraOn(boolean flag) {
                        mEffectRenderHelper.setFaceExtraOn(flag);
                    }


                    @Override
                    public void handDetectOn(boolean flag) {
                        mEffectRenderHelper.setHandDetectOn(flag);
                        if (null != mTipManager) {
                            if (flag) {
                                mTipManager.addHandTip();

                            } else {
                                mTipManager.removeHandTip();
                            }
                        }
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        }
                    }

                    @Override
                    public void skeletonDetectOn(boolean flag) {
                        mEffectRenderHelper.setSkeletonOn(flag);
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        }
                    }

                    @Override
                    public void portraitMattingOn(final boolean flag) {
                        if (null != mSurfaceView) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setPortraitMattingOn(flag);
                                }
                            });
                        }
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        }
                    }

                    @Override
                    public void hairParserOn(final boolean flag) {
                        if (null != mSurfaceView) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setParsingHair(flag);
                                }
                            });
                        }
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        }
                    }

                    @Override
                    public void onPicChoose(Bitmap bitmap) {
                        if (null != mSurfaceView) {
                            mFaceVerifyHandler.setOriginalBitmap(bitmap);
                            ivFaceVerifyShow.setImageBitmap(bitmap);
                        }
                    }

                    @Override
                    public void faceVerifyOn(final boolean flag) {
                        if (null != mSurfaceView) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setFaceVerify(flag);
                                }
                            });
                        }
                        if (flag) {
                            mFaceVerifyHandler.resume();
                        } else {
                            mFaceVerifyHandler.pause();
                        }
                        ivFaceVerifyShow.setVisibility(flag ? View.VISIBLE : View.GONE);
                        llFaceVerify.setVisibility(flag ? View.VISIBLE : View.GONE);
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        }
                    }

                    @Override
                    public void distanceOn(final boolean flag) {
                        if (mSurfaceView != null) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setHumanDistOn(flag);
                                }
                            });
                        }
                        if (flag) {
                            onFragmentWorking(mIdentifyFragment);
                        }
                    }
                });
                mIdentifyFragment = identifyFragment;
                return identifyFragment;
            case TAG_EFFECT:
                final EffectFragment effectFragment = new EffectFragment();
                effectFragment.setCallback(new EffectFragment.IEffectCallback() {

                    @Override
                    public void updateComposeNodes(final String[] nodes) {
                        LogUtils.e("update composer nodes: " + Arrays.toString(nodes));
                        if (nodes.length > 0) {
                            onFragmentWorking(mEffectFragment);
                        }
                        if (mSurfaceView != null) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setComposeNodes(nodes);
                                }
                            });
                        }
                    }

                    @Override
                    public void updateComposeNodeIntensity(final ComposerNode node) {
                        LogUtils.e("update composer node intensity: node: " + node.getNode() + ", key: " + node.getKey() + ", value: " + node.getValue());
                        if (mSurfaceView != null) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.updateComposeNode(node);
                                }
                            });
                        }
                    }

                    @Override
                    public void onFilterSelected(final File file) {
                        if (null != mSurfaceView) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setFilter(file != null ? file.getAbsolutePath() : "");

                                }
                            });
                        }
                        if (file != null) {
                            onFragmentWorking(mEffectFragment);
                        }
                    }

                    @Override
                    public void onFilterValueChanged(final float cur) {
                        if (null != mSurfaceView) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.updateIntensity(BytedEffectConstants.IntensityType.Filter, cur);
                                }
                            });
                        }
                    }

                    @Override
                    public void setEffectOn(final boolean isOn) {
                        if (mSurfaceView != null) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setEffectOn(isOn);
                                }
                            });
                        }
                    }
                });
                mEffectFragment = effectFragment;
                return effectFragment;
            case TAG_STICKER:
                StickerFragment stickerFragment = new StickerFragment();
                stickerFragment.setCallback(new StickerFragment.IStickerCallback() {
                    @Override
                    public void onStickerSelected(final File file) {
                        if (file != null) {
                            onFragmentWorking(mStickerFragment);
                        }
                        if (null != mSurfaceView) {
                            mSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    mEffectRenderHelper.setSticker(file != null ? file.getAbsolutePath() : "");
                                }
                            });
                        }
                    }
                });
                mStickerFragment = stickerFragment;
                return stickerFragment;
            default:
                return null;
        }
    }

    /**
     * 展示某一个 feature 面板
     *
     * @param tag 用于标志 Fragment 的 tag {@value TAG_IDENTIFY}
     */
    private void showFeature(String tag) {
        if (mSurfaceView == null) {
            return;
        }
        if (mEffectRenderHelper == null) {
            return;
        }
        mButtons.setVisibility(View.GONE);
        FragmentManager fm = getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();
        ft.setCustomAnimations(R.anim.board_enter, R.anim.board_exit);
        Fragment fragment = fm.findFragmentByTag(tag);

        if (fragment == null) {
            fragment = generateFragment(tag);
            ft.add(R.id.board_container, fragment, tag).commit();
        } else {
            ft.show(fragment).commit();
        }
        showOrHideBoard(false);
    }

    /**
     * 关闭所有的 feature 面板
     *
     * @return 是否成功关闭某个面板，即是否有面板正在开启中
     */
    private boolean closeFeature() {
        boolean hasFeature = false;

        Fragment showedFragment = null;
        if (mIdentifyFragment != null && !mIdentifyFragment.isHidden()) {
            showedFragment = mIdentifyFragment;
            hasFeature = true;
        } else if (mEffectFragment != null && !mEffectFragment.isHidden()) {
            showedFragment = mEffectFragment;
            hasFeature = true;
        } else if (mStickerFragment != null && !mStickerFragment.isHidden()) {
            showedFragment = mStickerFragment;
            hasFeature = true;
        }

        if (hasFeature) {
            getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.board_enter, R.anim.board_exit).hide(showedFragment).commit();
        }

        showOrHideBoard(true);
        return hasFeature;
    }

    /**
     * 展示或关闭菜单面板
     *
     * @param show 展示
     */
    private void showOrHideBoard(boolean show) {
        if (show) {
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    llFeature.setVisibility(View.VISIBLE);
                }
            }, ANIMATOR_DURATION);
        } else {
            llFeature.setVisibility(View.GONE);
        }
    }

    /**
     * 控制显示或隐藏二维码扫描器
     */
    public void hideAndShowQr(final boolean flag) {
        isShowQr = flag;
        if (null != mFinderView) {
            mFinderView.setVisibility(flag ? View.VISIBLE : View.GONE);
        }
        if (null != mSurfaceView) {
            mSurfaceView.queueEvent(new Runnable() {
                @Override
                public void run() {
                    mEffectRenderHelper.setQrDecoding(flag);
                    if (flag) {
                        mQrScannerHandler.resume();
                    } else {
                        mQrScannerHandler.pause();
                    }

                }
            });
        }
    }

    /**
     * 控制显示或者隐藏人脸检测结果
     *
     * @param hide
     */
    private void hideAndShowFaceAction(boolean hide) {
        FragmentManager fm = getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();
        faceInfoFragment = (FaceInfoFragment) fm.findFragmentByTag("action");

        if (hide) {
            if (null != faceInfoFragment) {
                ft.hide(faceInfoFragment).commit();
            }
        } else {
            if (null == faceInfoFragment) {
                faceInfoFragment = new FaceInfoFragment();
                ft.replace(R.id.faceinfotrans, faceInfoFragment, "action").commit();

            } else {
                ft.show(faceInfoFragment).commit();
            }
        }
    }

    /**
     * 注册检测结果回调 将结果信息返回到VideoRecordActivity中展示
     */
    private void initEffectHelper() {

        mEffectRenderHelper = new EffectRenderHelper(this);
        mShortVideoRecorder.setVideoFilterListener(new PLVideoFilterListener() {
            @Override
            public void onSurfaceCreated() {
            }

            @Override
            public void onSurfaceChanged(int width, int height) {
                mSurfaceWidth = width;
                mSurfaceHeight = height;
                mIsSet = false;
            }

            @Override
            public void onSurfaceDestroy() {
                mIsSet = false;
                mTextureProcessor.release();
            }

            @Override
            public int onDrawFrame(int texId, int texWidth, int texHeight, long timestampNs, float[] transformMatrix) {
                if (!mIsSet) {
                    mCameraWidth = texWidth;
                    mCameraHeight = texHeight;

                    mEffectRenderHelper.setImageSize(texWidth, texHeight);
                    mEffectRenderHelper.initSDKModules();
                    mEffectRenderHelper.recoverStatus(VideoRecordActivity.this);

                    mEffectRenderHelper.initViewPort(mSurfaceWidth, mSurfaceHeight);

                    mTextureProcessor = new TextureProcessor();
                    mTextureProcessor.setup();
                    mTextureProcessor.setViewportSize(texWidth, texHeight);
                    mIsSet = true;
                }

                texId = mTextureProcessor.draw(texId);
                BytedEffectConstants.Rotation rotation = OrientationSensor.getOrientation();
                int destTexId=mEffectRenderHelper.processTexture(texId, rotation, timestampNs);
                destTexId=mTextureProcessor.draw(destTexId);

                return destTexId;
            }
        });

        mEffectRenderHelper.addResultCallback(new EffectRenderHelper.ResultCallback<BefFaceInfo>() {
            @Override
            public void doResult(final BefFaceInfo befFaceInfo, int framecount) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        faceInfoFragment.updateProperty(befFaceInfo, mEffectRenderHelper.isFaceAttrOn());
                    }
                });
            }
        });

        mEffectRenderHelper.addResultCallback(new EffectRenderHelper.ResultCallback<BefHandInfo>() {
            @Override
            public void doResult(final BefHandInfo handInfo, int framecount) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null == mSurfaceView || null == mTipManager) {
                            return;
                        }
                        float radio = mEffectRenderHelper.getRadio();
                        int glpreviewWidth = (int) (mCameraWidth * radio);
                        int glpreviewHeight = (int) (mCameraHeight * radio);
                        int sufaceViewHeight = mSurfaceWidth;
                        int sufaceViewWidth = mSurfaceHeight;
                        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
                            mTipManager.updateHandInfo(handInfo, glpreviewHeight, glpreviewWidth, sufaceViewHeight, sufaceViewWidth);
                        } else {
                            mTipManager.updateHandInfo(handInfo, glpreviewWidth, glpreviewHeight, sufaceViewHeight, sufaceViewWidth);
                        }
                    }
                });
            }
        });

        mEffectRenderHelper.addResultCallback(new EffectRenderHelper.ResultCallback<BefPetFaceInfo>() {
            @Override
            public void doResult(final BefPetFaceInfo petFaceInfo, int framecount) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null == mSurfaceView || null == mTipManager) {
                            return;
                        }
                        float radio = mEffectRenderHelper.getRadio();
                        int glpreviewWidth = (int) (mCameraWidth * radio);
                        int glpreviewHeight = (int) (mCameraHeight * radio);
                        int sufaceViewHeight = mSurfaceWidth;
                        int sufaceViewWidth = mSurfaceHeight;
                        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
                            mTipManager.updatePetFaceInfo(petFaceInfo, glpreviewHeight, glpreviewWidth, sufaceViewHeight, sufaceViewWidth);

                        } else {
                            mTipManager.updatePetFaceInfo(petFaceInfo, glpreviewWidth, glpreviewHeight, sufaceViewHeight, sufaceViewWidth);

                        }
                    }
                });
            }
        });

        mEffectRenderHelper.addResultCallback(new EffectRenderHelper.ResultCallback<BefDistanceInfo>() {
            @Override
            public void doResult(final BefDistanceInfo distanceResult, int framecount) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null == mSurfaceView || null == mTipManager) {
                            return;
                        }
                        float radio = mEffectRenderHelper.getRadio();
                        int glpreviewWidth = (int) (mCameraWidth * radio);
                        int glpreviewHeight = (int) (mCameraHeight * radio);
                        int sufaceViewHeight = mSurfaceWidth;
                        int sufaceViewWidth = mSurfaceHeight;
                        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {

                            mTipManager.updateDistanceInfo(distanceResult, glpreviewHeight, glpreviewWidth, sufaceViewHeight, sufaceViewWidth);

                        } else {
                            mTipManager.updateDistanceInfo(distanceResult, glpreviewWidth, glpreviewHeight, sufaceViewHeight, sufaceViewWidth);

                        }
                    }
                });

            }
        });

        mEffectRenderHelper.addResultCallback(new EffectRenderHelper.ResultCallback<FaceVerifyResult>() {
            @Override
            public void doResult(final FaceVerifyResult faceVerifyResult, int framecount) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null == mSurfaceView || null == mTipManager || null == tvSimilarityFaceVerify || null == tvCostFaceVerify) {
                            return;
                        }
                        if (null == faceVerifyResult) {
                            tvSimilarityFaceVerify.setText("0.00");
                            tvCostFaceVerify.setText("0ms");
                            tvResultFaceVerify.setText("");
                        } else {
                            tvSimilarityFaceVerify.setText(df.format(faceVerifyResult.getSimilarity()));
                            tvCostFaceVerify.setText(faceVerifyResult.getCost() + "ms");
                            if (SAME_FACE_SCORE.compareTo(faceVerifyResult.getSimilarity()) < 0) {
                                tvResultFaceVerify.setText(R.string.face_verify_detect);
                            } else {
                                tvResultFaceVerify.setText(R.string.face_verify_no_detect);
                            }
                        }
                    }
                });
            }

        });
    }

    @Override
    public void onClick(View v) {
        if (CommonUtils.isFastClick()) {
            ToasUtils.show("too fast click");
            return;
        }
        switch (v.getId()) {
            case R.id.ll_identify:
                showFeature(TAG_IDENTIFY);
                break;
            case R.id.ll_effect:
                showFeature(TAG_EFFECT);
                break;
            case R.id.ll_sticker:
                showFeature(TAG_STICKER);
                break;
            default:
                break;
        }
    }


    @Override
    public void onBackPressed() {
        if (closeFeature()) {
            return;
        }
        super.onBackPressed();
    }


    @Override
    public void onDownloadSuccess(String dir, String path) {
        LogUtils.d("onDownloadSuccess " + path);
        if (null == mHandler) {
            return;
        }
        mHandler.sendEmptyMessage(DOWNLOAD_SUCCESS);
        dir = dir + System.currentTimeMillis();
        final String dstDir = DownloadStickerManager.getStickerPath(VideoRecordActivity.this, dir);
        if (DownloadStickerManager.unzip(path, dstDir)) {
            final String licensePath = DownloadStickerManager.getLicensePath(dstDir);
            if (TextUtils.isEmpty(licensePath)) {
                LogUtils.e("license file not found in sticker!!");
                mHandler.sendEmptyMessage(FILE_CHECK_FAIL);
                return;
            }
            LogUtils.d("licensePath =" + licensePath);
            LogUtils.d("stickerPath =" + dstDir);


            if (null != mSurfaceView) {
                mSurfaceView.queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        int ret = mEffectRenderHelper.initTest(VideoRecordActivity.this, licensePath);

                        if (ret != BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC) {
                            LogUtils.e("mEffectRenderHelper.initTest failure!! ret =" + ret);
                            mHandler.sendEmptyMessage(LICENSE_CHECK_FAIL);
                            return;
                        }
                        mEffectRenderHelper.setSticker("");
                        boolean result = mEffectRenderHelper.setSticker(dstDir);
                        if (result) {
                            mHandler.sendEmptyMessage(STICKER_LOAD_SUCCESS);
                        } else {
                            mHandler.sendEmptyMessage(STICKER_LOAD_FAIL);
                            LogUtils.e("setSticker return " + result);
                        }
                    }
                });
            }

        } else {
            mHandler.sendEmptyMessage(UNZIP_FAIL);
            LogUtils.e("sticker unizp fail!!");
        }
    }

    @Override
    public void onDownloading(int progress) {
        updateProgressDialog(progress);

    }

    @Override
    public void onDownloadFail() {
        LogUtils.e("onDownloadFail");
        if (null != mHandler) {
            mHandler.sendEmptyMessage(DOWNLOAD_FAIL);
        }
    }

    @Override
    public void onDecodeSuccess(Result result) {
        String id = StickerCodeParser.parseId(result);
        LogUtils.d(" sticker id =" + id);
        if (TextUtils.isEmpty(id)) {
            ToasUtils.show(getString(R.string.sticker_parse_fail));
            mQrScannerHandler.resume();
            return;
        }

        hideAndShowQr(false);
        if (!NetworkUtil.isNetworkConnected(VideoRecordActivity.this)) {
            ToasUtils.show(getString(R.string.network_error));
            return;
        }
        showProgressDialog(getString(R.string.download_sticker));
        DownloadUtil.get().download(id, ResourceHelper.getDownloadedStickerDir(VideoRecordActivity.this), this);

    }

    @Override
    public void onVerifyCallback(FaceVerifyResult result) {
        mEffectRenderHelper.dispatchResult(FaceVerifyResult.class, result, 0);
    }

    @Override
    public void requestDecodeFrame(Message msg) {
        mEffectRenderHelper.requestPreviewFrame(msg);
    }

    @Override
    public void requestVerifyFrame(Message msg) {
        mEffectRenderHelper.requestPreviewFrame(msg);
    }

    @Override
    public void onPicChoose(int validNum) {
        if (validNum < 1) {
            ToasUtils.show(getString(R.string.no_face_detected));
        } else if (validNum > 1) {
            ToasUtils.show(getString(R.string.face_more_than_one));
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        finish();
    }

    private static class InnerHandler extends Handler {
        private final WeakReference<VideoRecordActivity> mActivity;

        public InnerHandler(VideoRecordActivity activity) {
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            VideoRecordActivity activity = mActivity.get();
            if (activity != null) {
                switch (msg.what) {
                    case DOWNLOAD_SUCCESS:
                        activity.hideProressDialog();
                        break;

                    case DOWNLOAD_FAIL:
                        activity.hideProressDialog();
                        ToasUtils.show(activity.getString(R.string.download_fail));
                        break;

                    case UNZIP_FAIL:
                        activity.hideProressDialog();
                        ToasUtils.show(activity.getString(R.string.unip_fail));
                        break;

                    case FILE_CHECK_FAIL:
                        activity.hideProressDialog();
                        ToasUtils.show(activity.getString(R.string.file_check_fail));
                        break;
                    case LICENSE_CHECK_FAIL:
                        activity.hideProressDialog();
                        ToasUtils.show(activity.getString(R.string.license_check_fail));
                        break;
                    case STICKER_LOAD_FAIL:
                        activity.hideProressDialog();
                        ToasUtils.show(activity.getString(R.string.sticker_load_fail));
                        break;
                    case STICKER_LOAD_SUCCESS:
                        activity.hideProressDialog();
                        ToasUtils.show(activity.getString(R.string.sticker_load_success));
                        break;

                    case CAPTURE_FAIL:
                        ToasUtils.show(activity.getString(R.string.sticker_load_fail));
                        break;
                    case CAPTURE_SUCCESS:
                        CaptureResult captureResult = (CaptureResult) msg.obj;
                        SavePicTask task = new SavePicTask(mActivity.get());
                        task.execute(captureResult);
                        break;
                    default:
                        break;
                }
            }
        }

    }

    static class SavePicTask extends AsyncTask<CaptureResult, Void, String> {
        private WeakReference<Context> mContext;

        public SavePicTask(Context context) {
            mContext = new WeakReference<>(context);
        }

        @Override
        protected String doInBackground(CaptureResult... captureResults) {
            if (captureResults.length == 0) {
                return "captureResult arrayLength is 0";
            }
            Bitmap bitmap = Bitmap.createBitmap(captureResults[0].getWidth(), captureResults[0].getHeight(), Bitmap.Config.ARGB_8888);
            bitmap.copyPixelsFromBuffer(captureResults[0].getByteBuffer().position(0));
            File file = BitmapUtils.saveToLocal(bitmap);
            if (file.exists()) {
                return file.getAbsolutePath();
            } else {
                return "";
            }
        }

        @Override
        protected void onPostExecute(String path) {
            super.onPostExecute(path);
            if (TextUtils.isEmpty(path)) {
                ToasUtils.show("图片保存失败");
                return;
            }
            if (mContext.get() == null) {
                try {
                    new File(path).delete();
                } catch (Exception ignored) {
                }
                ToasUtils.show("图片保存失败");
            }
            try {
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.DATA, path);
                values.put(MediaStore.Images.Media.MIME_TYPE, "image/*");
                mContext.get().getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            } catch (Exception e) {
                e.printStackTrace();
            }
            ToasUtils.show("保存成功，路径：" + path);
        }
    }

    /**
     * 当用户选择贴纸时，利用回调接口，关闭对应的开关
     */
    private void onFragmentWorking(Fragment fragment) {
        if (fragment instanceof OnCloseListener) {
            if (fragment != mWorkingFragment) {
                if (mWorkingFragment != null) {
                    mWorkingFragment.onClose();
                }
                mWorkingFragment = (OnCloseListener) fragment;
            }
        } else {
            throw new IllegalArgumentException("fragment " + fragment + " must implement " + OnCloseListener.class);
        }
    }

    /**
     * 定义一个回调接口，用于当用户选择其中一个面板时，
     * 关闭其他面板的回调，此接口由各 Fragment 实现，
     * 在 onClose() 方法中要完成各 Fragment 中 UI 的初始化，
     * 即关闭用户已经开启的开关
     */
    public interface OnCloseListener {
        void onClose();
    }


}
