# Magi-knowledge

ナレッジ管理システム [Knowledge](https://github.com/support-project/knowledge) の Java 17 対応フォーク。
*[English version below](#-english)*

---

## 🇯🇵 日本語

---

### 概要

Magi-knowledge は、オープンソースのナレッジ管理システムです。
[support-project/knowledge](https://github.com/support-project/knowledge) を Fork し、Java 17 環境で動作するようモダナイズしました。

Fork 元の素晴らしいプロジェクトに感謝します。

### Fork 元からの主な変更点

- Java 8 → **Java 17** への移行
- 25 以上のライブラリの **CVE（脆弱性）修正**
- フロントエンド管理を **Bower → Maven WebJars** に刷新（Node.js 不要に）
- XML ライブラリを **simple-xml → Jackson XML** に置き換え
- 全文検索エンジンを **Lucene 4.x → 9.x** にメジャーバージョンアップ
- **commons-lang → commons-lang3** への移行
- **H2 Database 2.x** 対応（SQL 構文を標準 IDENTITY に変更）
- **Tomcat 8.5 → 9.0** 対応

詳細は [移行レポート](docs/java17-migration-report.md) を参照してください。

### 動作要件

- Java 17+
- Apache Maven 3.9+
- Apache Tomcat 9.0+

### ビルド & デプロイ

```bash
git clone https://github.com/Staba1139/Magi-knowledge.git
cd Magi-knowledge
mvn clean package -DskipTests
```

生成された `target/knowledge.war` を Tomcat の `webapps` ディレクトリにデプロイしてください。

### 旧バージョン（Java 8）

- [GitHub Releases](https://github.com/Staba1139/Magi-knowledge/releases)
- [Fork 元の WAR ダウンロード](https://github.com/support-project/knowledge/releases)

### 関連ドキュメント

- [Fork 元 Wiki（セットアップ詳細）](https://github.com/support-project/knowledge/wiki) — Fork 元のドキュメントです
- [Java 17 移行レポート](docs/java17-migration-report.md)

### ライセンス

[Apache License 2.0](LICENSE)

---

## 🇬🇧 English

---

### Overview

Magi-knowledge is an open-source knowledge management system.
It is a fork of [support-project/knowledge](https://github.com/support-project/knowledge), modernized to run on Java 17.

Special thanks to the original project.

### Key Changes from Upstream

- Java 8 → **Java 17**
- **CVE fixes** for 25+ libraries
- Frontend management: **Bower → Maven WebJars** (Node.js no longer required)
- XML library: **simple-xml → Jackson XML**
- Full-text search engine: **Lucene 4.x → 9.x**
- **commons-lang → commons-lang3**
- **H2 Database 2.x** support (SQL syntax updated to standard IDENTITY)
- **Tomcat 8.5 → 9.0**

See the [migration report](docs/java17-migration-report.md) for details.

### Requirements

- Java 17+
- Apache Maven 3.9+
- Apache Tomcat 9.0+

### Build & Deploy

```bash
git clone https://github.com/Staba1139/Magi-knowledge.git
cd Magi-knowledge
mvn clean package -DskipTests
```

Deploy the generated `target/knowledge.war` to your Tomcat `webapps` directory.

### Previous Versions (Java 8)

- [GitHub Releases](https://github.com/Staba1139/Magi-knowledge/releases)
- [Upstream WAR downloads](https://github.com/support-project/knowledge/releases)

### Documentation

- [Upstream Wiki (setup guide)](https://github.com/support-project/knowledge/wiki) — Documentation from the original project
- [Java 17 Migration Report](docs/java17-migration-report.md)

### License

[Apache License 2.0](LICENSE)
