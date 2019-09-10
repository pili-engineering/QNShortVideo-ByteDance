// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
package com.bytedance.labcv.effectsdk;

public class BytedEffectConstants {

    public static final String TAG = "bef_effect_ai";

    /**
     * 可检测的最多人体数目
     * The maximum number of skeleton that can be detected
     */
    public final static int BEF_SKELETON_MAX_NUM = 2;

    /**
     * faster face detection algorithm  更快的人脸检测模型
     */
    public static final int BEF_DETECT_SMALL_MODEL = 0x00200000;

    /**
     * 错误码枚举
     * Error code enumeration
     */
    public static class BytedResultCode {

        /**
         * 成功返回
         * return success
         */
        public static final int BEF_RESULT_SUC = 0;

        /**
         * 内部错误
         * Internal error
         */
        public static final int BEF_RESULT_FAIL = -1;

        /**
         * 文件没找到
         * File not find
         */
        public static final int BEF_RESULT_FILE_NOT_FIND = -2;

        /**
         * 数据错误
         * Data error
         */
        public static final int BEF_RESULT_FAIL_DATA_ERROR = -3;

        /**
         * 无效的句柄
         * Invalid handler
         */
        public static final int BEF_RESULT_INVALID_HANDLE = -4;

        /**
         * 无效的授权
         * Invalid licence
         */
        public static final int BEF_RESULT_INVALID_LICENSE = -114;

        /**
         * 无效的图片格式
         * Invalid image format
         */
        public static final int BEF_RESULT_INVALID_IMAGE_FORMAT = -7;

        /**
         * 模型加载失败
         * model load error
         */
        public static final int BEF_RESULT_MODEL_LOAD_FAILURE = -8;

    }


    /**
     * 图像格式
     * Image format
     */
    public enum PixlFormat {
        RGBA8888(0),
        BGRA8888(1),
        BGR888(2),
        RGB888(3),
        BEF_AI_PIX_FMT_YUV420P(5),
        BEF_AI_PIX_FMT_NV12(6),
        BEF_AI_PIX_FMT_NV21(7);
        private int value;

        PixlFormat(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }


    /**
     * 图像旋转角
     * Image rotation
     */
    public enum Rotation {
        /**
         * 图像不需要旋转，图像中的人脸为正脸
         * The image does not need to be rotated. The face in the image is positive
         */
        CLOCKWISE_ROTATE_0(0),
        /**
         * 图像需要顺时针旋转90度，使图像中的人脸为正
         * The image needs to be rotated 90 degrees clockwise so that the face in the image is positive
         */
        CLOCKWISE_ROTATE_90(1),
        /**
         * 图像需要顺时针旋转180度，使图像中的人脸为正
         * The image needs to be rotated 180 degrees clockwise so that the face in the image is positive
         */
        CLOCKWISE_ROTATE_180(2),
        /**
         * 图像需要顺时针旋转270度，使图像中的人脸为正
         * The image needs to be rotated 270 degrees clockwise so that the face in the image is positive
         */
        CLOCKWISE_ROTATE_270(3);

        public int id = 0;

        Rotation(int id) {
            this.id = id;
        }
    }

    /**
     * 检测模式枚举
     * Check mode enumeration
     */
    public static class DetectMode {
        /**
         * video mode 视频模式
         */
        public static final int BEF_DETECT_MODE_VIDEO = 0x00020000;
        /**
         * View slow mode 视频SLOW模式 能检测到更小的人脸
         */
        public static final int BEF_DETECT_MODE_VIDEO_SLOW = 0x00010000;
        /**
         * image detect 图片模式
         */
        public static final int BEF_DETECT_MODE_IMAGE = 0x00040000;

        /**
         * image detect 图片SLOW模式
         */
        public static final int BEF_DETECT_MODE_IMAGE_SLOW = 0x00080000;
    }

