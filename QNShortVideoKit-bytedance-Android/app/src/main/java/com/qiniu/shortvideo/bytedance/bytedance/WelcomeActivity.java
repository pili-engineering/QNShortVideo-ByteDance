package com.qiniu.shortvideo.bytedance.bytedance;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Toast;


import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.activity.VideoRecordActivity;
import com.qiniu.shortvideo.bytedance.bytedance.base.BaseActivity;
import com.qiniu.shortvideo.bytedance.bytedance.contract.WelcomeContract;
import com.qiniu.shortvideo.bytedance.bytedance.contract.presenter.WelcomePresenter;

/**
 * 加载资源界面
 */
public class WelcomeActivity extends BaseActivity<WelcomeContract.Presenter> implements WelcomeContract.View {

    private Button mBtStart;
    private ProgressBar mProgressBar;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome);
        setPresenter(new WelcomePresenter());

        initView();
        if (!mPresenter.resourceReady()) {
            mPresenter.startTask();
        } else {
            mBtStart.setEnabled(true);
            Intent intent = new Intent(WelcomeActivity.this, VideoRecordActivity.class);
            intent.putExtras(getIntent());
            startActivity(intent);
            this.finish();
        }
    }

    private void initView() {
        mBtStart = findViewById(R.id.bt_start);
        mProgressBar = findViewById(R.id.progress);
        // 增加隐藏功能：长按重新加载资源，避免更换资源后要重装应用
        mBtStart.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                mPresenter.startTask();
                return true;
            }
        });
    }

    @Override
    public void onStartTask() {
        mBtStart.setEnabled(false);
        mBtStart.setText(getString(R.string.resource_prepare));
        mProgressBar.setIndeterminate(true);
        mProgressBar.setVisibility(View.VISIBLE);
    }

    @Override
    public void onEndTask(boolean result) {
        mProgressBar.setVisibility(View.GONE);
        if (result) {
            mBtStart.setText(getString(R.string.start));
            mBtStart.setEnabled(true);
            Intent intent = new Intent(WelcomeActivity.this, VideoRecordActivity.class);
            intent.putExtras(getIntent());
            startActivity(intent);
            finish();
        } else {
            Toast.makeText(this, getString(R.string.resource_ready), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public Context getContext() {
        return getApplicationContext();
    }
}
