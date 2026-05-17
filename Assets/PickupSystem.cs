using Unity.Netcode;
using UnityEngine;
using UnityEngine.UI;

public class PickupSystem : NetworkBehaviour
{
    [Header("Ссылки")]
    public Camera playerCamera;
    public Transform holdPoint; // Пустой объект перед камерой
    public LayerMask ignoreLayer; // Обязательно выбери тут слой Player!

    [Header("Настройки луча")]
    public float interactionDistance = 3f;

    [Header("Физика притяжения")]
    public float pullForce = 15f; // Насколько быстро летит к руке
    public float maxSpeed = 10f;  // Ограничение скорости полета

    [Header("UI элементы")]
    public GameObject uiPanel;
    public Text panelText;
    public string pickUpMsg = "Нажми E, чтобы взять";
    public string dropMsg = "Нажми E, чтобы бросить";

    // Сетевая ссылка на объект, который мы держим
    private NetworkVariable<NetworkObjectReference> heldObjectRef = new NetworkVariable<NetworkObjectReference>();
    
    // Локальные переменные
    private GameObject currentHeldObject;
    private Rigidbody pickupRigidbody;

    public override void OnNetworkSpawn()
    {
        if (!IsOwner) return;
        
        // Автоматически ищем камеру, если забыли привязать
        if (playerCamera == null) playerCamera = GetComponentInChildren<Camera>();
        
        HideUI();
    }

    private void Update()
    {
        if (!IsOwner) return;

        CheckLookAt();

        if (Input.GetKeyDown(KeyCode.E))
        {
            if (currentHeldObject == null) TryPickup();
            else RequestDropServerRpc();
        }
    }

    // Проверяем, на что смотрит игрок, чтобы показывать UI
    private void CheckLookAt()
    {
        if (currentHeldObject != null)
        {
            ShowUI(dropMsg);
            return;
        }

        Ray ray = playerCamera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0));
        if (Physics.Raycast(ray, out RaycastHit hit, interactionDistance, ~ignoreLayer))
        {
            if (hit.collider.CompareTag("Pickupable"))
            {
                ShowUI(pickUpMsg);
                return;
            }
        }
        HideUI();
    }

    // Здесь происходит сама магия физического полета бутылки к руке
    private void FixedUpdate()
    {
        if (!IsOwner || currentHeldObject == null || pickupRigidbody == null) return;

        // Считаем дистанцию от предмета до точки в руках
        Vector3 direction = holdPoint.position - pickupRigidbody.position;
        float distance = direction.magnitude;

        // Если предмет застрял за стеной и отстал слишком сильно — роняем его
        if (distance > interactionDistance + 2f)
        {
            RequestDropServerRpc();
            return;
        }

        // Физическое притяжение
        Vector3 targetVelocity = direction.normalized * (pullForce * distance);
        pickupRigidbody.linearVelocity = Vector3.ClampMagnitude(targetVelocity, maxSpeed);
        
        // Гасим вращение, чтобы предмет не крутился как бешеный
        pickupRigidbody.angularVelocity *= 0.5f;
    }

    private void TryPickup()
    {
        Ray ray = playerCamera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0));
        if (Physics.Raycast(ray, out RaycastHit hit, interactionDistance, ~ignoreLayer))
        {
            if (hit.collider.CompareTag("Pickupable"))
            {
                var netObj = hit.collider.GetComponent<NetworkObject>();
                if (netObj != null)
                {
                    // Отправляем запрос на сервер и передаем свой ID клиента
                    RequestPickupServerRpc(netObj.NetworkObjectId);
                }
            }
        }
    }

    [ServerRpc]
    void RequestPickupServerRpc(ulong id, ServerRpcParams rpcParams = default)
    {
        if (NetworkManager.Singleton.SpawnManager.SpawnedObjects.TryGetValue(id, out var netObj))
        {
            // ВАЖНО: Передаем права клиенту, чтобы он мог управлять физикой предмета!
            netObj.ChangeOwnership(rpcParams.Receive.SenderClientId);
            
            heldObjectRef.Value = netObj;
            NotifyPickupClientRpc(id);
        }
    }

    [ServerRpc]
    void RequestDropServerRpc()
    {
        if (heldObjectRef.Value.TryGet(out NetworkObject netObj))
        {
            // Забираем права обратно серверу
            netObj.RemoveOwnership();
            
            heldObjectRef.Value = new NetworkObjectReference();
            NotifyDropClientRpc(netObj.NetworkObjectId);
        }
    }

    [ClientRpc]
    void NotifyPickupClientRpc(ulong id)
    {
        if (NetworkManager.Singleton.SpawnManager.SpawnedObjects.TryGetValue(id, out var netObj))
        {
            currentHeldObject = netObj.gameObject;
            pickupRigidbody = currentHeldObject.GetComponent<Rigidbody>();
            
            if (pickupRigidbody != null)
            {
                pickupRigidbody.useGravity = false; // Выключаем гравитацию
                pickupRigidbody.linearDamping = 5f; // Делаем движение плавным (торможение)
                pickupRigidbody.angularDamping = 5f;
            }
        }
    }

    [ClientRpc]
    void NotifyDropClientRpc(ulong id)
    {
        if (currentHeldObject != null)
        {
            if (pickupRigidbody != null)
            {
                pickupRigidbody.useGravity = true; // Включаем гравитацию обратно
                pickupRigidbody.linearDamping = 0f;
                pickupRigidbody.angularDamping = 0.05f;
            }
            currentHeldObject = null;
            pickupRigidbody = null;
        }
    }

    // Вспомогательные методы
    private void ShowUI(string text) { if(uiPanel) uiPanel.SetActive(true); if(panelText) panelText.text = text; }
    private void HideUI() { if(uiPanel) uiPanel.SetActive(false); }
    public bool IsCarrying() => currentHeldObject != null;
}