    /**
     * 人脸检测参数类型枚举
     * FaceDetect param type enum
     */
    public static class FaceDetectType{
        // 设置每隔多少帧进行一次人脸检测(默认值有人脸时24, 无人脸时24/3=8), 值越大,
        // cpu占用率越低, 但检测出新人脸的时间越长.
        /**
         * Set the number of frames for face detection every once in a while
         * (the default value is 24 when there is a face, and 24/3=8 when there is no face),
         * the higher the value is，
         * The lower the CPU usage, the longer it takes to detect a new face.
         */
       public static final int  BEF_FACE_PARAM_FACE_DETECT_INTERVAL = 1;  // default 24

        // 设置能检测到的最大人脸数目(默认值5),
        // 当跟踪到的人脸数大于该值时，不再进行新的检测. 该值越大, 但相应耗时越长.
        // 设置值不能大于 AI_MAX_FACE_NUM
        /**
         * Set the maximum number of faces that can be detected (default value is 5),
         * when the number of faces tracked is greater than this value, no new detection will be performed.
         * The higher the value, the longer the corresponding time.
         * The value cannot be greater than AI_MAX_FACE_NUM
         */
        public static final int  BEF_FACE_PARAM_MAX_FACE_NUM = 2; // default 5

        // 动态调整能够检测人脸的大小，视频模式强制是4，图片模式可以通过设置为8，检测更小的人脸，检测级别，越高代表能检测更小的人脸，取值范围：4～10
        /**
         * Dynamic adjustment can detect the size of face, video mode is forced to be 4,
         * picture mode can be set to 8, detect smaller face, detection level,
         * the higher means can detect smaller face, value range: 4 ~ 10
         */
        public static final int  BEF_FACE_PARAM_MIN_DETECT_LEVEL = 3;

        // base 关键点去抖参数，[1-30]
        // Base key debounce parameters
        public static final int  BEF_FACE_PARAM_BASE_SMOOTH_LEVEL = 4;

        // extra 关键点去抖参数，[1-30]
        // Extra key debounce parameters
        public static final int  BEF_FACE_PARAM_EXTRA_SMOOTH_LEVEL = 5;

        // 嘴巴 mask 去抖动参数， [0-1], 默认0， 平滑效果更好，速度更慢
        // Mouth mask to debounce parameters
        public static final int  BEF_FACE_PARAM_MASK_SMOOTH_TYPE = 6;

    }

    /**
     * 人脸动作枚举
     * Enumeration of facial actions
     */
    public static class FaceAction {

        /**
         * 106 key points face detect, 106 点人脸检测
         */
        public static final int BEF_FACE_DETECT = 0x00000001;
        /**
         * eye blink, 眨眼
         */
        public static final int BEF_EYE_BLINK = 0x00000002;
        /**
         * mouth open, 嘴巴大张
         */
        public static final int BEF_MOUTH_AH = 0x00000004;
        /**
         * shake head, 摇头
         */
        public static final int BEF_HEAD_SHAKE = 0x00000008;
        /**
         * nod, 点头
         */
        public static final int BEF_HEAD_NOD = 0x00000010;
        /**
         * brow jump, 眉毛挑动
         */
        public static final int BEF_BROW_RAISE = 0x00000020;
        /**
         * pout, 嘴巴嘟嘴
         */
        public static final int BEF_MOUTH_POUT = 0x00000040;
        /**
         * 检测上面所有的动作
         * all
         */
        public static final int BEF_DETECT_FULL = 0x0000007F;

    }

    /**
     * 人脸附加关键点模型类型
     * Facial additional model
     */
    public class FaceExtraModel {
        /**
         * 检测二级关键点: 眉毛, 眼睛, 嘴巴
         * Detect secondary key points: eyebrows, eyes, mouth
         */
        public static final int BEF_MOBILE_FACE_240_DETECT = 0x00000100;
        /**
         * 检测二级关键点: 眉毛, 眼睛, 嘴巴，虹膜
         * Detect secondary key points: eyebrows, eyes, mouth, iris
         */
        public static final int BEF_MOBILE_FACE_280_DETECT = 0x00000900;

