package com.bytedance.labcv.effectsdk;

import android.graphics.PointF;
import android.graphics.Rect;

import java.util.Arrays;

/**
 * 人手检测结果定义
 * Hand detected results
 */
public class BefHandInfo {
    // Amount of hand detected 检测到的hand的数量
    private int handCount = 0;

    // Information of hand detected 检测到的手信息
    private BefHand[] hands;

    public int getHandCount() {
        return handCount;
    }

    public BefHand[] getHands() {
        return hands;
    }


    @Override
    public String toString() {
        return "BefHandInfo{" +
                "hands=" + Arrays.toString(hands) +
                ", handCount=" +handCount +
                '}';
    }

    /**
     * 单个人手模型
     * Single hand model
     */
    public static class BefHand{

        // 手的id
        // Id of hand
        private int id;

        // 手部的矩形框
        // Rect box of hand
        private Rect rect;

        // 手部动作 bef_hand_types[]的index [0--20)
        // Action of hand
        private int action;

        // 手部旋转角度 仅手张开时比较准确
        // The angle of hand. It is more accurate when only the hand is open
        private float rotAngle;

        // 手部动作置信度
        // Confidence in hand action
        private float score;

        // 双手夹角
        // Hands Angle
        private float rotAngleBothhand;

        // 手部关键点, 如果没有检测到，则置为0
        // The key point of hand. If it's not detected, set 0
        private BefKeyPoint[] keyPoints;

        // 手部扩展点，如果没有检测到，则置为0
        // The extend key point. If it's not detected, set 0
        private BefKeyPoint[] keyPointsExt;
        // 动态手势 1 击拳 2 鼓掌
        // Dynamic hand gestures 1 punch 2 Applause
        private int seqAction;

        public int getId() {
            return id;
        }

        public Rect getRect() {
            return rect;
        }

        public int getAction() {
            return action;
        }

        public float getRotAngle() {
            return rotAngle;
        }

        public float getScore() {
            return score;
        }

        public float getRotAngleBothhand() {
            return rotAngleBothhand;
        }

        public BefKeyPoint[] getKeyPoints() {
            return keyPoints;
        }

        public BefKeyPoint[] getKeyPointsExt() {
            return keyPointsExt;
        }

        public int getSeqAction() {
            return seqAction;
        }

        @Override
        public String toString() {
            return "BefHand{" + "id ="+id + " rect = "+rect.toString() +
                    " action ="+action + " rotAngle ="+rotAngle + " score ="+ score + " rotAngleBothhand ="+rotAngleBothhand
                      +  "}";

        }
    }

    /**
     * 关键点
     */
    public static class BefKeyPoint{
        float x; // cols, range between [0, width]
        float y; // rows, range between [0, height]
        boolean is_detect; // if this is false,  x,y is useless

        public BefKeyPoint(float x, float y, boolean is_detect) {
            this.x = x;
            this.y = y;
            this.is_detect = is_detect;
        }
        public PointF asPoint() {
            return new PointF(x, y);
        }

        @Override
        public String toString() {
            return "BefKeyPoint { x ="+x + " y ="+ y + " is_detect ="+is_detect + "}";
        }
    }



}


