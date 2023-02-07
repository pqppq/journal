2023-02-06
[Hydration (web development) - Wiki](https://en.wikipedia.org/wiki/Hydration_(web_development))
server-sideで生成したhtmlをclient-sideにロードし、ロードされたhtmlに対してイベントハンドラーを紐づけることを指すらしい。UI部分とデータ処理のロジックを分離することでfirst view(FCP)を高速にすることを目的としている。
先走ったUIがclient-sideで立ち止まって、水をガブ飲みするようにイベントハンドラーを吸収するイメージかな。
(あるいはイベントの度にデータ部分だけチューチュー吸い取るイメージ。)
分離する分server-sideとの通信が発生するのでその部分がパフォーマンスに影響する点がデメリットか。

いくつかのバーリエーション
- Streaming server-side rendering
htmlをchunk単位で送信することで少しでも早くfirst viewを出そうとする方法
https://www.patterns.dev/posts/ssr/

- Progressive rehydration
SSRしたhtmlのうち優先度の高いものから順にhydrateする方法
逆に優先度の低い(あるいは利用頻度の低い)ものは遅延読み込みさせることができる
リンクのビデオが分かりやすい
https://www.patterns.dev/posts/progressive-hydration/

- Partial rehydration
Progressive rehydrationの拡張概念で各partごとにinteractiveかどうかを解析する(らしい？)
実装は難しいことが知られているそうで、SvelteのElder.jsとかでサポートされている(らしい)

- Trismorphic rendering
SSGとservice workerのprerenderingをfront-endのDOM renderingのいいとこどりをした実装(?)
https://web.dev/rendering-on-the-web/#trisomorphic-renderingも
    

[Using Service Worker](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers)
