using Unity.Netcode;
using UnityEngine;

public class CameraView : NetworkBehaviour
{
    [SerializeField] private GameObject bodyModel; // Тело игрока
    [SerializeField] private GameObject armModel; //руки игрока

    private void Start()
    {
        if (IsOwner)
        {
            // Убираем тело из видимости локальной камеры
            SetLayerRecursively(bodyModel, LayerMask.NameToLayer("ignore"));
            SetLayerRecursively(armModel, LayerMask.NameToLayer("View"));
        }
        else
        {
            // У чужих игроков тело видно
            SetLayerRecursively(bodyModel, LayerMask.NameToLayer("View"));
            SetLayerRecursively(armModel, LayerMask.NameToLayer("ignore"));
        }
    }

    // Рекурсивная смена слоя у всех детей объекта
    private void SetLayerRecursively(GameObject obj, int newLayer)
    {
        if (obj == null) return;

        obj.layer = newLayer;
        foreach (Transform child in obj.transform)
        {
            SetLayerRecursively(child.gameObject, newLayer);
        }
    }
}