# POST /webapi/tts/openai

使用 OpenAI TTS 服务进行文本转语音。

## 接口信息

**方法**: `POST`

**路径**: `/webapi/tts/openai`

**认证**: 需要 JWT Token

**Content-Type**: `application/json`

## 请求体

```typescript
{
  input: string;                 // 要转换的文本
  voice: 'alloy' | 'echo' | 'fable' | 'onyx' | 'nova' | 'shimmer';
  model?: 'tts-1' | 'tts-1-hd';  // 默认 tts-1
  speed?: number;                // 语速 0.25-4.0，默认 1.0
  response_format?: 'mp3' | 'opus' | 'aac' | 'flac';  // 默认 mp3
}
```

## 响应

**Content-Type**: `audio/mpeg` (或其他指定格式)

返回音频二进制流。

## 使用示例

```typescript
const response = await fetch('/webapi/tts/openai', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    input: '你好，欢迎使用 LobeChat！',
    voice: 'nova',
    model: 'tts-1-hd',
    speed: 1.0
  })
});

const audioBlob = await response.blob();
const audioUrl = URL.createObjectURL(audioBlob);

// 播放音频
const audio = new Audio(audioUrl);
audio.play();
```

## 支持的语音

- `alloy` - 中性音色
- `echo` - 男性音色
- `fable` - 英式男性音色
- `onyx` - 低沉男性音色
- `nova` - 女性音色
- `shimmer` - 活泼女性音色

详细文档：[OpenAI TTS API](https://platform.openai.com/docs/guides/text-to-speech)
