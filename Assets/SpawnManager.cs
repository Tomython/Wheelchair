using Unity.Netcode;
using UnityEngine;
using System.Collections.Generic;

public class SpawnManager : MonoBehaviour
{
    private void Start()
    {
        // Подписываемся на проверку подключения, как только NetworkManager готов
        if (NetworkManager.Singleton != null)
        {
            NetworkManager.Singleton.ConnectionApprovalCallback += ApprovalCheck;
        }
    }

    private void ApprovalCheck(NetworkManager.ConnectionApprovalRequest request, NetworkManager.ConnectionApprovalResponse response)
    {
        // 1. Сразу одобряем вход
        response.Approved = true;
        response.CreatePlayerObject = true;

        // 2. Ищем все точки с нашим тегом
        GameObject[] spawnPoints = GameObject.FindGameObjectsWithTag("SpawnPoint");

        if (spawnPoints.Length > 0)
        {
            // 3. Выбираем случайную точку
            int randomIndex = Random.Range(0, spawnPoints.Length);
            Transform targetPoint = spawnPoints[randomIndex].transform;

            response.Position = targetPoint.position;
            response.Rotation = targetPoint.rotation;
        }
        else
        {
            // Если забыл расставить точки, появится в центре
            response.Position = Vector3.zero;
            response.Rotation = Quaternion.identity;
        }

        response.Pending = false;
    }
}