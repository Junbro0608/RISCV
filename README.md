# 📄 [Project] RISC-V Design (RV32I)
> **"명령어 집합 구조(ISA)의 완벽한 이해부터 APB Bus 기반 MCU 설계 및 Basys3 FPGA 실물 검증까지"**

## 🎯 Project Overview
본 프로젝트는 RISC-V (RV32I) ISA를 기반으로 프로세서의 핵심 설계와 시스템 확장 능력을 증명한 하드웨어 프로젝트입니다. 
개인 프로젝트를 통해 **프로세서의 정교한 로직**을 검증하고, 팀 프로젝트를 통해 **표준 버스 기반의 SoC 시스템 설계 및 Basys3 FPGA 구현** 능력을 확보했습니다.

---

## 📊 Project Comparison: Single-cycle vs Multi-cycle
| 구분 | Single-cycle (Individual) | Multi-cycle MCU (Team) |
| :--- | :--- | :--- |
| **핵심 목표** | ISA 동작 원리 및 데이터패스 완벽 이해 | 시스템 확장 및 주변장치 제어(SoC) |
| **Architecture** | RV32I Single-cycle CPU | Multi-cycle CPU 기반 MCU |
| **Bus Protocol** | N/A (Internal Bus) | **APB (Advanced Peripheral Bus)** |
| **I/O 방식** | ROM Code 기반 고정 데이터 | **MMIO (Memory Mapped I/O)** |
| **Target HW** | Simulation | **Simulation & FPGA** |
| **주요 성과** | 모든 명령어 전수 검증 & 누적 Sum 구동 | **Up-Down Game** 실물 시스템 구현 |

---

## 🛠 1. Single-cycle Processor: ISA Deep Dive
**"하드웨어 레벨의 명령어 처리 및 제어 로직 최적화"**

* **Instruction Coverage:** R/I/S/B/U/J 모든 타입의 단일 명령어를 시뮬레이션을 통해 전수 검증 완료.
* **Program Execution:** ROM에 **누적 합(1 to N Summation)** 프로그램을 적재하여 데이터패스의 정합성 및 제어 신호의 정확성 증명.
* **Key Insight:** 단일 사이클 내의 Critical Path 분석을 통해 하드웨어 타이밍과 자원 할당의 기초를 다졌습니다.

---

## 🛠 2. Multi-cycle MCU: System Integration
**"산업 표준 버스를 활용한 확장 가능한 아키텍처 설계"**

### 🏗 System Architecture & Bus
| 구성 요소 | 기술 상세 내용 |
| :--- | :--- |
| **Bus Protocol** | **APB Bus**를 직접 설계하여 CPU와 주변장치 간의 표준 통신 인터페이스 구축 |
| **Address Map** | **MMIO** 설계를 통해 메모리, GPIO, Timer를 동일한 주소 공간에서 제어 |
| **Control Unit** | FSM(Finite State Machine) 기반의 효율적인 멀티 사이클 제어 로직 구현 |

### 🎮 Basys3 FPGA Implementation
* **Real-world Demo:** **Basys3** 보드 상에서 **'Up/Down Game'**을 성공적으로 구동.
* **Hardware Interface:** * **Input:** Push Buttons (Reset/Enter), Slide Switches (Number Input)
    * **Output:** 7-Segment Display (Current State/Number), LEDs (Game Status)
* **Collaboration:** 팀 프로젝트로서 인터페이스 규격을 정의하고 모듈 간 통합(Integration) 및 타이밍 동기화 주도.

---

## 💻 Development Environment
* **Design Tool:** Xilinx Vivado (Synthesis & Implementation)
* **Language:** Verilog HDL
* **Target Board:** **Digilent Basys3 (Artix-7 FPGA)**
* **ISA:** RISC-V RV32I (Base Integer Instruction Set)
