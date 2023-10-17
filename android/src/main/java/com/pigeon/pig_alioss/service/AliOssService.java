package com.pigeon.pig_alioss.service;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.widget.EditText;

import androidx.annotation.NonNull;

import com.alibaba.sdk.android.oss.ClientConfiguration;
import com.alibaba.sdk.android.oss.OSS;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.common.OSSLog;
import com.alibaba.sdk.android.oss.common.auth.OSSAuthCredentialsProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.pigeon.pig_alioss.PigAliOssApplication;
import com.pigeon.pig_alioss.R;
import com.pigeon.pig_alioss.config.Config;
import com.pigeon.pig_alioss.view.UIDisplayer;
import com.pigeon.pig_alioss.view.UIDisplayerI;
import com.pigeon.utils.file.FileUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * @program: android
 * @description: 阿里Oss存储
 * @author: 周立强
 * @create: 2023-09-10 09:26
 */
public class AliOssService {
    String TAG = "UMShareService";
    private static AliOssService aliOssService;
    MethodChannel.Result result;
    String imgServerUrl;
    String callback;
    MethodCall call;

    OssService mService;

    private static final int RESULT_LOAD_IMAGE = 1;


    private String mPicturePath = "";
    UIDisplayer mUIDisplayer;

    public static AliOssService getInstance() {
        if (aliOssService == null) {
            aliOssService = new AliOssService();
            return aliOssService;
        }
        return aliOssService;
    }

    /**
     * @Method init
     * @Author: zhouliqinag
     * @Description:初始化
     */
    public void init(MethodCall call, @NonNull MethodChannel.Result result, EventChannel.EventSink mSink) {
        this.call = call;
        this.result = result;
        String ossEndpoint = call.argument("ossEndpoint")!=null?call.argument("ossEndpoint"):Config.OSS_ENDPOINT;
        String stsServerUrl = call.argument("stsServerUrl")!=null?call.argument("stsServerUrl"):Config.STS_SERVER_URL;
        String callback = call.argument("callback")!=null?call.argument("callback"):"";
        String bucketName = call.argument("bucketName")!=null?call.argument("bucketName"): Config.BUCKET_NAME;
        String imgServerUrl = call.argument("imgServerUrl")!=null?call.argument("imgServerUrl"):"";
        AliOssService.getInstance().imgServerUrl = imgServerUrl;
        AliOssService.getInstance().callback = callback;
        mUIDisplayer = new UIDisplayer(new UIDisplayerI() {
            @Override
            public void returnListent(String type, int state, String msg, String info) {
//                JSONObject data = new JSONObject();
//                try {
//                    if (type.equals("upload") && state == 1) {
//                        data.put("path", Config.OSS_ENDPOINT+info);
//                        data.put("filePath", mPicturePath);
//                    } else if (type.equals("download") && state == 1) {
//                        data.put("path", info);
//                        data.put("filePath", info);
//                    } else if (type.equals("UpdateProgress") && state == 1) {
//                        data.put("progress", info);
//                    } else {
//                        data.put("info", info);
//                    }
//                    data.put("type", type);
//                } catch (JSONException e) {
//                    throw new RuntimeException(e);
//                }
//                if (mSink != null) {
//                    mSink.success(resultJson(state, msg, data));
//                }
            }

        });
        mService = initOSS(ossEndpoint, bucketName,stsServerUrl, mUIDisplayer);
        //设置上传的callback地址，目前暂时只支持putObject的回调
        mService.setCallbackAddress(AliOssService.getInstance().callback);
        result.success(resultJson(1, "初始化成功", null));
    }