        /**
         * 检测二级关键点: 眉毛, 眼睛, 嘴巴，更快
         * Detect secondary key points: eyebrows, eyes, mouth, faster
         */
        public static final int BEF_MOBILE_FACE_240_DETECT_FASTMODE = 0x00300000;
    }


    /**
     * 强度类型
     * The intensity of the type
     */
    public enum IntensityType {
        /**
         * 调节滤镜
         * Adjust the filter
         */
        Filter(12),
        /**
         * 调节美白
         * Adjust the whitening
         */
        BeautyWhite(1),
        /**
         * 调节磨皮
         * Adjust the exfoliating
         */
        BeautySmooth(2),
        /**
         * 同时调节瘦脸和大眼
         * Adjust for thin face and large eyes
         */
        FaceReshape(3),
        /**
         * 调节锐化
         * Adjust the sharpening
         */
        BeautySharp(9),
        /**
         * 唇色
         * Lips
         */
        MakeUpLip(17),
        /**
         * 腮红
         * Blusher
         */
        MakeUpBlusher(18);

        private int id;

        public int getId() {
            return id;
        }

        IntensityType(int id) {
            this.id = id;
        }
    }

    /**
     * 手势相关模型类型
     * hand model
     */
    public enum HandModelType {
        /**
         * 检测手，必须加载
         * Detect hand， must to be loaded
         */
        BEF_HAND_MODEL_DETECT(0x0001),
        /**
         * 检测手位置框，必须加载
         * Detect hand box， must load
         */
        BEF_HAND_MODEL_BOX_REG(0x0002),
        /**
         * 手势分类，可选
         * Classification of gestures
         */
        BEF_HAND_MODEL_GESTURE_CLS(0x0004),
        /**
         * 手关键点，可选
         * Key point of hand
         */
        BEF_HAND_MODEL_KEY_POINT(0x0008);
        private int value;

        HandModelType(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }




    /**
     * 人脸属性值枚举
     * Enumeration of face property values
     */
    public static class FaceAttribute {
        /**
         * 年龄
         * age
         */
        public static final int BEF_FACE_ATTRIBUTE_AGE = 0x00000001;
        /**
         * 性别
         * gender
         */
        public static final int BEF_FACE_ATTRIBUTE_GENDER = 0x00000002;
        /**
         * 表情
         * expression
         */
        public static final int BEF_FACE_ATTRIBUTE_EXPRESSION = 0x00000004;
        /**
         * 颜值
         * Level of appearance
         */
        public static final int BEF_FACE_ATTRIBUTE_ATTRACTIVE = 0x00000008;
        /**
         * 开心程度
         * The degree of happiness
         */
        public static final int BEF_FACE_ATTRIBUTE_HAPPINESS = 0x00000010;
        /**
         * 肤色
         * racial
         */
        public static final int BEF_FACE_ATTRIBUTE_RACIAL = 0x00000020;
    }

    /**
     * 人脸肤色枚举
     * Raical
     */
    public static class FaceRacial {
        /**
         * 白种人
         * white
         */
        public static final int BEF_FACE_ATTRIBUTE_WHITE = 0;
        /**
         * 黄种人
         * yellow
         */
        public static final int BEF_FACE_ATTRIBUTE_YELLOW = 1;
        /**
         * 印度人
         * indian
         */
        public static final int BEF_FACE_ATTRIBUTE_INDIAN = 2;
        /**
         * 黑种人
         * black
         */
        public static final int BEF_FACE_ATTRIBUTE_BLACK = 3;
        /**
         * 支持的肤色个数
         * Number of skin tones supported
         */
        public static final int BEF_FACE_ATTRIBUTE_NUM_RACIAL = 4;
    }


