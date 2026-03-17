# 📓 DECISION_LOG.md — K-Poker

> 주요 기술적 의사결정 기록 (ADR)

## 2026-03-16: 프로젝트 환경 및 에이전트 시스템 초기화

### Context
- React 기반의 이전 프로젝트(`hwatu-tazza`)에서 Flutter 기반의 `08_k-poker`로 전면 전환.
- Balatro의 성공 요인(시너지, 룰 왜곡)을 화투 게임에 이식하고자 함.

### Decisions
1. **State Management**: 확장성과 테스트 용이성을 위해 `Riverpod (Notifier)` 채택.
2. **Data Modeling**: 불변성 확보를 위해 `freezed` 도입 결정.
3. **Scoring Engine**: Balatro의 `Chips × Mult` 공식을 화투 족보에 결합한 하이브리드 시스템 설계.
4. **Agent System**: Minerva 표준 프로토콜에 따라 `.agent/` 구조 구축.

### Consequence
- 모든 로직은 모듈화되어 엔진 레이어에서 테스트 가능하게 됨.
- 코드 생성을 통해 보일러플레이트를 줄이고 타입 안전성을 강화함.
