# Raspberry Pi Cross Development Container

Docker 上に Raspberry Pi 向けの開発環境を用意し、  
Raspberry Pi 実機から `sysroot`（ヘッダ・共有ライブラリ群）を後から同期して、  
クロスコンパイル /cross compile/ するための開発キットです。

- 開発・ビルドは Docker コンテナ内で実施
- 実機依存ライブラリは Raspberry Pi から `rsync` で同期
- 生成したバイナリを Raspberry Pi へ配布
- SSH でコンテナに直接ログイン可能

## 特徴

- Docker で開発環境を固定できる
- ホスト環境を汚さずに ARM 向けビルドができる
- Raspberry Pi 実機上のライブラリ構成に合わせてリンクできる
- SSH 経由でコンテナに入れる
- Raspberry Pi 3 / 4 / 5 / Zero 2 W の **64-bit OS** が対象

## 想定ユースケース

この構成は、次のような用途を想定しています。

- WSL / Linux / macOS 上で Raspberry Pi 向け開発をしたい
- CMake + Ninja でクロスコンパイルしたい
- 実機に入っているライブラリに合わせてビルドしたい
- Docker に開発環境を閉じ込めたい
- Raspberry Pi へ配布するまでをスクリプト化したい

## サポート対象

### 主対象
以下の **64-bit Raspberry Pi OS** を対象とします。

- Raspberry Pi 5
- Raspberry Pi 4
- Raspberry Pi 3 / 3B / 3B+
- Raspberry Pi Zero 2 W

