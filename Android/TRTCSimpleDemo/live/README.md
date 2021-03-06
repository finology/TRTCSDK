## 适用场景
TRTC 支持四种不同的进房模式，其中视频通话（VideoCall）和语音通话（VoiceCall）统称为[通话模式](https://cloud.tencent.com/document/product/647/32169)，视频互动直播（Live）和语音互动直播（VoiceChatRoom）统称为[直播模式](https://cloud.tencent.com/document/product/647/35428)。

通话模式下的 TRTC，支持单个房间最多300人同时在线，支持最多50人同时发言。适合1对1视频通话、300人视频会议、在线问诊、远程面试、视频客服、在线狼人杀等应用场景。

## 原理解析
TRTC 云服务由两种不同类型的服务器节点组成，分别是“接口机”和“代理机”：

- **接口机**
这些节点都采用最优质的线路和高性能的机器，善于处理端到端的低延时连麦通话，单位时长计费较高。

- **代理机**
这些节点都采用普通的线路和性能一般的机器，善于处理高并发的拉流观看需求，单位时长计费较低。

在通话模式下，TRTC 房间中的所有用户都会被分配到接口机上，相当于每个用户都是“主播”，每个用户随时都可以发言（最高的上行并发限制为50路），因此适合在线会议等场景，不过单个房间的人数限制为300人。

![](https://main.qcloudimg.com/raw/b88a624c0bd67d5d58db331b3d64c51c.gif)

## 示例代码
访问 [Github](https://github.com/tencentyun/TRTCSDK/tree/master/Android/TRTCSimpleDemo) 即可获取本文档相关的实例代码。
![](https://main.qcloudimg.com/raw/6b22e023d733cd16976b00c22dd53b61.png)

## 使用步骤
<span id="step1"> </span>
### 步骤1：集成 SDK 到项目中
可以选择如下任意一种方式将 **TRTC SDK** 集成到项目中。
#### 自动加载（aar）
TRTC SDK 已经发布到 jcenter 库，您可以通过配置 gradle 自动下载更新。
只需要用 Android Studio 打开您自己需要集成 SDK 的工程（TRTCSimpleDemo已经集成好，示例代码可以供您参考），然后通过简单的三个步骤修改 app/build.gradle 文件，就可以完成 SDK 集成：

1. 添加 SDK 依赖
在 dependencies 中添加 TRTCSDK 的依赖。
```
dependencies {
  compile 'com.tencent.liteav:LiteAVSDK_TRTC:latest.release'
}
```
2. 指定 App 使用架构
在 defaultConfig 中，指定 App 使用的 CPU 架构(目前 TRTC SDK 支持 armeabi ， armeabi-v7a 和 arm64-v8a) 。
```
 defaultConfig {
      ndk {
          abiFilters "armeabi", "armeabi-v7a", "arm64-v8a"
      }
  }
```
3. 同步 SDK
单击 Sync Now 按钮，如果您的网络连接 jcenter 没有问题，很快 SDK 就会自动下载集成到工程里。

#### 下载 ZIP 包手动集成
如果您的网络连接 jcenter 有问题，可以考虑在下载页面直接下载 [ZIP 压缩包](https://cloud.tencent.com/document/product/647/32689)，并按照集成文档 [手动集成](https://cloud.tencent.com/document/product/647/32175#.E6.96.B9.E6.B3.95.E4.BA.8C.EF.BC.9A.E6.89.8B.E5.8A.A8.E4.B8.8B.E8.BD.BD.EF.BC.88aar.EF.BC.89) 到您的工程中。


<span id="step2"> </span>
### 步骤2：在工程文件中配置 App 权限
在 **AndroidManifest.xml** 文件中添加摄像头和麦克风，以及网络的申请权限

```
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />

<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```


<span id="step3"> </span>
### 步骤3：初始化 SDK 实例并监听事件回调

1. 使用 [sharedInstance()](https://cloud.tencent.com/document/product/647/32267) 接口创建 `TRTCCloud` 实例。
2. 设置 setListener 属性注册事件回调，并监听相关事件和错误通知。
```java
// 创建 trtcCloud 实例
mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
mTRTCCloud.setListener(new TRTCCloudListener());
```
监听
```java
// 错误通知监听，错误通知意味着 SDK 不能继续运行
@Override
public void onError(int errCode, String errMsg, Bundle extraInfo) {
    Log.d(TAG, "sdk callback onError");
    if (activity != null) {
        Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
        if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
            activity.exitRoom();
        }
    }
}
```

<span id="step4"> </span>
### 步骤4：组装进房参数 TRTCParams
在调用 [enterRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#abfc1841af52e8f6a5f239a846a1e5d5c) 接口时需要填写一个关键参数 [TRTCParams](http://doc.qcloudtrtc.com/group__TRTCCloudDef__android.html#a674b3c744a0522802d68dfd208763b59)，它包含如下四个必填的字段：sdkAppId、userId、userSig 和 roomId。

| 参数名称 | 填写示例 | 字段类型 | 补充说明 |
|---------|---------|---------|---------|
| sdkAppId | 1400000123 | 数字 | 应用ID，您可以在 [控制台](https://console.cloud.tencent.com/trtc/app) >【应用管理】>【应用信息】中查找到。 |
| userId | test_user_001 | 字符串 | 只允许包含大小写英文字母（a-zA-Z）、数字（0-9）及下划线和连词符。 |
| userSig | eJyrVareCeYrSy1SslI... | 字符串 | 基于 userId 可以计算出 userSig，计算方法请参见 [UserSig 计算](https://cloud.tencent.com/document/product/647/17275) 。|
| roomId | 29834 | 数字 | 默认不支持字符串类型的房间号，字符串类型的房间号会拖慢进房速度，如果您确实需要支持字符串类型的房间号，请通过工单联系我们。 |

>! TRTC 同一时间不支持两个相同的 userId 进入房间，否则会相互干扰。

<span id="step5"> </span>
### 步骤5：主播端开启摄像头预览和麦克风采音
1. 主播端调用 [startLocalPreview()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a84098740a2e69e3d1f02735861614116) 可以开启本地的摄像头预览，SDK 也会在此时向系统请求摄像头使用权限。
2. 主播端调用 [setLocalViewFillMode()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#af36ab721c670e5871e5b21a41518b51d) 可以设定本地视频画面的显示模式，其中 Fill 模式代表填充，此时画面可能会被等比放大和裁剪，但不会有黑边。Fit 模式代表适应，此时画面可能会等比缩小以完全显示其内容，可能会有黑边。
3. 主播端调用 [setVideoEncoderParam()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#ae047d96922cb1c19135433fa7908e6ce) 接口可以设定本地视频的编码参数，该参数决定了房间里其他用户观看您的画面时所感受到的[画面质量](https://cloud.tencent.com/document/product/647/32236)。
4. 主播端调用 [startLocalAudio()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a9428ef48d67e19ba91272c9cf967e35e) 开启麦克风，SDK 也会在此时向系统请求麦克风使用权限。

```java
//示例代码：发布本地的音视频流
mTRTCCloud.setLocalViewFillMode(TRTC_VIDEO_RENDER_MODE_FIT);
mTRTCCloud.startLocalPreview(mIsFrontCamera, localView);
//设置本地视频编码参数
TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
encParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
encParam.videoFps = 15;
encParam.videoBitrate = 850;
encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
mTRTCCloud.setVideoEncoderParam(encParam);
mTRTCCloud.startLocalAudio();
```

<span id="step6"> </span>
### 步骤6：主播端设置美颜效果

1. 主播端调用 [getBeautyManager()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a3fdfeb3204581c27bbf1c8b5598714fb) 可以获取美颜设置接口 [TXBeautyManager](http://doc.qcloudtrtc.com/group__TXBeautyManager__android.html#classcom_1_1tencent_1_1liteav_1_1beauty_1_1TXBeautyManager)。
2. 主播端调用 [setBeautyStyle()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a46ffe2b60f916a87345fb357110adf10) 可以设置美颜风格：`Smooth` 为类抖音的网红风格，`Nature` 风格给人的感觉会更加自然，`Pitu`风格仅 [企业版](https://cloud.tencent.com/document/product/647/32689#Enterprise) 才有提供。
3. 主播端调用 [setBeautyLevel()](http://doc.qcloudtrtc.com/group__TXBeautyManager__android.html#a7f388122cf319218b629fb8e192a2730) 可以设置磨皮的级别，一般设置为 5 即可。
4. 主播端调用 [setWhitenessLevel()](http://doc.qcloudtrtc.com/group__TXBeautyManager__android.html#aa4e57d02a4605984f4dc6d3508987746) 可以设置美白级别，一般设置为 5 即可。


<span id="step7"> </span>
### 步骤7：主播端创建房间并开始推流
1. 主播端设置 [TRTCParams](http://doc.qcloudtrtc.com/group__TRTCCloudDef__android.html#a674b3c744a0522802d68dfd208763b59) 中的字段 role 为 **TRTCCloudDef.TRTCRoleAnchor** ，表示当前用户的角色为主播。
2. 主播端调用 [enterRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#abfc1841af52e8f6a5f239a846a1e5d5c) 即可创建 TRTCParams 参数中 `roomId` 所指定的音视频房间，并指定 **appScene** 参数为 `TRTCCloudDef.TRTC_APP_SCENE_LIVE` 表示当前为视频互动直播模式（如果是语音互动直播场景，请设置 appScene 参数为 `TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM`）。
3. 如果房间创建成功，主播端也就同步开始了音视频数据的编码和传输流程。与此同时，SDK 会回调 [onEnterRoom(result)](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#abf0525c3433cbd923fd1f13b42c416a2)  事件，参数 `result` 大于0时代表进房成功，数值表示加入房间所消耗的时间，单位为毫秒（ms）；当 `result` 小于0时代表进房失败，数值表示进房失败的错误码。

```java
public void enterRoom() {
    TRTCCloudDef.TRTCParams trtcParams = new TRTCCloudDef.TRTCParams();
    trtcParams.sdkAppId = sdkappid;
    trtcParams.userId = userid;
    trtcParams.roomId = usersig;
    trtcParams.userSig = 908;
    mTRTCCloud.enterRoom(trtcParams, TRTC_APP_SCENE_VIDEOCALL);
}

@Override
public void onEnterRoom(long result) {
    if (result > 0) {
        toastTip("进房成功，总计耗时[\(result)]ms")
    } else {
        toastTip("进房失败，错误码[\(result)]")
    }
}
```

<span id="step8"> </span>
### 步骤8：观众端进入房间观看直播
1. 观众端设置 [TRTCParams](http://doc.qcloudtrtc.com/group__TRTCCloudDef__android.html#a674b3c744a0522802d68dfd208763b59) 中的字段 role 为 **TRTCCloudDef.TRTCRoleAudience** ，表示当前用户的角色为观众。
2. 观众端调用 [enterRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#abfc1841af52e8f6a5f239a846a1e5d5c) 即可进入 TRTCParams 参数中 `roomId` 所指定的音视频房间，并指定 **appScene** 参数为 `TRTCCloudDef.TRTC_APP_SCENE_LIVE` 表示当前为视频互动直播模式（如果是语音互动直播场景，请设置 appScene 参数为 `TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM`）。
3. 观看主播的画面：
- 如果观众端事先知道主播的 userId，直接在进房成功后调用 [startRemoteView(userId, view)](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a57541db91ce032ada911ea6ea2be3b2c) 即可显示主播的画面。
- 如果观众端不知道主播的 userId 也没有关系，因为观众端在进房成功后会收到 [onUserVideoAvailable()](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#ac1a0222f5b3e56176151eefe851deb05) 事件通知，之后用回调中获得的 `userId` 调用 [startRemoteView(userId, view)](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a57541db91ce032ada911ea6ea2be3b2c) 方法即可显示主播的画面。

<span id="step9"> </span>
### 步骤9：观众跟主播连麦
1. 观众端调用 [switchRole(TRTCCloudDef.TRTCRoleAnchor)](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a915a4b3abca0e41f057022a4587faf66) 把当前角色切换为主播（TRTCCloudDef.TRTCRoleAnchor）。
2. 观众端调用 [startLocalPreview()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a84098740a2e69e3d1f02735861614116) 可以开启本地的画面。
3. 观众端调用 [startLocalAudio()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a9428ef48d67e19ba91272c9cf967e35e) 开启麦克风采音。

```java
//示例代码：观众上麦
mTrtcCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
mTrtcCloud.startLocalAudio();
mTrtcCloud.startLocalPreview(mIsFrontCamera, localView);

//示例代码：观众下麦
mTrtcCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
mTrtcCloud.stopLocalAudio();
mTrtcCloud.stopLocalPreview();
```
<span id="step10"> </span>
### 步骤10：主播间进行跨房连麦 PK

TRTC 中两个不同音视频房间中的主播，可以通过“跨房通话”功能拉通连麦通话功能。使用此功能时， 两个主播无需退出各自原来的直播间即可进行“跨房连麦 PK”。

1. 主播 A 调用 [connectOtherRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#ac1ab7e4a017b99bb91d89ce1b0fac5fd) 接口，接口参数目前采用 json 格式，需要将主播 B 的 roomId 和 userId 拼装成形如 `{"roomId": "978","userId": "userB"}` 的参数传递给接口函数。
2. 如果跨房成功，主播 A 会收到 [onConnectOtherRoom()](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#ac9fd524ab9de446f4aaf502f80859e95)  事件回调。与此同时，两个直播房间里的所有用户均会收到 [onUserVideoAvailable()](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#ac1a0222f5b3e56176151eefe851deb05)  和 [onUserAudioAvailable()](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#ac474bbf919f96c0cfda87c93890d871f) 事件通知。
例如：当房间“001”中的主播 A 通过 `connectOtherRoom()` 跟房间“002”中的主播 B 拉通跨房通话后， 房间“001”中的用户都会收到主播 B 的 `onUserVideoAvailable(B, true)` 回调和 `onUserAudioAvailable(B, true)` 回调。 房间“002”中的用户都会收到主播 A 的 `onUserVideoAvailable(A, true)`  回调和 `onUserAudioAvailable(A, true)` 回调。
3. 两个房间里的用户通过调用 [startRemoteView(userId, view)](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a57541db91ce032ada911ea6ea2be3b2c) 即可显示另一房间里主播的画面，其声音是自动播放的。

```java
//示例代码：跨房连麦 PK
mTRTCCloud.ConnectOtherRoom(String.format("{\"roomId\":%s,\"userId\":\"%s\"}", roomId, username));
```

<span id="step11"> </span>
### 步骤11：正确的退出当前房间

调用 [exitRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__android.html#a41d16a97a9cb8f16ef92f5ef5bfebee1) 方法退出房间，由于 SDK 在退房时需要关闭和释放摄像头和麦克风等硬件设备，因此退房动作不是瞬间完成的，需要等待 [onExitRoom()](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#ad5ac26478033ea9c0339462c69f9c89e) 回调才算是真正退房结束。

```java
// 调用退房后请等待 onExitRoom 事件回调
trtcCloud.exitRoom()

@Override
public void onExitRoom(int reason) {
    Log.i(TAG, "onExitRoom: reason = " + reason);
}
```

>! 如果您在您的 App 中同时集成了多个音视频 SDK，请在收到 onExitRoom 回调后再启动其它音视频 SDK，否则可能会遭遇硬件占用问题。