    /**
     * 人脸属性 表情值枚举
     * Enumeration of expression values
     */
    public static class FaceExpression {
        /**
         * 生气
         * angry
         */
        public static final int BEF_FACE_ATTRIBUTE_ANGRY = 0;
        /**
         * 厌恶
         * hate
         */
        public static final int BEF_FACE_ATTRIBUTE_DISGUST = 1;
        /**
         * 害怕
         * afraid
         */
        public static final int BEF_FACE_ATTRIBUTE_FEAR = 2;
        /**
         * 高兴
         * happy
         */
        public static final int BEF_FACE_ATTRIBUTE_HAPPY = 3;
        /**
         * 伤心
         * sad
         */
        public static final int BEF_FACE_ATTRIBUTE_SAD = 4;
        /**
         * 吃惊
         * surprise
         */
        public static final int BEF_FACE_ATTRIBUTE_SURPRISE = 5;
        /**
         * 平静
         * calm
         */
        public static final int BEF_FACE_ATTRIBUTE_NEUTRAL = 6;
        /**
         * 支持的表情个数
         * Number of supported emoticons
         */
        public static final int BEF_FACE_ATTRIBUTE_NUM_EXPRESSION = 7;
    }


    /**
     * 手势检测参数类型
     * Gesture detection parameter types
     */
    public enum HandParamType {
        /**
         * 设置最多的手的个数，默认为1，目前最多设置为2
         * Set the maximum number of hands, default 1, max 2
         */
        BEF_HAND_MAX_HAND_NUM(2),
        /**
         * 设置检测的最短边长度, 默认192
         * Set the length of the shortest edge to be detected, default 192
         */
        BEF_HAND_DETECT_MIN_SIDE(3),
        /**
         * 设置分类平滑参数，默认0.7， 数值越大分类越稳定
         * Set the classification smoothing parameter (default: 0.7).
         * The larger the value, the more stable the classification will be
         */
        BEF_HAND_CLS_SMOOTH_FACTOR(4),
        /**
         * 设置是否使用类别平滑，默认1，使用类别平滑；不使用平滑，设置为0
         * Set whether to use category smoothing, default 1, use category smoothing; No smoothing, set to 0
         */
        BEF_HAND_USE_ACTION_SMOOTH(5),
        /**
         * 降级模式，在低端机型使用，可缩短算法执行时间，但准确率也会降低。默认为0，使用高级模式；如设置为1，则使用降级模式。
         * Degraded mode, used in low-end models, can shorten the algorithm execution time,
         * but also reduce the accuracy. Default is 0, use advanced mode; If set to 1, the degraded mode is used.
         */
        BEF_HAND_ALGO_LOW_POWER_MODE(6),
        /**
         * 自动降级模式，如果检测阈值超过BEF_HAND_ALGO_TIME_ELAPSED_THRESHOLD，则走降级模式，否则，走高级模式。
         * 默认为0，使用高级模式；如设置为1，则使用自动降级模式
         * Automatic degradation mode: if the detection threshold exceeds the BEF_HAND_ALGO_TIME_ELAPSED_THRESHOLD,
         * the degradation mode will be used; otherwise, the advanced mode will be used.
         * default is 0, use advanced mode; If set to 1, use automatic downgrade mode
         */
        BEF_HAND_ALGO_AUTO_MODE(7),
        /**
         * 算法耗时阈值，默认为 15ms
         * Algorithm time threshold, default 15ms
         */
        BEF_HAND_ALGO_TIME_ELAPSED_THRESHOLD(8),
        /**
         * 设置运行时测试算法的执行的次数, 默认是 150 次
         * Sets the number of times the runtime test algorithm is executed
         * default 150
         */
        BEF_HAND_ALGO_MAX_TEST_FRAME(9),
        /**
         * 设置是否使用双手手势， 默认为true
         * Set whether to use two-handed gestures, default true
         */
        BEF_HAND_IS_USE_DOUBLE_GESTURE(10),
        /**
         * 设置回归模型的输入初始框的放大比列
         * Sets the magnification column of the input initial box for the regression model
         */
        BEF_HNAD_ENLARGE_FACTOR_REG(11),

