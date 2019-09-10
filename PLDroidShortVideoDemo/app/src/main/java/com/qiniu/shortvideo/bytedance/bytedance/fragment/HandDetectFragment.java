package com.qiniu.shortvideo.bytedance.bytedance.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.bytedance.MainActivity;
import com.qiniu.shortvideo.bytedance.bytedance.base.IPresenter;
import com.qiniu.shortvideo.bytedance.bytedance.utils.CommonUtils;
import com.qiniu.shortvideo.bytedance.bytedance.utils.ToasUtils;
import com.qiniu.shortvideo.bytedance.bytedance.view.ButtonView;


/**
 * 手势
 */
public class HandDetectFragment extends BaseFeatureFragment<IPresenter, HandDetectFragment.IHandCallBack>
        implements View.OnClickListener, MainActivity.OnCloseListener {
    private ButtonView bvHand;

    public interface IHandCallBack {
        void handDetectOn(boolean flag);

    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return LayoutInflater.from(getActivity()).inflate(R.layout.fragment_hand_detect, null);
    }

    @Override
    public void onViewCreated(final View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        bvHand = view.findViewById(R.id.bv_hand);

        bvHand.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (CommonUtils.isFastClick()) {
            ToasUtils.show("too fast click");
            return;
        }
        switch (v.getId()) {
            case R.id.bv_hand:
                boolean isOn = !bvHand.isOn();
                getCallback().handDetectOn(isOn);
                bvHand.change(isOn);
                break;
        }
    }

    @Override
    public void onClose() {
        getCallback().handDetectOn(false);

        bvHand.off();
    }
}
