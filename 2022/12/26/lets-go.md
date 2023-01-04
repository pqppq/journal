---
title: "Let's Go - Alex Edwards"
date: 2022-12-26
tags:
  - Book
  - Go
  - "Alex Edwards"
---

[Let's Go - Learn to Build Professional Web Applications with Go](https://lets-go.alexedwards.net/)

同僚のおすすめGo本. Pragmatic BookshelfのCLI本に引きつづき.

## Chap2.

Web Serverのめちゃめちゃ雑な構成.
- handler
	- func(http.ResponseWriter, *http.Request)な関数
	- http.ResponseWriterはinterfaceでhttp.Requestはstruct(なのでResponseWriterはポインタではない)
- router(servermux)
	- http.NewServerMuxで作る
	- リクエストのパスとhandlerをマッピングする役割
- server
	- ListenAndServerなど諸々実装されたstruct

handlerのloggingをまとめて管理したいならLoggerをもったstructをつくって、そのstructにhandlerを実装していけばいい
```
...
func New(out io.Writer, prefix string, flag int) *Logger {
...

infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)

type application struct {
	errorLog *log.Logger
	infoLog  *log.Logger
}

func (app *application) handler(w http.ResponseWriter, r *http.Request) {
	...
}

mux.HandleFunc("/path", app.handler)
```

struct application経由でLoggerをDIする感じ.(多くの場合引数として渡すよりも良いやり方.)

## Chap3.
設定の管理. 標準のflagを使うのが一番簡単.
```
addr := flag.String("addr", ":4000", "HTTP network address")
flag.Parse()
```

## Chap4.

アンダースコアのついたパッケージは依存関係の解決に必要なものに使われる. ブランク識別子というらしい.
```
import (
	"database/sql"

	_ "github.com/go-sql-driver/mysql"
)
```
これが無いと不要なパッケージがimportされているとみなされてコンパイルエラーになる.


あとで読む
https://peter.bourgon.org/go-best-practices-2016/#repository-structure

DB.Query() -> SELECT multiple rows
DB.QueryRow() -> SELECT single row
DB.Exec() -> used for data manupilate query

GoでDBから取得したrowはstructにscanしてすることで使うことができる.
```
stmt := `SELECT id, title, content, created, expires FROM snippets WHERE expires > UTC_TIMESTAMP() AND id = ?`
row := m.DB.QueryRow(stmt, id)

s := &Snippet{}
err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
if err != nil {
	...
}
```

https://github.com/jmoiron/sqlx


transaction
```
tx, err := m.DB.Begin()
...
defer tx.Rollback()
...
_, err = tx.Exec("...")
...
err = tx.Commit()
...
```

prepared statement
```
stmt, err :=  db.Prepare("...") // *sql.Stmt
...
defer stmt.Close()

_, err := stmt.Exec(args...)
```
prepared statementは、まず最初に一つのコネクション上に作られる.
以降はリクエストがあった場合に、そのコネクションを使おうとするが、closedであればまた別のコネクション上に作られることになる.
高負荷のときには相当数のprepared statementが複数コネクション上に何度も再作成される可能性もある.
prepared statementを使うことは実装の複雑さ(そんなに複雑か？)とパフォーマンスのトレードオフの問題だが、実際のパフォーマンスを測定し使うべきかどうか考える価値はある.

## Chap5.
テンプレートエンジンにはあまり興味がないので割愛

## Chap6.
Middleware
middleware: http.Handlerの処理に別のhttp.Handlerを差し込むもの
```
func middleware(next http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request)  {
		// some logic
		next.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}
```

middlewareをどこに置くか
middleware -> servermux -> application handler すべてのパスでmiddlewareを通す
servermux -> middleware -> application handler 特定のパスでmiddlewareを通す

panicをリカバリーするにはdefer func() をつくってbuild-inのrecoverメソッドで500を返す
```
defer func() {
	if err := recover(); err != nil {
		w.Header().Set("Connection", "close")
		// return 500 error
		app.serverError(w, fmt.Errorf("%s", err))
	}
}()
```

## Chap7.
Advanced routing

julienschmidt/httprouter
go-chi/chi
gorilla/mux

## Chap8.
Processing forms

Validatorをinternalに作成して、作った構造体をappの構造体にembedした
attributeは構造体でふつうに持って、functionalityはembedする感じか

github.com/go-playground/form/v4@v4
http.Request.PostFormをstruct tagを使っていいかんじにdecode/parseしてくれるライブラリ

## Chap9.
Stateful HTTP

sessionをつかう

"github.com/alexedwards/scs/mysqlstore"
"github.com/alexedwards/scs/v2"

## Chap10.
Security improvements

self-signed TLS(オレオレ証明書) productionではlet's encryptoなどを使うべきだけど、developならこれでもひとまずok

Goの標準パッケージのcrypto/tls/generate_cert.goを利用する
```
go run  ~/go/src/crypto/tls/generate_cert.go -rsa-bits=2048 --host=localhost
```

いろいろヘッダを追加
```
srv := &http.Server{
	Addr:           *addr,
	ErrorLog:       errorLog,
	Handler:        app.routes(),
	TLSConfig:      tlsConfig,
	IdleTimeout:    time.Minute,
	ReadTimeout:    5 * time.Second,
	WriteTimeout:   10 * time.Second,
	MaxHeaderBytes: 512 * 1024, // 0.5MB
}
```

## Chap11.
user authentication

erros.Isとerros.Asの違いを一回調べとく

golang.org/x/crypto/bcrypt

side-channel timing attacks

emailはregexpを使って書いたが、他のvalidationのライブラリあるのかな
DBにはパスワードをbcryptでhashした値を保存する

authはDBからパスワードハッシュを比較してokなら、
sessionManager.RenewToken(r.Context())でtokenをupdateする
sessionにkeyを追加するには、sessionManager.Put(r.Context(), "key", value)

CSRF対策
dobule submit tokenというやり方を実装
一回目のリクエストでtokenをCookieに入れて渡す
二回目のやり取りでtokenをhidden inputにもつformでやり取りする
serverはCookieとformのtokenが一致するかチェックする
https://tech.basicinc.jp/articles/231

## Chap12.
Using request context

request context

```
ctx = context.WithValue(r.Context(), "isAuthenticated", true)
r = r.WithContext(ctx) // add context to request!
```

## Chapter13.
Optional Go features

embed package
generic(ﾁｮｯﾄﾀﾞｹ)

unit test/tdd

http handlerのテスト
net/http/httptestを使う

```
rr := httptest.NewRecorder()
...
rs := rr.Result()
body, err := io.ReadAll(rs.Body)
defer rs.Body.Close()

if err != nil {
	t.Fatal(err)
}
bytes.TrimSpace(body)
assert.Equal(t, string(body), "OK")
```
これをResponseWriterとして使って、書き込まれた値をチェックする

io.Discard

## Chap14.
Test
https://go.dev/blog/subtests

run all the tests in current project by using the ./...wildcard pattern
```
$ go test ./...
```

run test with regex pattern
```
$ go test -v -run="^TestPing$" ./cmd/web
```

run sub-test with regex pattern(table-driven test)
```
$ go test -v -run="^TestHumanDate$/^UTC$" ./cmd/web
```

t.Errorfはexitしないが、-failfastフラグを付けるとexitするようになる

test coverage
```
$ go test -cover ./...
$ go test -coverprofile=/tmp/profile.out ./...
$ go test -cover -func=/tmp/profile.out
$ go test -cover -html=/tmp/profile.out
```

