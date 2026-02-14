# POST /webapi/stt/openai

使用 OpenAI Whisper 进行语音转文字。

## 接口信息

**方法**: `POST`

**路径**: `/webapi/stt/openai`

**认证**: 需要 JWT Token

**Content-Type**: `multipart/form-data`

## 请求参数

```typescript
{
  file: File;                    // 音频文件（必需）
  model?: 'whisper-1';           // 默认 whisper-1
  language?: string;             // 语言代码（如 'zh', 'en'）
  prompt?: string;               // 提示词，用于指导转录
  response_format?: 'json' | 'text' | 'srt' | 'vtt';  // 默认 json
  temperature?: number;          // 0-1，默认 0
}
```

## 响应

```typescript
{
  text: string;  // 转录文本
}
```

## 使用示例

```typescript
const formData = new FormData();
formData.append('file', audioFile);
formData.append('language', 'zh');

const response = await fetch('/webapi/stt/openai', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const { text } = await response.json();
console.log('转录结果:', text);
```

## 支持的音频格式

- mp3
- mp4
- mpeg
- mpga
- m4a
- wav
- webm

## 文件大小限制

最大 25 MB

详细文档：[OpenAI Whisper API](https://platform.openai.com/docs/guides/speech-to-text)
