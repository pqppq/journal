[go/wiki](https://github.com/golang/go/wiki)

[Embedding in Go: Part 1 - structs in structs](https://eli.thegreenplace.net/2020/embedding-in-go-part-1-structs-in-structs/)

ある型があるインターフェースを満たしているかチェックする
```
var _ Some = (*Other)(nil)
```
nil値を初期値として渡して検査したいインターフェースに代入することで検査できる

型switch
型に応じて処理を切り分ける
```
func checkType(value interface{}) {
    switch v := value.(type) {
        case nil:
            fmt.Println("value is nil")
        ...
    }
}
```

IO
```
type Reader interface {
   Read(p []byte) (n int, err error)
}

type Writer interface {
   Write(p []byte) (n int, err error)
}
```

goroutine
> Do not communicate by sharing memory; instead, share memory by communitating.

セマフォ: 排他制御のための仕組みで、割り当て可能な数が決まっているものに対してあとどれだけ使用可能かを表したもの

channel vs wait group

snc.WaitGroup
errgroup.Group(golang.org/x/sync/errgroup)
semaphore.Weighted(golang.org/x/sync/semaphore)

go routineのleak検出
[uber-go/goleak](https://github.com/uber-go/goleak)


Context: goroutine間で値や実行状況の共有を行うことができる

```go
type Context interface {
    Deadline() (deadline time.Tile, ok bool) // contextが自動でキャンセルされる時刻と、それが設定されているかどうか
    Done() <- chan struct{}
    Err() error // contextがキャンセルされた理由を返す
    Value(key interface()) interface{} // 指定されたkeyに対応する値をcontext中から探す
}
```

contextを使う上で守るべきルール
- contextは関数の引数として使う(structには入れない)
- 第一引数ctxとして利用する
- 渡すべきcontextが判定できない場合はnilではなくcontext.TODOを渡す
- contextに保存する値(Valueの戻り値になるもの)はリクエストスコープ内に収まる値にする

いろいろなcontext
cancelCtx
emptyCtx
valueCtx

context tree
.
└── Background or TODO
    └── emptyCtx
        ├── valueCtx(withValue)
        ├── cancelCtx(withCancel)
        └── timerCtx(WithDeadline or WithTimeout)


```
import "context"

func main() {
    emptyCtx := context.Background() // parent context
    cancelCtx, cancel := context.WithCancel(emptyCtx) // child context
    defer cancel()

    doSomeThing(cancelCtx)
}
```

Pointer
実体はそれぞれのゼロ値を持つので、optionalな値を作りたいときはポインター(ゼロ値nil)にする

Error
errorのラッピング/errors.Unwrap
errors.As
```go
if err := doSomeThing(); err != nil {
    var de *db.Error
    if errors.As(err, &de) {
        // ...
    }
}
```
