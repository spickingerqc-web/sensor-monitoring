# Sensor Real-Time Monitoring System

## 프로젝트 개요

Python 스크립트(`injector.py`)가 난수 기반 센서 데이터를 생성하여 LAMP 스택의 MySQL 데이터베이스에 저장하고,
**Node-RED Dashboard**와 **Grafana Dashboard** 두 가지 경로로 실시간 모니터링하는 시스템입니다.

---

## 시스템 구성 요소

| 구성 요소 | 역할 |
|-----------|------|
| `injector.py` | 난수 센서 데이터 생성 및 MySQL 삽입 (2초 주기) |
| MySQL (LAMP) | 센서 데이터 영속 저장소 (`sensor_db`) |
| Node-RED | MySQL 폴링 → UI Dashboard 게이지/차트 표시 |
| Grafana | MySQL 데이터소스 연결 → 실시간 대시보드 |

---

## 생성 데이터 항목

| 필드 | 단위 | 범위 |
|------|------|------|
| temperature | °C | 15.0 ~ 40.0 |
| humidity | % | 20.0 ~ 90.0 |
| pressure | hPa | 980.0 ~ 1025.0 |
| light_level | lux | 0.0 ~ 1000.0 |

---

## 전체 시스템 Flowchart

```mermaid
flowchart TD
    subgraph Generator["🐍 Python Generator"]
        A([injector.py 시작]) --> B[난수 센서값 생성\ntemperature / humidity\npressure / light_level]
        B --> C[2초 대기]
        C --> B
    end

    subgraph LAMP["🗄️ LAMP Stack"]
        D[(MySQL\nsensor_db\nsensor_data 테이블)]
    end

    subgraph NodeRED["🔴 Node-RED"]
        E[Inject\n2초 주기 트리거] --> F[MySQL Query Node\nSELECT 최신 1행]
        F --> G[Function Node\n필드별 메시지 분리]
        G --> H1[Gauge: Temperature]
        G --> H2[Gauge: Humidity]
        G --> H3[Gauge: Pressure]
        G --> H4[Gauge: Light Level]
        G --> H5[Text: Timestamp]
        H1 & H2 & H3 & H4 & H5 --> I[[Node-RED Dashboard\nlocalhost:1880/ui]]
    end

    subgraph Grafana["📊 Grafana"]
        J[MySQL Data Source\nSensorDB] --> K[Gauge Panels\n4개 센서 최신값]
        J --> L[Time Series Panels\n5분간 트렌드]
        K & L --> M[[Grafana Dashboard\nlocalhost:3000]]
    end

    B -->|INSERT| D
    D -->|SELECT| F
    D -->|rawSql 쿼리| J
```

---

## 데이터 흐름 상세

```mermaid
sequenceDiagram
    participant PY  as injector.py
    participant DB  as MySQL (sensor_db)
    participant NR  as Node-RED
    participant GF  as Grafana
    participant USER as 사용자 브라우저

    loop 매 2초
        PY->>DB: INSERT sensor_data (timestamp, temp, hum, press, light)
    end

    loop 매 2초 (Node-RED)
        NR->>DB: SELECT * FROM sensor_data ORDER BY id DESC LIMIT 1
        DB-->>NR: 최신 레코드 반환
        NR->>USER: Dashboard 게이지 업데이트 (localhost:1880/ui)
    end

    loop 매 5초 (Grafana auto-refresh)
        GF->>DB: rawSql 쿼리 (최신값 / 시계열)
        DB-->>GF: 결과 반환
        GF->>USER: Dashboard 패널 갱신 (localhost:3000)
    end
```

---

## 설치 및 실행 방법

### 1. DB 초기화

```bash
sudo mysql < setup_db.sql
```

### 2. Python 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. 데이터 주입 시작

```bash
python3 injector.py
```

### 4. Node-RED 설정

```bash
# node-red 설치 (최초 1회)
sudo npm install -g node-red node-red-dashboard node-red-node-mysql

# 실행
node-red

# 브라우저에서 http://localhost:1880 접속
# 우측 상단 메뉴 → Import → node_red_flow.json 붙여넣기 → Deploy
# 대시보드: http://localhost:1880/ui
```

### 5. Grafana 설정

```bash
# Grafana 설치 (최초 1회)
sudo apt-get install -y grafana

# 프로비저닝 파일 복사
sudo cp -r grafana/provisioning/* /etc/grafana/provisioning/

# 서비스 시작
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# 브라우저: http://localhost:3000  (admin / admin)
```

---

## 파일 구조

```
project3/
├── injector.py                          # 난수 데이터 생성 및 DB 삽입
├── setup_db.sql                         # DB / 테이블 / 사용자 초기화
├── requirements.txt                     # Python 패키지 목록
├── node_red_flow.json                   # Node-RED 플로우 내보내기
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       │   └── mysql.yaml               # Grafana MySQL 데이터소스
│       └── dashboards/
│           ├── dashboard.yaml           # 대시보드 프로바이더 설정
│           └── sensor_dashboard.json    # Grafana 대시보드 정의
└── project.md                           # 본 문서
```

---

## 포트 정보

| 서비스 | 포트 | URL |
|--------|------|-----|
| MySQL | 3306 | - |
| Node-RED Editor | 1880 | http://localhost:1880 |
| Node-RED Dashboard | 1880 | http://localhost:1880/ui |
| Grafana | 3000 | http://localhost:3000 |
