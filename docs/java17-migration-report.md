# Java 17 マイグレーション レポート

> **対象ブランチ**: `java17`（ベース: `v1`）
> **コミット数**: 6
> **最終更新**: 2026-02-12

---

## 目次

1. [はじめに — なぜ Java 17 に移行するのか？](#1-はじめに)
2. [変更の全体像](#2-変更の全体像)
3. [コンパイラとビルド設定の変更](#3-コンパイラとビルド設定の変更)
4. [脆弱性（CVE）対応 — ライブラリのバージョンアップ](#4-脆弱性cve対応)
5. [XML ライブラリの移行（simple-xml → Jackson XML）](#5-xml-ライブラリの移行)
6. [Java 17 で削除された API への対応](#6-java-17-で削除された-api-への対応)
7. [フロントエンド管理の刷新（Bower → Maven WebJars）](#7-フロントエンド管理の刷新)
8. [Tomcat のバージョンアップ](#8-tomcat-のバージョンアップ)
9. [Lucene 4.x → 9.x の移行](#9-lucene-4x--9x-の移行)
10. [commons-lang → commons-lang3 の移行](#10-commons-lang--commons-lang3-の移行)
11. [H2 Database 2.x 対応と SQL 構文の変更](#11-h2-database-2x-対応と-sql-構文の変更)
12. [その他の細かい修正](#12-その他の細かい修正)
13. [変更ファイル一覧](#13-変更ファイル一覧)
14. [コミット履歴](#14-コミット履歴)

---

## 1. はじめに

### なぜ Java 17 に移行するのか？

- **Java 8 は 2019 年にパブリック・アップデートが終了**しており、セキュリティ修正を受けられない
- Java 17 は**LTS（長期サポート）版**であり、2029 年頃まで更新が提供される
- 古いライブラリには**既知の脆弱性（CVE）**が多数あり、放置するとセキュリティリスクになる
- 新しい Java の言語機能（テキストブロック、レコード、パターンマッチングなど）が使えるようになる

### 「CVE」とは？

> **CVE（Common Vulnerabilities and Exposures）** とは、世界中で共有されるセキュリティ脆弱性の識別番号のこと。例えば「CVE-2021-44228」は Log4j の重大な脆弱性（Log4Shell）を指す。ライブラリのバージョンを上げることで、これらの既知の脆弱性を解消できる。

---

## 2. 変更の全体像

この移行は大きく **8 つのカテゴリ** に分けられる。

```
┌──────────────────────────────────────────────────────┐
│              Java 17 マイグレーション                  │
├──────────────────────────────────────────────────────┤
│ 1. コンパイラ設定       Java 8 → Java 17              │
│ 2. CVE 対応            25+ ライブラリのバージョンアップ  │
│ 3. XML ライブラリ       simple-xml → Jackson XML       │
│ 4. フロントエンド       Bower → Maven WebJars          │
│ 5. Tomcat              8.5 → 9.0                     │
│ 6. Lucene              4.10.4 → 9.12.3               │
│ 7. commons-lang        2.x → 3.x（パッケージ名変更）   │
│ 8. H2 Database / SQL   1.4 → 2.3（構文変更）          │
└──────────────────────────────────────────────────────┘
```

---

## 3. コンパイラとビルド設定の変更

### 何を変えたか

`pom.xml` の `maven-compiler-plugin` 設定を変更した。

| 項目 | 変更前 | 変更後 |
|------|--------|--------|
| Java バージョン指定方法 | `<source>1.8</source>` / `<target>1.8</target>` | `<release>17</release>` |
| compiler plugin | 3.1 | 3.11.0 |

### ポイント解説

```xml
<!-- 変更前: Java 8 のソース/ターゲットを個別指定 -->
<source>1.8</source>
<target>1.8</target>

<!-- 変更後: release で一括指定（Java 9 以降の推奨方式） -->
<release>17</release>
```

- `<source>` と `<target>` を別々に指定する古い方式から、`<release>` で一括指定する方式に変更
- `<release>` を使うと、**指定バージョンに存在しない API を使った場合にコンパイルエラー**になるので安全

---

## 4. 脆弱性（CVE）対応

多くのライブラリで既知の脆弱性があったため、安全なバージョンに更新した。

### 主なバージョン変更一覧

| ライブラリ | 変更前（v1） | 変更後（java17） | 更新理由 |
|-----------|-------------|-----------------|---------|
| **log4j → reload4j** | 1.2.17 | 1.2.25 | Log4j 1.x は EOL。reload4j はセキュアな drop-in replacement |
| **PostgreSQL JDBC** | 42.1.4 | 42.7.7 | 複数の CVE 修正 |
| **Apache Tika** | 1.16 (tika-parsers) | 3.2.2 (tika-core + tika-parsers-standard-package) | モジュール構成の変更 + CVE 修正 |
| **Apache Lucene** | 4.10.4 | 9.12.3 | メジャーバージョンアップ、API 刷新 |
| **H2 Database** | 1.4.196 | 2.3.232 | CVE 修正 + SQL 構文変更 |
| **Guava** | 20.0 | 33.3.1-jre | 多数の CVE 修正 |
| **Gson** | 2.8.2 | 2.11.0 | CVE 修正 |
| **OWASP HTML Sanitizer** | 20171016.1 | 20240325.1 | セキュリティ改善 |
| **HttpClient** | 4.5.3 | 4.5.14 | CVE 修正 |
| **commons-lang** | 2.6 | **commons-lang3** 3.17.0 | パッケージ名変更を伴うメジャーアップ |
| **commons-fileupload** | 1.3.3 | 1.6.0 | CVE 修正 |
| **Apache Directory API** | 1.0.0 | 2.1.6 | CVE 修正 |
| **Javassist** | 3.21.0-GA | 3.29.2-GA | Java 17 対応 |
| **JUnit** | 4.11 | 4.13.2 | CVE 修正 |
| **jcabi-log** | 0.17.2 | 0.24.1 | 互換性改善 |
| **javax.mail** | 1.5.6 / 1.6.0 | 1.6.2 / 1.6.2 | バグ修正 |
| **Jackson XML** | なし（simple-xml 2.7.1） | 2.18.2 | XML ライブラリの置き換え |
| **Tomcat** | 8.5.23 | 9.0.110 | Java 17 対応 |

### reload4j とは？

```
log4j 1.x（EOL・脆弱性あり）
    ↓ そのまま置き換え可能（drop-in replacement）
reload4j（セキュリティ修正済みフォーク）
```

> Log4j 1.x は既にサポートが終了しており、Log4Shell のような深刻な脆弱性がある。reload4j は **API をそのまま維持** しつつセキュリティ修正を加えたフォークなので、コードの変更なしで移行できる。

### Tika のモジュール構成変更

```
変更前: tika-parsers 1.16（1つの巨大 JAR）
    ↓
変更後: tika-core 3.2.2 + tika-parsers-standard-package 3.2.2（分割されたモジュール）
```

Tika 2.x 以降ではモジュールが分割されたため、依存関係の書き方が変わった。

---

## 5. XML ライブラリの移行

### 何を変えたか

XML のシリアライズ/デシリアライズに使っていた `simple-xml` を `Jackson XML (jackson-dataformat-xml)` に置き換えた。

| 項目 | 変更前 | 変更後 |
|------|--------|--------|
| ライブラリ | simple-xml 2.7.1 | jackson-dataformat-xml 2.18.2 |
| メインクラス | `org.simpleframework.xml.core.Persister` | `com.fasterxml.jackson.dataformat.xml.XmlMapper` |

### 変更理由

- `simple-xml` は長期間メンテナンスされていない
- Java 17 の**強化されたモジュールシステム**と相性が悪い
- Jackson は業界標準で、JSON/XML/YAML など複数フォーマットを統一的に扱える

### コード変更例

#### ConfigLoader.java（設定ファイルの読み込み）

```java
// === 変更前 ===
import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;

Serializer serializer = new Persister();
T config = serializer.read(type,
    ConfigLoader.class.getResourceAsStream(configPath), false);

// === 変更後 ===
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import com.fasterxml.jackson.databind.DeserializationFeature;

// static 初期化ブロックで XmlMapper を1回だけ生成（スレッドセーフ）
private static final XmlMapper XML_MAPPER;
static {
    XML_MAPPER = new XmlMapper();
    XML_MAPPER.configure(
        DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
}

InputStream is = ConfigLoader.class.getResourceAsStream(configPath);
T config = XML_MAPPER.readValue(is, type);
```

> **`FAIL_ON_UNKNOWN_PROPERTIES = false`** にしているのは、XML に Java クラスに対応しないフィールドがあってもエラーにしないため。既存の XML 設定ファイルとの互換性を保つために重要。

#### AppConfig.java（setter の追加）

```java
// Jackson XML は JavaBean 規約に従って setter を呼ぶので、
// simple-xml 時代には不要だった setter を追加
public void setEnvKey(String envKey) {
    AppConfig.initEnvKey(envKey);
}
```

> Jackson はデシリアライズ時に `setXxx()` メソッドを探す。simple-xml はアノテーションベースだったので setter が不要だったが、Jackson に移行したことで追加が必要になった。

#### SerializerForXmlOnSimpleImpl.java（XML シリアライザ）

```java
// === 変更前 ===
Persister serializer = new Persister(format);
serializer.write(obj, byteArrayOutputStream, "UTF-8");

// === 変更後 ===
private static final XmlMapper XML_MAPPER = new XmlMapper();
return XML_MAPPER.writeValueAsBytes(obj);
```

---

## 6. Java 17 で削除された API への対応

Java 9 以降、多くの API が非推奨 → 削除されている。該当するものを修正した。

### 6.1 `Method.isAccessible()` → `Method.canAccess(obj)`

```java
// 変更前（Java 8）: isAccessible() は Java 9 で非推奨
if (method.isAccessible()) { ... }

// 変更後（Java 17）: canAccess() を使用
if (method.canAccess(obj)) { ... }
```

> `isAccessible()` はリフレクション API で、メソッドにアクセスできるかを判定する。Java 9 以降のモジュールシステムでは正確に動作しないため、`canAccess()` に置き換えられた。

### 6.2 `Class.newInstance()` → `getDeclaredConstructor().newInstance()`

```java
// 変更前（Java 8）: newInstance() は Java 9 で非推奨
target = obj.getClass().newInstance();

// 変更後（Java 17）: コンストラクタを明示的に取得
target = obj.getClass().getDeclaredConstructor().newInstance();
```

> `Class.newInstance()` は例外処理が不適切（チェック例外を非チェック例外として投げる）ため非推奨になった。

### 6.3 JAXB / Activation の外部依存追加

Java 8 では JDK に含まれていた JAXB と Activation が、Java 11 で完全に削除された。外部ライブラリとして追加する必要がある。

```xml
<!-- pom.xml に追加 -->
<dependency>
  <groupId>javax.xml.bind</groupId>
  <artifactId>jaxb-api</artifactId>
  <version>2.3.1</version>
</dependency>
<dependency>
  <groupId>org.glassfish.jaxb</groupId>
  <artifactId>jaxb-runtime</artifactId>
  <version>2.3.9</version>
</dependency>
<dependency>
  <groupId>com.sun.activation</groupId>
  <artifactId>javax.activation</artifactId>
  <version>1.2.0</version>
</dependency>
```

### 6.4 Tika の定数名変更

```java
// 変更前
metadata.set(Metadata.RESOURCE_NAME_KEY, filename.toString());

// 変更後（Tika 2.x 以降ではクラスが移動）
metadata.set(TikaCoreProperties.RESOURCE_NAME_KEY, filename.toString());
```

### 6.5 `NotImplementedException` → `UnsupportedOperationException`

```java
// 変更前: commons-lang の例外クラス
import org.apache.commons.lang.NotImplementedException;
throw new NotImplementedException();

// 変更後: Java 標準ライブラリの例外クラス
throw new UnsupportedOperationException();
```

> `commons-lang3` には `NotImplementedException` が存在するが、Java 標準の `UnsupportedOperationException` で十分なため、外部依存を減らした。

---

## 7. フロントエンド管理の刷新

### Bower → Maven WebJars

#### 変更前の問題

- **Bower** はフロントエンドのパッケージマネージャーだが、2017 年に**開発終了（deprecated）**
- ビルドに **Node.js 6.x + npm + Gulp** が必要で、ビルド環境の構築が複雑
- `frontend-maven-plugin` でビルド中に Node.js をダウンロード → npm install → bower install する仕組みだった

#### 変更後の仕組み

```
Maven WebJars
  ↓ maven-dependency-plugin で JAR を展開
  ↓ maven-antrun-plugin でパスを変換
  ↓ maven-war-plugin で WAR に同梱
  ↓
/bower/{ライブラリ名}/... のパスを維持
```

> **WebJars** とは、JavaScript ライブラリを Maven の JAR として配布する仕組み。Maven だけでフロントエンドライブラリを管理でき、Node.js は不要になる。

#### 削除されたファイル

| ファイル | 役割 |
|---------|------|
| `bower.json` | Bower の依存関係定義 |
| `.bowerrc` | Bower のインストール先設定 |
| `package.json` | npm の依存関係定義 |
| `gulpfile.js` | Gulp タスク（JS/CSS の minify、ファイルコピー等） |

#### ビルドパイプラインの変化

```
【変更前】
Maven → frontend-maven-plugin → Node.js DL → npm install
  → bower install → gulp（minify / copy）→ WAR パッケージ

【変更後】
Maven → dependency:unpack-dependencies（WebJars 展開）
  → antrun:run（パスの再配置）→ WAR パッケージ
```

> **重要**: JSP ファイル内のパス（`/bower/xxx/...`）は変更していない。WebJars から展開したファイルを `bower/` ディレクトリに再配置することで、既存の JSP との互換性を維持している。

#### JSP の変更（highlight.js のファイル名）

```jsp
<!-- 変更前: 旧バージョンのファイル名 -->
<script src="<%= request.getContextPath() %>/bower/highlightjs/highlight.pack.js">

<!-- 変更後: 新バージョンではファイル名が変わった -->
<script src="<%= request.getContextPath() %>/bower/highlightjs/highlight.min.js">
```

---

## 8. Tomcat のバージョンアップ

| 項目 | 変更前 | 変更後 |
|------|--------|--------|
| Tomcat | 8.5.23 | 9.0.110 |
| `tomcat-embed-logging-juli` | 8.5.2 | **削除**（廃止済み） |

- Tomcat 8.5 は Java 17 を公式にはサポートしていない
- Tomcat 9.0 は Java 17 を正式サポート
- `tomcat-embed-logging-juli` は廃止されたため依存関係から削除

---

## 9. Lucene 4.x → 9.x の移行

### 概要

全文検索エンジン Apache Lucene を **4.10.4 → 9.12.3** にメジャーバージョンアップした。Lucene 9.x では API が大幅に変更されているため、インデクサー（`LuceneIndexer`）と検索（`LuceneSearcher`）の両方を書き換えた。

### 9.1 モジュール名の変更

```xml
<!-- 変更前 -->
<artifactId>lucene-analyzers-common</artifactId>
<artifactId>lucene-analyzers-kuromoji</artifactId>

<!-- 変更後（Lucene 9.x ではモジュール名が変わった） -->
<artifactId>lucene-analysis-common</artifactId>
<artifactId>lucene-analysis-kuromoji</artifactId>
```

### 9.2 Version 定数の廃止

```java
// 変更前: Lucene のバージョンを明示的に渡す必要があった
IndexWriterConfig iwc = new IndexWriterConfig(Version.LUCENE_4_10_2, analyzer);
QueryParser parser = new QueryParser(Version.LUCENE_4_10_2, field, analyzer);

// 変更後: バージョン指定が不要に（クラスパス上の Lucene が自動的に使われる）
IndexWriterConfig iwc = new IndexWriterConfig(analyzer);
QueryParser parser = new QueryParser(field, analyzer);
```

### 9.3 ディレクトリの開き方

```java
// 変更前: java.io.File を渡す
Directory dir = FSDirectory.open(indexDir);

// 変更後: java.nio.file.Path を渡す（Java NIO API）
Directory dir = FSDirectory.open(indexDir.toPath());
```

> Lucene 9.x は Java NIO の `Path` API を使う。`File.toPath()` で変換する。

### 9.4 数値フィールドの扱い（最大の変更点）

Lucene 9.x では数値フィールドの設計思想が変わった。1 つの用途に 1 つのフィールドを使い分ける。

```java
// === 変更前: IntField / LongField ===
// 1つのフィールドで「検索」「取得」「ソート」すべてを担っていた
doc.add(new IntField("type", value, Field.Store.YES));
doc.add(new LongField("time", timestamp, Field.Store.YES));

// === 変更後: 用途別に3種類のフィールドを使い分ける ===

// ① IntPoint / LongPoint: 範囲検索用（「type が 1〜3 のもの」等）
doc.add(new IntPoint("type", value));
doc.add(new LongPoint("time", timestamp));

// ② StoredField: 値の取得用（検索結果から値を読み出す）
doc.add(new StoredField("type", value));
doc.add(new StoredField("time", timestamp));

// ③ NumericDocValuesField: ソート用（時刻で並び替え等）
doc.add(new NumericDocValuesField("time", timestamp));
```

> **なぜ分けるのか？** Lucene 9.x では内部構造が最適化され、検索・取得・ソートで異なるデータ構造が使われる。分離することでインデックスサイズの削減と検索速度の向上が実現される。

### 9.5 範囲クエリの変更

```java
// 変更前: NumericRangeQuery（Lucene 4.x）
Query q = NumericRangeQuery.newIntRange("type", 1, targetValue, targetValue, true, true);

// 変更後: IntPoint.newRangeQuery（Lucene 9.x）
Query q = IntPoint.newRangeQuery("type", targetValue, targetValue);
```

### 9.6 BooleanQuery のビルダーパターン化

```java
// 変更前: 直接インスタンス化して add
BooleanQuery boolQuery = new BooleanQuery();
boolQuery.add(query1, BooleanClause.Occur.MUST);
boolQuery.add(query2, BooleanClause.Occur.SHOULD);

// 変更後: Builder パターン
BooleanQuery.Builder builder = new BooleanQuery.Builder();
builder.add(query1, BooleanClause.Occur.MUST);
builder.add(query2, BooleanClause.Occur.SHOULD);
BooleanQuery boolQuery = builder.build();
```

> **Builder パターン** とは、オブジェクトの生成を段階的に行うデザインパターン。`build()` を呼ぶまでオブジェクトが不変（immutable）にならないため、スレッドセーフになる。

### 9.7 検索結果の取得方法（Collector → CollectorManager）

```java
// === 変更前: Collector を生成して渡す ===
TotalHitCountCollector countCollector = new TotalHitCountCollector();
searcher.search(query, countCollector);
int totalHits = countCollector.getTotalHits();

TopScoreDocCollector collector = TopScoreDocCollector.create(numHits, true);
searcher.search(query, collector);
ScoreDoc[] hits = collector.topDocs(offset, limit).scoreDocs;

// === 変更後: CollectorManager を使い、戻り値で直接結果を受け取る ===
Integer totalHits = searcher.search(query, new TotalHitCountCollectorManager());

TopDocs topDocs = searcher.search(query, numHits);          // スコア順
TopDocs topDocs = searcher.search(query, numHits, sort);    // 指定順
ScoreDoc[] hits = topDocs.scoreDocs;
```

> Lucene 9.x では `Collector` が `CollectorManager` に置き換えられた。`searcher.search()` が直接結果を返すようになり、コードがシンプルになった。

### 9.8 PDFBox のローダー変更

Lucene と同時に PDFBox もアップデートされ、ドキュメントの読み込み方法が変わった。

```java
// 変更前
PDDocument document = PDDocument.load(inputFile);

// 変更後（PDFBox 3.x）
PDDocument document = Loader.loadPDF(inputFile);
```

---

## 10. commons-lang → commons-lang3 の移行

### 概要

Apache Commons Lang を **2.6 → 3.17.0** にメジャーバージョンアップした。commons-lang3 ではパッケージ名が変更されているため、**15 ファイル**の import 文を書き換えた。

### パッケージ名の変更

```java
// 変更前（commons-lang 2.x）
import org.apache.commons.lang.ClassUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.ObjectUtils;

// 変更後（commons-lang3 3.x）— "lang" が "lang3" に変わるだけ
import org.apache.commons.lang3.ClassUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.ObjectUtils;
```

> **なぜパッケージ名が変わったのか？** commons-lang3 はバイナリ互換性を維持しないメジャーバージョンアップだったため、既存の commons-lang 2.x と**同じプロジェクトで共存**できるようにパッケージ名を変更した。

### 変更対象ファイル（15 ファイル）

| ファイル | 変更内容 |
|---------|---------|
| `ObjectUtils.java` | 親クラスの参照を `lang` → `lang3` に変更 |
| `StringUtils.java` | 親クラスの参照を `lang` → `lang3` に変更 |
| `AggregateBat.java` | import の `ClassUtils` を `lang3` に変更 |
| `CreateExportDataBat.java` | 同上 |
| `DataTransferBat.java` | 同上 |
| `FileParseBat.java` | 同上 |
| `KnowledgeFileClearBat.java` | 同上 |
| `MailReadBat.java` | 同上 |
| `MailSendBat.java` | 同上 |
| `NotifyMailBat.java` | 同上 |
| `ReIndexingBat.java` | 同上 |
| `WebhookBat.java` | 同上 |
| `ConnectionConfigPropertiesLoader.java` | `NotImplementedException` → `UnsupportedOperationException` |
| `AddSampleKnowledge.java` (test) | `StringUtils` を `lang3` に変更 |
| `TestBatch.java` (test) | `ClassUtils` を `lang3` に変更 |

---

## 11. H2 Database 2.x 対応と SQL 構文の変更

### 概要

組み込みデータベース H2 を **1.4.196 → 2.3.232** にメジャーバージョンアップした。H2 2.x では PostgreSQL 互換の `SERIAL` / `BIGSERIAL` 構文がサポートされなくなったため、**12 ファイル**の DDL/マイグレーション SQL を書き換えた。

### 構文の変更

```sql
-- === 変更前: PostgreSQL 互換の構文（H2 1.x で使えた） ===
CREATE TABLE ACTIVITIES (
  ACTIVITY_NO BIGSERIAL NOT NULL,
  ...
);

CREATE TABLE BADGES (
  NO SERIAL NOT NULL,
  ...
);

-- === 変更後: SQL 標準の IDENTITY 構文（H2 2.x で必要） ===
CREATE TABLE ACTIVITIES (
  ACTIVITY_NO BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  ...
);

CREATE TABLE BADGES (
  NO INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  ...
);
```

### 変更パターン一覧

| 変更前 | 変更後 | 説明 |
|--------|--------|------|
| `SERIAL` | `INT GENERATED BY DEFAULT AS IDENTITY` | 32 ビット自動採番 |
| `BIGSERIAL` | `BIGINT GENERATED BY DEFAULT AS IDENTITY` | 64 ビット自動採番 |
| `AUTO_INCREMENT` | `GENERATED BY DEFAULT AS IDENTITY` | MySQL 互換構文からの移行 |

### 「GENERATED BY DEFAULT AS IDENTITY」とは？

> **SQL 標準** で定義された自動採番の構文。`DEFAULT` の意味は「明示的に値を指定しない場合に自動採番する」ということ。`SERIAL` や `AUTO_INCREMENT` は特定のデータベース固有の構文だが、`GENERATED BY DEFAULT AS IDENTITY` は **PostgreSQL、H2、Oracle、DB2** などで広くサポートされている。

### 変更対象ファイル（12 ファイル）

| ファイル | 説明 |
|---------|------|
| `knowledge/database/ddl.sql` | メインの DDL 定義 |
| `web/database/ddl.sql` | Web モジュールの DDL 定義 |
| `deploy/v0_3_0/migrate.sql` | v0.3.0 マイグレーション |
| `deploy/v0_6_0pre2/migrate.sql` | v0.6.0pre2 マイグレーション |
| `deploy/v0_8_0pre1/migrate.sql` | v0.8.0pre1 マイグレーション |
| `deploy/v1_4_0/migrate.sql` | v1.4.0 マイグレーション |
| `deploy/v1_4_0/migrate2.sql` | v1.4.0 マイグレーション（2） |
| `deploy/v1_5_0/migrate.sql` | v1.5.0 マイグレーション |
| `deploy/v1_7_0/migrate.sql` | v1.7.0 マイグレーション |
| `deploy/v1_11_0/migrate_v1_11_1.sql` | v1.11.1 マイグレーション |
| `deploy/v1_11_0/migrate_v1_11_2.sql` | v1.11.2 マイグレーション |
| `src/test/resources/ddl.sql` | テスト用 DDL |

---

## 12. その他の細かい修正

### 12.1 Jackson XML デシリアライズエラーの修正

Tomcat デプロイ時に Jackson XML がエラーを出す問題を修正。AppConfig に setter を追加し、`FAIL_ON_UNKNOWN_PROPERTIES` を `false` に設定することで解決。

### 12.2 Maven Wrapper の追加

```
mvnw       (Linux/Mac 用)
mvnw.cmd   (Windows 用)
```

> **Maven Wrapper** を使うと、プロジェクトに Maven のバージョンが固定される。開発者が個別に Maven をインストールする必要がなくなり、`./mvnw clean package` でビルドできる。

---

## 13. 変更ファイル一覧

### 新規追加

| ファイル | 説明 |
|---------|------|
| `mvnw` | Maven Wrapper（Linux/Mac） |
| `mvnw.cmd` | Maven Wrapper（Windows） |
| `.mvn/wrapper/maven-wrapper.properties` | Wrapper 設定 |

### 変更（Java ソース — 23 ファイル）

| ファイル | 変更内容 |
|---------|---------|
| `pom.xml` | Java 17 化、全ライブラリ更新、Bower → WebJars |
| `ConfigLoader.java` | simple-xml → Jackson XML、非推奨 API 修正 |
| `SerializerForXmlOnSimpleImpl.java` | simple-xml → Jackson XML |
| `AppConfig.java` | Jackson 用 setter 追加 |
| `TikaParser.java` | Tika 3.x API 対応 |
| `LuceneIndexer.java` | Lucene 9.x API 対応（Field、Directory 等） |
| `LuceneSearcher.java` | Lucene 9.x API 対応（Query、Collector 等） |
| `PdfSlideShowParserOnPdfbox.java` | PDFBox 3.x の `Loader.loadPDF()` に変更 |
| `ObjectUtils.java` | commons-lang → lang3 |
| `StringUtils.java` | commons-lang → lang3 |
| `AggregateBat.java` | commons-lang → lang3 |
| `CreateExportDataBat.java` | commons-lang → lang3 |
| `DataTransferBat.java` | commons-lang → lang3 |
| `FileParseBat.java` | commons-lang → lang3 |
| `KnowledgeFileClearBat.java` | commons-lang → lang3 |
| `MailReadBat.java` | commons-lang → lang3 |
| `MailSendBat.java` | commons-lang → lang3 |
| `NotifyMailBat.java` | commons-lang → lang3 |
| `ReIndexingBat.java` | commons-lang → lang3 |
| `WebhookBat.java` | commons-lang → lang3 |
| `ConnectionConfigPropertiesLoader.java` | `NotImplementedException` → `UnsupportedOperationException` |
| `TestCommon.java` (test) | Lucene Version 定数の削除 |
| `AddSampleKnowledge.java` (test) | commons-lang → lang3 |
| `TestBatch.java` (test) | commons-lang → lang3 |

### 変更（SQL — 12 ファイル）

| ファイル | 変更内容 |
|---------|---------|
| `knowledge/database/ddl.sql` | SERIAL → IDENTITY |
| `web/database/ddl.sql` | SERIAL → IDENTITY |
| `deploy/v0_3_0/migrate.sql` | AUTO_INCREMENT → IDENTITY |
| `deploy/v0_6_0pre2/migrate.sql` | SERIAL → IDENTITY |
| `deploy/v0_8_0pre1/migrate.sql` | SERIAL → IDENTITY |
| `deploy/v1_4_0/migrate.sql` | SERIAL → IDENTITY |
| `deploy/v1_4_0/migrate2.sql` | SERIAL → IDENTITY |
| `deploy/v1_5_0/migrate.sql` | SERIAL → IDENTITY |
| `deploy/v1_7_0/migrate.sql` | SERIAL → IDENTITY |
| `deploy/v1_11_0/migrate_v1_11_1.sql` | SERIAL → IDENTITY |
| `deploy/v1_11_0/migrate_v1_11_2.sql` | BIGSERIAL → IDENTITY |
| `src/test/resources/ddl.sql` | AUTO_INCREMENT → IDENTITY |

### 変更（JSP — 2 ファイル）

| ファイル | 変更内容 |
|---------|---------|
| `commonScripts.jsp` | highlight.js ファイル名変更 |
| `highlight.jsp` | highlight.js ファイル名変更 |

### 削除

| ファイル | 説明 |
|---------|------|
| `bower.json` | Bower 依存関係定義（WebJars に移行） |
| `.bowerrc` | Bower 設定 |
| `package.json` | npm 依存関係定義 |
| `gulpfile.js` | Gulp ビルドタスク |

---

## 14. コミット履歴

| # | コミット | 概要 |
|---|---------|------|
| 1 | `5d689b44` | Java 17 化、CVE 対応、Bower → WebJars |
| 2 | `c0abe378` | Jackson XML デシリアライズエラーの修正 |
| 3 | `f71a30be` | ライブラリ追加更新（Lucene 9.x、Tika 3.x、H2 2.x 等） |
| 4 | `c3013971` | commons-lang → commons-lang3 移行（15 ファイル） |
| 5 | `77cb800f` | Lucene 4.x → 9.x API 移行 + PDFBox 更新 |
| 6 | `273e6ed1` | SQL: SERIAL/BIGSERIAL → IDENTITY 構文（12 ファイル） |

---

## まとめ

この移行で達成したこと:

1. **Java 8 → 17**: LTS バージョンに更新し、2029 年頃までサポートを受けられるようになった
2. **25 以上のライブラリの CVE 修正**: 既知の脆弱性を解消
3. **ビルドの簡素化**: Node.js / Bower / Gulp が不要になり、Maven だけでビルド可能に
4. **非推奨 API の修正**: Java 17 で削除された API を新しい API に置き換え
5. **XML ライブラリの近代化**: メンテナンスされていない simple-xml から業界標準の Jackson に移行
6. **全文検索エンジンの刷新**: Lucene 4.x → 9.x へのメジャーバージョンアップ
7. **データベース互換性の向上**: H2 2.x 対応と SQL 標準構文への移行
8. **ユーティリティライブラリの更新**: commons-lang → commons-lang3 への移行
