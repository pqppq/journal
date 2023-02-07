shell関連のことを書き溜める

# ファイルの変更を監視してスクリプトを実行したい
こういうのがある.
[inotify-tools/inotify-tools](https://github.com/inotify-tools/inotify-tools/wiki)

```bash
$ while inotifywait .; do cargo check; done;
```

軽い操作で定期実行でもいいならwatchでもいい.
特定のログファイルの監視とかなら`tail -f`が使える.

```
$ tail -f file_name | grep some_word
```

