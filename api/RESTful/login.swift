import Foundation
import FoundationNetworking

// 修复 URL 空格问题
let urlString = "https://chat-dev.ainft.com/api/auth/callback/apple-v2?noCookie=1"
    .trimmingCharacters(in: .whitespaces)

guard let url = URL(string: urlString) else {
    print("Invalid URL")
    exit(1)
}

let csrfToken = "a262494c5cf9fd3cf29541660f52cd3dc5c2c67402ae5b606b1ccd3d84fb7666"
let csrfFull = "a262494c5cf9fd3cf29541660f52cd3dc5c2c67402ae5b606b1ccd3d84fb7666|2431feaa3d19dd8055e2ea79fde1c1915cc5216e5b303012aa08bcf420fe6395"
let authorizationCode = "c475f468a0fd548b6b1f36486343e7d20.0.mrxuv.pjr_gBAAVYZxcIpATbLTBQ"

var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
request.setValue(csrfFull, forHTTPHeaderField: "X-Auth-CSRF-Token")

// 正确编码，避免特殊字符问题
let params = [
    "csrfToken": csrfToken,
    "authorizationCode": authorizationCode
]
let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
print(bodyString)
request.httpBody = bodyString.data(using: .utf8)

// 创建信号量来阻塞主线程
let semaphore = DispatchSemaphore(value: 0)

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    defer { semaphore.signal() } // 确保信号量总是被释放
    if let error = error {
        print("❌ Error: \(error)")
        return
    }
    if let httpResponse = response as? HTTPURLResponse {
        print("📡 Status Code: \(httpResponse.statusCode)")
        print("📋 Headers: \(httpResponse.allHeaderFields)")
    }
    if let data = data {
        if let body = String(data: data, encoding: .utf8) {
            print("📦 Response Body: \(body)")
        } else {
            print("📦 Raw Data: \(data)")
        }
    } else {
        print("⚠️ No data received")
    }
}

task.resume()

// 等待请求完成（最多 30 秒）
let result = semaphore.wait(timeout: .now() + 30)
if result == .timedOut {
    print("⏱️ Request timeout")
    task.cancel()
}
