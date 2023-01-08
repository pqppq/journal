---
title: 'Powerful Command-Line Application in Go'
date: 2022-12-10
tags:
  - Book
  - Go
  - "Pragmatic Bookshelf"
---

[Powerful Command-Line Applications in Go: Build Fast and Maintainable Tools](https://www.amazon.co.jp/Powerful-Command-line-Applications-Go-Maintainable/dp/168050696X/ref=sr_1_1?keywords=powerful+command-line+applications+in+go&qid=1671934770&sprefix=powerful+command+line%2Caps%2C257&sr=8-1)

[pqppq/powerful-command-line-application-in-go](https://github.com/pqppq/powerful-command-line-applications-in-go)

Goでまとまったものを作ってみたくて購入した. 一冊を通してCLIツールをいくつか作っていく中でGoのシンタックスやテストを書くことに結構慣れることができた. とくにテストに関しては一切手抜きせずに完全に記述があるので、後半は多少きつくなるほどだった. 実装の後半はcobraとviperを使って実装を進めるので、その点も勉強になった.

取り扱ったテーマの中だとgo generateとpprofはあまり理解が進まなかったので別のドキュメントも参考にしたい.

CLIのアプリケーションでも、パッケージとしての処理を担うレイヤー/パッケージを呼び出して処理やエラーをハンドリングするレイヤー/フラグを解析してアクションへと処理を割り振るレイヤーと分離されていて、httpサーバーなどを書く時に近いものを感じた.
