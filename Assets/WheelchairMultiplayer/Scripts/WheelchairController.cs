using Unity.Netcode;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class WheelchairController : NetworkBehaviour
{
    [Header("Колеса")]
    public WheelCollider wheelLeft;
    public WheelCollider wheelRight;
    public Transform visualLeft;
    public Transform visualRight;

    [Header("Настройки движения")]
    public float motorTorque = 150f;   
    public float brakeTorque = 300f;  
    public float turnSensitivity = 0.8f; 
    public Vector3 centerOfMassOffset = new Vector3(0, -0.5f, 0);

    [Header("Стамина (Энергия)")]
    public float maxStamina = 100f;
    public float staminaConsumption = 20f; // Расход в секунду при полной нагрузке
    public float staminaRegen = 15f;      // Восстановление в секунду
    
    // Сетевая переменная стамины (сервер управляет, все видят)
    public NetworkVariable<float> currentStamina = new NetworkVariable<float>(100f, NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Server);

    private Rigidbody rb;
    private PickupSystem pickup;

    public override void OnNetworkSpawn()
    {
        rb = GetComponent<Rigidbody>();
        rb.centerOfMass += centerOfMassOffset;
        pickup = GetComponent<PickupSystem>();

        if (!IsOwner)
        {
            rb.isKinematic = true; 
        }
    }

    void FixedUpdate()
    {
        if (!IsOwner) return;

        float move = Input.GetAxis("Vertical"); 
        float turn = Input.GetAxis("Horizontal");

        // ПРОВЕРКА 1: Если в руках предмет — колеса не крутим
        if (pickup != null && pickup.IsCarrying())
        {
            StopMovement();
            return;
        }

        // ПРОВЕРКА 2: Если стамина кончилась — ехать нельзя
        bool isMoving = Mathf.Abs(move) > 0.1f || Mathf.Abs(turn) > 0.1f;
        
        if (currentStamina.Value <= 5f && isMoving)
        {
            StopMovement();
            // Запрашиваем сервер обновить стамину (расход/реген)
            UpdateStaminaServerRpc(move, turn, Time.fixedDeltaTime);
            return;
        }

        // Логика движения
        float leftForce = (move + turn * turnSensitivity) * motorTorque;
        float rightForce = (move - turn * turnSensitivity) * motorTorque;

        ApplyTorque(wheelLeft, leftForce);
        ApplyTorque(wheelRight, rightForce);

        // Отправляем запрос серверу на изменение стамины
        UpdateStaminaServerRpc(move, turn, Time.fixedDeltaTime);

        UpdateVisuals(wheelLeft, visualLeft);
        UpdateVisuals(wheelRight, visualRight);
    }

    [ServerRpc]
    void UpdateStaminaServerRpc(float move, float turn, float deltaTime)
    {
        float targetStamina = currentStamina.Value;
        bool isUsingEffort = Mathf.Abs(move) > 0.1f || Mathf.Abs(turn) > 0.1f;

        if (isUsingEffort)
        {
            targetStamina -= staminaConsumption * deltaTime;
        }
        else
        {
            targetStamina += staminaRegen * deltaTime;
        }

        currentStamina.Value = Mathf.Clamp(targetStamina, 0f, maxStamina);
    }

    void StopMovement()
    {
        wheelLeft.motorTorque = 0;
        wheelRight.motorTorque = 0;
        wheelLeft.brakeTorque = brakeTorque;
        wheelRight.brakeTorque = brakeTorque;
    }

    void Update()
    {
        // Визуализация для всех
        if (!IsOwner)
        {
            UpdateVisuals(wheelLeft, visualLeft);
            UpdateVisuals(wheelRight, visualRight);
        }
    }

    void ApplyTorque(WheelCollider wheel, float force)
    {
        if (Mathf.Abs(force) < 0.01f)
        {
            wheel.motorTorque = 0;
            wheel.brakeTorque = brakeTorque;
        }
        else
        {
            wheel.brakeTorque = 0;
            wheel.motorTorque = force;
        }
    }

    void UpdateVisuals(WheelCollider collider, Transform visual)
    {
        if (visual == null) return;
        Vector3 pos;
        Quaternion rot;
        collider.GetWorldPose(out pos, out rot);
        visual.position = pos;
        visual.rotation = rot;
    }
}