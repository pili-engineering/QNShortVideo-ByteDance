package com.qiniu.shortvideo.bytedance.bytedance.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.activity.VideoRecordActivity;
import com.qiniu.shortvideo.bytedance.bytedance.base.IPresenter;
import com.qiniu.shortvideo.bytedance.bytedance.utils.CommonUtils;
import com.qiniu.shortvideo.bytedance.bytedance.utils.ToasUtils;
import com.qiniu.shortvideo.bytedance.bytedance.view.ButtonView;


public class PetFaceDetectFragment  extends BaseFeatureFragment<IPresenter, PetFaceDetectFragment.IFaceCallback>
        implements View.OnClickListener, VideoRecordActivity.OnCloseListener {
    // 关键点跟踪
    private ButtonView bvFace;

    /**
     * 宠物脸相关设置回调接口，用于和FeatureBoardFragment通信
     */
    public interface IFaceCallback {
        // 宠物脸检测
        void petFaceOn(boolean flag);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return LayoutInflater.from(getActivity()).inflate(R.layout.fragment_pet_face_detect, null);
    }

    @Override
    public void onViewCreated(final View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        bvFace = view.findViewById(R.id.bv_face);

        bvFace.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (CommonUtils.isFastClick()) {
            ToasUtils.show("too fast click");
            return;
        }
        switch (v.getId()) {
            case R.id.bv_face:
                boolean is106On = !bvFace.isOn();
                bvFace.change(is106On);
                getCallback().petFaceOn(is106On);
                break;
        }
    }

    @Override
    public void onClose() {
        getCallback().petFaceOn(false);

        bvFace.off();
    }
}