### 注意
このリポジトリの初期構成は、基本的に **ARM64 /aarch64/** を対象にしています。

- `RPI_TARGET_TRIPLE=aarch64-linux-gnu`
- `sysroot` も `aarch64` 前提
- `pkg-config` の検索先も `aarch64-linux-gnu` 前提

## ディレクトリ構成

```text
.
├─ compose.yaml
├─ .env.example
├─ docker/
│  ├─ rpi-dev.Dockerfile
│  └─ entrypoint-sshd.sh
├─ scripts/
│  ├─ dev-up.sh
│  ├─ dev-down.sh
│  ├─ dev-shell.sh
│  ├─ dev-ssh.sh
│  └─ sync-sysroot.sh
└─ README.md
```

## プロジェクトリポジトリの例
```text
your-project/
├─ CMakeLists.txt
├─ CMakePresets.json
├─ cmake/
│  └─ toolchains/
│     └─ rpi-aarch64.cmake
└─ scripts/
   └─ qemu-smoke.sh
```

## 必要条件

### ホスト側

* Docker
* Docker Compose
* SSH クライアント
* Raspberry Pi 実機へ SSH 接続できること

### Raspberry Pi 側

* SSH サーバが有効
* `rsync` が使えること
* 開発対象のライブラリが実機に入っていること

## 初回セットアップ

### 1. `.env` を作成

```bash
cp .env.example .env
```

### 2. スクリプトに実行権限を付与

```bash
chmod +x scripts/*.sh
chmod +x docker/entrypoint-sshd.sh
```

### 3. コンテナを起動

```bash
./scripts/dev-up.sh
```

## SSH でコンテナへ接続する

このコンテナは `sshd` を起動するので、次で接続できます。

```bash
ssh dev@localhost -p 63206
```

パスワードは `.env` の `DEV_PASSWORD` です。

### 補足

SSH 接続をスクリプト経由で行う場合は、次でも構いません。

```bash
./scripts/dev-ssh.sh
```

Docker Compose 経由で直接シェルに入るだけなら、次でも構いません。

```bash
./scripts/dev-shell.sh
```

## 使い方の流れ

### 手順 1. Raspberry Pi 実機から sysroot を同期

ホスト側から次を実行します。

```bash
./scripts/sync-sysroot.sh
```

これにより、実機の以下がコンテナ内へ同期されます。

- `/lib/aarch64-linux-gnu`
- `/usr/lib/aarch64-linux-gnu`
- `/usr/include`

つまり、実機のライブラリ構成に合わせたビルドができます。

### 手順 2. コンテナ内でプロジェクトを clone

```bash
cd /workspace
git clone git@github.com:your-org/your-project.git
cd your-project
```

### 手順 3. プロジェクト側に toolchain ファイルを用意する

プロジェクト側で、たとえば次の場所に toolchain ファイルを配置します。

```text
cmake/toolchains/rpi-aarch64.cmake
```

### 手順 4. プロジェクト側で CMake configure

```bash
cmake --preset rpi-release
```

### 手順 5. プロジェクト側でビルド

```bash
cmake --build --preset rpi-release -j
```

### 手順 6. 必要なら QEMU で簡易確認

QEMU による簡易確認は、プロジェクト側で行います。  
たとえば、プロジェクトに `scripts/qemu-smoke.sh` を用意しておき、次のように実行します。

```bash
./scripts/qemu-smoke.sh build/rpi-release/your_binary --version
```

このスクリプトは、実機から同期した sysroot を用いて ARM64 バイナリを QEMU 上で実行します。
共有ライブラリ解決や、CLI ツールの起動確認、--help / --version などの簡易確認に向いています。

### 手順 7. 必要に応じて成果物を Raspberry Pi へ配布

配布方法はプロジェクト側で管理します。たとえば rsync や scp、あるいはプロジェクト専用の deploy スクリプトを使います。

## プロジェクト側の QEMU スモークテスト用スクリプト例

`scripts/qemu-smoke.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${BUILD_DIR:=build/rpi-release}"
: "${RPI_SYSROOT_BASE:=/opt/rpi-sysroot}"
: "${RPI_TARGET_TRIPLE:=aarch64-linux-gnu}"

RPI_SYSROOT="${RPI_SYSROOT_BASE}/${RPI_TARGET_TRIPLE}"
BIN="${1:-${BUILD_DIR}/your_binary}"

if [[ ! -x "${BIN}" ]]; then
  echo "Binary not found or not executable: ${BIN}" >&2
  exit 1
fi

shift || true

exec qemu-aarch64 -L "${RPI_SYSROOT}" "${BIN}" "$@"
```

### 使い方

```bash
chmod +x scripts/qemu-smoke.sh
./scripts/qemu-smoke.sh build/rpi-release/your_binary --version
```

設定ファイルを与えて起動確認する場合は、たとえば次のようにします。

```bash
./scripts/qemu-smoke.sh build/rpi-release/your_binary --config ./config/dev.toml
```

### 注意

この方法はスモークテスト向けです。
GPIO、I2C、SPI、/dev 直叩き、systemd 依存、厳密なタイミング依存処理などは、最終的に Raspberry Pi 実機で確認してください。

## CPU 最適化の考え方

この構成では `.env` の `RPI_CPU` により、ターゲット CPU 最適化を切り替えます。

### 推奨値

| デバイス               | 推奨 `RPI_CPU` |
| --------------------- | ------------ |
| Raspberry Pi 5        | `cortex-a76` |
| Raspberry Pi 4        | `cortex-a72` |
| Raspberry Pi 3        | `cortex-a53` |
| Raspberry Pi Zero 2 W | `cortex-a53` |

### 汎用性を優先する場合

複数機種に同じバイナリを持っていきたい場合や、
特定 CPU に寄せたくない場合は、`.env` の `RPI_CPU` を空にします。

```dotenv
RPI_CPU=
```

このときツールチェーン側では、より汎用な

* `-march=armv8-a`

を使う想定です。

### どれを選ぶべきか

* **単一の実機専用**なら `RPI_CPU` を機種に合わせる
* **Pi 3/4/5 に広く持っていきたい**なら空にして汎用化する

## `.env` の例

### Raspberry Pi 5 向け

```dotenv
RPI_HOST=pi5.local
RPI_USER=pi
RPI_CPU=cortex-a76
DEV_PASSWORD=devpassword
TZ=Asia/Tokyo
```

### Raspberry Pi 4 向け

```dotenv
RPI_HOST=pi4.local
RPI_USER=pi
RPI_CPU=cortex-a72
DEV_PASSWORD=devpassword
TZ=Asia/Tokyo
```

### Raspberry Pi 3 / Zero 2 W 向け

```dotenv
RPI_HOST=pi3.local
RPI_USER=pi
RPI_CPU=cortex-a53
DEV_PASSWORD=devpassword
TZ=Asia/Tokyo
```

### 機種非依存寄り

```dotenv
RPI_HOST=raspberrypi.local
RPI_USER=pi
RPI_CPU=
DEV_PASSWORD=devpassword
TZ=Asia/Tokyo
```

## プロジェクト側の toolchain ファイル例

`cmake/toolchains/rpi-aarch64.cmake`:

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(_RPI_TARGET_TRIPLE "aarch64-linux-gnu")

if(DEFINED ENV{RPI_SYSROOT} AND NOT "$ENV{RPI_SYSROOT}" STREQUAL "")
  set(CMAKE_SYSROOT "$ENV{RPI_SYSROOT}")
elseif(DEFINED ENV{RPI_SYSROOT_BASE} AND NOT "$ENV{RPI_SYSROOT_BASE}" STREQUAL "")
  set(CMAKE_SYSROOT "$ENV{RPI_SYSROOT_BASE}/${_RPI_TARGET_TRIPLE}")
else()
  set(CMAKE_SYSROOT "/opt/rpi-sysroot/${_RPI_TARGET_TRIPLE}")
endif()

set(CMAKE_C_COMPILER   "/usr/bin/${_RPI_TARGET_TRIPLE}-gcc")
set(CMAKE_CXX_COMPILER "/usr/bin/${_RPI_TARGET_TRIPLE}-g++")
set(CMAKE_AR           "/usr/bin/${_RPI_TARGET_TRIPLE}-ar")
set(CMAKE_RANLIB       "/usr/bin/${_RPI_TARGET_TRIPLE}-ranlib")
set(CMAKE_STRIP        "/usr/bin/${_RPI_TARGET_TRIPLE}-strip")

set(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(_PKG_CONFIG_LIBDIR_LIST
  "${CMAKE_SYSROOT}/usr/lib/${_RPI_TARGET_TRIPLE}/pkgconfig"
  "${CMAKE_SYSROOT}/usr/lib/pkgconfig"
  "${CMAKE_SYSROOT}/usr/share/pkgconfig"
  "${CMAKE_SYSROOT}/usr/local/lib/${_RPI_TARGET_TRIPLE}/pkgconfig"
  "${CMAKE_SYSROOT}/usr/local/lib/pkgconfig"
)
list(JOIN _PKG_CONFIG_LIBDIR_LIST ":" _PKG_CONFIG_LIBDIR)

set(ENV{PKG_CONFIG_DIR} "")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")
set(ENV{PKG_CONFIG_LIBDIR} "${_PKG_CONFIG_LIBDIR}")

if(DEFINED ENV{RPI_CPU} AND NOT "$ENV{RPI_CPU}" STREQUAL "")
  set(CMAKE_C_FLAGS_INIT   "-mcpu=$ENV{RPI_CPU}")
  set(CMAKE_CXX_FLAGS_INIT "-mcpu=$ENV{RPI_CPU}")
else()
  set(CMAKE_C_FLAGS_INIT   "-march=armv8-a")
  set(CMAKE_CXX_FLAGS_INIT "-march=armv8-a")
endif()

message(STATUS "Raspberry Pi target triple : ${_RPI_TARGET_TRIPLE}")
message(STATUS "Raspberry Pi sysroot       : ${CMAKE_SYSROOT}")
message(STATUS "Raspberry Pi CPU tuning    : $ENV{RPI_CPU}")
```

## プロジェクト側の CMakePresets.json 例

```json
{
  "version": 5,
  "configurePresets": [
    {
      "name": "rpi-release",
      "displayName": "Raspberry Pi Release",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/rpi-release",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_TOOLCHAIN_FILE": "${sourceDir}/cmake/toolchains/rpi-aarch64.cmake"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "rpi-release",
      "configurePreset": "rpi-release"
    }
  ]
}
```

## `~/.ssh/config`の設定例

```
Host rpi-dev
    HostName localhost
    Port 63206
    User dev
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
```

もしすでに古い鍵が記録されていて警告が出ているなら、最初に1回だけ消してください。

```
$ ssh-keygen -R "[localhost]:63206"
```

## スクリプト一覧

### `scripts/dev-up.sh`

コンテナをビルドして起動します。

```bash
./scripts/dev-up.sh
```

### `scripts/dev-down.sh`

コンテナを停止します。

```bash
./scripts/dev-down.sh
```

### `scripts/dev-shell.sh`

Docker Compose 経由でコンテナ内へ bash で入ります。

```bash
./scripts/dev-shell.sh
```

### `scripts/dev-ssh.sh`

SSH でコンテナへ接続します。

```bash
./scripts/dev-ssh.sh
```

### `scripts/sync-sysroot.sh`

Raspberry Pi 実機から sysroot を同期します。

```bash
./scripts/sync-sysroot.sh
```

## テンプレートファイル
### `scripts/qemu-smoke.sh`

新規プロジェクト向けの雛形として、`templates/project/scripts/qemu-smoke.sh` にサンプルを置いています。
必要に応じてプロジェクト側へコピーして使用してください。

QEMU 用のスモークテストスクリプトは各プロジェクト側の `scripts/qemu-smoke.sh` として配置する想定です。  
新規プロジェクト作成時は、この README に記載した例をそのまま雛形として利用してください。

## 注意点

### 1. `sysroot` は実機ごとに同期し直す

Raspberry Pi 側で OS 更新やライブラリ更新を行った場合は、
再度 `sync-sysroot.sh` を実行してください。

### 2. ターゲット実機と sysroot は合わせる

Pi 4 用の sysroot で Pi 5 専用ビルドをする、のようなズレは避けてください。
CPU 命令最適化やライブラリ差異で問題が出ることがあります。

### 3. `RPI_CPU` は強すぎると他機種で動かない

たとえば `cortex-a76` 向けに最適化したバイナリを、
より古い ARM コアへ持っていくのは危険です。

* Pi 5 専用なら `cortex-a76`
* 複数機種で使うなら空にして汎用化

### 4. 開発環境リポジトリとプロジェクトリポジトリは分離する

このリポジトリは Docker ベースの開発環境を提供するためのものです。  
実際のソースコードは、コンテナ内の永続領域 `/workspace` に clone して管理します。

### 5. クロスコンパイル設定はプロジェクト側で管理する

`toolchain` ファイルや `CMakePresets.json` は、各プロジェクト側に配置して管理します。  
これにより、プロジェクト単体でビルド設定を完結できます。