    /**
     * @Method upload
     * @Author: zhouliqinag
     * @Description:上传
     * @Param: [fileName:文件名, filePath:本地图片路径]
     */
    public void fileUpload(MethodCall call, @NonNull MethodChannel.Result result, EventChannel.EventSink mSink) {
        this.call = call;
        this.result = result;

        String filePath = call.argument("filePath")!=null?call.argument("filePath"):mPicturePath;
        String objectKey = call.argument("objectKey")!=null?call.argument("objectKey"):"app/" + FileUtil.getFileName(filePath);



//        String flieName = FileUtil.getFileName(mPicturePath);
//        String objectName = "app/" + flieName;
        //String objectName ="文件名";
        //String mPicturePath ="本地图片路径";
        mService.asyncPutImage(objectKey, filePath, new OssService.OssServiceI() {
            @Override
            public void onProgress(int progress, long totalSize,String objectKey) {

                try {
                    JSONObject data = new JSONObject();
                    data.put("progress", progress);
                    data.put("action", "uploadProgress");
                    data.put("objectKey", objectKey);
                    if (mSink != null) {
                        mSink.success(resultJson(1, "上传进度", data));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
            }

            @Override
            public void onSuccess(JSONObject jsonObject) {
                try {
                    JSONObject data = new JSONObject();
                    data.put("url", AliOssService.getInstance().imgServerUrl+jsonObject.getString("objectKey"));
                    data.put("filePath", filePath);
                    if (result != null) {
                        result.success(resultJson(1, "上传成功", data));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
            }

            @Override
            public void onFailure(ServiceException serviceException) {

                try {
                   String info = serviceException.toString();
                    JSONObject data = new JSONObject();
                    data.put("info", info);
                    if (result != null) {
                        result.success(resultJson(0, "上传失败", data));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
            }
        });


//        try {
//            if (type.equals("upload") && state == 1) {
//                data.put("path", Config.OSS_ENDPOINT+info);
//                data.put("filePath", mPicturePath);
//            } else if (type.equals("download") && state == 1) {
//                data.put("path", info);
//                data.put("filePath", info);
//            } else if (type.equals("UpdateProgress") && state == 1) {
//                data.put("progress", info);
//            } else {
//                data.put("info", info);
//            }
//            data.put("type", type);
//        } catch (JSONException e) {
//            throw new RuntimeException(e);
//        }



    }

    /**
     * @Method fileDownload
     * @Author: zhouliqinag
     * @Description:下载
     * @Param: [fileName:文件名]
     */
    public void fileDownload(MethodCall call, @NonNull MethodChannel.Result result, EventChannel.EventSink mSink) {
        this.call = call;
        this.result = result;
        String objectKey = call.argument("objectKey")!=null?call.argument("objectKey"):"app/";

//        String objectName = "app/123.jpg";
        mService.asyncGetImage(objectKey, new OssService.OssServiceI() {
            @Override
            public void onProgress(int progress, long totalSize, String objectKey) {
                try {
                    JSONObject data = new JSONObject();
                    data.put("progress", progress);
                    data.put("action", "downloadProgress");
                    data.put("objectKey", objectKey);
                    if (mSink != null) {
                        mSink.success(resultJson(1, "下载进度", data));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
            }

            @Override
            public void onSuccess(JSONObject jsonObject) {
                try {
                    JSONObject data = new JSONObject();
                    data.put("url", AliOssService.getInstance().imgServerUrl+jsonObject.getString("objectKey"));
                    data.put("filePath", jsonObject.getString("filePath"));
                    if (result != null) {
                        result.success(resultJson(1, "下载成功", data));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
            }

            @Override
            public void onFailure(ServiceException serviceException) {
                try {
                    String info = serviceException.toString();
                    JSONObject data = new JSONObject();
                    data.put("info", info);
                    if (result != null) {
                        result.success(resultJson(0, "下载失败", data));
                    }
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
            }
        });
    }

    /**
     * @Method picSelector
     * @Author: zhouliqinag
     * @Description:图片选择器
     * @Param: [fileName:文件名]
     */
    public void picSelector(MethodCall call, @NonNull MethodChannel.Result result) {
        this.call = call;
        this.result = result;
        Intent i = new Intent(
                Intent.ACTION_PICK,
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

        PigAliOssApplication.getActivity().startActivityForResult(i, RESULT_LOAD_IMAGE);
    }

    /**
     * @Method initOSS
     * @Author: zhouliqinag
     * @Description: 初始化oss存储
     */
    public OssService initOSS(String endpoint, String bucket,String stsServerUrl, UIDisplayer uiDisplayer) {

        // 移动端是不安全环境，不建议直接使用阿里云主账号ak，sk的方式。建议使用STS方式。具体参
        // https://help.aliyun.com/document_detail/31920.html
        // 注意：SDK 提供的 PlainTextAKSKCredentialProvider 只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。具体使用如下
        // 主账户使用方式
        // String AK = "******";
        // String SK = "******";
        // credentialProvider = new PlainTextAKSKCredentialProvider(AK,SK)
        // 以下是使用STS Sever方式。
        // 如果用STS鉴权模式，推荐使用OSSAuthCredentialProvider方式直接访问鉴权应用服务器，token过期后可以自动更新。
        // 详见：https://help.aliyun.com/document_detail/31920.html
        // OSSClient的生命周期和应用程序的生命周期保持一致即可。在应用程序启动时创建一个ossClient，在应用程序结束时销毁即可。

        //使用自己的获取STSToken的类
        OSSCredentialProvider credentialProvider = new OSSAuthCredentialsProvider(stsServerUrl);
        String editBucketName = bucket;
        ClientConfiguration conf = new ClientConfiguration();
        conf.setConnectionTimeout(15 * 1000); // 连接超时，默认15秒
        conf.setSocketTimeout(15 * 1000); // socket超时，默认15秒
        conf.setMaxConcurrentRequest(5); // 最大并发请求书，默认5个
        conf.setMaxErrorRetry(2); // 失败后最大重试次数，默认2次
        OSS oss = new OSSClient(PigAliOssApplication.getActivity(), endpoint, credentialProvider, conf);
        OSSLog.enableLog();
        return new OssService(oss, editBucketName, uiDisplayer);
    }

    /**
     * @Method onActivityResult
     * @Author: zhouliqinag
     * @Description:Activity回调
     * @Date: 15:08 2023/9/10
     */
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == RESULT_LOAD_IMAGE && resultCode == PigAliOssApplication.getActivity().RESULT_OK && null != data) {
            Uri selectedImage = data.getData();
            String[] filePathColumn = {MediaStore.Images.Media.DATA};

            Cursor cursor = PigAliOssApplication.getActivity().getContentResolver().query(selectedImage,
                    filePathColumn, null, null, null);
            cursor.moveToFirst();

            int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
            mPicturePath = cursor.getString(columnIndex);
            Log.d("PickPicture", mPicturePath);
            cursor.close();
            try {
                JSONObject dataJson = new JSONObject();
                dataJson.put("filePath",mPicturePath);
                if (result != null) {
                    result.success(resultJson(1, "操作成功", dataJson));
                }
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
            try {
                //Bitmap bm = mUIDisplayer.autoResizeFromLocalFile(mPicturePath);
                //mUIDisplayer.displayImage(bm);
                /*
                ImageView imageView = (ImageView) findViewById(R.id.imageView);
                imageView.setImageBitmap(bm);*/
                File file = new File(mPicturePath);

                mUIDisplayer.displayInfo("文件: " + mPicturePath + "\n大小: " + String.valueOf(file.length()));
            } catch (Exception e) {
                e.printStackTrace();
                mUIDisplayer.displayInfo(e.toString());
            }
        }
    }

    public String resultJson(int state, String msg, JSONObject dataJson) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("state", state);
            jsonObject.put("msg", msg);
            if (dataJson != null) {
                jsonObject.put("data", dataJson);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

}
