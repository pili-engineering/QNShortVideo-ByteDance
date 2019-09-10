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


public class SegmentationFragment
        extends BaseFeatureFragment<IPresenter, SegmentationFragment.IPortraitMattingCallback>
        implements View.OnClickListener, MainActivity.OnCloseListener {
    private ButtonView bvSegment;
    private ButtonView bvHairParser;

    public interface IPortraitMattingCallback {
      void portraitMattingOn(boolean mattingOn);
      void hairParserOn(boolean on);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_segmentation, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        bvSegment = view.findViewById(R.id.bv_segment_segment);
        bvHairParser = view.findViewById(R.id.bv_hair_segment);

        bvSegment.setOnClickListener(this);
        bvHairParser.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (CommonUtils.isFastClick()) {
            ToasUtils.show("too fast click");
            return;
        }
        switch (v.getId()) {
            case R.id.bv_segment_segment:
                boolean isSegmentOn = !bvSegment.isOn();
                getCallback().portraitMattingOn(isSegmentOn);
                bvSegment.change(isSegmentOn);
                break;
            case R.id.bv_hair_segment:
                boolean isHairParserOn = !bvHairParser.isOn();
                getCallback().hairParserOn(isHairParserOn);
                bvHairParser.change(isHairParserOn);
                break;
        }
    }

    @Override
    public void onClose() {
        getCallback().portraitMattingOn(false);
        getCallback().hairParserOn(false);

        bvHairParser.off();
        bvSegment.off();
    }
}