        /**
         * 设置支持火影忍者手势，默认为false，如果开启，则支持包括火影在内的45类手势识别
         * Naruto gestures are supported by setting the default to false,
         * and 45 types of gesture recognition including naruto are supported if enabled
         */
        BEF_HAND_NARUTO_GESTUER(12);


        private int value;

        HandParamType(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }

    }

    /**
     * 人体分割参数
     * Body segmentation parameters
     */
    public enum PortraitMatting
    {
        BEF_PORTAITMATTING_LARGE_MODEL(0),
        BEF_PORTAITMATTING_SMALL_MODEL(1);

        private int value;
        PortraitMatting(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }

    public enum PorraitMattingParamType
    {
        /**
         *  算法参数，用来设置边界的模式
         *       - 0: 不加边界
         *       - 1: 加边界
         *       - 2: 加边界, 其中, 2 和 3 策略不太一样，但效果上差别不大，可随意取一个
         *  Algorithm parameters used to set the boundary mode
         *      - 0: Without borders
         *      - 1: boundary
         *      - 2: Add the boundary, where the strategies of 2 and 3 are not quite the same,
         *          but the effect is not very different, you can arbitrarily choose one
         */
        BEF_MP_EdgeMode(0),
        /**
         * 算法参数，设置调用多少次强制做预测，目前设置 15 即可
         * Algorithm parameters, set how many times to call the mandatory prediction, the current set of 15
         */
        BEF_MP_FrashEvery(1),
        /**
         * 返回短边的长度, 默认值为128, 需要为16的倍数；
         * Returns the length of the short side, which defaults to 128 and needs to be a multiple of 16.
         */
        BEF_MP_OutputMinSideLen(2);

        private int value;

        PorraitMattingParamType(int v){this.value = v;}

        public int getValue(){return value;}
    }

    public enum HumanDistanceParamType{
        BEF_HumanDistanceEdgeMode(0),
        BEF_HumanDistanceCameraFov(1);

        private int value;

        HumanDistanceParamType(int v){this.value = v;}

        public int getValue(){return value;}
    }

    /**
     * 宠物脸检测配置
     * Pet face detection configuration
     */
    public static class PetFaceDetectConfig {
        /**
         * 检测猫
         * Detect cat
         */
        public static final int BEF_PET_FACE_DETECT_CAT = 0x00000001;
        /**
         * 检测狗
         * Detection dog
         */
        public static final int BEF_PET_FACE_DETECT_DOG = 0x00000002;
        /**
         * 快速检测
         * Fast detection
         */
        public static final int BEF_PET_FACE_DETECT_QUICK = 0x00000004;
    }

    /**
     * 宠物脸检测结果类型
     * Type of pet face detection results
     */
    public static class PetFaceDetectType {
        /**
         *  宠物检测为猫
         *  The pet was detected as a cat
         */
        public static final int BEF_PET_FACE_CAT = 1;

        /**
         * 宠物检测结果为狗
         * The pet was detected as a dog
         */
        public static final int BEF_PET_FACE_DOG = 2;

        /**
         * 检测结果为人
         * The pet was detected as a human
         */
        public static final int BEF_PET_FACE_HUMAN = 3;

        /**
         * 未知检测类型
         * The pet was detected as a unknown
         */
        public static final int BEF_PET_FACE_OTHER = 99;
    }

    /**
     * 宠物脸动作枚举
     * Pet face movement enumeration
     */
    public static class PetFaceAction {

        /**
         * 左眼睛睁开
         * Left eye open
         */
        public static final int BEF_LEFT_EYE_PET_FACE = 0x00000001;
        /**
         * 右眼睛睁开
         * Right eye open
         */
        public static final int BEF_RIGHT_EYE_PET_FACE = 0x00000002;
        /**
         * 嘴巴张开
         * Mouth open
         */
        public static final int BEF_MOUTH_PET_FACE = 0x00000004;

    }
}
