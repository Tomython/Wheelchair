# Wheelchair Multiplayer (Netcode for GameObjects)

Полная система инвалидной коляски с мультиплеером.

## Установка

1. **Создать префаб**: `Wheelchair Multiplayer > Create Wheelchair Player Prefab`
2. **Настроить сцену лобби**: `Wheelchair Multiplayer > Setup Lobby Scene`
3. **Добавить префаб в NetworkPrefabs**:
   - Откройте NetworkManager в сцене Lobby
   - В Network Config > Network Prefabs добавьте `WheelchairPlayer`
   - Player Prefab оставьте пустым (спавн идёт через OnClientConnectedCallback)
4. **Настроить WheelchairPlayer**:
   - Перетащите `wheelchair.fbx` в Mesh
   - Добавьте ragdoll (например, из `man.fbx` через Ragdoll Wizard) в Ragdoll
   - В RagdollSeatJoint: Pelvis = кость Pelvis ragdoll, SeatAnchor = Seat, WheelchairRigidbody = Rigidbody корня

## Управление (WASD)

- **W** — передача вперёд
- **S** — передача назад
- **A** — левое колесо
- **D** — правое колесо

## Структура префаба WheelchairPlayer

```
WheelchairPlayer (NetworkObject, Rigidbody 50kg, NetworkTransform, WheelchairController, RagdollSeatJoint)
├── Mesh (модель коляски)
├── Seat (пустой GameObject для joint anchor)
├── Ragdoll (Humanoid, Animator OFF, RB isKinematic=false)
│   └── Pelvis (ConfigurableJoint → Seat/Wheelchair)
│       ├── Spine → Head
│       ├── LeftLeg → LeftFoot
│       └── RightLeg → RightFoot
└── SpawnPoints (в сцене)
```

## Lobby UI

- **Create Host** — запуск хоста
- **Join** — подключение по IP (по умолчанию 127.0.0.1:7777)
- **Start Game** — загрузка игровой сцены (только хост)

## Build Settings

Добавьте в Build Settings:
- `Scenes/Lobby` (первая)
- Вашу игровую сцену (например, SampleScene → переименуйте в GameScene)

## Relay (опционально)

Для Join по коду нужны Unity Services: `com.unity.services.relay`, `com.unity.services.authentication`. Добавьте через Package Manager.
