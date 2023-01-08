---
title: 'The Complete GitHub Actions & Workflows Guide'
date: 2022-11-26
tags:
  - Github Actions
draft: false
---

[Github Actions](https://docs.github.com/ja/actions)

Github Actionsの構成要素
|             |                                                                                                  |
| ----------- | --                                                                                               |
| Runners     | workflowがトリガーされたときにjobが実行されるサーバー.                                           |
| Workflows   | 1つ以上のジョブを実行する自動化プロセスの単位. .github/workflowsで定義する.                      |
| Jobs        | それぞれのrunner内で実行されるjobの集まり. 各jobはstepsで定義され、各stepの依存関係も定義できる. |
| Actions     | 繰り返しの多いタスクを切り出したもの. workflowの中で使うことで記述をシンプルにできる.            |
| Events      | pull requestなどのrepositoryに対するactionでworkflowのトリガーになる.                            |

[Workflow syntax for GitHub Actions](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#run-name)

workflowはyamlで記述する. yamlはあまり書きなれていないので一回jsonにして確認してもいいかもしれない.
[yaml-to-json](https://jsonformatter.org/yaml-to-json)

stepの中でコードにチェックアウトする
[actions/checkout](https://github.com/actions/checkout)
デフォルトではworkflowのあるrepositoryで単一のcommitがfetchされた状態にcheckoutする.

cron jobを設定するときは、[ctontab guru](https://crontab.guru/)が便利そう.

マニュアル実行するには、onでworkflow_dispatchを設定する.

[workflow_dispatch - GitHub Docs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs)

複数のrepositoryでトリガーを伝搬させたい場合にはrepository_dispatchをtriggerにし、apiを叩くことで他のrepositoryの workflowを実行できる.

defaultの環境変数
[Default environment variables - Github Actions](https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables)

環境変数をworkflowファイルに書きたくない場合は、repositoryのsecretに設定すればsecrets.ENV_NAMEでアクセスできる.usecaseとしては認証が必用なactionsにwithでtokenを渡したり、curlでリクエストを飛ばすときのAuthorization request headerに使用したりする.
secretsをgpgとかでencryptoし、workflowでdecryptoして使うやり方もある.

martix strategyを使うと、変数の組み合わせのjobを自動で実行できる. usecaseとしては、runs-onのosバージョンやnodeなどのバージョンを組み合わせて実行するなど.
[Using a martix for you jobs](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)

jobをコンテナで実行するには、container contextを指定する.
[Running jobs in a container](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container)

dependencyをcacheするには、[actions/cache](https://github.com/actions/cache)を使う.
```
- name: Get npm cache directory
  id: npm-cache-dir
  run: |
    echo "::set-output name=dir::$(npm config get cache)"
- uses: actions/cache@v3
  id: npm-cache # use this to check for `cache-hit` ==> if: steps.npm-cache.outputs.cache-hit != 'true'
    with:
      path: ${{ steps.npm-cache-dir.outputs.dir }}
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
        restore-keys: |
          ${{ runner.os }}-node-
```

artifactをuploadするには[actions/upload-artifact](https://github.com/actions/upload-artifact)を使う.
uploadされたartifactはGithub Actionsの結果のところからdownloadできる.

Actionsを自作するには[actions/toolkit](https://github.com/actions/toolkit)を使う.
[actions/typescript-action](https://github.com/actions/typescript-action)





